/* Homepage hub search: instant client-side filter over a seed index.
   Keyboard: "/" focuses, Esc clears, ArrowUp/Down + Enter navigate.
   Scoped to the homepage; no-ops when the hero search is absent. */
(function () {
  "use strict";

  // Seed index. Every href points to a real page on this site.
  var INDEX = [
    { title: "The agentic trust boundary", type: "DIAGRAM", tag: "trust boundary", href: "/threat-modelling/" },
    { title: "Agentic AI controls", type: "CONTROL", tag: "agency", href: "/core/agentic/" },
    { title: "Multi-agent controls", type: "CONTROL", tag: "multi-agent", href: "/core/multi-agent-controls/" },
    { title: "Three-layer controls", type: "CONTROL", tag: "guardrails", href: "/core/controls/" },
    { title: "Tool access controls", type: "CONTROL", tag: "tool scope", href: "/infrastructure/agentic/tool-access-controls/" },
    { title: "Sandbox patterns", type: "DIAGRAM", tag: "sandbox", href: "/infrastructure/agentic/sandbox-patterns/" },
    { title: "Delegation chains", type: "CONTROL", tag: "delegation", href: "/infrastructure/agentic/delegation-chains/" },
    { title: "Supply chain & provenance", type: "THREAT", tag: "supply chain", href: "/infrastructure/agentic/supply-chain/" },
    { title: "Should you use AI?", type: "HOW-TO", tag: "decision", href: "/how-to/should-you-use-ai/" },
    { title: "Selecting guardrails", type: "HOW-TO", tag: "prompt injection", href: "/how-to/selecting-guardrails/" },
    { title: "Scaling and PACE", type: "HOW-TO", tag: "resilience", href: "/how-to/scaling-and-pace/" },
    { title: "Worked example: customer service", type: "HOW-TO", tag: "worked example", href: "/how-to/worked-example/" },
    { title: "Worked example: MCP agent", type: "HOW-TO", tag: "mcp", href: "/how-to/example-mcp-agent/" },
    { title: "Implementation checklist", type: "REFERENCE", tag: "checklist", href: "/core/checklist/" },
    { title: "Production readiness", type: "REFERENCE", tag: "checklist", href: "/getting-started/production-readiness/" },
    { title: "Risk tiers", type: "REFERENCE", tag: "risk", href: "/core/risk-tiers/" },
    { title: "Risk classification", type: "REFERENCE", tag: "risk", href: "/getting-started/risk-classification/" },
    { title: "OWASP LLM Top 10 mapping", type: "THREAT", tag: "owasp llm01", href: "/infrastructure/mappings/owasp-llm-top10/" },
    { title: "Threat modelling", type: "THREAT", tag: "prompt injection", href: "/threat-modelling/" },
    { title: "Sensitive data exposure", type: "THREAT", tag: "exfiltration", href: "/infrastructure/controls/data-protection/" },
    { title: "Identity and access", type: "CONTROL", tag: "iam", href: "/infrastructure/controls/identity-and-access/" },
    { title: "Secrets and credentials", type: "CONTROL", tag: "secrets", href: "/infrastructure/controls/secrets-and-credentials/" },
    { title: "Logging and observability", type: "CONTROL", tag: "audit", href: "/infrastructure/controls/logging-and-observability/" },
    { title: "Model selection", type: "REFERENCE", tag: "model", href: "/building/model-selection/" },
    { title: "Adversarial testing", type: "HOW-TO", tag: "red team", href: "/getting-started/adversarial-testing/" }
  ];

  var MAX = 7;

  function esc(s) {
    return String(s).replace(/[&<>"]/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c];
    });
  }

  function init() {
    var root = document.querySelector("[data-hub-search]");
    if (!root) return;

    var input = root.querySelector(".hub-search__input");
    var panel = root.querySelector(".hub-search__panel");
    if (!input || !panel) return;

    var current = [];
    var active = -1;

    function close() {
      panel.hidden = true;
      panel.innerHTML = "";
      input.setAttribute("aria-expanded", "false");
      active = -1;
      current = [];
    }

    function render(results) {
      current = results;
      active = -1;
      if (!input.value.trim()) {
        close();
        return;
      }
      if (!results.length) {
        panel.innerHTML =
          '<div class="hub-search__empty">No matches. Try ' +
          "<code>excessive agency</code>, <code>tool scope</code>, or <code>sandbox</code>.</div>";
        panel.hidden = false;
        input.setAttribute("aria-expanded", "true");
        return;
      }
      panel.innerHTML = results
        .map(function (r, i) {
          return (
            '<a class="hub-result" role="option" id="hub-opt-' + i + '" href="' + r.href + '">' +
            '<span class="hub-result__type">' + esc(r.type) + "</span>" +
            '<span class="hub-result__title">' + esc(r.title) + "</span>" +
            '<span class="hub-result__tag">' + esc(r.tag) + "</span>" +
            "</a>"
          );
        })
        .join("");
      panel.hidden = false;
      input.setAttribute("aria-expanded", "true");
    }

    function search(q) {
      q = q.trim().toLowerCase();
      if (!q) return [];
      return INDEX.filter(function (r) {
        return (r.title + " " + r.tag + " " + r.type).toLowerCase().indexOf(q) !== -1;
      }).slice(0, MAX);
    }

    function setActive(next) {
      var opts = panel.querySelectorAll(".hub-result");
      if (!opts.length) return;
      if (active >= 0 && opts[active]) opts[active].classList.remove("is-active");
      active = (next + opts.length) % opts.length;
      opts[active].classList.add("is-active");
      input.setAttribute("aria-activedescendant", "hub-opt-" + active);
      opts[active].scrollIntoView({ block: "nearest" });
    }

    input.addEventListener("input", function () {
      render(search(input.value));
    });

    input.addEventListener("keydown", function (e) {
      if (e.key === "Escape") {
        input.value = "";
        close();
        input.blur();
        return;
      }
      if (panel.hidden) return;
      if (e.key === "ArrowDown") {
        e.preventDefault();
        setActive(active + 1);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setActive(active - 1);
      } else if (e.key === "Enter") {
        if (active >= 0 && current[active]) {
          e.preventDefault();
          window.location.href = current[active].href;
        }
      }
    });

    // "/" focuses the hub search when not already typing somewhere
    document.addEventListener("keydown", function (e) {
      if (e.key !== "/" || e.ctrlKey || e.metaKey || e.altKey) return;
      var t = e.target;
      var tag = t && t.tagName ? t.tagName.toLowerCase() : "";
      if (tag === "input" || tag === "textarea" || (t && t.isContentEditable)) return;
      e.preventDefault();
      input.focus();
    });

    document.addEventListener("click", function (e) {
      if (!root.contains(e.target)) close();
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
