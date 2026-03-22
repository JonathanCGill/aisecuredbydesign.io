---
description: Verifying model provenance and integrity, ensuring AI models are authentic, unmodified, and traceable to their source.
---

# Provenance and Integrity

Model provenance answers the question: where did this model come from, and can you prove it? Integrity answers: has it been modified since it left its source?

These are not optional checks. A model with unverified provenance is untrusted code running in your environment. A model with unverified integrity may have been tampered with in transit or at rest.

## Why provenance matters

Models are not compiled from source code you can read. You cannot open a model file and understand what it does by inspection. This makes provenance, the chain of custody from training to deployment, the primary way to establish trust.

Without provenance verification, you cannot distinguish between:

- A legitimate model from a trusted provider
- A modified version with an injected backdoor
- A completely different model with the same filename
- A model trained on data you would never approve

## Provenance verification checklist

### Source verification

- [ ] **Identify the original publisher.** Who trained this model? Is the publisher a known, reputable organisation?
- [ ] **Verify the download source.** Did you download from the official source, or a mirror? Mirrors can serve modified files.
- [ ] **Check the model card.** Does a model card exist? Does it document training data, intended use, limitations, and known biases?
- [ ] **Confirm licensing.** Is the model licence compatible with your use case? Some licences restrict commercial use or specific applications.

### Integrity verification

- [ ] **Hash verification.** Compare cryptographic hashes (SHA-256 minimum) against publisher-provided values. Automate this in your pipeline.
- [ ] **Signature verification.** Where available, verify digital signatures. Projects like Sigstore for ML are making this practical for model artefacts.
- [ ] **Model Bill of Materials (ML-BOM).** Does the model come with or can you generate a bill of materials documenting its components, dependencies, and training lineage?

### Ongoing integrity

- [ ] **Storage integrity.** Models at rest should be protected against unauthorised modification. Use checksums and access controls on model storage.
- [ ] **Transfer integrity.** Models in transit (download, deployment, replication) should be verified at each stage.
- [ ] **Version pinning.** Pin specific model versions in your pipeline. Never pull "latest" in production. A model update is a change that requires assessment.

## Model cards

A model card is the minimum documentation a model should have before you consider using it. The absence of a model card is a red flag, not a minor oversight.

A useful model card includes:

| Section | What to look for |
|---------|-----------------|
| **Model details** | Architecture, parameters, training framework, version |
| **Intended use** | What the model was designed for, and what it was not |
| **Training data** | Data sources, size, known biases, geographic and demographic coverage |
| **Evaluation** | Benchmarks, metrics, known failure modes |
| **Limitations** | What the model cannot do, known weaknesses, adversarial robustness |
| **Ethical considerations** | Bias analysis, potential for harm, mitigations applied |

!!! tip "No model card? No deployment."
    If a model lacks adequate documentation, either create your own through evaluation and testing, or choose a different model. Deploying an undocumented model is deploying an unknown risk.

## Serialisation format risks

The format a model is stored in can itself be a vulnerability.

**Pickle files** (`.pkl`, `.pt`, `.pth`) can execute arbitrary Python code when loaded. Loading an untrusted pickle file is equivalent to running `eval()` on attacker-controlled input. This is not a theoretical risk; it has been exploited in the wild.

**SafeTensors** (`.safetensors`) is a format designed to be safe to load. It stores only tensor data, no executable code. Prefer SafeTensors where available.

**ONNX** (`.onnx`) is an interchange format that is generally safe but can reference external data files. Verify all referenced files.

| Format | Risk level | Recommendation |
|--------|-----------|----------------|
| Pickle (`.pkl`, `.pt`) | **High**: arbitrary code execution | Avoid for untrusted models. Scan before loading. |
| SafeTensors | **Low**: data only, no code execution | Preferred format for model distribution |
| ONNX | **Medium**: safe format, but verify external refs | Acceptable with verification |
| GGUF/GGML | **Low**: data format for quantised models | Acceptable for inference-only use |

## Building provenance into your pipeline

Provenance verification should not be a manual step. Build it into your model ingestion pipeline:

1. **Download from verified sources only.** Maintain an allow-list of approved model sources.
2. **Verify hashes automatically.** Your pipeline should fail if hash verification fails.
3. **Scan serialisation format.** Reject pickle files from untrusted sources. Prefer SafeTensors.
4. **Store verification results.** Log provenance checks as artefacts alongside the model.
5. **Register in your model registry.** Only models that pass provenance checks enter your internal registry.

!!! info "References"
    - [Model Cards for Model Reporting, Mitchell et al.](https://arxiv.org/abs/1810.03993)
    - [Hugging Face SafeTensors](https://huggingface.co/docs/safetensors/)
    - [Sigstore](https://www.sigstore.dev/)
    - [MITRE ATLAS: ML Supply Chain Compromise](https://atlas.mitre.org/techniques/AML.T0010)
