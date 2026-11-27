---
description: "A bidirectional map from the pre-runtime infrastructure controls you build here to the runtime layers, circuit breaker, and MASO controls that enforce them on airuntimesecurity.io."
---

# Control Handoff Matrix

You build controls here, *before* deployment: the sandbox, the gateway, the vault, the network zones. They only earn their keep once the system is live and those controls turn into behaviour. This page draws the line between the two, so a control you implement pre-runtime is easy to trace to what it does at runtime.

- **Secure by Design (this site)** builds the infrastructure and decides *what* to enforce.
- **[AI Runtime Security (AIRS)](https://airuntimesecurity.io/)** runs the behaviour: [Layer 01 Guardrails](https://airuntimesecurity.io/glossary/#guardrails), [Layer 02 Model-as-Judge](https://airuntimesecurity.io/glossary/#model-as-judge), [Layer 03 Human Oversight](https://airuntimesecurity.io/glossary/#human-oversight), and the [Circuit Breaker](https://airuntimesecurity.io/glossary/#circuit-breaker) behind them.

This mirrors the [canonical handoff matrix on airuntimesecurity.io](https://airuntimesecurity.io/infrastructure/handoff-matrix/); where the two differ, airuntimesecurity.io is authoritative. Every control ID resolves in the [machine-readable catalog](catalog/README.md) and in the [Infrastructure Controls](README.md) pages.

!!! abstract "The one-line version"
    Pre-runtime **containment and identity** become runtime **Layer 01 guardrails**. Pre-runtime **logging and isolation** become the substrate for **Layer 02 detection**. Pre-runtime **approval workflows** become **Layer 03 human oversight**. Pre-runtime **rollback and resource limits** become the **circuit breaker** that contains what the layers cannot hold.

## How to read a row

| Column | Meaning |
|--------|---------|
| **Pre-runtime control** | The infrastructure control built on this site, with its ID |
| **Established before deploy** | What that control puts in place while the system is still being built |
| **Runtime layer** | The AIRS layer the control most directly enables once the system is live |
| **Runtime behaviour** | What actually happens at request time because the pre-runtime control exists |

## Containment and execution → Layer 01 + Circuit Breaker

| Pre-runtime control | Established before deploy | Runtime layer | Runtime behaviour |
|---------------------|---------------------------|---------------|-------------------|
| **SAND-01** [Isolated sandboxes](agentic/sandbox-patterns.md) | A micro-VM / gVisor boundary around agent-generated code | Layer 01 + [Circuit Breaker](https://airuntimesecurity.io/glossary/#circuit-breaker) | Untrusted code executes inside the boundary; a breakout or overrun trips the breaker and kills the session |
| **SAND-04** [Resource limits](agentic/sandbox-patterns.md) | CPU / memory / disk ceilings on the sandbox | [Circuit Breaker](https://airuntimesecurity.io/glossary/#circuit-breaker) | A runaway or fork-bombing agent hits the ceiling and is contained rather than exhausting the host |
| **NET-02** [No guardrail-bypass path](controls/network-and-segmentation.md) | Network topology with no route to the model that skips guardrails | [Layer 01](https://airuntimesecurity.io/glossary/#guardrails) | Every request is forced through the guardrail path; there is no side door at runtime |
| **NET-04** [Agent egress control](controls/network-and-segmentation.md) | An egress proxy with a default-deny allowlist | [Layer 01](https://airuntimesecurity.io/glossary/#guardrails) | Agent calls to non-allowlisted hosts are blocked in-line, closing the exfiltration and SSRF path |

## Identity, tools, and delegation → Layer 01

| Pre-runtime control | Established before deploy | Runtime layer | Runtime behaviour |
|---------------------|---------------------------|---------------|-------------------|
| **IAM-01 / IAM-02** [Authenticate, least privilege](controls/identity-and-access.md) | Every entity has a verified identity and a minimal permission set | [Layer 01](https://airuntimesecurity.io/glossary/#guardrails) | Unauthenticated or over-scoped calls are refused at the gateway before reaching the model |
| **TOOL-01 / TOOL-02** [Tool manifest, gateway enforcement](agentic/tool-access-controls.md) | A declared, allowlisted tool manifest enforced at the gateway | [Layer 01](https://airuntimesecurity.io/glossary/#guardrails) | Any tool call outside the manifest is denied deterministically, not left to the agent's discretion |
| **SEC-02 / IAM-06** [Short-lived, session-scoped tokens](controls/secrets-and-credentials.md) | A token issuer that mints scoped, expiring credentials | [Layer 01](https://airuntimesecurity.io/glossary/#guardrails) | Tokens that are expired, wildcard-scoped, or unbound to the session are rejected before the call proceeds |
| **DEL-01 / DEL-05** [Least delegation, identity propagation](agentic/delegation-chains.md) | A delegation model that intersects permissions and carries the originating principal | Layer 01 + [MASO](https://airuntimesecurity.io/maso/) | A worker agent cannot exceed the orchestrator's grant; every action stays attributable to the initiating human |

## Observation and detection → Layer 02

| Pre-runtime control | Established before deploy | Runtime layer | Runtime behaviour |
|---------------------|---------------------------|---------------|-------------------|
| **LOG-01** [Log model I/O](controls/logging-and-observability.md) | A tamper-evident log pipeline for every prompt and response | [Layer 02](https://airuntimesecurity.io/glossary/#model-as-judge) | The Judge has the raw I/O it needs to evaluate outputs against policy |
| **LOG-04** [Log agent decision chains](controls/logging-and-observability.md) | Structured chain-of-action logging across agents | [Layer 02](https://airuntimesecurity.io/glossary/#model-as-judge) | Process-aware evaluation can reconstruct what a multi-step agent did and judge whether it was appropriate |
| **NET-03** [Isolate Judge infrastructure](controls/network-and-segmentation.md) | A separate network zone for the evaluation stack | [Layer 02](https://airuntimesecurity.io/glossary/#model-as-judge) | The Judge evaluates independently; the runtime path cannot influence or silence it |
| **LOG-05** [Detect behavioural drift](controls/logging-and-observability.md) | A baseline and drift-detection pipeline | Layer 02 → [Layer 03](https://airuntimesecurity.io/glossary/#human-oversight) | Drift outside baseline raises a signal that escalates to human review |

## Decision and accountability → Layer 03

| Pre-runtime control | Established before deploy | Runtime layer | Runtime behaviour |
|---------------------|---------------------------|---------------|-------------------|
| **IAM-05** [Human approval for high-impact actions](controls/identity-and-access.md) | An approval-routing workflow for irreversible actions | [Layer 03](https://airuntimesecurity.io/glossary/#human-oversight) | High-consequence actions (transfers, deletions) pause for a human decision before they commit |
| **TOOL-04** [Classify actions by reversibility](agentic/tool-access-controls.md) | An action-impact classification on every tool | [Layer 03](https://airuntimesecurity.io/glossary/#human-oversight) | Irreversible actions are routed to oversight; reversible ones proceed, so humans are spent where it matters |
| **SUP-02 / SUP-07** [Model risk assessment, AI-BOM](agentic/supply-chain.md) | An adoption decision and a component inventory | [Layer 03](https://airuntimesecurity.io/glossary/#human-oversight) | Humans retain a defensible record of what is deployed and why it was approved |

## Recovery and containment → Circuit Breaker

| Pre-runtime control | Established before deploy | Runtime layer | Runtime behaviour |
|---------------------|---------------------------|---------------|-------------------|
| **IR-04** [Model rollback and guardrail hot-reload](controls/incident-response.md) | A rollback mechanism and hot-reloadable policy | [Circuit Breaker](https://airuntimesecurity.io/glossary/#circuit-breaker) | A bad model or policy is reverted in place without redeploying the whole system (PACE Emergency) |
| **IR-03** [Containment procedures](controls/incident-response.md) | Pre-defined containment runbooks and kill switches | [Circuit Breaker](https://airuntimesecurity.io/glossary/#circuit-breaker) | On a confirmed incident the system routes to a non-AI fallback path rather than continuing to serve |
| **SEC-05** [Rotate credentials on exposure](controls/secrets-and-credentials.md) | Automated rotation triggers | [Circuit Breaker](https://airuntimesecurity.io/glossary/#circuit-breaker) | Exposed credentials are invalidated automatically, shrinking the window of a compromise |

## Reading it the other way

If you start from a runtime layer and want to know what pre-runtime infrastructure it needs:

| Runtime layer | Depends on pre-runtime controls |
|---------------|--------------------------------|
| [Layer 01 Guardrails](https://airuntimesecurity.io/glossary/#guardrails) | NET-01/02/04/07, IAM-01/02/04, TOOL-01/02/03, SEC-01/02, SAND-01/02/03 |
| [Layer 02 Model-as-Judge](https://airuntimesecurity.io/glossary/#model-as-judge) | LOG-01/03/04/05, NET-03, DAT-08 |
| [Layer 03 Human Oversight](https://airuntimesecurity.io/glossary/#human-oversight) | IAM-05/08, TOOL-04, LOG-10, IR-01/05/06 |
| [Circuit Breaker](https://airuntimesecurity.io/glossary/#circuit-breaker) | IR-03/04, SAND-04/05, SEC-05, SESS-05 |

!!! tip "Use the catalog to generate your own view"
    Each control in [`controls.json`](catalog/controls.json) carries a `primary_runtime_layer_code` field (`L1`, `L2`, `L3`, `CB`). Filter on it to build a handoff view scoped to your own control set, or to check coverage of a given layer.

!!! info "References"
    - [Control Handoff Matrix (airuntimesecurity.io, canonical)](https://airuntimesecurity.io/infrastructure/handoff-matrix/)
    - [Infrastructure Controls](README.md)
    - [Machine-Readable Control Catalog](catalog/README.md)
    - [Glossary and Unified Taxonomy](../glossary.md)
