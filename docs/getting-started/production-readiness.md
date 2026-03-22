---
description: Preparing AI systems for the transition from development to production. Deployment gates, observability, runtime security handoff, and ensuring visibility from day one.
---

# Production Readiness

The transition from development to production is where pre-runtime security ends and runtime security begins. This page covers how to make that handoff clean, complete, and visible. A system that reaches production without proper preparation forces runtime security to discover what it is protecting on the fly.

## The deployment gate

No AI system should reach production without passing through a deployment gate appropriate to its [risk tier](risk-classification.md). The gate is the final checkpoint before the system is live.

### Gate checklist by tier

#### All tiers (minimum)

- [ ] Risk classification documented and approved
- [ ] Model provenance verified ([provenance and integrity](../building/model-selection/provenance-and-integrity.md))
- [ ] Basic adversarial testing completed ([adversarial testing](adversarial-testing.md))
- [ ] PACE resilience plan documented for critical components ([resilience](../building/devops/resilience.md))
- [ ] Logging configured and verified
- [ ] Rollback procedure documented and tested
- [ ] Runtime security team notified of pending deployment

#### MEDIUM tier (add to above)

- [ ] Structured adversarial test suite passed
- [ ] Data governance review completed ([data governance](../building/mlops/data-governance.md))
- [ ] Secrets management verified ([secrets management](../building/devops/secrets-management.md))
- [ ] Input and output guardrails configured and tested
- [ ] Monitoring dashboards created
- [ ] On-call rotation identified for AI-specific issues

#### HIGH tier (add to above)

- [ ] Red-team exercise completed, findings remediated
- [ ] Regulatory compliance verified ([regulatory alignment](regulatory-alignment.md))
- [ ] Domain-specific guardrail testing completed
- [ ] Judge evaluation configured and calibrated
- [ ] Human oversight workflow tested end-to-end
- [ ] Incident response runbook created for AI-specific scenarios
- [ ] Privacy impact assessment completed (if processing personal data)

#### CRITICAL tier (add to above)

- [ ] Independent adversarial assessment completed
- [ ] Senior stakeholder sign-off on risk acceptance
- [ ] Immutable logging configured and verified
- [ ] Real-time Judge evaluation operational
- [ ] Human oversight escalation path tested
- [ ] Regulatory notifications filed (if required)
- [ ] Board or risk committee briefed
- [ ] Canary or staged deployment plan approved

## Making the system visible

A deployed AI system that is invisible to the security operations team, the platform team, and the governance function is an unmanaged risk. Visibility must be established before deployment, not discovered after an incident.

### What needs to be visible

| Audience | What they need to see | Why |
|----------|----------------------|-----|
| **Security operations** | Alerts on guardrail violations, anomalous usage patterns, Judge escalations | To detect and respond to attacks or misuse |
| **Platform/infrastructure** | Resource utilisation, latency, error rates, PACE level status | To maintain service reliability and capacity |
| **AI/ML team** | Model performance metrics, drift indicators, output quality trends | To maintain model quality and detect degradation |
| **Governance/compliance** | Audit logs, decision records, human oversight actions, tier compliance status | To demonstrate regulatory compliance and track governance effectiveness |
| **Product owner** | Usage metrics, user feedback, business outcome indicators | To validate the system delivers value and manage risk |

### Observability requirements by tier

| Aspect | LOW | MEDIUM | HIGH | CRITICAL |
|--------|-----|--------|------|----------|
| **Metrics** | Basic (latency, errors) | Standard (+ usage, quality) | Comprehensive (+ drift, fairness) | Full (+ per-decision tracking) |
| **Alerting** | Error-based | Error + anomaly | Real-time on violations | Real-time + escalation chain |
| **Dashboards** | Optional | Team-level | Cross-functional | Executive + operational |
| **Log retention** | 90 days | 1 year | 3 years | 7 years (immutable) |
| **Audit trail** | Metadata | Key decisions | All interactions | Full reasoning chain |

### Integration with existing security tooling

AI systems must plug into the organisation's existing security infrastructure. Do not build parallel monitoring that bypasses the SOC.

**Pre-deployment integration checklist:**

- [ ] AI system logs flow to the central SIEM or log aggregation platform
- [ ] AI-specific alerts are routed to the appropriate response team
- [ ] AI system health metrics are visible on infrastructure monitoring dashboards
- [ ] AI-specific runbooks are loaded into the incident management system
- [ ] AI system is registered in the organisation's asset inventory / AI registry

!!! warning "Shadow AI is invisible AI"
    If an AI system is deployed without integration into existing security and monitoring infrastructure, it is effectively invisible to the organisation's security posture. This is one of the highest-risk outcomes of poor pre-runtime security. Make integration a hard gate, not a post-deployment task.

## The runtime security handoff

