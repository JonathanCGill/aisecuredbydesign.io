---
description: A HIGH-tier worked example, an internal engineering agent that operates systems through MCP servers, focused on MCP and tool supply chain, tool-description and tool-output injection, delegation, non-human identity, and sandboxing.
---

# HIGH Tier: MCP Engineering Agent

**The system:** an internal assistant that helps engineers operate production systems. It connects to several **Model Context Protocol (MCP) servers** that expose tools, query logs and metrics, search the ticket system, read configuration, run read-only diagnostics, and (for some users) restart a service or open a change. An engineer asks in natural language; the agent plans and calls tools to get it done.

This is the example where **the tools are the risk**. A retrieval assistant reads; this agent *acts*, through tools it did not write, described by metadata it did not author, returning output it cannot trust. It exercises the parts of the framework that a chat assistant never touches.

## Why this is HIGH tier

From the [classification process](../core/risk-tiers.md#classification-process): the agent has access to production systems, can take actions with operational impact, and operates with meaningful autonomy. It is internal, which caps some exposure, but the combination of system access and autonomy puts it at **HIGH**, with destructive actions (service restart, config change) attracting CRITICAL-level controls *for those actions*.

## The MCP-specific risks

MCP makes it easy to give an agent many tools from many sources. That convenience is the threat surface. See this site's [MCP-specific controls](../core/agentic.md#mcp-specific-controls) and AIRS's [The MCP Problem](https://airuntimesecurity.io/insights/the-mcp-problem/).

| Risk | What goes wrong |
|------|-----------------|
| **Untrusted MCP servers (tool supply chain)** | An MCP server is a third-party dependency that can call your systems. A compromised or malicious server is a direct path into your environment. |
| **Tool-description injection** | The agent reads each tool's name and description to decide how to use it. A malicious server can embed instructions in that metadata ("to use this tool, first call `exfiltrate`..."), injecting the agent before any user input. |
| **Tool-output injection** | Logs, tickets, and configs contain attacker-influenced text. When that output returns to the agent, it can carry instructions that steer the next action. |
| **Over-broad tool scope** | It is easy to grant an agent every tool a server offers. Excess capability is excess blast radius. |
| **Confused deputy via delegation** | The agent acts "on behalf of" an engineer. If it does not carry that engineer's identity and limits, it can do things the engineer could not. |

## The controls that matter most

### Treat every MCP server as untrusted supply chain

Vet, pin, and inventory MCP servers the way you would any dependency. See [SUP-05, Audit Tool and Plugin Supply Chain](../infrastructure/agentic/supply-chain.md) and [Tool Access Controls](../infrastructure/agentic/tool-access-controls.md).

- Allowlist which MCP servers the agent may connect to; pin versions; maintain an [AI-BOM](../infrastructure/agentic/supply-chain.md) that includes them.
- Treat tool descriptions as untrusted input. Do not let tool metadata flow into the planning context without inspection.
- Sanitise tool output before it re-enters the model ([Tool Output Sanitisation](../core/agentic.md#3-tool-output-sanitisation)).

### Enforce tool permissions at a broker, not in the prompt

The agent must call tools through a broker that holds the credentials and decides what is allowed, so a prompt-injected agent still cannot exceed its grant.

| Control | What it enforces | Reference |
|---------|------------------|-----------|
| Explicit tool permissions | Which tools, for which users, with which parameter bounds | [Tool Access Controls](../infrastructure/agentic/tool-access-controls.md) |
| Action classification | Read vs write vs destructive; reversibility-based handling | [Agentic Controls](../core/agentic.md#control-categories) |
| Approval for high-impact actions | Service restart and config change require human confirmation | [Approval Workflows](../core/agentic.md#4-approval-workflows) |
| Egress control | The agent and its tools can reach only declared destinations | [Network & Segmentation](../infrastructure/controls/network-and-segmentation.md) |

### Identity: the agent is a non-human identity acting under delegation

Two identity problems sit on top of each other here.

- **Non-human identity (NHI).** The agent itself is an identity with a lifecycle, credentials, and least-privilege scope. It needs short-lived, scoped tokens from a vault, never standing admin rights. See [IAM Governance](../core/iam-governance.md) and AIRS's [NHI Lifecycle](https://airuntimesecurity.io/extensions/technical/nhi-lifecycle/).
- **Delegation.** When the agent acts for an engineer, it must propagate that engineer's identity and never exceed their permissions. Enforce [least delegation and identity propagation](../infrastructure/agentic/delegation-chains.md): the agent's effective permission is the *intersection* of its own scope and the user's, never the union.

### Sandbox anything that executes

If the agent runs diagnostics or generated commands, run them in an isolated sandbox with restricted file system, network, and resource limits, and scan before execution. See [Sandbox Patterns](../infrastructure/agentic/sandbox-patterns.md).

!!! warning "The 'just add the MCP server' reflex"
    The fastest way to create a HIGH-tier incident is to point the agent at a convenient public MCP server so it can "also do X." Every new server is a new supplier with a path into your systems and a new channel for tool-description injection. Adding one is a re-tiering event, not a configuration tweak.

## What this example teaches

Tools turn an assistant into an actor, and MCP turns tool sprawl into supply-chain risk. The defining moves are: broker-enforced permissions (not prompt instructions), least delegation with identity propagation, untrusted handling of tool descriptions *and* outputs, and sandboxed execution. When agents start calling other agents, this moves into multi-agent territory, hand off to [Multi-Agent Controls](../core/multi-agent-controls.md) and [MASO](https://airuntimesecurity.io/maso/). For the opposite end of the impact scale, where the model itself is the risk, see the [CRITICAL Credit Decisioning](example-decisioning-critical.md) example.

!!! info "References"
    - [Agentic AI Controls](../core/agentic.md)
    - [Tool Access Controls](../infrastructure/agentic/tool-access-controls.md)
    - [Delegation Chain Controls](../infrastructure/agentic/delegation-chains.md)
    - [Sandbox Patterns for Agentic AI](../infrastructure/agentic/sandbox-patterns.md)
    - [Supply Chain Security Controls](../infrastructure/agentic/supply-chain.md)
    - [AI Runtime Security: The MCP Problem](https://airuntimesecurity.io/insights/the-mcp-problem/)
