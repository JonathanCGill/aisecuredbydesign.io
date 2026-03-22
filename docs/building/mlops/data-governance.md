---
description: Data governance for MLOps, covering data lineage, versioning, classification, quality controls, and regulatory compliance for machine learning workflows.
---

# Data Governance for MLOps

Every model is a product of its data. If you do not govern the data flowing through your ML pipeline, you cannot trust the models that come out of it. Data governance for MLOps goes beyond traditional data governance. It must account for the unique ways ML systems consume, transform, and depend on data across training, evaluation, and production.

## Why ML data governance is different

Traditional data governance focuses on storage, access, and retention. ML data governance adds several dimensions that traditional frameworks were not designed for.

| Traditional concern | ML-specific extension |
|--------------------|----------------------|
| **Who can access data?** | Who can use data *for training*? Access and training rights are not the same |
| **Where is data stored?** | Where was data stored *when the model was trained*? The data may have changed since |
| **Is data accurate?** | Is data accurate *enough to train on*? Statistical quality, not just correctness |
| **Data retention** | Model retention depends on data retention: retiring data may require retiring models |
| **Compliance** | Training on personal data creates new obligations (right to erasure affects trained models) |

## Data lineage

Data lineage tracks the origin, movement, and transformation of data throughout the ML pipeline. It answers: where did this data come from, what happened to it, and which models were trained on it?

### What to track

| Lineage element | Why it matters |
|----------------|----------------|
| **Source** | Where the data originated (database, API, vendor, scrape, synthetic generator) |
| **Collection timestamp** | When the data was acquired, critical for detecting temporal poisoning |
| **Transformations** | Every preprocessing step: cleaning, normalisation, augmentation, feature engineering |
| **Schema** | Column names, types, and constraints at each stage |
| **Who modified it** | Human edits, automated pipelines, or third-party processing |
| **Which models used it** | Forward traceability from data to every model trained on it |

### Implementing lineage tracking

Lineage tracking does not require a dedicated platform on day one. Start with what you can implement now.

**Minimum viable lineage:**

- [ ] Hash every dataset version used for training
- [ ] Record the dataset hash in the training attestation (see [Secure ML Pipelines](secure-ml-pipelines.md))
- [ ] Store a manifest listing data sources, collection dates, and row counts
- [ ] Log all transformations applied to the data before training

**Mature lineage:**

- [ ] Use a data versioning tool (DVC, LakeFS, Pachyderm) to version datasets alongside code
- [ ] Automate lineage capture in your pipeline orchestrator
- [ ] Build forward and backward traceability: from any model, find its data; from any data, find all models
- [ ] Integrate lineage with your model registry so every registered model links to its exact training data

!!! tip "Lineage is a security control"
    When a production model behaves unexpectedly, lineage is how you investigate. Without it, incident response becomes guesswork. Lineage also enables targeted remediation: if a data source is compromised, you can identify every model that was trained on it.

## Data versioning

Data changes over time. Models trained on different versions of the same dataset can behave differently. Without versioning, you lose reproducibility and auditability.

### Versioning approaches

| Approach | Trade-offs |
|----------|-----------|
| **File-based (DVC)** | Versions data files alongside code in Git. Lightweight. Requires discipline in tagging |
| **Snapshot-based (LakeFS)** | Git-like branching for data lakes. Good for large datasets. Adds infrastructure |
| **Pipeline-integrated (Pachyderm)** | Versioning built into the pipeline. Automatic. Platform-dependent |
| **Manual hashing** | Compute and store hashes of datasets. Minimal tooling. No rollback capability |

Whichever approach you choose, the principle is the same: every training run must reference a specific, immutable version of its data, and that version must be retrievable.

## Data classification for ML

Not all data is equally sensitive, and not all data is suitable for training. Data classification for ML adds training-specific considerations to your existing classification scheme.

### Classification dimensions

**Sensitivity:**

- **Public:** Open datasets, published benchmarks. Low risk, but verify provenance
- **Internal:** Organisation-specific data without personal or regulated content
- **Confidential:** Contains personal data, trade secrets, or regulated content
- **Restricted:** Highly regulated data (health records, financial data, classified information)

**Training suitability:**

- **Approved for training:** Data has been reviewed and cleared for use in ML training
- **Approved with conditions:** Can be used for training only with specific controls (anonymisation, aggregation, geographic restrictions)
- **Not approved for training:** Data exists in the organisation but must not be used for training (legal restrictions, licensing, consent limitations)

!!! warning "Access does not equal training rights"
    A data analyst may have access to customer data for reporting purposes. That does not mean the same data can be used to train a model. Training creates a derivative work that embeds information from the data in the model's weights. Separate authorisation for training use is essential.

### Practical classification checklist

