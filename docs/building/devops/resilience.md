---
description: PACE resilience planning for AI systems, ensuring primary, alternate, contingency, and emergency options exist for every critical AI component.
---

# Resilience

AI systems fail. Models degrade, APIs go down, inference endpoints hit capacity, dependencies break, and cloud regions have outages. Resilience planning for AI is not optional. It is a security and operational necessity.

The challenge is that AI systems have failure modes that traditional applications do not. A model can silently degrade (producing plausible but incorrect output) without triggering a health check. A vector database can return stale embeddings. An MCP tool can become unavailable, leaving an agent unable to complete its task. These failures do not always produce errors. They produce wrong answers, and wrong answers from an AI system can cause real harm.

## PACE for AI development

PACE is a resilience framework originally developed for military communications planning. It ensures that for every critical capability, there are four defined options:

| Level | Meaning | Application to AI |
|-------|---------|-------------------|
| **P** Primary | The preferred, default method | The primary model, endpoint, or service in normal operation |
| **A** Alternate | A backup that uses a different method but achieves the same result | A different model, provider, or deployment that can substitute |
| **C** Contingency | A fundamentally different approach used when primary and alternate fail | A simplified fallback, cached responses, rule-based system, or human handoff |
| **E** Emergency | A last-resort option that maintains minimum viable capability | Static responses, graceful degradation messaging, full service pause with user notification |

The value of PACE is that it forces teams to think through failure scenarios before they happen and to document concrete, tested fallback options rather than hoping for the best.

[AI Runtime Security](https://airuntimesecurity.io/) uses PACE to structure resilience for runtime controls (guardrails, LLM-as-Judge, human oversight). The same discipline applies to the development and deployment phase. Every critical component of the AI system should have a PACE plan defined before it reaches production.

## Applying PACE to AI components

### Model inference

The model endpoint is the most visible single point of failure in an AI system.

| Level | Example |
|-------|---------|
| **Primary** | Production model endpoint (e.g., GPT-4o on Azure OpenAI, self-hosted Llama on Kubernetes) |
| **Alternate** | Same model on a different provider or region (e.g., failover to a second Azure region, or switch from Azure OpenAI to direct OpenAI API) |
| **Contingency** | A smaller, faster model that provides reduced capability but maintains service (e.g., fall back from GPT-4o to GPT-4o-mini, or from a 70B model to a 7B model) |
| **Emergency** | Cached responses for common queries, static fallback content, or graceful degradation with a clear message to users that AI capabilities are temporarily limited |

### RAG and knowledge retrieval

| Level | Example |
|-------|---------|
| **Primary** | Vector database with live embeddings (e.g., Pinecone, Weaviate, pgvector) |
| **Alternate** | Replica vector database in a different region or availability zone |
| **Contingency** | Full-text search against the source documents (bypassing embeddings entirely) |
| **Emergency** | Model operates without retrieval context, with a warning that responses may be less accurate or current |

### Tool use and MCP connections

| Level | Example |
|-------|---------|
| **Primary** | Live MCP connection to the tool or data source |
| **Alternate** | Alternative tool or API that provides equivalent functionality |
| **Contingency** | Cached or pre-fetched data from the tool, used with a staleness warning |
| **Emergency** | Model responds without tool access, clearly stating it cannot perform the requested action |

### CI/CD pipeline

| Level | Example |
|-------|---------|
| **Primary** | Primary CI/CD platform (e.g., GitHub Actions, GitLab CI, Jenkins) |
| **Alternate** | Secondary CI/CD platform or self-hosted runner in a different environment |
| **Contingency** | Manual deployment process with documented steps, checklists, and dual-approval requirements |
| **Emergency** | Freeze deployments and operate on the last known good configuration until the pipeline is restored |

### Secrets and credentials

| Level | Example |
|-------|---------|
| **Primary** | Cloud secrets manager (e.g., AWS Secrets Manager, Azure Key Vault, HashiCorp Vault) |
| **Alternate** | Secondary secrets manager in a different region or provider |
| **Contingency** | Encrypted secrets stored in a break-glass location with strict access controls and audit logging |
| **Emergency** | Pre-provisioned service accounts with time-limited credentials stored offline, accessible only through a documented emergency procedure |

## Building PACE into development

PACE planning is not something to retrofit after deployment. It belongs in the development process.

### During design

- **Identify critical components.** Map every component the AI system depends on: models, databases, APIs, tools, infrastructure services.
- **Assess failure impact.** For each component, determine what happens when it fails. Does the system crash? Does it silently degrade? Does it produce harmful output?
- **Define PACE for each critical component.** Document the primary, alternate, contingency, and emergency options. Be specific: name the service, the endpoint, the configuration.

### During development

- **Build fallback logic.** The application code should implement the PACE transitions. When the primary model endpoint returns errors or times out, the code should automatically attempt the alternate, then the contingency, then the emergency response.
- **Make PACE transitions observable.** Log every PACE level transition. If the system falls back from primary to alternate, that should trigger an alert. If it falls to contingency or emergency, that should trigger an incident.
- **Avoid silent degradation.** When operating at a lower PACE level, communicate this to users and operators. A chatbot running on cached responses should say so, not pretend it is operating normally.

### During testing

- **Test each PACE level.** Do not just test the happy path. Simulate failure of the primary and verify that the alternate works. Simulate failure of both and verify the contingency. Test the emergency level.
- **Test PACE transitions.** The transition from one level to the next should be smooth. Test that the fallback logic handles timeouts, error codes, and partial failures correctly.
- **Test recovery.** When the primary comes back, the system should return to it. Test that recovery from lower PACE levels works without manual intervention.

### During deployment

- **Include PACE status in health checks.** The system should report which PACE level each component is operating at. A system running entirely on primary is healthy. A system running on contingency for its model endpoint is degraded and needs attention.
- **Document PACE plans.** The PACE plan for each component should be documented, reviewed, and accessible to the operations team. During an incident is not the time to invent fallback strategies.
- **Review PACE plans regularly.** As the system evolves, PACE plans need updating. A new model version may require a new alternate. A deprecated API may invalidate a contingency option.

## PACE checklist

Before any AI system reaches production, verify:

- [ ] Every critical component has a documented PACE plan
- [ ] Primary and alternate options use different failure domains (different providers, regions, or infrastructure)
- [ ] Contingency options are fundamentally different approaches, not just variations of the primary
- [ ] Emergency options maintain minimum viable capability or fail safely with clear user communication
- [ ] Fallback logic is implemented in application code, not just documented
- [ ] PACE transitions are logged and trigger alerts
- [ ] Each PACE level has been tested, including transitions between levels
- [ ] Recovery from lower PACE levels back to primary has been tested
- [ ] The operations team knows the PACE plan and has practised it
- [ ] PACE plans are reviewed and updated when the system changes

!!! abstract "PACE connects pre-runtime to runtime"
    PACE planning during development ensures that runtime resilience is built in, not bolted on. The PACE plans defined here feed directly into [runtime resilience controls](https://airuntimesecurity.io/). Pre-runtime PACE planning determines what fallbacks exist. Runtime PACE execution determines when and how to use them.

!!! info "References"
    - [PACE Communications Planning](https://en.wikipedia.org/wiki/PACE_(communication_methodology))
    - [AI Runtime Security: PACE Resilience](https://airuntimesecurity.io/core/)
    - [AWS Well-Architected Framework: Reliability Pillar](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/)
    - [Google SRE: Embracing Risk](https://sre.google/sre-book/embracing-risk/)
