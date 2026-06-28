---
description: AI Secured by Design, the reference library for architects who design and review secured agentic AI systems. Architecture diagrams, how-tos, quick references, and threat-to-control mappings, so you can answer hard security questions fast.
hide:
  - title
  - navigation
  - toc
---

<section class="hub-hero" markdown>

<p class="hub-eyebrow">REFERENCE LIBRARY · AGENTIC AI SECURITY</p>

<h1 class="hub-h1">Architect agentic AI that's secure by design.</h1>

<p class="hub-lede">Diagrams, how-tos, quick references, and threat-to-control mappings for the people who design and review agentic systems, so you can answer hard questions fast.</p>

<div class="hub-search" data-hub-search>
  <div class="hub-search__bar">
    <span class="hub-search__icon" aria-hidden="true"></span>
    <input
      type="text"
      class="hub-search__input"
      role="combobox"
      aria-expanded="false"
      aria-controls="hub-search-results"
      aria-autocomplete="list"
      aria-label="Search controls, diagrams, how-tos"
      placeholder="Search controls, diagrams, how-tos, e.g. &quot;prompt injection&quot;"
      autocomplete="off"
    />
    <kbd class="hub-search__kbd">/</kbd>
  </div>
  <div class="hub-search__panel" id="hub-search-results" role="listbox" hidden></div>
</div>

<div class="hub-chips">
  <a class="hub-chip" href="#hub-library">Architecture diagrams</a>
  <a class="hub-chip" href="#hub-library">Step-by-step how-tos</a>
  <a class="hub-chip" href="#hub-library">Quick reference</a>
  <a class="hub-chip" href="#hub-threats">Threat to control map</a>
</div>

</section>

<section id="hub-library" class="hub-cards">

<a class="hub-card" href="threat-modelling/">
  <div class="hub-card__top">
    <span class="hub-card__icon hub-card__icon--grid" aria-hidden="true"><span></span><span></span><span></span><span></span></span>
    <span class="hub-card__count">trust boundaries</span>
  </div>
  <h3 class="hub-card__title">Architecture &amp; Diagrams</h3>
  <p class="hub-card__desc">Reference architectures and trust-boundary patterns for agents, tools, and data.</p>
  <span class="hub-card__links">
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> The agentic trust boundary</span>
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Agentic AI controls</span>
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Multi-agent systems</span>
  </span>
</a>

<a class="hub-card" href="how-to/">
  <div class="hub-card__top">
    <span class="hub-card__icon hub-card__icon--steps" aria-hidden="true"><span></span><span></span><span></span></span>
    <span class="hub-card__count">step by step</span>
  </div>
  <h3 class="hub-card__title">How-To Guides</h3>
  <p class="hub-card__desc">Step-by-step procedures to secure a capability end to end, with reviewable acceptance criteria.</p>
  <span class="hub-card__links">
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Should you use AI?</span>
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Worked examples by risk tier</span>
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Selecting guardrails</span>
  </span>
</a>

<a class="hub-card" href="core/checklist/">
  <div class="hub-card__top">
    <span class="hub-card__icon hub-card__icon--lines" aria-hidden="true"><span></span><span></span><span></span><span></span></span>
    <span class="hub-card__count">checklists</span>
  </div>
  <h3 class="hub-card__title">Quick Reference</h3>
  <p class="hub-card__desc">Cheat sheets and checklists you can scan in seconds during a design review.</p>
  <span class="hub-card__links">
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Implementation checklist</span>
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Production readiness gates</span>
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Standards mappings</span>
  </span>
</a>

<a class="hub-card" href="infrastructure/mappings/owasp-llm-top10/">
  <div class="hub-card__top">
    <span class="hub-card__icon hub-card__icon--diamond" aria-hidden="true"><span></span></span>
    <span class="hub-card__count">threat &rarr; control</span>
  </div>
  <h3 class="hub-card__title">Threat &amp; Control Mappings</h3>
  <p class="hub-card__desc">Map agentic threats to concrete, reviewable controls, and where to enforce them.</p>
  <span class="hub-card__links">
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Prompt injection</span>
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Excessive agency</span>
    <span class="hub-card__link"><span class="hub-arrow">&rarr;</span> Sensitive data exposure</span>
  </span>
</a>

</section>

