# Controls: SESS-06 (Rule of Two per session), TOOL-07 (pin tool definitions),
#           SUP-10 (track model retirement)
# Layer: design-time gate in CI, before anything is deployed
#
# Checks a system's design manifest, a short YAML or JSON file kept next to the
# code that declares each session type, the models it uses, and its tools. The
# policy fails the build when the declared design breaks a rule, so a design
# problem is caught in review rather than in production.
#
# Missing fields are violations, not passes. In Rego a rule that reads an absent
# field is undefined rather than false, so every property this policy depends on
# is checked for presence first.
#
# Test with: opa test docs/infrastructure/policy/opa -v
# Evaluate:  opa eval -d design_manifest.rego -i manifest.yaml 'data.design.manifest.decision'
package design.manifest

import rego.v1

rule_of_two_keys := ["untrusted_input", "sensitive_access", "outbound_or_state_change"]

high_tiers := {"HIGH", "CRITICAL"}

valid_tiers := {"LOW", "MEDIUM", "HIGH", "CRITICAL"}

valid_patterns := {
	"action-selector",
	"plan-then-execute",
	"map-reduce",
	"dual-llm",
	"code-then-execute",
	"context-minimisation",
}

retirement_warning_days := 90

tier := object.get(input, ["system", "tier"], "")

# --- Manifest shape ---------------------------------------------------------

deny contains "manifest declares no valid system.tier (LOW, MEDIUM, HIGH or CRITICAL)" if {
	not tier in valid_tiers
}

deny contains "manifest declares no sessions" if {
	count(object.get(input, "sessions", [])) == 0
}

# --- SESS-06: Rule of Two ---------------------------------------------------

deny contains msg if {
	some s in input.sessions
	some key in rule_of_two_keys
	not is_boolean(object.get(s, key, null))
	msg := sprintf("session %q must declare %s as true or false", [session_id(s), key])
}

deny contains msg if {
	some s in input.sessions
	holds_all_three(s)
	not has_value(s, "approval_step")
	msg := sprintf("session %q holds untrusted input, sensitive access and outbound action with no approval_step (SESS-06, Rule of Two)", [session_id(s)])
}

deny contains msg if {
	tier in high_tiers
	some s in input.sessions
	s.untrusted_input == true
	s.sensitive_access == true
	not has_value(s, "isolation_pattern")
	msg := sprintf("session %q mixes untrusted input and sensitive access at tier %s without an isolation_pattern", [session_id(s), tier])
}

deny contains msg if {
	some s in input.sessions
	has_value(s, "isolation_pattern")
	not s.isolation_pattern in valid_patterns
	msg := sprintf("session %q names unknown isolation_pattern %q", [session_id(s), s.isolation_pattern])
}

holds_all_three(s) if {
	s.untrusted_input == true
	s.sensitive_access == true
	s.outbound_or_state_change == true
}

# --- SUP-10: model pinning and retirement -----------------------------------

deny contains msg if {
	some m in object.get(input, "models", [])
	not has_value(m, "pinned_version")
	msg := sprintf("model %q has no pinned_version (SUP-10)", [object.get(m, "id", "<unnamed>")])
}

deny contains msg if {
	some m in object.get(input, "models", [])
	has_value(m, "retirement_date")
	days_until(m.retirement_date) < 0
	msg := sprintf("model %q passed its retirement date %s (SUP-10)", [m.id, m.retirement_date])
}

warn contains msg if {
	some m in object.get(input, "models", [])
	has_value(m, "retirement_date")
	d := days_until(m.retirement_date)
	d >= 0
	d < retirement_warning_days
	msg := sprintf("model %q retires in %v days, start re-qualifying a successor (SUP-10)", [m.id, d])
}

warn contains msg if {
	some m in object.get(input, "models", [])
	not has_value(m, "retirement_date")
	msg := sprintf("model %q has no retirement_date recorded (SUP-10)", [object.get(m, "id", "<unnamed>")])
}

# --- TOOL-07: pinned tool definitions (Tier 2+, so HIGH and CRITICAL) --------

deny contains msg if {
	tier in high_tiers
	some t in object.get(input, "tools", [])
	not regex.match(`^[a-f0-9]{64}$`, object.get(t, "definition_sha256", ""))
	msg := sprintf("tool %q has no valid definition_sha256 (TOOL-07)", [object.get(t, "name", "<unnamed>")])
}

# --- Helpers ----------------------------------------------------------------

has_value(obj, key) if {
	v := object.get(obj, key, null)
	v != null
	v != ""
}

session_id(s) := object.get(s, "id", "<unnamed>")

# as_of pins "today" for reproducible builds and tests; otherwise use the clock.
now_ns := time.parse_rfc3339_ns(sprintf("%sT00:00:00Z", [input.as_of])) if input.as_of

now_ns := time.now_ns() if not input.as_of

days_until(date) := floor((time.parse_rfc3339_ns(sprintf("%sT00:00:00Z", [date])) - now_ns) / 86400000000000)

decision := {
	"pass": count(deny) == 0,
	"deny": deny,
	"warn": warn,
}