The handoff to [AI Runtime Security](https://airuntimesecurity.io/) is not a clean break. It is a structured transition where responsibility shifts but context must be preserved.

### What to hand off

| Item | Description | Format |
|------|------------|--------|
| **Risk classification** | Tier assignment, driving factors, accepted risks | Classification document |
| **Control configuration** | Guardrail settings, Judge policies, human oversight rules | Configuration files or policy documents |
| **Test results** | Adversarial testing findings, remediation status, known residual risks | Test report |
| **PACE plan** | Resilience plan for each critical component | PACE documentation |
| **Escalation paths** | Who to contact for AI-specific issues, what triggers escalation | Runbook |
| **Model documentation** | Model card, provenance record, known limitations, failure modes | Model documentation |
| **Regulatory obligations** | Applicable regulations, compliance requirements, reporting obligations | Compliance mapping |

### Handoff meeting

For HIGH and CRITICAL tier systems, conduct a formal handoff meeting between the development/deployment team and the runtime security/operations team. Cover:

- System purpose, scope, and risk classification
- Known risks, accepted risks, and residual risks
- Control configuration and rationale
- Monitoring and alerting setup
- Escalation and incident response procedures
- Scheduled review dates

For LOW and MEDIUM tier systems, this can be an asynchronous handoff using documented artifacts, but the information must still be transferred.

## Staged deployment

Not every system should go from zero to full production in one step. Staged deployment reduces risk by limiting blast radius during the initial production period.

### Deployment strategies by tier

| Tier | Recommended approach |
|------|---------------------|
| **LOW** | Direct deployment is acceptable. Monitor for the first week. |
| **MEDIUM** | Deploy to a subset of users or use cases first. Expand after one to two weeks of stable operation. |
| **HIGH** | Canary deployment: route a small percentage of traffic to the new system. Monitor closely. Expand gradually over weeks. |
| **CRITICAL** | Shadow deployment first (run in parallel with existing process, compare outputs, no live impact). Then canary. Then gradual expansion. Each stage requires explicit approval to proceed. |

### What to monitor during staged deployment

- Output quality and consistency
- Guardrail trigger rates (are they firing too often? too rarely?)
- Judge evaluation results (what is the Judge catching that guardrails miss?)
- User feedback and behaviour
- Error rates and latency
- PACE level (is the system operating on primary, or has it already fallen back?)

## Post-deployment: the first 30 days

The first 30 days in production are the highest-risk period. Controls that worked in testing may behave differently under real-world load, with real users, and with real data.

### First-week focus

- Monitor all metrics at elevated frequency
- Review all Judge escalations manually
- Track guardrail trigger patterns
- Verify logging is capturing what you expect
- Confirm alerting is reaching the right people

### First-month focus

- Compare actual usage patterns to design assumptions
- Review whether the risk tier assignment is accurate based on real-world behaviour
- Identify any gaps between pre-deployment testing and production behaviour
- Update adversarial test suite based on production observations
- Conduct first scheduled review of the deployment

### Tier reassessment

After the first 30 days, reassess the risk classification. Real-world deployment may reveal that the system:

- Processes data you did not anticipate (tier may need to go up)
- Is used differently than intended (tier may need adjustment in either direction)
- Has attack surface you did not identify during testing (tier may need to go up)
- Operates more safely than anticipated (tier may be eligible for reduction, but only after six months per the [tier change requirements](risk-classification.md#tier-changes))

## Connecting both sites

This page marks the boundary between [AI Secured by Design](../README.md) (pre-runtime) and [AI Runtime Security](https://airuntimesecurity.io/) (runtime). The relationship is sequential but connected.

**Pre-runtime security** ensures that what gets deployed is trustworthy. It covers model selection, platform decisions, pipeline security, data governance, adversarial testing, and the deployment gate.

**Runtime security** ensures that the deployed system stays trustworthy. It covers guardrails, Judge evaluation, human oversight, monitoring, and incident response.

Neither is sufficient alone. A well-built system without runtime controls will degrade undetected. A poorly-built system with excellent runtime controls will fight fires that should never have started.

<div class="runtime-callout" markdown>
<p class="runtime-callout__label">Continue to</p>
<p class="runtime-callout__title">AI Runtime Security</p>
<p class="runtime-callout__desc">Your system is deployed. Runtime controls take over: guardrails to prevent, Judge to detect, humans to decide. Start with the risk tier you classified here and implement the corresponding runtime controls.</p>

[Continue to AI Runtime Security](https://airuntimesecurity.io/){ .md-button }
</div>

!!! info "References"
    - [AI Runtime Security](https://airuntimesecurity.io/)
    - [AI Runtime Security: Risk Tiers](https://airuntimesecurity.io/core/risk-tiers/)
    - [Google SRE: Release Engineering](https://sre.google/sre-book/release-engineering/)
    - [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
    - [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
