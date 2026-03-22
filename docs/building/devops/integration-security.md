---
description: Securing the full AI system stack, including web frontends, databases, APIs, MCP connections, and traditional infrastructure that AI depends on.
---

# Integration Security

AI does not exist in isolation. Every AI system is part of a larger architecture: a chatbot has a web frontend, connects to a database, calls external APIs, and may use protocols like MCP (Model Context Protocol) to interact with tools and data sources. A recommendation engine sits behind a load balancer, reads from a feature store, writes to a cache, and reports to a monitoring stack. An autonomous agent orchestrates calls across multiple services, each with its own attack surface.

Securing the AI component alone is not enough. If the web frontend is vulnerable to XSS, an attacker can manipulate what users see from the model. If the database has weak access controls, training data or RAG context can be poisoned. If the API gateway lacks authentication, the model endpoint is exposed. The security of the AI system is bounded by the security of its weakest integration point.

## The full stack matters

Teams building AI systems often focus on model security (provenance, scanning, evaluation) and pipeline security (CI/CD hardening, secrets management). These are necessary, but they address only part of the attack surface.

The components surrounding the AI model are just as critical:

| Component | Role in AI system | Security concerns |
|-----------|------------------|-------------------|
| **Web frontend** | User interface for chatbots, dashboards, prompt interfaces | XSS, CSRF, session hijacking, input manipulation |
| **API gateway** | Routes requests to model endpoints | Authentication, rate limiting, input validation, DDoS |
| **Application server** | Orchestrates calls between user, model, and data | Injection attacks, broken access control, insecure deserialization |
| **Database** | Stores conversation history, user data, RAG documents | SQL injection, access control, encryption at rest |
| **Vector database** | Stores embeddings for RAG retrieval | Query injection, access control, data poisoning |
| **Cache layer** | Caches model responses, embeddings, session state | Cache poisoning, data leakage, stale response serving |
| **Message queue** | Asynchronous processing of inference requests | Message tampering, queue poisoning, replay attacks |
| **Object storage** | Stores model artefacts, training data, logs | Access control misconfiguration, data exfiltration |
| **Monitoring stack** | Observability for model performance and system health | Log injection, sensitive data in logs, alert tampering |

## Securing AI integration points

### Web frontends

A chatbot frontend is a web application. It needs the same security controls as any other web application:

- **Input sanitisation.** User prompts pass through the frontend before reaching the model. Sanitise inputs to prevent injection attacks against the application layer, while preserving the prompt content needed for the model.
- **Output encoding.** Model responses may contain content that, if rendered unsanitised, creates XSS vulnerabilities. Encode all model output before rendering in the browser.
- **Authentication and session management.** Who is allowed to interact with the model? Session tokens, OAuth flows, and access controls apply here just as they do in any web application.
- **Content Security Policy.** Restrict what the frontend can load and execute. AI applications that render dynamic content from models are particularly susceptible to injection through model output.
- **Rate limiting at the frontend.** Prevent abuse before requests reach the model endpoint. Client-side rate limiting is a UX control; server-side rate limiting is a security control.

### API and service integration

AI systems typically expose model capabilities through APIs and consume other services to enrich context or take actions.

**Inbound API security (exposing AI capabilities):**

- Authenticate every request. API keys, OAuth tokens, or mutual TLS, depending on the trust boundary.
- Validate and constrain input payloads. Maximum prompt length, allowed content types, required fields.
- Rate limit by client, by endpoint, and by cost (token-based billing means cost abuse is a real threat).
- Log requests and responses for audit, but redact sensitive content.

**Outbound API security (AI calling other services):**

- Apply least-privilege credentials for each service the AI system calls.
- Validate responses from external services before using them as model context. An attacker who compromises an upstream API can inject malicious content into your model's context window.
- Set timeouts and circuit breakers. A slow or unresponsive external service should not cascade into your AI system.
- Pin TLS certificates or use certificate transparency monitoring for critical integrations.

### MCP and tool-use protocols

Model Context Protocol (MCP) and similar tool-use frameworks allow AI models to interact with external tools, data sources, and services. This is powerful and, if unsecured, dangerous.

**MCP security considerations:**

- **Tool access control.** Define which tools the model can invoke and under what conditions. A model should not have unrestricted access to every available tool.
- **Parameter validation.** Validate the parameters the model passes to tools. A model that can construct arbitrary database queries through a tool is a SQL injection risk.
- **Result sanitisation.** Tool results feed back into the model's context. Malicious content in tool results can influence model behaviour (indirect prompt injection).
- **Scope limitation.** Restrict the scope of each tool connection. A filesystem tool should access specific directories, not the entire filesystem. A database tool should use a read-only connection unless writes are explicitly required.
- **Audit logging.** Log every tool invocation: what tool, what parameters, what result, triggered by what prompt. This is essential for incident investigation.
- **Transport security.** MCP connections should use authenticated, encrypted transport. Treat every MCP connection as a trust boundary.

