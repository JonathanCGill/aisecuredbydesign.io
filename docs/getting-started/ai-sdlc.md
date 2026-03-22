---
description: An AI-aware software development lifecycle that integrates risk classification, model and platform decisions, secure build practices, adversarial testing, and runtime handoff into each phase of delivery.
---

# AI-Aware SDLC

Traditional software development lifecycles assume you are building deterministic systems from code you write. AI systems break that assumption. The model is not your code. The training data is not your database. The behaviour is not fully predictable. An effective SDLC for AI must account for these differences at every phase, not bolt AI considerations onto the end.

This page maps the complete lifecycle from ideation through to production operation. Each phase links to the detailed guidance elsewhere on this site and on [AI Runtime Security](https://airuntimesecurity.io/). The goal is a single reference that shows where everything fits and what happens when.

![AI-Aware SDLC](../images/ai-sdlc-lifecycle.svg){ .arch-diagram }

## Phase 1: Ideation and use case evaluation

Before any technical work begins, evaluate whether AI is the right tool for the problem. Not every automation needs a model. Not every model needs to be an LLM.

### Is AI the right approach?

| Question | If yes | If no |
|----------|--------|-------|
| Does the problem require handling ambiguous, unstructured input? | AI is likely appropriate | Consider rules, workflows, or traditional automation |
| Does the problem need natural language understanding or generation? | LLM-based AI is likely appropriate | Consider simpler ML models, search, or templating |
| Can the problem be solved with deterministic rules? | AI adds complexity without proportionate benefit | Use rules. AI is not a universal upgrade. |
| Is the cost of a wrong answer high? | AI may still be appropriate, but requires higher-tier controls | Simpler approaches may offer better predictability |
| Does the problem require real-time autonomous action? | AI with agentic capabilities, plan for CRITICAL tier | Consider whether human-in-the-loop achieves the same outcome more safely |

!!! tip "The best AI decision might be no AI"
    If deterministic logic, keyword matching, or a simple lookup solves the problem reliably, adding AI introduces non-determinism, a larger attack surface, and ongoing operational cost. Use AI where it provides genuine capability that simpler approaches cannot match.

### Use case definition

For each proposed AI use case, document:

- **Problem statement.** What specific problem does this solve? What does success look like?
- **User context.** Who uses it? Internal experts, internal general staff, external customers, or no direct user (autonomous)?
- **Data requirements.** What data does the AI need access to? Is any of it sensitive, regulated, or confidential?
- **Decision impact.** Does the AI make decisions, recommend decisions, or provide information?
- **Action capability.** Will the AI take actions (write data, call APIs, send messages) or only read and respond?
- **Failure consequences.** What happens when the AI is wrong? What is the blast radius?

This use case definition feeds directly into [risk classification](risk-classification.md). The clearer the use case, the more accurate the classification.

### Single agent or multi-agent?

Most AI use cases are single-agent: one model, one set of tools, one task. Multi-agent architectures (orchestrators, delegators, specialist agents) are appropriate when:

- The task requires multiple distinct capabilities that cannot be served by one model with tools
- Different parts of the workflow need different permission levels
- The system needs to decompose complex goals into subtasks autonomously

If multi-agent, the [MASO Framework](https://airuntimesecurity.io/core/) applies, with additional [multi-agent controls](../core/multi-agent-controls.md) and [delegation chain](../infrastructure/agentic/delegation-chains.md) requirements. Each agent needs independent risk classification, and the system starts at MASO Tier 1 (Supervised) regardless of how confident you are in the design.

For single-agent systems, the Foundation Framework applies: [core controls](../core/controls.md) (the three-layer pattern) plus [infrastructure controls](../infrastructure/README.md) (80 technical controls covering IAM, logging, network, data protection, secrets, supply chain, and incident response).

## Phase 2: Risk classification

Once the use case is defined, classify it. This is not a one-time activity. Classification is revisited at every phase as the system's scope, data access, and capabilities become clearer.

### Initial classification

Follow the [risk classification process](risk-classification.md):

1. Score impact dimensions (decision authority, reversibility, data sensitivity, audience, scale, regulatory)
2. Apply the highest tier across all dimensions
3. Factor in [host application risk alignment](risk-classification.md#host-application-risk-alignment)
4. Check [regulatory requirements](regulatory-alignment.md) and adjust the floor upward if regulation demands it
5. Document the classification with driving factors

### What the tier unlocks

The tier determines the rigour required at every subsequent phase. Higher tiers do not just mean more controls. They mean more scrutiny, more independence in testing, more formal approvals, and more documentation.

| Phase | LOW | MEDIUM | HIGH | CRITICAL |
|-------|-----|--------|------|----------|
| **Model selection** | Documented choice | Documented evaluation | Formal assessment with alternatives | Independent review of assessment |
| **Platform selection** | Standard requirements | Data residency check | Compliance-driven selection | Board-level platform approval |
| **Build** | Standard CI/CD | AI-specific pipeline gates | Pipeline integrity verification | Immutable, auditable pipelines |
| **Test** | Basic prompt testing | Structured test suite | Red-team exercise | Independent adversarial assessment |
| **Deploy** | Standard deployment | Subset rollout | Canary with monitoring | Shadow then canary with approval gates |
| **Run** | Basic monitoring | Guardrails + batch Judge | Guardrails + near-real-time Judge + human oversight | Full three-layer pattern with real-time Judge |

## Phase 3: Design

Design is where you make the decisions that constrain everything downstream. Three decisions dominate this phase: which model, which platform, and what architecture.

### Model selection

Choose the model based on capability needs, risk tier requirements, and security posture.

| Decision | Guidance |
|----------|----------|
| Open-weight vs. closed API | [Risk assessment](../building/model-selection/risk-assessment.md) covers the tradeoffs. Open-weight gives you control and auditability. Closed API gives you managed infrastructure and regular updates. |
| Model provenance | [Provenance and integrity](../building/model-selection/provenance-and-integrity.md). At HIGH and CRITICAL tiers, you must verify the model's origin, training process, and integrity before use. |
| Model trust | [Trust and evaluation](../building/model-selection/trust-and-evaluation.md). Evaluate the model against your specific use case, not just generic benchmarks. |
| Vulnerability exposure | [Vulnerability scanning](../building/model-selection/vulnerability-scanning.md). Scan for known vulnerabilities, backdoors, and adversarial weaknesses. |
| Threat landscape | [Model threat landscape](../building/model-selection/threat-landscape.md). Understand the current threats to the type of model you are selecting. |

### Platform selection

Choose the platform based on data requirements, compliance obligations, and operational capability.

| Pattern | When to use | Guidance |
|---------|------------|----------|
| **Cloud AI services** | Most use cases. Managed infrastructure, rapid development, provider handles model serving. | [Cloud AI services](../building/platform-selection/cloud-ai-services.md) |
| **Self-hosted** | Regulated data that cannot leave your environment. Full control requirements. Air-gapped deployments. | [Self-hosted infrastructure](../building/platform-selection/self-hosted-infrastructure.md) |
| **Hybrid** | Sensitive processing on-premises, less sensitive in the cloud. Gradual migration. Multi-cloud resilience. | [Hybrid patterns](../building/platform-selection/hybrid-patterns.md) |

### Architecture decisions

Document the system architecture, including:

- How users interact with the AI (API, chat interface, embedded in application)
- What data flows into and out of the model
- What tools or actions the model has access to
- How the AI component connects to the host application
- What the [PACE resilience plan](../building/devops/resilience.md) looks like for each critical component
- Which [infrastructure controls](../infrastructure/README.md) apply based on the risk tier

For agentic systems, also document:

- [Tool access controls](../infrastructure/agentic/tool-access-controls.md): what tools are available, what permissions they have, how invocations are constrained
- [Sandbox patterns](../infrastructure/agentic/sandbox-patterns.md): how generated code is isolated and executed
- [Agentic controls](../core/agentic.md): plan approval, action constraints, circuit breakers

For multi-agent systems, additionally document:

- Agent roles and responsibilities
- [Delegation boundaries](../infrastructure/agentic/delegation-chains.md) (what each agent can and cannot do, depth limits, privilege constraints)
- Communication channels between agents
- The orchestration pattern (central orchestrator, peer-to-peer, hierarchical)

### Infrastructure control selection

During design, identify which of the [80 infrastructure controls](../infrastructure/README.md) apply to your system. The controls are organised by domain and tagged by risk tier, so you can quickly filter to what is relevant.

| Domain | Controls | Key design decisions |
|--------|----------|---------------------|
| [Identity and access](../infrastructure/controls/identity-and-access.md) | 8 controls | Authentication model, least privilege, control/data plane separation |
| [Logging and observability](../infrastructure/controls/logging-and-observability.md) | 10 controls | What to log, retention, redaction, SIEM integration |
| [Network and segmentation](../infrastructure/controls/network-and-segmentation.md) | 8 controls | Zone architecture, guardrail bypass prevention, egress controls |
| [Data protection](../infrastructure/controls/data-protection.md) | 8 controls | Classification, minimisation, PII handling, RAG access controls |
| [Secrets and credentials](../infrastructure/controls/secrets-and-credentials.md) | 8 controls | Vault strategy, context window isolation, rotation policy |
| [Supply chain](../infrastructure/agentic/supply-chain.md) | 8 controls | Model provenance, RAG data integrity, AI-BOM |
| [Incident response](../infrastructure/controls/incident-response.md) | 8 controls | AI-specific categories, containment, rollback, investigation |

Not every control applies to every system. Select based on your tier, deselect what does not apply, and document the rationale.

!!! tip "Platform-specific implementation patterns"
    If you are deploying on a specific cloud platform, the infrastructure section includes reference patterns for [AWS Bedrock](../infrastructure/reference/platform-patterns/aws-bedrock.md), [Microsoft Foundry](../infrastructure/reference/platform-patterns/microsoft-foundry.md), and [Databricks](../infrastructure/reference/platform-patterns/databricks.md) that map controls to platform-native services.

## Phase 4: Build

Build the system using AI-aware DevOps and MLOps practices. The build phase is where pipeline integrity, data governance, and secrets management are established.

### Pipeline security

Your CI/CD pipeline for AI has requirements that traditional software pipelines do not.

| Area | Guidance |
|------|----------|
| **CI/CD adaptation** | [CI/CD for AI](../building/devops/ci-cd-for-ai.md). Add model validation gates, artefact integrity checks, and AI-specific test stages. |
| **Infrastructure** | [Infrastructure as code](../building/devops/infrastructure-as-code.md). Define GPU provisioning, inference endpoints, and environment configuration as code. |
| **Secrets** | [Secrets management](../building/devops/secrets-management.md). AI systems have an expanded credential surface: model endpoints, vector databases, tool APIs, experiment trackers. |
| **Integration** | [Integration security](../building/devops/integration-security.md). The AI component connects to web frontends, databases, APIs, and MCP servers. Secure every integration point. |

### Data governance

Data shapes model behaviour. Govern it accordingly.

| Area | Guidance |
|------|----------|
| **Data lineage** | [Data governance](../building/mlops/data-governance.md). Know where your training and RAG data comes from, who modified it, and what it contains. |
| **ML pipelines** | [Secure ML pipelines](../building/mlops/secure-ml-pipelines.md). Ensure training integrity, reproducibility, and attestation. |
| **Model lifecycle** | [Model lifecycle](../building/mlops/model-lifecycle.md). Manage transitions from training through staging to production with approval gates. |
| **Experiments** | [Experiment tracking](../building/mlops/experiment-tracking.md). Protect intellectual property in hyperparameters, results, and experiment configurations. |

### Guardrail configuration

Configure input and output guardrails during the build phase, not after deployment. The [control matrix](risk-classification.md#input-guardrails) specifies what is required at each tier, and the [controls page](../core/controls.md) details the three-layer pattern (guardrails, Judge, human oversight).

At a minimum:

- Input guardrails: injection detection, content policy enforcement, rate limiting
- Output guardrails: content filtering, PII detection, grounding checks (where applicable)
- Logging: configured to the retention and protection level required by the tier
- [Network controls](../infrastructure/controls/network-and-segmentation.md): guardrail bypass prevention at the network level (ensure traffic cannot reach the model without passing through guardrails)

For specialised deployments, also configure during build:

- [Multimodal controls](../core/multimodal-controls.md) if processing images, audio, or video
- [Streaming controls](../core/streaming-controls.md) if using streaming responses
- [Memory and context controls](../core/memory-and-context.md) if using persistent memory or long context windows
- [Reasoning model controls](../core/reasoning-model-controls.md) if using chain-of-thought reasoning models

### Resilience

Build [PACE resilience](../building/devops/resilience.md) into the application from the start. Every critical component (model endpoint, vector database, tool connections, pipeline infrastructure) needs a documented and tested fallback path. The [PACE controls section](../core/pace-controls-section.md) defines fail postures for each control layer, and the [PACE checklist](../core/pace-checklist-section.md) provides verification criteria.

## Phase 5: Test

Testing for AI systems goes beyond functional verification. You need to verify that the system behaves correctly, and that it resists deliberate attempts to make it misbehave.

### Functional testing

- Does the model produce useful, accurate outputs for the intended use case?
- Do guardrails fire correctly (blocking what should be blocked, allowing what should be allowed)?
- Do tools and integrations work as expected?
- Does the PACE fallback logic trigger correctly when components fail?

### Adversarial testing

Follow the [adversarial testing](adversarial-testing.md) requirements for your tier:

| Tier | Minimum requirement before deployment |
|------|--------------------------------------|
| **LOW** | Basic prompt injection test suite |
| **MEDIUM** | Structured adversarial test suite, no HIGH-severity findings |
| **HIGH** | Red-team exercise completed, all findings remediated or risk-accepted |
| **CRITICAL** | Independent adversarial assessment, senior stakeholder review, remediation plan approved |

### Domain-specific testing

Generic safety testing is insufficient. Test guardrails against the specific risk categories relevant to your use case. A model that refuses to generate malware may readily give inappropriate financial advice. See [domain-specific guardrail tuning](risk-classification.md#judge-evaluation) for guidance.

### Risk classification review

After testing, revisit the risk classification. Testing may reveal:

- The model accesses or generates data you did not anticipate
- Attack surface is broader than assumed
- Guardrails are less effective in your specific domain than in generic benchmarks

Adjust the tier if needed. It is better to upgrade before deployment than after an incident.

## Phase 6: Deploy

Deployment is the gate between pre-runtime and runtime. No system passes through without meeting the requirements for its tier.

### Deployment gate

Follow the [production readiness](production-readiness.md) checklist for your tier. The gate is a hard requirement, not a suggestion.

Key gate items:

- Risk classification documented and approved
- Adversarial testing passed at the required level
- Guardrails configured and verified
- PACE resilience plan documented and tested
- Logging operational
- Rollback procedure tested
- Runtime security team notified and briefed

### Staged deployment

| Tier | Strategy |
|------|----------|
| **LOW** | Direct deployment, monitor for one week |
| **MEDIUM** | Subset of users first, expand after one to two weeks |
| **HIGH** | Canary deployment, gradual expansion over weeks |
| **CRITICAL** | Shadow deployment first (parallel run, no live impact), then canary, then gradual expansion with explicit approval at each stage |

### Runtime handoff

The handoff to [AI Runtime Security](https://airuntimesecurity.io/) is structured, not informal. Transfer:

- Risk classification and accepted risks
- Control configuration (guardrails, Judge policies, oversight rules)
- Adversarial test results and known residual risks
- PACE plans for all critical components
- Escalation paths and incident response runbooks
- Model documentation and known limitations

For HIGH and CRITICAL tiers, conduct a formal handoff meeting. See [production readiness: the runtime security handoff](production-readiness.md#the-runtime-security-handoff).

## Phase 7: Run

Once deployed, the [three-layer control pattern](../core/controls.md) takes over: guardrails prevent known-bad inputs and outputs in real-time, the [Judge](../core/judge-assurance.md) evaluates interactions asynchronously for unknown-bad patterns, and [human oversight](../core/oversight-readiness-problem.md) handles high-consequence decisions.

The [quantitative risk assessment](../core/risk-assessment.md) methodology lets you measure how effectively each layer reduces residual risk, using the same NIST AI RMF alignment that structures the rest of the framework.

Pre-runtime responsibilities do not end at deployment.

### Ongoing pre-runtime obligations

| Activity | Cadence | Trigger |
|----------|---------|---------|
| **Risk classification review** | Annual minimum | Also triggered by scope changes, incidents, or model updates |
| **Model update assessment** | Every model version change | Treat as a new deployment through the SDLC |
| **Adversarial re-testing** | Per tier cadence (quarterly to continuous) | Also triggered by new threat intelligence or incidents |
| **Regulatory review** | Quarterly | Also triggered by new regulation or enforcement actions |
| **PACE plan review** | When system changes | Also after any PACE level transition in production |

### Model updates as SDLC cycles

A model update is not a patch. It can change the system's behaviour in unpredictable ways. Every model update should cycle back through the relevant SDLC phases:

- **Minor version update (same provider, same model family):** Re-run adversarial test suite, verify guardrail effectiveness, monitor closely for the first week
- **Major version update or model change:** Full cycle from Phase 3 (Design) onward, including model evaluation, adversarial testing, and staged deployment
- **Provider-side update (API models updated by the provider):** Re-run adversarial test suite immediately, review outputs for behavioural changes, escalate if guardrail effectiveness has changed

### Feedback loop

Production observations feed back into the SDLC:

- Guardrail trigger patterns inform adversarial test suite updates
- Judge evaluation findings reveal gaps in pre-deployment testing
- Incidents trigger risk classification review and potential tier upgrade
- User behaviour patterns may reveal use case drift that changes the risk profile

This is not a linear process with a defined end. It is a continuous cycle where production experience improves pre-runtime decisions, and pre-runtime decisions improve production outcomes.

## Mapping the lifecycle to your organisation

### Where does this fit with existing SDLC processes?

This AI-aware SDLC does not replace your existing development process. It augments it. If your organisation uses agile sprints, the AI phases map to sprint activities. If you use a stage-gate process, the AI gates sit alongside your existing gates.

The key additions to a standard SDLC:

1. **Ideation adds AI suitability assessment** before committing to an AI approach
2. **Risk classification is a new activity** that does not exist in traditional software development
3. **Design adds model and platform selection** as first-class architectural decisions
4. **Build adds AI-specific pipeline gates**, data governance, and guardrail configuration
5. **Test adds adversarial testing** alongside functional and integration testing
6. **Deploy adds a structured runtime handoff** that traditional deployments do not require
7. **Run adds ongoing model assessment** and classification review that traditional software does not need

### Roles and responsibilities

Each role has a [stakeholder view](../stakeholders/README.md) that provides role-specific guidance, reading paths, and concrete first actions.

| Role | Primary SDLC responsibilities | Stakeholder view |
|------|------------------------------|-----------------|
| **Product owner** | Use case definition, risk classification approval, tier change decisions | [Product owners](../stakeholders/product-owners.md) |
| **AI/ML engineer** | Model selection, pipeline build, guardrail configuration, model lifecycle | [AI engineers](../stakeholders/ai-engineers.md) |
| **Security leader** | Security strategy, control framework, adversarial testing oversight | [Security leaders](../stakeholders/security-leaders.md) |
| **Enterprise architect** | Platform selection, infrastructure controls, integration patterns | [Enterprise architects](../stakeholders/enterprise-architects.md) |
| **Governance/compliance** | Regulatory alignment, audit trail, classification review, policy enforcement | [Compliance and legal](../stakeholders/compliance-and-legal.md) |
| **Risk management** | Risk quantification, board reporting, control effectiveness measurement | [Risk and governance](../stakeholders/risk-and-governance.md) |
| **CIO/CTO** | AI portfolio governance, platform strategy, technology standards | [Chief information officers](../stakeholders/chief-information-officers.md) |
| **Business owner** | Business case, cost/benefit, operational risk across product lines | [Business owners](../stakeholders/business-owners.md) |

### Low-risk fast lane

Not every AI system needs the full process. For LOW-tier systems (internal, read-only, no regulated data, no personal data), a streamlined path is appropriate:

1. Document the use case and classify as LOW
2. Select model and platform (standard choices, no formal evaluation required)
3. Build with basic guardrails
4. Run basic prompt injection tests
5. Deploy directly with one-week monitoring
6. Annual review

The fast lane is only for systems that genuinely meet LOW-tier criteria. If there is any doubt, use the full process.

!!! abstract "The SDLC connects both sites"
    Phases 1 through 6 are pre-runtime (this site). Phase 7 is runtime ([AI Runtime Security](https://airuntimesecurity.io/)). The SDLC is the thread that connects them. Risk classification, established in Phase 2, carries through every phase and determines the intensity of both pre-runtime and runtime controls.

!!! info "References"
    - [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [ISO/IEC 42001: AI Management System](https://www.iso.org/standard/81230.html)
    - [OWASP AI Security and Privacy Guide](https://owasp.org/www-project-ai-security-and-privacy-guide/)
    - [Microsoft Security Development Lifecycle](https://www.microsoft.com/en-us/securityengineering/sdl)
    - [Google SAIF: Secure AI Framework](https://safety.google/cybersecurity-advancements/saif/)
    - [AI Runtime Security](https://airuntimesecurity.io/)
    - [AI Runtime Security: MASO Framework](https://airuntimesecurity.io/core/)
