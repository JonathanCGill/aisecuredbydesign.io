package design.manifest_test

import data.design.manifest
import rego.v1

good := {
	"system": {"name": "support-assistant", "tier": "HIGH"},
	"as_of": "2026-11-27",
	"sessions": [
		{
			"id": "triage",
			"untrusted_input": true,
			"sensitive_access": false,
			"outbound_or_state_change": false,
		},
		{
			"id": "reply",
			"untrusted_input": true,
			"sensitive_access": true,
			"outbound_or_state_change": true,
			"approval_step": "agent-reply-review",
			"isolation_pattern": "plan-then-execute",
		},
	],
	"models": [{"id": "primary", "pinned_version": "provider-model-2026-06-01", "retirement_date": "2027-12-31"}],
	"tools": [{"name": "crm_lookup", "definition_sha256": "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"}],
}

denies(inp) := manifest.deny with input as inp

warns(inp) := manifest.warn with input as inp

has_msg(msgs, fragment) if {
	some m in msgs
	contains(m, fragment)
}

test_good_manifest_passes if {
	count(denies(good)) == 0
	count(warns(good)) == 0
}

test_all_three_without_approval_denied if {
	inp := json.patch(good, [{"op": "remove", "path": "/sessions/1/approval_step"}])
	has_msg(denies(inp), "Rule of Two")
}

test_missing_rule_of_two_field_denied if {
	inp := json.patch(good, [{"op": "remove", "path": "/sessions/0/sensitive_access"}])
	has_msg(denies(inp), "must declare sensitive_access")
}

test_non_boolean_field_denied if {
	inp := json.patch(good, [{"op": "replace", "path": "/sessions/0/untrusted_input", "value": "yes"}])
	has_msg(denies(inp), "must declare untrusted_input")
}

test_high_tier_needs_isolation_pattern if {
	inp := json.patch(good, [{"op": "remove", "path": "/sessions/1/isolation_pattern"}])
	has_msg(denies(inp), "without an isolation_pattern")
}

test_medium_tier_does_not_need_isolation_pattern if {
	inp := json.patch(good, [
		{"op": "replace", "path": "/system/tier", "value": "MEDIUM"},
		{"op": "remove", "path": "/sessions/1/isolation_pattern"},
	])
	count(denies(inp)) == 0
}

test_unknown_pattern_denied if {
	inp := json.patch(good, [{"op": "replace", "path": "/sessions/1/isolation_pattern", "value": "hope"}])
	has_msg(denies(inp), "unknown isolation_pattern")
}

test_invalid_tier_denied if {
	inp := json.patch(good, [{"op": "replace", "path": "/system/tier", "value": "SEVERE"}])
	has_msg(denies(inp), "valid system.tier")
}

test_no_sessions_denied if {
	inp := json.patch(good, [{"op": "replace", "path": "/sessions", "value": []}])
	has_msg(denies(inp), "no sessions")
}

test_unpinned_model_denied if {
	inp := json.patch(good, [{"op": "remove", "path": "/models/0/pinned_version"}])
	has_msg(denies(inp), "no pinned_version")
}

test_retired_model_denied if {
	inp := json.patch(good, [{"op": "replace", "path": "/models/0/retirement_date", "value": "2026-01-31"}])
	has_msg(denies(inp), "passed its retirement date")
}

test_model_near_retirement_warns if {
	inp := json.patch(good, [{"op": "replace", "path": "/models/0/retirement_date", "value": "2026-12-31"}])
	count(denies(inp)) == 0
	has_msg(warns(inp), "retires in 34 days")
}

test_missing_retirement_date_warns if {
	inp := json.patch(good, [{"op": "remove", "path": "/models/0/retirement_date"}])
	has_msg(warns(inp), "no retirement_date")
}

test_unpinned_tool_denied_at_high_tier if {
	inp := json.patch(good, [{"op": "remove", "path": "/tools/0/definition_sha256"}])
	has_msg(denies(inp), "TOOL-07")
}

test_unpinned_tool_allowed_at_low_tier if {
	inp := json.patch(good, [
		{"op": "replace", "path": "/system/tier", "value": "LOW"},
		{"op": "remove", "path": "/tools/0/definition_sha256"},
	])
	count(denies(inp)) == 0
}