!!! warning "Tool use amplifies model risk"
    A model that can only generate text has limited blast radius. A model that can execute tools, query databases, send emails, or modify files has the blast radius of every tool it can access. Secure tool-use integrations with the same rigour you apply to privileged service accounts.

### Database connections

AI systems interact with databases for conversation history, RAG document storage, user preferences, feature stores, and more.

- **Use parameterised queries.** AI-generated content should never be concatenated into SQL statements. This applies whether the application code or the model itself constructs the query.
- **Separate read and write credentials.** Inference workloads that only need to read from a database should use read-only credentials. Training or ingestion pipelines that write should use separate, scoped credentials.
- **Encrypt connections.** TLS for database connections is not optional, even within a private network.
- **Restrict network access.** Database servers should not be reachable from the internet. Use private subnets, security groups, and network policies to limit access to authorised services.
- **Audit database access.** Log queries from AI workloads separately from application queries. Unusual query patterns from an AI system may indicate prompt injection or tool-use abuse.

## Traditional security still applies

The presence of AI in a system does not eliminate traditional security concerns. It adds to them.

### Server and infrastructure security

- **Patch management.** Servers running model inference, training jobs, or supporting services need regular patching. A vulnerability in the operating system, container runtime, or web server is exploitable regardless of whether AI is involved.
- **Hardening.** Apply CIS benchmarks or equivalent hardening guides to all servers in the AI stack. GPU servers and inference nodes are servers, not special cases exempt from hardening.
- **Network segmentation.** Separate AI workloads from other workloads. Training environments should not share network segments with production inference. Neither should share segments with general corporate infrastructure.
- **Endpoint protection.** Servers running AI workloads benefit from the same endpoint detection and response (EDR) tooling as any other server.

### Dependency management

AI systems have deep dependency trees. ML frameworks, CUDA drivers, Python packages, JavaScript frontend libraries, container base images: each is a potential vulnerability.

- **Scan dependencies regularly.** Use tools like `pip-audit`, `npm audit`, `trivy`, or `grype` to scan for known vulnerabilities.
- **Pin versions.** Lock dependency versions in requirements files, lock files, and container image tags. Floating versions introduce unpredictability and risk.
- **Monitor for advisories.** Subscribe to security advisories for your key dependencies (PyTorch, TensorFlow, LangChain, FastAPI, etc.).
- **Update promptly.** Known vulnerabilities in dependencies are among the most exploited attack vectors. Do not defer updates indefinitely.

### Container and orchestration security

Most AI inference and training workloads run in containers orchestrated by Kubernetes or similar platforms.

- **Minimal base images.** Use distroless or minimal base images. Every additional package in the image is attack surface.
- **Non-root execution.** Run containers as non-root users. Model inference does not require root privileges.
- **Image scanning.** Scan container images for vulnerabilities before deployment. Integrate scanning into the CI/CD pipeline.
- **Pod security policies.** Restrict container capabilities, prevent privilege escalation, and limit host access.
- **Secrets injection.** Mount secrets from a secrets manager at runtime, not baked into the image. See [Secrets Management](secrets-management.md).

### Access control across the stack

Access control failures compound across integration points. A weak point anywhere in the chain can expose the entire system.

- **Apply zero-trust principles.** Every service-to-service call should be authenticated and authorised, not just calls from external users.
- **Use service mesh or mutual TLS** for internal communication between AI components.
- **Centralise identity.** Use a single identity provider for human users and a consistent approach for service identities (service accounts, workload identity, managed identity).
- **Review permissions regularly.** Permissions granted during development often persist into production. Audit and prune.

## Infrastructure may or may not be code

Not every organisation manages infrastructure as code. Some environments are manually provisioned, use GUI-based cloud consoles, or rely on managed services where infrastructure is abstracted away.

Regardless of how infrastructure is managed:

- **Document the architecture.** If it is not in code, it must be documented somewhere. Undocumented infrastructure is unauditable infrastructure.
- **Apply the same security controls.** Whether a firewall rule is defined in Terraform or configured through a console, it needs the same review, the same least-privilege principles, and the same monitoring.
- **Detect configuration drift.** Without IaC, drift detection requires manual auditing or cloud-native tools (AWS Config, Azure Policy, GCP Security Command Centre). Drift in AI infrastructure is a security risk regardless of how the infrastructure is managed.
- **Automate what you can.** Even without full IaC adoption, automate security controls: vulnerability scanning, compliance checks, access reviews, and secret rotation.

For teams ready to adopt infrastructure as code, see [Infrastructure as Code](infrastructure-as-code.md).

!!! info "References"
    - [OWASP Top 10](https://owasp.org/www-project-top-10/)
    - [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
    - [OWASP Top 10 for LLM Applications](https://genai.owasp.org/)
    - [MCP Specification](https://modelcontextprotocol.io/)
    - [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
    - [AI Runtime Security](https://airuntimesecurity.io/)
