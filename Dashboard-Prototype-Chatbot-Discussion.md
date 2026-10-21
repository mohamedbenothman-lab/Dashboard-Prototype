# Dashboard Prototype — Chatbot and Fine-Tuning Discussion

**Date:** 2026-10-21

## Project context

The project is located at:

`C:\Users\moham\Desktop\Dashboard-Prototype`

The prototype is a Python Streamlit dashboard using SQLite, Pandas, NumPy, and Altair. It already includes project data, deadlines, material availability, open tasks, a rule-based risk score, risk levels, and recommendations.

## Main recommendation

Do not train a language model from scratch. Use a hybrid architecture:

1. Use a pre-trained local language model through Ollama.
2. Keep the risk calculation as a separate analytical component.
3. Retrieve current project data from SQLite.
4. Let Ollama generate summaries, explanations, and suggestions from verified data.
5. Fine-tune later only to teach the model company-specific language, report style, and workflows.

## Recommended architecture

```text
SQLite / ERP / CSV data
          |
          v
Risk model + business rules
          |
          v
Current verified project context
          |
          v
Ollama running the language model
          |
          v
Management summary, report, explanation, suggestions
```

## Responsibilities of each component

### SQLite and company systems

Provide current facts:

- Project status
- Deadlines
- Material availability
- Open tasks
- Responsible employees
- Supplier information
- Historical project information

### Risk model and business rules

Calculate:

- Risk score
- Delay probability
- Expected delay days
- Main risk factors
- Project priority
- Cost and ROI values
- Team capacity
- Deadline calculations

The current rule-based risk score is a suitable transparent baseline. Later, historical project data could be used to train Logistic Regression, Random Forest, XGBoost, or LightGBM.

### Ollama

Ollama runs the language model locally. It can generate:

- Daily management briefings
- Weekly reports
- Individual project summaries
- Risk explanations
- Suggested next actions
- Supplier escalation drafts
- Answers to questions such as “Which projects need attention today?”

### Fine-tuning

Fine-tuning should teach:

- Company terminology
- German business language
- Preferred report structure
- How risks should be explained
- How recommendations should be phrased
- Which information should be shown to management
- Which actions require human confirmation

Fine-tuning should not be used to store current project statuses. If a project deadline changes, update SQLite rather than fine-tuning the model.

## One model or several models?

For the first version, use one language model with different controlled report functions:

```python
generate_daily_summary(data)
generate_project_summary(project)
generate_risk_explanation(project)
generate_weekly_report(data)
generate_supplier_email(project)
```

Use separate traditional models or programmed logic for analytical tasks:

```text
Risk prediction        -> XGBoost / Logistic Regression
Delay prediction      -> Machine-learning model
Cost calculation       -> Python formulas
Text generation        -> Ollama LLM
```

## Database-grounded chatbot flow

When a user asks which projects are risky, the application should query SQLite and calculate the current risk results first. It should then send structured, verified context to Ollama:

```json
{
  "project": "BV Regensburg Altstadt",
  "deadline": "2026-11-05",
  "days_remaining": 15,
  "material_available": false,
  "open_tasks": 3,
  "risk_score": 78,
  "risk_level": "High",
  "risk_reasons": [
    "Material is not confirmed",
    "Three tasks remain open"
  ],
  "recommended_action": "Escalate the supplier and confirm a new delivery date"
}
```

The language model should explain the verified data instead of inventing project facts or freely calculating risk percentages.

## Suggested response format

```text
Risk level: High — 78%

Why:
- Material is not confirmed
- Deadline is approaching
- Three tasks remain open

Recommended actions:
1. Contact the supplier today.
2. Confirm the delivery date in writing.
3. Prepare an alternative installation date.

Expected benefit:
This may prevent an unused installation team and reduce the risk of customer delay.

Source:
Project data updated: 21.10.2026
```

The system should clearly distinguish between:

- Facts from the database
- Calculated risk indicators
- AI-generated suggestions
- Assumptions or missing information

Important decisions should require confirmation by the responsible project manager.

## Fine-tuning process

Fine-tuning does not need to run every day. It can be performed initially and repeated only when enough new examples exist or the company’s reporting style changes.

Example training data:

```json
{
  "input": {
    "risk_score": 82,
    "risk_reasons": [
      "Material not confirmed",
      "Deadline in 4 days",
      "Three open tasks"
    ]
  },
  "expected_output": {
    "summary": "The project is at high risk...",
    "actions": [
      "Escalate the supplier today",
      "Confirm the delivery date",
      "Prepare an alternative installation date"
    ]
  }
}
```

Recommended process:

```text
Base model
    -> LoRA/QLoRA fine-tuning
    -> fine-tuned adapter
    -> compatible Ollama model
    -> Ollama + current database context
```

Start without fine-tuning:

```text
Ollama + SQLite + controlled prompts
```

Then collect employee-approved summaries and corrections. Once there are enough high-quality examples, use LoRA/QLoRA fine-tuning to improve the company-specific style.

## Hardware guidance

For QLoRA fine-tuning:

- Minimum practical setup for a 3B–4B model: 6–8 GB NVIDIA VRAM and 16 GB system RAM.
- Minimum practical setup for a 7B–8B model: 12 GB NVIDIA VRAM and 32 GB system RAM.
- Comfortable setup for a 7B–8B model: 16–24 GB VRAM and 32–64 GB system RAM.
- Recommended local setup: RTX 3060 12 GB or better, 32 GB RAM, and approximately 100 GB free SSD space.
- Full fine-tuning is not recommended for this project.
- CPU-only fine-tuning is technically possible but generally too slow.

## Kaggle TPU

Kaggle TPU may be usable for some training workflows, but it is not the easiest option for Ollama/QLoRA. Ollama and many quantized fine-tuning workflows are primarily designed around NVIDIA CUDA GPUs. A Kaggle NVIDIA GPU session is usually simpler for this purpose.

TPUs require TPU-compatible frameworks such as PyTorch/XLA or JAX, and the resulting model or adapter may still need conversion before it can be used with Ollama.

## Final architecture for Hanshans

| Component | Responsibility |
|---|---|
| SQLite / ERP | Current project facts |
| Python rules | Transparent initial risk score |
| ML model later | Delay and risk prediction |
| RAG / document retrieval | Company procedures and knowledge |
| Ollama | Local chatbot and report generation |
| Fine-tuning | Company-specific language and report style |
| Streamlit | Dashboard and chatbot interface |
| Human approval | Final operational, customer, and supplier decisions |

The key principle is:

> The risk model calculates what is dangerous. The database provides what is happening now. Fine-tuning teaches the model how Hanshans communicates. Ollama writes the summary and recommendations.