- [ ] Does the data contain personal information (PII, PHI)?
- [ ] What licences or terms of service apply to the data?
- [ ] Was consent obtained for ML training use specifically?
- [ ] Does the data cross jurisdictional boundaries (GDPR, POPIA, CCPA)?
- [ ] Is the data from a trusted, verified source?
- [ ] Has the data been reviewed for bias or representational issues?
- [ ] Is there a retention policy that affects how long models trained on this data can remain in use?

## Data quality for ML

Data quality in ML is statistical, not just structural. A dataset can be perfectly formatted and still produce a harmful model if it contains bias, is unrepresentative, or has been subtly poisoned.

### Quality dimensions

| Dimension | What to check |
|-----------|--------------|
| **Completeness** | Missing values, gaps in coverage, underrepresented categories |
| **Consistency** | Contradictory labels, conflicting records, schema drift between versions |
| **Accuracy** | Label correctness, measurement precision, source reliability |
| **Timeliness** | Data age relative to the prediction task, temporal distribution |
| **Distribution** | Class balance, feature distributions, outlier presence |
| **Provenance** | Source trustworthiness, collection methodology, chain of custody |

### Automated quality gates

Build data quality checks into your pipeline, not as a manual review step.

```python
# Example: basic data quality gate before training
def validate_training_data(df, config):
    """Run before training begins. Fail the pipeline if data quality is below threshold."""
    checks = {
        "null_rate": df.isnull().mean().max() < config.max_null_rate,
        "min_rows": len(df) >= config.min_training_rows,
        "label_balance": df[config.label_col].value_counts(normalize=True).min() > config.min_class_ratio,
        "schema_match": set(df.columns) == set(config.expected_columns),
    }
    failed = [name for name, passed in checks.items() if not passed]
    if failed:
        raise DataQualityError(f"Data quality checks failed: {failed}")
```

## Regulatory considerations

ML training creates new regulatory obligations that traditional data governance may not cover.

### Right to erasure and model retention

Under GDPR and similar regulations, individuals can request deletion of their personal data. If that data was used to train a model, the model may retain information derived from the deleted data in its weights. This creates a tension between data deletion obligations and model retention.

**Practical approaches:**

- Track which datasets contain personal data and which models were trained on them
- When data is deleted, assess whether affected models need retraining
- For high-sensitivity models, consider differential privacy techniques during training to limit memorisation
- Document your approach and the rationale for your retention decisions

### Cross-border data flows

Training data may originate from multiple jurisdictions. The model itself may be deployed across borders. Data governance must account for:

- Where training data is stored and processed
- Whether data transfer agreements are in place
- Whether the model's deployment locations are consistent with data origin restrictions
- Local regulations on AI training (the EU AI Act imposes specific obligations on training data documentation)

### Training data documentation

Regulatory frameworks increasingly require documentation of training data. Model cards and datasheets provide structured formats for this.

**What to document:**

- Data sources and their provenance
- Collection methodology and timeframe
- Preprocessing and filtering steps applied
- Known limitations, biases, or gaps in the data
- Licence and consent information
- PII handling and anonymisation methods used

!!! abstract "The EU AI Act and training data"
    The EU AI Act requires providers of high-risk AI systems to document their training data, including data governance measures, data preparation steps, and any assumptions about the data. Organisations operating in or serving EU markets should treat training data documentation as a compliance requirement, not optional good practice.

## Connecting data governance to MLOps

Data governance is not a separate activity. It integrates directly into the ML pipeline.

| Pipeline stage | Data governance control |
|---------------|----------------------|
| **Data collection** | Source approval, provenance recording, classification |
| **Data preparation** | Transformation logging, quality validation, bias assessment |
| **Training** | Dataset versioning, lineage linking, access control enforcement |
| **Evaluation** | Test data independence, evaluation data governance |
| **Registration** | Training data metadata stored with model, data lineage linked |
| **Monitoring** | Input data drift detection, data quality monitoring in production |

The model registry should link every model to its training data version. The experiment tracker should record which data was used for each experiment. The pipeline orchestrator should enforce data quality gates before training begins. When these connections exist, data governance becomes auditable, traceable, and enforceable rather than aspirational.

!!! info "References"
    - [AWS: Governing the ML Lifecycle at Scale](https://aws.amazon.com/blogs/machine-learning/governing-the-ml-lifecycle-at-scale-part-4-scaling-mlops-with-security-and-governance-controls/)
    - [Databricks: What is MLOps](https://www.databricks.com/glossary/mlops)
    - [OpenSSF MLSecOps Whitepaper](https://openssf.org/blog/2025/08/05/visualizing-secure-mlops-mlsecops-a-practical-guide-for-building-robust-ai-ml-pipeline-security/)
    - [EU AI Act: Training Data Requirements](https://artificialintelligenceact.eu/)
    - [DVC: Data Version Control](https://dvc.org/)
    - [LakeFS: Data Versioning for ML](https://lakefs.io/)
    - [Google: MLOps Continuous Delivery](https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning)