<section class="hub-arch">
  <div class="hub-arch__head">
    <div>
      <p class="hub-eyebrow">REFERENCE ARCHITECTURE</p>
      <h2 class="hub-h2">The agentic trust boundary</h2>
      <p class="hub-arch__intro">Everything untrusted must cross a control plane before it reaches your models, memory, and enterprise systems. Use this as a checklist when reviewing a design.</p>
    </div>
    <a class="hub-arch__cta" href="threat-modelling/">Open full diagram &rarr;</a>
  </div>

  <div class="hub-zones">
    <div class="hub-zone hub-zone--untrusted">
      <p class="hub-zone__label">UNTRUSTED</p>
      <div class="hub-zone__items">
        <div class="hub-node"><span class="hub-node__title">End users &amp; prompts</span><span class="hub-node__meta">untrusted input</span></div>
        <div class="hub-node"><span class="hub-node__title">External tools &amp; web</span><span class="hub-node__meta">indirect injection</span></div>
        <div class="hub-node"><span class="hub-node__title">Third-party data</span><span class="hub-node__meta">poisoning risk</span></div>
      </div>
    </div>

    <div class="hub-zone__arrow" aria-hidden="true">&rarr;</div>

    <div class="hub-zone hub-zone--control">
      <p class="hub-zone__label">SECURITY CONTROL PLANE</p>
      <div class="hub-zone__grid">
        <div class="hub-node"><span class="hub-node__title">Input validation</span></div>
        <div class="hub-node"><span class="hub-node__title">Policy &amp; guardrails</span></div>
        <div class="hub-node"><span class="hub-node__title">AuthZ &amp; tool scopes</span></div>
        <div class="hub-node"><span class="hub-node__title">Output filtering</span></div>
        <div class="hub-node hub-node--wide"><span class="hub-node__title">Observability &amp; audit logging</span></div>
      </div>
    </div>

    <div class="hub-zone__arrow" aria-hidden="true">&rarr;</div>

    <div class="hub-zone hub-zone--trusted">
      <p class="hub-zone__label">TRUSTED</p>
      <div class="hub-zone__items">
        <div class="hub-node"><span class="hub-node__title">Agent orchestrator</span><span class="hub-node__meta">planner · memory</span></div>
        <div class="hub-node"><span class="hub-node__title">Model / LLM</span><span class="hub-node__meta">inference</span></div>
        <div class="hub-node"><span class="hub-node__title">Memory &amp; vector store</span><span class="hub-node__meta">least privilege</span></div>
        <div class="hub-node"><span class="hub-node__title">Enterprise APIs</span><span class="hub-node__meta">scoped access</span></div>
      </div>
    </div>
  </div>
</section>

<section class="hub-questions">
  <p class="hub-eyebrow">START HERE</p>
  <h2 class="hub-h2">Answer the question you actually have</h2>
  <div class="hub-q-grid">
    <a class="hub-q" href="getting-started/production-readiness/"><span class="hub-q__tag">Q.</span><span class="hub-q__text">Is this design actually secured?</span><span class="hub-arrow hub-arrow--muted">&rarr;</span></a>
    <a class="hub-q" href="infrastructure/agentic/tool-access-controls/"><span class="hub-q__tag">Q.</span><span class="hub-q__text">Where do I enforce tool permissions?</span><span class="hub-arrow hub-arrow--muted">&rarr;</span></a>
    <a class="hub-q" href="how-to/selecting-guardrails/"><span class="hub-q__tag">Q.</span><span class="hub-q__text">How do I contain prompt injection?</span><span class="hub-arrow hub-arrow--muted">&rarr;</span></a>
    <a class="hub-q" href="infrastructure/controls/data-protection/"><span class="hub-q__tag">Q.</span><span class="hub-q__text">What stops an agent exfiltrating data?</span><span class="hub-arrow hub-arrow--muted">&rarr;</span></a>
    <a class="hub-q" href="core/checklist/"><span class="hub-q__tag">Q.</span><span class="hub-q__text">Which controls are mandatory vs. recommended?</span><span class="hub-arrow hub-arrow--muted">&rarr;</span></a>
    <a class="hub-q" href="core/multi-agent-controls/"><span class="hub-q__tag">Q.</span><span class="hub-q__text">How do I review a multi-agent system?</span><span class="hub-arrow hub-arrow--muted">&rarr;</span></a>
  </div>
</section>

<section id="hub-threats" class="hub-matrix-wrap">
  <p class="hub-eyebrow">THREAT &rarr; CONTROL</p>
  <h2 class="hub-h2">Map the threat to a control you can review</h2>
  <div class="hub-matrix">
    <div class="hub-matrix__head">
      <span>THREAT</span><span>PRIMARY CONTROL</span><span>ENFORCE AT</span>
    </div>
    <a class="hub-matrix__row" href="infrastructure/mappings/owasp-llm-top10/">
      <span class="hub-matrix__threat">Prompt injection</span>
      <span class="hub-matrix__control">Input and content filtering, instruction isolation, untrusted-content tagging</span>
      <span class="hub-matrix__where">Control plane</span>
    </a>
    <a class="hub-matrix__row" href="core/agentic/">
      <span class="hub-matrix__threat">Excessive agency</span>
      <span class="hub-matrix__control">Scoped tool permissions, allow-lists, human-in-the-loop approval</span>
      <span class="hub-matrix__where">Orchestrator</span>
    </a>
    <a class="hub-matrix__row" href="infrastructure/controls/data-protection/">
      <span class="hub-matrix__threat">Sensitive data exposure</span>
      <span class="hub-matrix__control">Output filtering, DLP, least-privilege data access</span>
      <span class="hub-matrix__where">Egress</span>
    </a>
    <a class="hub-matrix__row" href="infrastructure/agentic/sandbox-patterns/">
      <span class="hub-matrix__threat">Insecure tool use</span>
      <span class="hub-matrix__control">Sandboxing, signed tool manifests, parameter validation</span>
      <span class="hub-matrix__where">Tool gateway</span>
    </a>
    <a class="hub-matrix__row" href="building/model-selection/provenance-and-integrity/">
      <span class="hub-matrix__threat">Supply chain</span>
      <span class="hub-matrix__control">Pinned models and deps, provenance attestation, integrity checks</span>
      <span class="hub-matrix__where">Build / runtime</span>
    </a>
  </div>
</section>

<section class="hub-related">
  <a class="hub-related__card" href="https://airuntimesecurity.io/">
    <span class="hub-related__tag">RELATED</span>
    <span class="hub-related__body">
      <span class="hub-related__title">Securing AI at runtime, not just at design time?</span>
      <span class="hub-related__desc">airuntimesecurity.io, the runtime security framework this library pairs with.</span>
    </span>
    <span class="hub-related__visit">Visit &nearr;</span>
  </a>
</section>
