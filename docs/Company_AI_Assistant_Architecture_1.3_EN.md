# Company AI Assistant

## Technical Architecture for Handwerkerhaus Hanshans

**[E] Version 1.3 – Approval Baseline Phase 0**

**[E] Document date:** 04.11.2026 · **Status:** Draft for approval

On-premises architecture for photo search, document knowledge, consultation and risk dashboard

> **[E]** The baseline is a verifiable approval template. Open decisions remain open; no technical or operational approval is claimed.

---

> **Translator's note (not part of the original document)**
>
> This is a complete English translation of the German source document
> *Company AI Assistant · Architektur 1.3 · Freigabe-Baseline Phase 0* (93 pages, dated 04.11.2026).
> All content is reproduced faithfully; nothing has been added, condensed or re-scoped.
>
> The status markers of the original are preserved unchanged:
>
> - **[P]** – project requirement (from the original architecture / project plan)
> - **[E]** – recommendation (technical implementation or proposal, not a confirmed company decision)
> - **[O]** – open (missing evidence, assumption, or pending decision)
> - **[P/O]**, **[P/E]** – mixed markers, as in the original
>
> Identifiers, field names, table names, endpoint names and code-like tokens are **not** translated, since they
> are technical contracts. German organisational terms are translated once and then used consistently
> (e.g. *Vorgang* → case, *Beleg* → voucher/record, *Anlass* → occasion).
>
> Figures in the original are black-and-white diagrams. These were extracted from the PDF as label sequences;
> in this translation each figure is reproduced as a structured list of its labels, followed by the original
> legend and caption lines. The figures themselves are not redrawn here.
>
> Appendix D ends with two machine-generated audit inventories (pp. 74–93 of the original): "All number
> occurrences" and "All status markers". These are raw extraction dumps whose context column consists of
> truncated German mid-sentence fragments. Their headers, purpose and structure are translated; the raw
> snippet rows are summarised rather than translated, because a fragment such as "ige lautet Datenstand
> unbekannt; der Importzeitpunkt wird separat genannt." cannot be meaningfully rendered without the sentence
> it was cut from. The full inventory remains available in the German original.

---

<div style="page-break-after: always;"></div>

## Document control

| Function | Responsibility / Name | Signature | Date | Version |
| --- | --- | --- | --- | --- |
| Author | **[O]** To be named | | | **[E]** 1.3 |
| Review / Approval | **[E]** IT | | | |
| Review / Approval | **[E]** Business department | | | |
| Review / Approval | **[E]** Data Protection Officer | | | |
| Involvement | **[E]** Works council: involved, where one exists | | | |

### Roles and responsible persons

| Name | Role |
| --- | --- |
| Mike | **[O]** To be confirmed (OP-19) |
| Jan | **[O]** To be confirmed (OP-19) |
| Tobias | **[O]** To be confirmed (OP-19) |
| Tanja | **[O]** To be confirmed (OP-19) |

### Change log

| Version / Date | Change status |
| --- | --- |
| 1.1 / 03.11.2026 | **[E]** Historical starting point according to v1.2; original not submitted. |
| 1.2 / 04.11.2026 | IN-FORM and stable IDs; provenance and data as-of date; sync/Excel; tasks, phases, permissions and ten pilot cases; shared infrastructure open. |
| 1.3 / 04.11.2026 | **[E]** Consistency corrections F1–F20; 18 black-and-white figures; unified contracts, registers and evidence. |

---

<div style="page-break-after: always;"></div>

## Table of contents

| Section | Content | Page |
| --- | --- | --- |
| 01 | Management overview | 7 |
| 02 | Content and reading guidance | 8 |
| 03 | Goals, requirements and boundaries | 8 |
| 04 | Overall architecture and system components | 9 |
| 05 | Data model, storage and references | 13 |
| 06 | Indexing and processing architecture | 21 |
| 07 | Photo search and visual classification | 25 |
| 08 | Document search, RAG and consultation | 27 |
| 09 | Risk analysis and dashboard | 31 |
| 10 | API and backend interfaces | 37 |
| 11 | Permissions, security and data protection | 38 |
| 12 | Deployment, operation and maintenance | 42 |
| 13 | Model strategy and hardware | 43 |
| 14 | Quality assurance and acceptance criteria | 44 |
| 15 | Implementation plan and priorities | 45 |
| 16 | Open architecture decisions | 48 |
| A | Technical appendix A.1–A.6 | 50 |
| B | IT checklist | 53 |
| C | Register of open items and traceability | 55 |
| D | Architecture decisions and conflict resolutions | 64 |

## List of figures

| Figure | Title | Chapter | Page |
| --- | --- | --- | --- |
| 1 | System context | 04 | 10 |
| 2 | Container view | 04 | 11 |
| 3 | ID chain | 05 | 17 |
| 4 | ER file and index model | 05 | 18 |
| 5 | ER project and provenance model | 05 | 19 |
| 6 | ER rules, suggestions and risks | 05 | 20 |
| 7 | Two ingestion tracks | 06 | 22 |
| 8 | ERP sync states | 06 | 23 |
| 9 | Photo search decision flow | 07 | 26 |
| 10 | RAG request path | 08 | 28 |
| 11 | Lifecycle of an AI suggestion | 08 | 30 |
| 12 | Risk detection | 09 | 32 |
| 13 | Seven phases | 09 | 35 |
| 14 | Lifecycles of risk and task candidate | 09 | 36 |
| 15 | Trust zones | 11 | 39 |
| 16 | Permission check | 11 | 40 |
| 17 | Roadmap with gates | 15 | 47 |
| 18 | Infrastructure options | 16 | 49 |

---

<div style="page-break-after: always;"></div>

## Glossary and abbreviations

| Term | Definition / status |
| --- | --- |
| AB | **[E]** Proposed definition: order confirmation (*Auftragsbestätigung*) |
| AV | **[E]** Proposed definition: work preparation (*Arbeitsvorbereitung*) |
| OPOS | **[E]** Proposed definition: open items / receivables (*Offene Posten*) |
| DSB | **[E]** Proposed definition: Data Protection Officer (*Datenschutzbeauftragte(r)*) |
| DSFA | **[E]** Proposed definition: data protection impact assessment (*Datenschutz-Folgenabschätzung*) |
| ACL | **[E]** Proposed definition: Access Control List; access control list |
| UNC | **[E]** Proposed definition: Universal Naming Convention; network path |
| SMB | **[E]** Proposed definition: Server Message Block; file-sharing protocol |
| ODBC | **[E]** Proposed definition: Open Database Connectivity |
| DSN | **[E]** Proposed definition: Data Source Name; ODBC data source name |
| ERP | **[E]** Proposed definition: Enterprise Resource Planning |
| RAG | **[E]** Proposed definition: Retrieval-Augmented Generation; source-based answer generation |
| VLM | **[E]** Proposed definition: Vision-Language Model; image-language model |
| OCR | **[E]** Proposed definition: Optical Character Recognition; text recognition |
| SSO | **[E]** Proposed definition: Single Sign-on; central authentication |
| AD | **[E]** Proposed definition: Active Directory |
| MVP | **[E]** Proposed definition: Minimum Viable Product; smallest verifiable product scope |
| LLM | **[E]** Proposed definition: Large Language Model |
| API | **[E]** Proposed definition: Application Programming Interface |
| TLS | **[E]** Proposed definition: Transport Layer Security |
| VRAM | **[E]** Proposed definition: graphics memory |
| GPU | **[E]** Proposed definition: graphics processor |
| ID | **[E]** Proposed definition: unique identifier |
| UNIQUE | **[E]** Proposed definition: uniqueness constraint in the local database |
| order | **[O]** Business meaning and relationship not proven in IN-FORM by original sources. Neutral adapter reference: `external_case_id` |
| case (*Vorgang*) | **[O]** Business meaning and relationship not proven in IN-FORM by original sources. Neutral adapter reference: `external_case_id` |
| project | **[O]** Business meaning and relationship not proven in IN-FORM by original sources. Neutral adapter reference: `external_project_id` |
| voucher / record (*Beleg*) | **[O]** Business meaning and relationship not proven in IN-FORM by original sources. Neutral adapter reference: `source_records`; concrete document type open |
| order | **[O]** Business meaning and relationship not proven in IN-FORM by original sources. Neutral adapter reference: historical component of `order_file_links`; no confirmed business definition |
| source_as_of | **[E]** Business source as-of date; not the import time. |
| imported_at | **[E]** Import time; does not replace an unknown source as-of date. |
| Monitor / monitor | **[E]** "Monitor" denotes the view; `monitor` is the technical role name. |
| Rule engine / rules/ | **[E]** Job module inside the worker process `indexer`; not an additional container. |
| source_ref / source_refs | **[E]** Individual source reference / collection of source references; business values carry `source_ref` and `source_as_of`. |
| data_as_of | **[E]** Evidence as-of date of a suggestion or field-catalogue metadata; not a substitute for `source_as_of` per source value. |

### Reading key

**[P]** *Project requirement* designates requirements adopted from the original architecture. **[E]** *Recommendation* designates a technical implementation or a proposal, not a confirmed company decision. **[O]** *Open* designates missing evidence, assumptions or pending decisions. Unmarked existing sections retain their previous status. New additions are marked.

**[E]** All figures show logical relationships, not a network plan. Solid line: data flow within scope; dashed: optional/open/proposal only; 2 pt frame: trust zone. Structural arrows show data flow, sequence arrows show invocations. A connection never means write access to source systems. ER lines without an arrow are relationships. State diagrams show transitions.

**[O]** Only architecture v1.2 is available. The project board blueprint, layout reference, architecture v1.1 and the original project plan have not been submitted separately. Their contents are not reconstructed or issued as additionally verified. Existing project requirements are retained; cross-checking is open (OP-17, OP-22).
## 01 Management overview

The goal is an internal AI assistant operated entirely on-premises. Employees search for photos by their content, query company documents with source evidence, receive data-based suggestions and review risks through a dashboard. Customer data remains inside the approved company infrastructure.

**Architecture recommendation**

A central on-premises server runs FastAPI, local AI models, PostgreSQL and Qdrant. The interface initially runs in the browser. A modular backend codebase and separate workers are sufficient for pilot operation. Microservices are introduced only once a proven need exists.

**What is adopted from the existing project plan**

| Fixed in the project plan | Impact on the architecture |
| --- | --- |
| Data remains local | No external model endpoint; egress block, internal model provisioning. |
| RAG before fine-tuning | Document index, reranker and a citable retrieval pipeline. |
| Central provisioning | One GPU server, clients with a browser; Tauri only later. |
| Photo and document search | Two processing tracks with a shared file register. |
| Risk dashboard | Reproducible rules, evidence reference and human review. |

**Architecture principles**

- Uniform identifiers, file versions and traceability via PostgreSQL.
- Permission checking as a Phase-0 gate: verify the effectiveness of approvals, do not infer it from Wi-Fi access.
- Separate job queue, retry mechanisms and monitoring for indexing.
- Explicit quality measurement for image recognition, RAG, source evidence and risks.

**Initial situation and unverified assumptions**

Observed: employees open a mapped network drive in Windows Explorer in the manner of a UNC mapping (target unknown **[O]**) without a separate password prompt. **[P]** IN-FORM is named as the ERP; the intended access is read-only via ODBC. **[O]** Photos and documents are still presumed to reside on an SMB share; technical connections are to be confirmed on site. Unresolved: whether Windows uses automatic logon, whether rights apply per person, whether folders carry customer names, and whether ERP order numbers are linked to files.

**Scope delimitation**

The AI models and hardware figures named in the project plan are candidates or guide values, not a conclusively validated product selection. Model licences, performance requirements and GDPR requirements are to be reviewed with IT and Data Protection before a rollout.

**[P]** The assistant uses IN-FORM as the designated ERP source via read-only ODBC access. The project board blueprint supplies business requirements but does not extend the assistant into a project board. Rules decide, the AI proposes, a human confirms. Binding financial or safety-relevant decisions as well as access decisions remain outside the AI.

**[P]** Stable project/case IDs, provenance and as-of date of every value, recognisable sync failures, rule-bound standard tasks and a human review lifecycle become binding architectural boundaries.

**[O]** Installation, available fields, role approvals and shared infrastructure are to be confirmed on site.

## 02 Content and reading guidance

**[E]** Chapters 01–16 retain their numbering. Document control, change log, indexes, glossary and reading key precede chapter 01. Appendix A contains technical contracts, appendix B the consolidated IT checklist, appendix C the register of open items and appendix D the architecture decisions. The table of contents and the list of figures apply to this structure.

## 03 Goals, requirements and boundaries

**Functional capabilities**

| Area | Expected behaviour |
| --- | --- |
| Photo search | Search by image content, door/window types, customers, period, image preview and source file. |
| Documents | Read and search PDFs, reports, notes and other texts, and answer with source references. |
| Consultation | Combine information from company rules, checklists and similar cases. Distinguish facts from recommendations. |
| Dashboard | Display indexing status, image holdings, data quality, corrections and the risk list. |
| Risks | Flag violations or anomalies traceably, with evidence and a manual lifecycle. |

**Non-functional requirements**

- **Data protection:** customer data is processed only locally, including OCR, embeddings, reranking and model inference.
- **Traceability:** answers and risks reference concrete source documents or files.
- **Permission concept:** a Wi-Fi connection does not replace identity verification; all hits and answers observe verified source rights.
- **Change management:** new, changed and deleted files are synchronised consistently.
- **Observability:** processing results, technical errors and approval decisions are verifiable.

**Explicitly not part of the first pilot**

- Automatic decisions with financial or safety-relevant effect.
- Write access to ERP/corporate databases by language-model tools.
- External API fallback for customer data and automatic forwarding to cloud models.
- Company-wide rollout before permission filters and evaluation have been demonstrated.
- Fine-tuning without measurable need arising from the pilot data.

**Binding boundaries of the integration**

**[P]** Every displayed business value has a source and an as-of date. Unknown means neither zero nor not present. Missing mandatory data leads to a review flag. Every AI recommendation contains source, responsible person and deadline and requires human confirmation. If the person or deadline cannot yet be determined, they remain explicitly open; the draft is not executable until it is completed and confirmed.

**[P]** Standard tasks arise from fixed rules once per occasion. For this purpose the assistant manages only traceable review and suggestion objects. Approvals, ordering, readiness for assembly, project completion and reopening are not executed by the language model.

**Out of scope and open**

**[O]** Calendar, service and minor-repair list, commercial finance view, cut-off date export, post-calculation, deployment planning and route planning belong to the separate project board. The assistant does not take over any of these operating functions. What remains relevant from the blueprint are its data, permission and phase rules. After-sales service appointments and their automatic creation are also not to be implemented here. The display of AI suggestions within the board is an open integration option in chapter 16.

## 04 Overall architecture and system components

What is proposed is a logically separated architecture that is initially operated centrally in physical terms. The backend bundles business logic and APIs. Indexing processes run as separate workers so that user requests are not blocked by OCR or image analysis. **[E]** See figure 1. **[E]** See figure 2.

### Figure 1 – System context (p. 10)

**Design of roles [E]:** `monitor` · `staff` · `office` · technical administration · browser / HTTPS

**Labels as shown in the figure:**

- **AI server [E]** — on-premises
- **Company AI Assistant [E]** — search · consultation · dashboard · review
- **Identity source [O]** — app login; Windows/AD SSO open
- **File server [O]** — SMB · photos / documents · UNC `\\fileserver\share`, name unknown
- **IN-FORM [P]** — ODBC read-only; DBMS/driver [O]; Excel fallback import [P], flagged, manual by an authorised person
- **Project board [O]** — display AI suggestions?
- **Internet / cloud models** — requests / answers — **× egress blocked**
- Access arrows: read-only, logged; "suggestions? [O]"

**[E]** Arrows: data flow. Solid: within scope; dashed: open/optional.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 1: System context;** logical data flow, not a network plan. Reading note: sources supply data; business confirmation is performed by humans.

### Figure 2 – Container view (p. 11)

**Labels as shown in the figure:**

- **AI server [E] · Docker Compose [O]** — containerisation to be released by IT
- **Browser [E]** — HTTPS
- **SMB [O] · read-only**
- **IN-FORM [P] · read-only**
- `reverse-proxy` **[E]**; `web` **[E] · React**; `api` **[E] · FastAPI** (identity; source rights; field rights; review; server-side tool layer)
- `indexer` **[E]** — SMB scan, OCR, tags, embeddings; rule engine: job after sync/index
- **Windows bridge [O]** — 32-bit adapter
- `erp-sync` **[E]** — parameterised read queries
- `postgres` **[E]** — metadata, jobs, outbox, audit
- `qdrant` **[E]** — vectors, filters
- `ollama` **[E]** — LLM, VLM, embedding
- `redis` **[O]** — optional
- Flows: outbox / reconciliation; tool layer / inference

**[E]** Arrows: data flow. Solid: within scope; dashed: open/optional.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 2: Container view;** logical data flow, not a network plan. Reading note: `api` talks separately to `postgres`, `qdrant` and `ollama`; `ollama` has no database connection.

### Modules and responsibilities

| Module | Responsibility | Technology |
| --- | --- | --- |
| Web frontend | Chat, search filters, results, correction, dashboard. | React + TypeScript |
| API / application | Authentication, ACL, endpoints, chat sessions, tools. | Python + FastAPI |
| Retriever | Hybrid search, metadata filters, ranking, source resolution. | Python + Qdrant |
| AI runtime | Local LLM/VLM; test embedding and reranking separately. | Ollama + Python runner if needed |
| Indexing worker | SMB scan, OCR, tagging, embeddings and synchronisation. | Python + PostgreSQL jobs |
| Business database | File register, permissions, metadata, risks, audit. | PostgreSQL |
| **[E]** `erp-sync` | Fixed parameterised ODBC read queries; independent cadence | Python; adapter/bridge **[O]** |
| **[E]** Rule engine | Module of the modular monolith; scheduled job in the worker after every sync/index run; results in PostgreSQL, API only reads | Python; module `rules/` next to `risks/` |

### Known and presumed data connections

In Windows, a network drive apparently appears in the manner of a UNC mapping (target unknown **[O]**). This is normally a local mapping on the workstation PC, not a permanently valid path for the AI server. After IT approval, the server connects via a UNC path such as `\\fileserver\share`. The real name is still unknown.

| Source | Access from the AI server | Status / test |
| --- | --- | --- |
| Photos / files | SMB share via UNC, with a read-only service account. | Assumption: file server behind UNC mapping (target unknown **[O]**). To be verified with IT. |
| Business data **[P/O]** | ODBC to IN-FORM; fixed read-only adapter. | IN-FORM named; DBMS, driver, bitness, modules, tables and voucher references open on site. |
| Linking | **[P]** Unique project/case ID; names only as a search aid. | Check file reference in the file register. **[O]** Verify the meaning of folder names and a reliable link to the IN-FORM ID. |
| User rights | App login and roles; file rights from the actual source. | Open: Windows could authenticate transparently. |

### Security boundary for Phase 0

Wi-Fi access and an automatically opened drive do not prove that all employees have the same rights. Before indexing, IT must test which identities may read which files. A simple shared read area is permissible only after this check.

### Architecture recommendation: modular monolith

The Python application is divided into business modules but initially versioned and deployed together. Workers are separate processes and access the same clearly defined data models. This reduces coordination costs and preserves the option of a later split.

| Layer | Contains | Must not contain |
| --- | --- | --- |
| API | Request validation, permission checks, status codes | File parsing directly in the request |
| Application logic | Search flows, chat tools, risk workflows | Direct UI presentation |
| Domain | File, case, customer, risk, tag, evidence | Model-specific HTTP details |
| Infrastructure | ODBC, SMB, PostgreSQL, Qdrant, model adapters | Business access decisions |
| Worker | Asynchronous tasks, retries, versioning | Interactive user sessions |

**Internal boundaries**

- The AI executes only approved tools implemented server-side.
- The API manages identities, sessions and permissions. The model makes no access decisions.
- PostgreSQL remains the system of record for metadata and object states.
- Qdrant contains search vectors and minimal filter payloads. It is not the sole data source.
- Files remain in their original location on the company file server. Previews receive controlled URLs, not free file paths.

**Recommended minimum deployment**

**[E]** Minimum deployment: 1 React web interface, 1 FastAPI application, 1 indexer/worker with rule engine, 1 separate `erp-sync` service, PostgreSQL including jobs/outbox, Qdrant and at least 1 local AI runtime. Use Redis/Celery only once PostgreSQL jobs are insufficient.

### IN-FORM connection and business responsibility

**[P]** IN-FORM is the named ERP source; ODBC is initially used exclusively read-only. The target is an update in roughly two minutes. Driver, 32/64-bit compatibility, DSN, DBMS, available modules and voucher references are to be checked against the actual installation. Naming the ERP confirms neither the database type nor technical reachability.

**[P]** Projects and cases are linked via unique source IDs. Customer names, folder designations and similarity are only search aids; without a confirmed ID mapping a file link remains unresolved. A language model does not confirm a mapping.

**[E]** A separate ERP sync worker uses fixed, parameterised read queries and normalises approved fields. PostgreSQL holds local metadata and review states; IN-FORM remains the source of the business data maintained there. No operational project board data ownership is defined here. **[O]** Shared adapter, shared database, login and display location of the suggestions remain variants in chapter 16.
## 05 Data model, storage and references

The most important architectural anchor is a uniform file register. Every image and text representation references the original file via stable IDs. Customers, projects, orders, access rights, model versions and risks remain linkable.

### Recommended relational core schema

| Table / collection **[E]** | Key fields and purpose **[E]** |
| --- | --- |
| `source_files` | `id`, `source_path`, `source_system`, `file_hash`, `mtime`, `access_scope_id`, `ingestion_status`, `deleted_at` |
| `customers` | `id`, `name`, `alias` |
| `projects` | `id`, `customer_id`, `source_system_id`, `external_project_id`; `UNIQUE(source_system_id, external_project_id)` |
| `source_records` | `id`, `source_system_id`, `external_case_id`, `project_id`, `source_ref`, `source_as_of`, `sensitivity_class` |
| `order_file_links` | `project_id`, `external_case_id`, `source_file_id`, `match_status`, `match_source`, `reviewed_by`, `reviewed_at`, `match_score` |
| `photos` | `id`, `source_file_id`, `taken_at`, `caption`, `width`, `height`, `processing_version` |
| `photo_labels` | `photo_id`, `object_class`, `property`, `state`, `visible_area`, `confidence`, `reviewed_by` |
| `documents` | `id`, `source_file_id`, `title`, `doc_type`, `language`, `extracted_at` |
| `document_chunks` | `id`, `document_id`, `chunk_index`, `page_ref`, `text_hash`, `vector_id` |
| `acl_entries` | `scope_id`, `principal_id`, `permission`, `source`, `checked_at`, `expires_at` |
| `index_jobs` | `id`, `file_id`, `job_status`, `attempts` |
| `outbox` | `event_id`, `target`, `applied_at` |
| `audit_events` | `id`, `actor_id`, `action`, `target_id`, `timestamp`, `outcome` |
| `source_systems` | `source_system_id` |
| `field_catalog` | `field_key`, `source_id_field`, `source_field`, `data_as_of`, `maintenance_owner`, `fallback_path`; status of the on-site check |
| `field_values` | `project_id`, `field_key`, `value`, `value_state`, `source_system_id`, `source_record_id`, `source_as_of`, `imported_at`, `sync_run_id`, `access_scope_id` |
| `sync_runs` | `id`, `source_system_id`, `started_at`, `completed_at`, `last_success_at`, `status`, `watermark`, `error_code` |
| `fallback_imports` | `id`, `file_hash`, `imported_by`, `imported_at`, `business_as_of`, `source_label=Excel fallback import` |
| `rule_versions` | `rule_id`, `version`, `phase`, `conditions`, `required_fields`, `freshness_limit`, `owner`, `effective_at` |
| `rule_runs` | `id`, `rule_id`, `rule_version`, `source_refs`, `result` |
| `task_candidates` | `id`, `project_id`, `occasion_key`, `task_type`, `rule_version`, `owner_id`, `due_at`, `state`, `confirmed_by`, `confirmed_at`; `UNIQUE(project_id, task_type, occasion_key)` |
| `suggestions` | `id`, `project_id`, `source_refs`, `data_as_of`, `proposed_owner_id`, `proposed_due_at`, `model_version`, `status`, `confirmed_by`, `confirmed_at`, `object_version` |
| `risks` | `id`, `stable_key`, `risk_type`, `customer_id`, `external_case_id`, `project_id`, `severity`, `confidence`, `rule_version`, `rule_run_id`, `detected_at`, `visible_scope`, `evidence_ref`, `evidence_scope`, `status`, `reviewed_by`, `acknowledged_at`, `confirmed_at`, `resolved_at`, `dismissal_reason` |
| `risk_evidence` | `risk_id`, `rule_run_id`, `source_record_id` or `source_file_id`/`chunk_id`, `source_as_of`, `coverage_state`, `freshness_state`, `evidence_scope`, `page_ref`, `quote` |
| `project_phase_events` | `project_id`, `external_project_id`, `source_event_id`, `phase`, `event_at`, `source_ref`, `confirmed_by` |

**Consistency rules**

- Every search hit has a valid `source_file_id` and a verifiable access scope.
- File versions and model versions remain separate. A new model does not automatically force a new file state.
- On deletion or a change of rights, the outbox updates the vector index and all caches; a daily reconciliation looks for deviations.
- Human overrides do not silently overwrite machine labels but remain auditable.

### Vector index: recommended Qdrant collections

| Collection **[E]** | Payload **[E]** |
| --- | --- |
| `photo_embeddings` | `photo_id`, `source_file_id`, `access_scope_id`, `door_state`, `glass_state`, `adjacent_window_state`, `model_version`, `sensitivity_class` |
| `text_chunks` | `chunk_id`, `document_id`, `source_file_id`, `access_scope_id`, `doc_type`, `page_ref`, `sensitivity_class` |

**Important:** image and text embedding models are generally not interchangeable. Text search against images works only with a shared multimodal embedding space. Documents use their own text-embedding pipeline.

### Permissions and search

The app determines permissible scopes server-side. Permissible labels and rights should act as Qdrant filters before the vector search; alternatively PostgreSQL first supplies permitted candidates. A check only after top-k loses relevant hits. A PostgreSQL ACL cache alone is not a live check. Before preview and before including text or snippets in the LLM context, the current source permission must be secured.

**[E]** The API determines permissible scopes and business search filters before the vector search. Candidates are then checked against current source rights and only afterwards ordered. The five server-side checkpoints are described in chapter 11; see figure 16.

> **Important checkpoint**
>
> Phase-0 acceptance: test effective SMB rights with at least two different user identities. IT sets a maximum ACL cache age in writing (discussion value: 60 seconds). If permissions are unclear, outdated or cannot be checked live, no hits, snippets or files are output. For risks, the most restrictive evidence release applies.

### Provenance, identity and review

**[P]** The field catalogue contains, per field, the source, source ID, field name, as-of date, maintenance responsibility and fallback path. The existing file references and ACLs are retained. **[E]** The following extensions concretise the project requirements; names are schema drafts.

**[E]** The consolidated core schema above contains `customers`, `projects` and `source_records` exactly once. Field catalogue and `source_records` describe local adapter contracts; no IN-FORM table or field names are derived from them.

**[E]** `order_file_links` uses `match_status` instead of `match_confidence`. `match_score` is optional and purely informative. Only `match_status=confirmed` may feed rules, filters and risks; `reviewed_by` and `reviewed_at` document the human review together with the source ID.

**[E]** `sensitivity_class` is carried in `source_records` and both Qdrant payloads. `monitor` is blocked by default for free text and document chunks; only demonstrably amount-free document types on an approved allowlist may pass. Classification alone is not evidence. **[O]** Allowlist, review method and approval remain to be confirmed.

**[E]** `value_state` distinguishes `known`, `unknown`, `not_applicable` and `confirmed_absent`; `stale` is a separate freshness attribute and not a value. Null remains distinct from `unknown`. `source_as_of` designates the business source as-of date, `imported_at` the import time. A missing source timestamp is shown as unknown; an import time does not replace it.

**[E]** Unique source keys and transactional upserts prevent duplicate records. An occasion is a stable source event, for example a specific quotation despatch, order, assembly or invoice. Repeat runs and rule versions do not create a second task for it; changes update a versioned candidate. A genuine re-despatch is a new occasion only after a business-confirmed occasion definition. Parallelism is safeguarded by a unique constraint and a transaction. **[E]** See figure 3. **[E]** See figure 4. **[E]** See figure 5. **[E]** See figure 6.

### Figure 3 – ID chain (p. 17)

**Labels as shown in the figure:**

- **IN-FORM vouchers [P]** — voucher types on site [O]
- **Case [O]** — `external_case_id`
- **Project [E]** — `external_project_id`, `UNIQUE(source_system_id, external_project_id)`
- `order_file_links` **[E]** — `match_source`, `match_status`, `reviewed_by`, `reviewed_at`
- `source_files` **[E]** — local reference to SMB file · read-only
- Cardinality [O] on all four links
- "Names = search aid [E]": customer name / alias / folder name; "Müller" → candidate; no identity from similarity
- Human reviews source ID [E]: unresolved → candidate → confirmed or rejected
- Two "Müller" records: two project IDs

**[E]** Only *confirmed* feeds rules, filters and risks; no language model confirms.
**[E]** Lines: logical references, not data flows; cardinalities [O].
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 3: ID chain;** logical data flow, not a network plan. Reading note: the chain describes references and not a write action on a source file.

### Figure 4 – ER file and index model (p. 18)

**Labels as shown in the figure:**

- `source_files` **[E]** — `id`, `source_path`, `file_hash`, `mtime`, `access_scope_id`, `ingestion_status`, `deleted_at`
- `photos` **[E]** — `id`, `source_file_id`, `taken_at`, `caption`, `processing_version`; FK: `source_files`
- `photo_labels` **[E]** — `photo_id`, `object_class`, `property`, `state`, `confidence`, `reviewed_by`; FK: `photos`
- `documents` **[E]** — `id`, `source_file_id`, `title`, `doc_type`, `language`, `extracted_at`; FK: `source_files`
- `document_chunks` **[E]** — `id`, `document_id`, `page_ref`, `text_hash`, `vector_id`; FK: `documents`
- `acl_entries` **[E]** — `scope_id`, `principal_id`, `permission`, `source`, `checked_at`, `expires_at`; scope: `source_files`
- `index_jobs` **[E]** — `id`, `file_id`, `job_status`, `attempts`; FK: `source_files`
- `outbox` **[E]** — `event_id`, `target`, `applied_at`; index reconciliation
- `audit_events` **[E]** — `id`, `actor_id`, `action`, `target_id`, `timestamp`, `outcome`; `target_id`: polymorphic
- `photo_embeddings` **[E]** — `photo_id`, `source_file_id`, `access_scope_id`, `door_state`, `glass_state`, `adjacent_window_state`, `model_version`, `sensitivity_class`; **[E]** ID reference: `photos`
- `text_chunks` **[E]** — `chunk_id`, `document_id`, `source_file_id`, `access_scope_id`, `doc_type`, `page_ref`, `sensitivity_class`; **[E]** ID reference: `document_chunks`

**[E]** Qdrant: reference via ID, no foreign key; PostgreSQL is the system of record.
**[E]** Lines: logical references, not data flows; cardinalities [O].
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 4: ER file and index model;** logical data flow, not a network plan. Reading note: FK names the table reference; `access_scope_id` refers to `acl_entries.scope_id`.

### Figure 5 – ER project and provenance model (p. 19)

**Labels as shown in the figure:**

- `source_systems` **[E]** — `source_system_id`; source identity
- `field_catalog` **[E]** — `field_key`, `source_field`, `source_id_field`, `data_as_of`, `maintenance_owner`, `fallback_path`; source fields [O]
- `customers` **[E]** — `id`, `name`, `alias`; names only as a search aid
- `projects` **[E]** — `id`, `customer_id`, `source_system_id`, `external_project_id`; `UNIQUE`: source system + project ID
- `source_records` **[E]** — `id`, `external_case_id`, `project_id`, `source_ref`, `source_as_of`, `sensitivity_class`; **[E]** FK: `projects`, `source_systems`
- `field_values` **[E]** — `value`, `value_state`, `source_as_of`, `imported_at`, `sync_run_id`, `access_scope_id`; FK: `projects`, `sync_runs`, `field_catalog`
- `sync_runs` **[E]** — `id`, `last_success_at`, `watermark`, `status`; last valid view kept separately
- `fallback_imports` **[E]** — `id`, `business_as_of`, `source_label=Excel fallback import`; flagging; separate import
- `order_file_links` **[E]** — `project_id`, `source_file_id`, `match_status`, `reviewed_at`; FK: `projects`, `source_files` (fig. 4)
- `project_phase_events` **[E]** — `project_id`, `source_event_id`, `phase`, `event_at`, `source_ref`; FK: `projects`

**[E]** `projects`: `UNIQUE(source_system_id, external_project_id)`.
**[E]** Lines: logical references, not data flows; cardinalities [O].
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 5: ER project and provenance model;** logical data flow, not a network plan. Reading note: field values keep source and import time separate; fallback imports remain distinguishable.

### Figure 6 – ER rules, suggestions and risks (p. 20)

**Labels as shown in the figure:**

- `rule_versions` **[E]** — `rule_id`, `version`, `conditions`, `required_fields`, `freshness_limit`; rule contract
- `rule_runs` **[E]** — `id`, `rule_id`, `rule_version`, `source_refs`, `result`; FK: `rule_versions`
- `task_candidates` **[E]** — `project_id`, `task_type`, `occasion_key`, `state`, `owner_id`, `due_at`; FK: `projects`, `rule_versions`
- `suggestions` **[E]** — `status`, `source_refs`, `proposed_owner_id`, `proposed_due_at`, `model_version`, `confirmed_by`; FK: `projects`
- `risks` **[E]** — `stable_key`, `status`, `rule_version`, `rule_run_id`, `confirmed_at`; FK: `projects`, `rule_runs`
- `risk_evidence` **[E]** — `rule_run_id`, `source_record_id`, `source_file_id` / `chunk_id`, `source_as_of`, `coverage_state`, `freshness_state`, `evidence_scope`; FK: `risks`, `rule_runs`
- `projects` **[E]** · fig. 5 — shared project reference
- `UNIQUE` **[E]** `task_candidates`: `project_id` + `task_type` + `occasion_key`; a new run updates the same candidate

**[E]** Lines: logical references, not data flows; cardinalities [O].
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 6: ER rules, suggestions and risks;** logical data flow, not a network plan. Reading note: rule version, run and evidence make a finding reproducible; the AI remains a draft.
## 06 Indexing and processing architecture

Indexing consists of independent, repeatable steps. New files are detected, metadata normalised and, depending on file type, passed to the image or document pipeline. Errors affect individual jobs, not the entire processing run. **[E]** See figure 7. **[E]** See figure 8.

### Figure 7 – Two ingestion tracks (p. 22)

**Labels as shown in the figure:**

- **[E] Track A: files / GPU** — outside core hours; VRAM budget; chat prioritised
- **[E] Track B: ERP sync** — target approx. 2 min **[P]**; independent of OCR
- **File server [O]** — UNC · read-only
- **IN-FORM [P]** — ODBC · read-only
- **1–3 Detect / normalise / check [E]** — hash, version, duplicates; `postgres`
- **4 Extract [E]** — photo: image analysis, labels, description; document: Docling/OCR, chunks
- **5–6 Embed / publish [E]** — model version; atomically `ready`; outbox → `qdrant`
- **B1 Read source state [E]** — fixed, parameterised queries
- **B2 Validate IDs / field catalogue [E]** — Excel fallback import **[P]**: human, flagged, logged
- **B3–B4 Transaction / completion [E]** — upsert; `last_success_at` and `watermark`
- Only `postgres`; last valid state
- `postgres` / `qdrant` **[E]**: `source_files`, `photo_labels`, `document_chunks`, `field_values`, `sync_runs`, `index_jobs`, `outbox`
- Outbox + daily reconciliation; file/project link only with `match_status=confirmed`

**[E]** A: limited retries, explicit error status. B: abort/partial failure → fig. 8.
**[E]** Arrows: data flow. Solid: within scope; dashed: open/optional.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 7: Two ingestion tracks;** logical data flow, not a network plan. Reading note: both tracks are clocked separately and can fail independently.

### Figure 8 – ERP sync states (p. 23)

**States and labels as shown in the figure:**

- **Fresh [E]** — as-of date visible
- **Run active [E]** — cadence approx. 2 min **[P]**
- **Error [E]** — last valid state active
- **Outdated [E]** — `freshness_state=stale`
- **Fallback state [E]** — Excel; provenance + `business_as_of`
- **Return / reconciliation [E]** — ERP reachable; conflict check
- Transitions: cadence; abort / partial failure / driver failure; age; human imports: IDs, as-of date, hash
- **Retry and display [E]** — error/outdated → run active; transaction ok → fresh (`last_success_at` + `watermark`)
- Freshness limit **[O]**. When `stale`, only a review flag; old risks historical, not re-confirmed
- Fallback state: Excel fallback import; return only after a decision by data maintenance
- **Invariants [E]** — partial state never as success; no deletions from a failed import; Excel does not overwrite IN-FORM; replay/restore without duplicates; `stale` is `freshness_state`, not `value_state`
- Error display: last successful sync + error status

**[E]** Arrows: state transitions; dashed: open handover / proposal.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 8: ERP sync states;** logical data flow, not a network plan. Reading note: the display combines run status, data freshness and fallback source; it is not a single enum.

### Process for each source file

| Step | Action | Storage effect |
| --- | --- | --- |
| 1. Detect | Capture SMB files via UNC; ERP sync separately in track B. | File register, access metadata |
| 2. Normalise | Check path, customer identifier, date, character encoding, EXIF. | Cleaned metadata |
| 3. Check | Compare hash and modification state; handle duplicates. | Job status / version |
| 4. Extract | Analyse images; parse documents and run OCR if required. | Text, labels, descriptions |
| 5. Embed | Compute text and image vectors with a model version tag. | Qdrant vectors |
| 6. Publish | Validate records and set them atomically to retrievable. | Index status: `ready` |

**Robustness and restart**

- Idempotent processing: the same file state does not create duplicate index entries.
- Retries with a limited number of attempts and an explicit error status.
- Re-indexing per pipeline version, without uncontrollably overwriting the active search system.
- Indexing preferably outside core working hours, with a VRAM budget and lower priority than chat.
- PostgreSQL outbox plus scheduled reconciliation against Qdrant: detect missing, orphaned or incorrectly authorised vectors.

### ERP synchronisation and flagged fallback import

**[P]** ODBC synchronisation and compute-intensive photo/document indexing are separate cadences. The target of roughly two minutes applies to the read-only ERP sync, not to full OCR or image analysis. The preferred indexing outside core hours continues to apply to the GPU pipeline.

**[E]** Flow: read the approved source state, validate IDs and field catalogue, apply changes in one transaction and only then advance the last successful sync and the watermark. On abort or partial failure, the last fully valid state remains active; partial states must not appear as complete success. Deletions are recognised only through confirmed source signals or a full reconciliation, never derived from a failed import.

**[P]** On failure the interface shows the last successful sync, the error status and the outdated marker. **[O]** The measurement point, permissible delay and business freshness limits per rule are decided before the pilot.

**[E]** Outdated decision-relevant inputs generate a review flag; an old risk entry remains marked as a historical finding that has not been re-confirmed.

**[P]** Excel is exclusively a visibly flagged fallback import. **[E]** Import template, reviewer, source IDs, business as-of date, file hash and conflicts are recorded. ERP and fallback values remain distinguishable; Excel does not silently overwrite IN-FORM. Repeated import of the same file and the same occasions is idempotent. Data maintenance responsibility decides on conflicting values.

**[P]** Writing back is conceivable only via a confirmed channel and is not part of the read-only pilot. There is no LLM write access and no generic SQL write interface. **[O]** A later business write channel requires a separate interface and approval decision.

**[E]** Track B: read source state → validate IDs/field catalogue → transactional upsert → advance `last_success_at` and `watermark`. The process states from figure 8 are a composite display, not an additional `value_state`. The threshold for `freshness_state=stale` remains **[O]**.

## 07 Photo search and visual classification

**Example requirement: “entrance doors without windows”**

A missing tag does not mean “no window”. The business department must distinguish between a glass panel in the door leaf, a side panel / frame window, and another window within the visible image area. Each property receives the states *present*, *visible* and *absent* or *not assessable*. A tight image crop proves nothing about the invisible area.

| Phase | Procedure |
| --- | --- |
| Offline: capture photo | Extract customer/date from the folder structure (e.g. Müller/02.04.2026) and EXIF. Date format explicitly `%d.%m.%Y`. |
| Offline: understand | Multimodal model or zero-shot method determines categories, types, description and confidence. |
| Offline: index | Store labels in PostgreSQL and, additionally, the states needed for pre-filtering in the Qdrant payload. |
| Online: query | Execute rights and label constraints before the vector search; do not treat *unknown* as absence. |
| Online: ranking | Order permitted candidates by semantic similarity and evidenced classification state. |
| Feedback | Employees correct tags; the change and the original prediction remain traceable. |

**Search logic: three result groups**

- **Confirmed hits:** door present, window confirmed as not present.
- **Uncertain hits:** door present, window status unknown or low confidence.
- **Excluded:** window unambiguously present, or image not authorised.

**Validation approach**

For 10–20 defined search queries, relevance is assessed across all 1,000 pilot photos so that Recall@K is meaningful. In addition, 100–200 diversely selected images serve for detailed label assessment. Account for differences in customers, lighting, camera and photographers. Operational label corrections remain separate from the frozen test set. **[E]** See figure 9.

### Figure 9 – Photo search decision flow (p. 26)

**Labels as shown in the figure:**

- **Query [E]** — “entrance doors without windows”
- **Constraint parsing [E]** — door; glass panel; side panel/frame window; further window — present / visible / absent / not assessable
- **Filter before vector search [E]** — `scope_filter` + `label_filter`; `qdrant`; read-only
- **Live rights check and ranking [E]** — unclear rights → discard; unknown is not absent
- **Confirmed hits [E]** — door present; window confirmed absent
- **Uncertain hits [E]** — unknown status / low confidence
- **Excluded [E]** — window present / image not authorised
- **Correction by employee [E]** — audit + original prediction; not into the frozen test set

**[E]** Arrows: data flow. Solid: within scope; dashed: open/optional.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 9: Photo search decision flow;** logical data flow, not a network plan. Reading note: semantic similarity replaces neither the rights check nor confirmed absence.

## 08 Document search, RAG and consultation

The system answers technical questions on the basis of the company's internal documents, rules, checklists and historical cases. Every relevant factual claim should have a verifiable reference. Without sufficient evidence, the answer must name the knowledge gap. **[E]** See figure 10.

### Figure 10 – RAG request path (p. 28)

**Labels as shown in the figure:**

1. **Employee question [E]** — German and domain language
2. **Query and rights [E]** — ACL, glossary, filters, reformulation
3. **Hybrid retrieval [E]** — keywords + `qdrant` + reranking; read-only
4. **Source check [E]** — reference, `source_as_of`, current rights
5. **Answer with citations [E]** — What the documents say / What is missing / Next steps
- **Knowledge gap [E]** — insufficient evidence: review flag; name the missing knowledge

**[E]** Only authorised evidence enters the LLM context; no invented evidence.
**[E]** Arrows: data flow. Solid: within scope; dashed: open/optional.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 10: RAG request path;** logical data flow, not a network plan. Reading note: the source check branches to an explicit knowledge gap when evidence is insufficient.

### RAG pipeline

- Extract files with Docling or OCR, preserving structured sections and page references.
- Chunking by paragraphs, headings and tables rather than by character count alone.
- Handle the glossary and German compounds: synonyms, decompounding tests and n-gram/trigram matching.
- Keyword search in the pilot via PostgreSQL full-text search (German) plus `pg_trgm`; semantic search in Qdrant; then joint reranking.
- Check references and ACL before text is passed to the local answering AI.
- Answer format: "What the documents say", "What is missing", "Next steps".

### Guiding principle for consultation

The model formulates recommended actions, not binding decisions. For price questions, safety relevance or incomplete evidence it refers to the responsible employees. Sources are identified by file, section and where possible page number.

### Binding format for AI suggestions

**[P]** Every suggestion states the source with reference or source ID, as-of date, responsible person and deadline. Facts, interpretation and proposal are separated. If evidence is missing, the result is a review flag; missing data is not interpreted as a business event.

**[E]** The output contains `status=draft`, `source_refs`, `data_as_of`, `proposed_owner_id` and `proposed_due_at`. Persons and deadlines are taken from approved specifications or marked as to be confirmed; they are not invented as known company decisions. A human with business authorisation completes open fields and confirms. The API then checks rights, current evidence and object version again. A confirmation documents a recommendation; it does not trigger an ERP posting or assembly release.

**[P]** Document logic accounts for quotation, follow-up, work preparation, assembly, invoice, completed and complaint. Records are assigned to an unambiguously identified project and its business event. A report about a partial delivery or an incoming payment is not by itself an assembly release or a project completion.

**[E]** The stored suggestion status is `suggestions.status`: `draft`, `confirmed` or `dismissed`. "Confirmable" is a derived condition, not a stored status. Source and business as-of date are output per reference as `source_ref` and `source_as_of`; `data_as_of` designates the documented evidence state of the suggestion and does not replace `source_as_of`. **[E]** See figure 11.

### Figure 11 – Lifecycle of an AI suggestion (p. 30)

**Labels as shown in the figure:**

- **Model / rule [E]** → **Human with business rights [E]**
- **Draft [E]** — `status=draft`; open fields permitted
- **Only draft by model** — confirmable **[E]**; derived, not a stored status
- `source_refs`, `data_as_of`, `proposed_owner_id`, `proposed_due_at` complete; evidence current
- `confirm` **[E]** · human — API re-checks right, evidence and `object_version`
- 403 rights; 409 version/occasion; 422 incomplete
- **Confirmed [E]** — `status=confirmed`; documented recommendation; no ERP/assembly release
- **Dismissed [E]** — `status=dismissed`; human decision

**[E]** Changes are versioned; confirmation has an exclusively local effect. A draft can be dismissed by a human.
**[E]** Arrows: state transitions; dashed: open handover / proposal.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 11: Lifecycle of an AI suggestion;** logical data flow, not a network plan. Reading note: completeness only makes a draft confirmable; only a human may confirm.
## 09 Risk analysis and dashboard

Risk analysis draws on structured data and evidenced text findings. For the pilot, the focus is on a few traceable rules. **[P]** AI classifications remain suggestion candidates, also at a later stage; binding risk findings arise exclusively rule-bound and with human review. **[E]** See figure 12.

### Figure 12 – Risk detection (p. 32)

**Labels as shown in the figure:**

- **Authorised evidence [E]** — confirmed project ID; source + `source_as_of`; rule ID, `rule_version`, `rule_run_id`; `coverage_state`, `freshness_state`
- **Fixed versioned rule [E]** — only confirmed assignments; evidenced conditions
- **Review flag [E]** — `stale` / `unknown` / coverage incomplete; data quality; no new business conclusion
- **Risk + evidence [E]** — detected; no AI status setting
- **AI proposes [E]** — draft; unconfirmed candidate; no binding priority
- **Human review [E]** — in review → confirmed → resolved or dismissed; Acknowledge / Confirm / Resolve / Dismiss; audit; fig. 14

**[E]** Arrows: data flow. Solid: within scope; dashed: open/optional.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 12: Risk detection;** logical data flow, not a network plan. Reading note: the AI side path ends as a draft; business findings require rule, evidence and review.

### Risk object

| Field group | Example |
| --- | --- |
| Identity | `id`, `stable_key`, `risk_type`, `customer_id`, `external_case_id`, `project_id` |
| Assessment | `severity`, `confidence`, `rule_version`, `detected_at`, `rule_run_id` |
| Evidence | `source_file_id`, `chunk_id`, `evidence_scope`, `page_ref`, `quote`, `coverage_state` |
| Workflow | `status`, `reviewed_by`, `acknowledged_at`, `resolved_at`, `dismissal_reason`, `confirmed_at` |

**Dashboard boundaries**

**[O]** Multiple complaints, unanswered quotations and photo damage are later candidates (not pilot); the fixed rule and case assignment remain to be confirmed by the business side.

A "missing document" must not appear as a business risk in the case of OCR errors, unsorted files or incomplete indexing. In such cases a data quality problem is displayed. Risks with multiple pieces of evidence are shown in the pilot only if the user has access to all associated sources. Initially the dashboard contains no personal processing-time metrics. "Ask AI" loads exclusively approved evidence.

### Rules, tasks and business phases

**[P]** The dashboard derives risks exclusively from fixed, versioned rules with evidence and human review. AI classifications and image findings are unconfirmed candidates. They may not independently set a risk status, a priority with binding effect, access rights or an approval.

| Phase | Adopted project requirement and assistant behaviour |
| --- | --- |
| Quotation | Measurement remains in the quotation phase. Confirmed despatch is the occasion for follow-up; no phase change based on an AI text supposition. |
| Follow-up | Rule task after despatch; 5–7 days configurable **[O, to be checked against the blueprint]**. **[O]** The concrete value and deadline calculation are to be approved. Order leads to work preparation in business terms; cancellation ends the resubmission. |
| Work preparation | Technical release before ordering. Check supplier order confirmation. Readiness for assembly only once material is fully checked; a partial delivery is not sufficient. |
| Assembly | The end of the appointment creates a feedback task, not a completion report. Confirmed completion report, performance records and, where applicable, acceptance open the invoicing review. |
| Invoice | Open-items (OPOS) review task at voucher due date. 10 calendar days as the default **[O, to be checked against the blueprint]**; applicability is to be demonstrated. Payment, invoicing and performance status remain separate. |
| Completed | Only the responsible project handler closes the project deliberately, after settlement and payment are clarified. Payment or the end of the appointment alone do not close a project. |
| Complaint | Remaining work during execution stays within the running project. A later complaint reopens the same originating project in business terms; record responsible person, deadline and measure. Here only check/propose, do not write back autonomously. |

**[P]** Standard tasks are rule-bound: follow-up after quotation despatch, order-confirmation check after ordering, feedback after assembly or end of appointment, and OPOS check at due date. One task per occasion. **[E]** For this purpose the assistant stores confirmable task candidates; the leading operational task list and its handover remain open until the infrastructure decision. A rule generates the candidate deterministically; the AI may formulate the explanation.

### Rule candidates

| Rule | Prerequisites and outcome | Pilot status |
| --- | --- | --- |
| R1 Measurement report missing | Confirmed project ID, business reporting obligation, complete current inventory and successful extraction. Only then a risk; otherwise a review flag for data quality. | **[E]** Pilot candidate; business approval open **[O]** |
| R2 Delivery date exceeded | Verified delivery date, currently open order and reliable delivery status. A missing delivery status means unknown. | **[E]** Pilot candidate; business approval open **[O]** |
| R3 Assembly release contradictory | Documented release or readiness contradicts a confirmed partial delivery / missing material check. Review/risk flag only, no automatic block or release posting. | **[E]** Pilot candidate; business approval open **[O]** |
| R4 Due standard task open | Unambiguous occasion, approved deadline rule and known current task status. A missing board connection does not prove an uncompleted task. | **[O]** Not in the first pilot set; leading task list unresolved |
| R5 Phase contradictory | Check a confirmed completion caused solely by payment or by a complaint on a closed project without a related reopening. Without evidenced events, review flag only. | **[E]** Pilot candidate; business approval open **[O]** |

**[E]** There is one shared catalogue R1–R5. "Measurement report missing" corresponds to R1, "delivery date exceeded" to R2. Three to five rules remain a discussion value; R4 is excluded until the task-list decision is taken. **[O]** Selection, severity, deadlines and thresholds are approved by the business side. A higher `confidence` replaces neither evidence nor rule condition.

### Human review and freshness

**[E]** Lifecycle: detected → in review → confirmed → resolved or dismissed. Responsible reviewer, deadline, reason and timestamp are audited; permitted transitions are defined server-side. Unconfirmed AI candidates sit separately in the *draft* state. New evidence leads to a new assessment; a closed occasion is not silently reopened. **[O]** Responsibility and reopening rules for the review are decided by the business side.

**[P]** Every finding shows rule ID and version, source IDs/references, as-of date and freshness. **[E]** In the case of `stale`/`unknown`/incomplete coverage, no new business conclusion is drawn; a review flag is visible instead. All evidence rights must apply. For monitor roles, the API also suppresses amounts in free texts, quotations, previews and explanations.

**[E]** Acknowledge sets *in review* and `acknowledged_at`; Confirm sets *confirmed* and `confirmed_at`; Resolve sets *resolved* and `resolved_at`; Dismiss sets *dismissed* and requires `dismissal_reason`. Transitions are reserved for a human with review rights and are audited. The deterministic entry into *detected* requires a rule and authorised evidence; an AI draft cannot trigger it. **[E]** See figure 13. **[E]** See figure 14.

### Figure 13 – Seven phases (p. 35)

**Labels as shown in the figure:**

- Phases: **Quotation [E]** → **Follow-up [E]** → **AV (work preparation) [E]** → **Assembly [E]** → **Invoice [E]** → **Completed [E]**
- **Quotation [E]:** measurement remains here. Despatch confirmed → follow-up; 5–7 days [O].
- **Follow-up [E]:** order → work preparation; cancellation ends resubmission.
- **Work preparation [E]:** technical release before ordering; order-confirmation check; complete material (R3).
- **Assembly [E]:** end of appointment → feedback, not a completion report. Records / acceptance where applicable.
- **Invoice [E]:** OPOS check at voucher due date; 10 calendar days [O]. Payment ≠ performance status.
- **Completed [E]:** project handler closes deliberately; payment / end of appointment alone is not enough (R5).
- **Complaint [E] · seventh phase:** remaining work stays in the running project. Later complaint: record responsible person, deadline and measure. Originating project **[E]** reopened — human confirms.
- Candidate (rule) · human confirms · assistant: check/propose only
- **[O]** To be checked against the blueprint. **[E]** One candidate per occasion; no write-back of a phase.

**[E]** Arrows: state transitions; dashed: open handover / proposal.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 13: Seven phases;** logical data flow, not a network plan. Reading note: the business phase chain is not a process executed by the assistant.

### Figure 14 – Lifecycles of risk and task candidate (p. 36)

**Labels as shown in the figure:**

- **Risk [E]:** detected [E] (rule + evidence + review) → in review [E] (Acknowledge) → confirmed [E] (Confirm) → resolved / dismissed [E] (Resolve / Dismiss; `dismissal_reason`)
- **AI draft [E]** — unconfirmed candidate; no direct entry into *detected*
- **Task candidate [E]:** occasion [E] (despatch / order / end of appointment / due date) → rule creates candidate [E] — `UNIQUE(project_id, task_type, occasion_key)` → candidate [E] (`owner_id` / `due_at` possibly open) → human confirms [E] (422 missing mandatory data; 409 occasion conflict) → confirmed candidate [E] — no operational task → leading task list **[O]**, handover open; chapter 16

**[E]** New evidence → new assessment; occasion not silently reopened. Review transitions only human + audit; in review it is possible to dismiss directly.
**[E]** Arrows: state transitions; dashed: open handover / proposal.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 14: Lifecycles of risk and task candidate;** logical data flow, not a network plan. Reading note: rule runs update the candidate of the same occasion; a new despatch requires a confirmed occasion definition.

## 10 API and backend interfaces

The frontend communicates exclusively with the FastAPI application. Business APIs do not expose direct SMB paths, database credentials or unfiltered Qdrant results.

### REST endpoints

**[E]** Each method/path combination is defined here exactly once. Writing routes modify exclusively local technical or review objects. No endpoint writes to SMB or IN-FORM.

| Method / path **[E]** | Contract **[E]** |
| --- | --- |
| `POST /api/v1/photos/search` | Text query and filters; only authorised photos; paginated hits. |
| `POST /api/v1/documents/search` | Hybrid document search with references, ACL and snippets. |
| `POST /api/v1/chat` | Local RAG answer; evidence IDs and source references. |
| `GET /api/v1/files/{id}/preview` | Short-lived internal preview after re-authorisation. |
| `POST /api/v1/photos/{id}/labels` | Human with business rights only: local label correction, audit; no change to the source file. |
| `GET /api/v1/risks` | Filtered risk list according to role/project permission. |
| `PATCH /api/v1/risks/{id}` | Human with review rights only: Acknowledge = in review; Confirm = confirmed; Resolve = resolved; Dismiss = dismissed with `dismissal_reason`. Reason, editor, object version and audit; no LLM execution. |
| `GET /api/v1/index/jobs` | Indexer status for authorised technical administration only. |
| `GET /api/v1/sync/status` | `last_success_at`, `status`, `age_seconds`, `freshness_state`; authorised source status only, no credentials. |
| `GET /api/v1/projects/{id}/facts` | Permitted fields: `value`, `value_state`, `source_ref`, `source_as_of`, `imported_at`, `freshness_state`; `monitor` without amounts. |
| `GET /api/v1/field-catalog` | Field provenance and maintenance responsibility for approved administrative rights. |
| `POST /api/v1/fallback-imports` | Authorised human only: file check, preview, flagging and audit; local fallback state, not an AI tool. |
| `GET /api/v1/task-candidates` | Rule candidates with occasion, source, responsibility and deadline; project-related ACL. |
| `POST /api/v1/suggestions` | Creates exclusively `status=draft`; open mandatory fields permitted; no operational execution. |
| `POST /api/v1/suggestions/{id}/confirm` | Human with business rights only: `proposed_owner_id`, `proposed_due_at`, `source_refs` and `data_as_of` complete; evidence current; re-check `object_version`. |
| `POST /api/v1/task-candidates/{id}/confirm` | Human only: `owner_id` and `due_at` complete; check occasion and version; no second task and no ERP write. |
| `POST /api/v1/exports` | **[E]** Optional API function for a human with `export.execute` and field filter; delivery to an authorised client, no writing to SMB or IN-FORM. **[O]** Scope and approval open. |
### Server-side permitted AI tools

| Tool **[E]** | Purpose | read / draft | ACL check | Return / route |
| --- | --- | --- | --- | --- |
| `search_photos` | Photo search | read | Photo/project/source rights and view profile | `source_ref` + `source_as_of`; POST photos/search |
| `search_documents` | Document passages | read | Scope, field rights, `sensitivity_class` and live ACL | `source_ref` + `source_as_of`; POST documents/search |
| `open_file` | Restricted, checked preview | read | Live preview check and amount filter | `source_ref` + `source_as_of`; GET files preview |
| `get_risks` | Approved risks | read | All evidence rights and field filters | `source_ref` + `source_as_of`; GET risks |
| `get_project_facts` | Project values | read | Project, source and field rights | `source_ref` + `source_as_of`; GET projects facts |
| `get_sync_status` | Authorised source status | read | Source/operating right; no secrets | `source_ref` + `source_as_of`; GET sync status |
| `get_task_candidates` | Task candidates | read | Project/source rights | `source_ref` + `source_as_of`; GET task-candidates |
| `draft_suggestion` | Create unconfirmed suggestion | draft | Project/source/field rights; only `status=draft` | `source_ref` + `source_as_of`; POST suggestions |

**[E]** Every tool contract returns `source_ref` and `source_as_of` per business result; where the source as-of date is unknown, the explicit message "data as-of date unknown" is shown. Empty hits do not create an invented source. The technical sync status distinguishes `last_success_at` from the business `source_as_of`.

No arbitrary model SQL execution, no freely selectable file-system paths and no general shell commands. Parameters, data volumes, rate limits and permissions are enforced in the API.

**[P]** Source and as-of date apply also to search hits, citations, dashboard values and exports. **[E]** A shared metadata format prevents divergent display contracts. Missing fields are explicitly delivered as unknown. Monitor responses contain neither financial fields nor hidden raw values.

**[E]** HTTP 403 for missing functional rights, 409 for version/occasion conflicts and 422 for incomplete confirmations. Object existence must not be disclosed to unauthorised parties. Export requires `export.execute` and field filters. The model may point to the human-operated function but must not execute it. `confirm`, `import`, `review-write`, `export`, `SQL`, `shell` and free file paths are not AI tools.

## 11 Permissions, security and data protection

**[E]** Trust zones and the five checkpoints limit every access. The following figures concretise the server-side permission contract. **[E]** See figure 15. **[E]** See figure 16.

### Figure 15 – Trust zones (p. 39)

**Labels as shown in the figure:**

- **Workstation / browser [E]** — VPN/intranet · HTTPS · verified identity; app login; AD/SSO **[O]**
- **AI server · isolated networks [E]** — `reverse-proxy` · `api` · `indexer` (worker) · local AI
- `api`: check source rights live before retrieval / LLM context / answer / preview / export; unclear/outdated/unverifiable rights → deny
- **Source systems: read-only [E]** — SMB: UNC, read-only account; IN-FORM: ODBC, fixed `SELECT`s; one separate read-only account per source
- Source-right evidence flows to `api`; no write action
- TLS / requests; read-only / permission check
- **Secret management [E]** — not in Git
- **Internet / cloud models** — **× egress blocked**

**[E]** No customer data to external models. Wi-Fi is not an identity.
**[E]** Arrows: data flow. Solid: within scope; dashed: open/optional.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 15: Trust zones;** logical data flow, not a network plan. Reading note: source-rights data flows to the API; the structural view shows no arrow into a source system.

### Figure 16 – Permission check (p. 40)

**Sequence, as shown in the figure** (participants: Browser, `api`, `postgres`, `qdrant`, SMB source, `ollama`):

1. Session / identity
2. Scopes / field rights
3. Before retrieval: filters; read-only
4. Live rights: read-only; age ≤ limit **[O]** — unclear / outdated / unverifiable: discard; no snippet
5. Before LLM context: filter fields / amounts; evidence only — draft; no database access
6. Before answer: source / as-of date / monitor filter
7. Before preview: live check again
8. Before export: human + `export.execute`

**[E]** Every decision: `audit_events`; formula only in chapter 11. Limit: 60 s **[O]**.
**[E]** Arrows: invocations / results; no write call to a source system.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 16: Permission check;** logical data flow, not a network plan. Reading note: the API initiates the live check internally; the source only supplies the permission result.

### Security principles

- **Identity:** separate app login; possible Windows/AD integration only after review. Wi-Fi alone is not a user login.
- **Authorisation:** Phase-0 check of effective source rights. Deny access when rights are unclear; filter search, LLM context and risk view.
- **Source systems:** SMB-UNC and ODBC with separate read-only accounts provided by IT; fixed SQL queries.
- **Network:** internal TLS connections, segmentation, restrictive outbound firewall rules.
- **Logging:** record technical actions and permission decisions, no unnecessary raw content.
- **Secrets:** separate secret management, no passwords in the Git repository.
- **Data protection:** involve the Data Protection Officer; review DPIA under Art. 35 GDPR; involve the works council early pursuant to § 87 (1) No. 6 BetrVG, where one exists.

### Protective mechanisms

Retrieval contents are treated as untrusted data. A document may not grant the LLM any new tool rights. Rights changes are checked also between index sync and file retrieval. On loss of access, existing caches, hits and derived risks are blocked. Personal audit data, assignments and performance metrics require purpose limitation and agreed retention periods.

### Roles and server-side field rights

**[P]** The monitor view contains no amounts. Commercial details and exports are available only to authorised users; the API enforces this. **[E]** The following roles are a draft to be agreed, not already assigned company rights.

| Role **[E]** | Draft of rights |
| --- | --- |
| `monitor` | Approved reduced project/risk view without amounts; no commercial export, no confirmation. Monitor endpoints remain amount-free even for logged-in office staff. |
| `staff` | Project-related search and consultation within the scope of source rights; review/label correction only with additional business rights. No commercial details through this role alone. |
| `office` | Commercial details only with `finance.read` and matching project/source right; export additionally requires `export.execute`. Review and confirmation granted separately. |
| Technical administration | Operation and sync status according to least privilege; no automatic authorisation for commercial content. |

**[E]** effective permission = confirmed identity ∩ source rights ∩ project/object right ∩ field/function right ∩ view profile. Multiple roles do not cancel a monitor profile. Access is denied where rights cannot be verified. Permissions are checked before retrieval, before LLM context, before answer, before preview and before export; the same boundary applies to caches and audit views. Sensitive contents in documents require approved redaction or blocking of the entire source, not mere CSS hiding.

**[E]** `sensitivity_class` alone does not reliably detect amounts. For `monitor`, server-side default-deny therefore applies to free text/document chunks, except for demonstrably amount-free, approved document types. This applies before retrieval, before LLM context, before answer, before preview and before export, as well as to caches and audit views. **[O]** Allowlist and verification procedure are to be approved.

### Open review with data protection and works council

**[O]** To be clarified with the Data Protection Officer: review Art. 22 GDPR in the concrete decision and confirmation process; document the scope and effectiveness of human review. No legal classification is anticipated by this architecture.

**[O]** To be clarified with the Data Protection Officer: necessity of a DPIA under Art. 35 GDPR, processing purposes, data minimisation, data subject rights and retention/deletion periods including vectors, suggestions and audit data.

**[O]** To be clarified with the works council, where one exists: possible co-determination under § 87 (1) No. 6 BetrVG for dashboard, tasks, responsibility assignment and logs. Personal performance or behaviour evaluation is not an approved function. Agree limits and access rights in writing. Reference for review: GDPR Art. 22 and 35, https://eur-lex.europa.eu/eli/reg/2016/679/oj ; BetrVG § 87, https://www.gesetze-im-internet.de/betrvg/__87.html . These points are open review assignments, not legal advice or approval.

**[O]** The Data Protection Officer reviews the classification of the concrete use with regard to the EU AI Act. This architecture makes no statement about resulting obligations; review assignment in appendix C.

## 12 Deployment, operation and maintenance

### Docker Compose topology for the pilot

| Container / service | Task | Operating note |
| --- | --- | --- |
| `reverse-proxy` | Internal TLS and routing | Publish only the necessary internal ports. |
| `web` | React frontend | Static delivery, no direct database access. |
| `api` | FastAPI | User identity, ACL, APIs and AI orchestration. |
| `indexer` | SMB scan and PostgreSQL jobs | Prioritise off-hours, limit GPU load. |
| **[E]** `erp-sync` | Read-only, parameterised ODBC sync | Independent cadence; adapter/bridge **[O]** |
| **[E]** Rule engine in the `indexer` | Job in the worker after every sync/index run | Results in `postgres`; `api` only reads |
| `postgres` | Metadata, jobs and outbox | Test backups, restore and job recovery. |
| `qdrant` | Vector index | Persistent volume and documented rebuild. |
| `ollama` | Local AI inference | GPU allocation, no external model endpoint. |
| `redis` (optional) | Job queue | Only if needed for retries and parallel workers. |

**[E]** The connections between the services are shown in figure 2.

### Operating requirements

- IT approval for Docker, GPU drivers, NVIDIA Container Toolkit and internal DNS names.
- Persistent volumes for PostgreSQL, Qdrant, model weights and temporary processing.
- Versioned deployments and separate configuration for development, test and production environments.
- Monitoring for indexer backlog, processing failures, VRAM, response times and memory consumption.
- Test backups and outbox restart; daily comparison of file register and Qdrant including scope changes.
- Technical patch and model update procedure for the offline-operated environment.

### Operating sequence in the event of faults

Metadata and permissions take priority. If Qdrant fails, search is restricted and no unchecked fallback to unauthorised original files is permitted. If the model fails, the indexer may continue its work in an orderly manner or pause.

### Operation of the read-only ERP connection

**[E]** Separate `erp-sync` service with a read-only ODBC account and limited connection load. If only a 32-bit driver is available, a compatible isolated adapter or an approved driver change is examined. A Windows bridge service may be an option; platform and container capability are not assumed and remain open.

**[P]** Sync errors are visible, the last success and the outdated state remain recognisable. **[E]** Monitoring additionally covers sync age, run duration, error rate, record count, duplicate conflicts and discarded assignments. No personal performance metrics. Backups also capture field catalogue, rule versions, occasion keys, suggestions and review history.

**[E]** Restore and replay must create neither duplicate standard tasks nor unmarked partial states. ODBC failure, broken driver, fallback import and return to the ERP source are rehearsed in the operations manual. **[O]** Responsible persons, escalation path, maintenance windows and freshness limits are defined by IT together with data maintenance.

## 13 Model strategy and hardware

The concrete model selection is made on the basis of real German company photos and documents. The following names are options from the project plan, not a final determination. All required models and model weights must be approved legally and technically before offline use.

| Task | Candidates from the plan to be tested |
| --- | --- |
| Photo semantics / embeddings | SigLIP 2/OpenCLIP via Python or a compatible multimodal Ollama model |
| Text embeddings | BGE-M3, alternatively Qwen3-Embedding or multilingual-E5 |
| Reranking | BGE-reranker-v2-m3 |
| Image description and handwriting | Qwen3-VL or a comparable locally tested VLM |
| Chat / tool use | Qwen3, Mistral Small or a comparable local model |
| Document processing | Docling, if needed PaddleOCR or Tesseract for German |
| Object localisation, optional | Grounding DINO or YOLO |

### Rough hardware planning

| Scenario | Architectural assessment |
| --- | --- |
| Pilot: 1 GPU machine | 24 GB VRAM only as a test hypothesis; not all models loaded permanently at the same time. |
| More quality / larger models | 48 GB VRAM or more as a test assumption, to be validated by benchmarks before procurement. |
| High parallelism | Plan separate inference and indexing resources only after load measurement. |

### Model approval criteria

- Sufficient hit quality on the internal German test set.
- Acceptable response time and indexing throughput under realistic loads.
- Working model runner: **[O]** demonstrate support for multimodal inputs in the specific Ollama model and runner used; test SigLIP/OpenCLIP and reranker separately.
- Concrete VRAM budget for LLM, VLM, image/text embedder, reranker and indexer. Load tests with parallel users.

## 14 Quality assurance and acceptance criteria

Quality is measured against company tasks. Numerical thresholds are agreed bindingly before the first evaluation run. The following figures are a preliminary discussion, not business-approved contractual values.

**[E, discussion value]** Recall@20 ≥ 85 % is impossible with more than 23 relevant photos (20/0.85 ≈ 23.5). Proposed decision: questions with at most 20 relevant photos, or use R-precision or Recall@max(20, number of relevant photos). Precision@10 ≥ 85 % requires at least nine relevant hits given exactly ten hits; for fewer hits the evaluation procedure is **[O]**. **[O]** Define the number of test questions and the evaluation denominator for 95 % correct sources, as well as all approval thresholds.

| Component | Metric / evidence |
| --- | --- |
| Photo search | Proposal: Precision@10 at least 85 %, Recall@20 at least 85 %; complete relevance labels for 10–20 queries. |
| Texts / RAG | Proposal: at least 95 % correct sources for verifiable factual answers, separate abstention rate. |
| Consultation | Facts/interpretations cleanly separated, correct escalation where evidence is missing. |
| Risks | Precision per rule, availability of all evidence and data coverage; no employee time measurement. |
| Data protection | 0 tolerated permission leaks in negative tests, also after a change of permissions. |
| Operation | Throughput, P95 latency, failed jobs, recovery after restart. |

**Binding approval checks before a broad rollout**

- An unauthorised user must be able neither to search for nor to open a file or file excerpt.
- Removed or reclassified source files are no longer retrievable after synchronisation.
- Every risk notification references traceable evidence or an exact rule.
- For questions without a source, the AI transparently declares its uncertainty.
- Offline processing without automatic data transmission to external endpoints is demonstrated.
- Data protection, IT operations and business users confirm their respective check points.

**Recommended test data**

1,000 pilot photos: complete relevance assessment for 10–20 fixed search queries; additionally a classification sample (100–200 photos). Representative PDFs, permission-change tests and 10–20 evidenced risk examples.

**Acceptance cases**

**[P]** The ten real cases are selected in Phase 0 with the business team (roles still open) and merged with the existing ten-path check from appendix B. For each case a matrix is created from project/case ID, ERP vouchers, actual file paths, as-of date, permission variants and target behaviour. Missing file paths or uncovered variants remain open; ten complete cases are not claimed.

| Check | Evidence and approval status |
| --- | --- |
| Identity and idempotency | Customers with the same name remain separate; the same import, parallel runs and replay produce zero duplicate projects or task candidates per occasion. |
| Rule quality | Precision per rule = business-correct risk notifications / reviewed risk notifications. Report number and test cases, false alarms, missed cases and exclusions due to `unknown`/`stale`; without notifications precision is not computable. Approve the threshold per rule **[O]** before evaluation. |
| Evidence | Each risk entry reproducible from rule version and authorised source states. A missing report only where completeness is evidenced; an OCR error results in a review flag. |
| Sync and provenance | Simulate failure/partial import: the last successful sync remains correct, outdated is visible, no conclusion from a partial state. Source and business as-of date per value; import time separate. |
| Two-minute target | Measure end-to-end from a visible ERP change to API/display under pilot load; report run time, P95 and failures. Target approx. 2 minutes **[P]**; final measurement boundary and tolerance **[O]**. |
| Unknown values | Unknown, null, confirmed absent and not applicable remain distinguishable; unknown does not produce a negative factual claim. |
| Tasks and confirmation | Despatch, order, end of assembly and due date trigger. One candidate per occasion; source, person, deadline present. Missing fields prevent confirmation. LLM cannot call confirm. |
| Phase rules | A partial delivery does not release assembly; the end of an appointment does not report completion; payment does not close; a later complaint references the same project. The assistant writes back no phase. |
| Rights | 0 tolerated permission leaks, including monitor amounts, search snippet, chat, preview, risk, export, direct API call, cache and permission revocation. Frontend hiding alone does not pass the test. |
| Fallback and restart | Excel remains flagged, provenance and as-of date visible; conflicts are checked. Return to the ERP source and restore produce no duplicates. |

**[E]** Ten pilot cases do not replace the frozen photo/RAG test set or sufficient examples per rule. Missing business positive/negative cases are added; thresholds must be decided before measurement. A passed pilot is not an automatic rollout approval.

## 15 Implementation plan and priorities

The sequence minimises technical dependencies and leads early to verifiable results. Timings are deliberately open because GPU, data access, file volumes and team capacity are not yet fixed.

**First development tasks**

**[E]** Before the Phase-0 ACL gate is passed, use exclusively synthetic data or explicitly approved isolated test data. No indexing of production files before the gate is passed.

- Create the repository with `backend/`, `frontend/`, `infrastructure/`, `tests/` and `docs/`.
- Define a minimal database design for `source_files`, `photo_labels`, `document_chunks`, `acl_entries`, `order_file_links`, `index_jobs` and `outbox`.
- Implement a read-only file scanner with path normalisation and hash detection.
- Build an end-to-end test: a photo source is registered, embedded and found via the API.
- Collect a small reference set of German search questions together with the expected files.

**Implementation and gates**

| Phase | Deliverable and exit |
| --- | --- |
| 0 Preliminary clarification **[P]** | Ten cases with the business team (roles still open) plus ten-path matrix; check IN-FORM/ODBC/32-bit/modules/voucher reference; field catalogue and source IDs; ACL gate, role draft as well as data protection/works council questions. Present open shared infrastructure as a decision. |
| 1 Basic framework **[E]** | Retain the existing modular monolith; add adapter boundary, provenance contract and rule versioning. No shared service without a decision. |
| 2 Data ingestion **[P/E]** | Read-only sync separate from OCR; upserts, `last_success_at`, `unknown`/`stale`, Excel fallback import and conflict check. Exit: replay and failure without duplicates/partial-state illusion. |
| 3 Photo MVP | Content scope remains unchanged; a verified project ID may supplement existing search filters. |
| 4 Document RAG **[P/E]** | References, as-of date and phase context; unknown data leads to review flags. |
| 5 Consultation **[P/E]** | Suggestion contract with source, person, deadline; human confirmation; no binding effect. |
| 6 Dashboard risks **[P/E]** | **[E]** Approved selection from R1–R5 (R4 initially excluded), occasion deduplication, review, monitor field filter and freshness check. |
| 7 Pilot approval **[P/E]** | Ten-case acceptance plus quality sets; precision per rule, zero permission leaks, failure display, restore; IT, business department and data protection review their respective gates. |
| 8 Further development **[O]** | Board integration or confirmed write-back channel only after a separate decision. Calendar, service, finance view and deployment planning remain outside the assistant. |

**[E]** The implementation includes no project board implementation phase. As first tasks, field catalogue, ID constraints, sync status contract and `rule_versions`/`task_candidates` are modelled in addition to the existing file register. **[E]** See figure 17.

### Figure 17 – Roadmap with gates (p. 47)

**Labels as shown in the figure:**

- Phases: 0 Preliminary clarification **[P]** → 1 Basic framework **[E]** → 2 Data ingestion **[E]** → 3 Photo MVP **[E]** → 4 Document RAG **[E]** → 5 Consultation **[E]** → 6 Dashboard risks **[E]** → 7 Pilot approval **[E]** → 8 Further development **[O]**
- **Gate after phase 0 [E]:** ACL with two identities; maximum age; ten-case matrix; IN-FORM check; data protection / works council; before that only synthetic / isolated test data
- **Gate after phase 2 [E]:** replay and failure without duplicates or partial-state illusion
- **Pilot approval [E]:** ten-case acceptance + quality sets; precision per rule; zero permission leaks; failure display; restore; approvals from IT, business department, data protection; no automatic rollout approval

**[E]** Arrows: state transitions; dashed: open handover / proposal.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 17: Roadmap with gates;** logical data flow, not a network plan. Reading note: gates show evidence and dependencies; duration and dates remain open.

## 16 Open architecture decisions

The following questions originate from open points of the project plan or from this technical elaboration. They influence security, data model or performance and should be clarified before larger implementation steps.

**[O]** Decisions and priorities are maintained exclusively in appendix C. These include folder meaning, UNC/identity/ACL, hardware, IDs, data processing, rule evidence, preview/export as well as a possible manually approved channel for external general questions outside the MVP.

### Infrastructure options

**[P/O]** The relationship between assistant and project board is to be decided by the company and IT. The following variants can be combined; none is presented as decided.

| Option | Benefit and trade-off |
| --- | --- |
| Separate ODBC adapters | Independent releases and failure boundaries; duplicate mapping maintenance and additional ERP load. A shared field catalogue and ID contract are still required. |
| Shared ODBC adapter | Uniform provenance, sync and error handling; shared operational responsibility and failure dependency. Safeguard read rights and interface versions separately. |
| Separate PostgreSQL data storage | Clear data ownership and separate restores; exchange contract and reconciliation required. |
| Shared PostgreSQL | Less duplicate storage and shared transactions possible; stronger coupling, schema/migration and permission conflicts. A shared instance does not automatically mean shared tables. |
| Shared login and roles | Uniform identity and fewer logins; keep role/claim contract and revocation consistent. Source and field rights remain required in both APIs. |
| Separate identity integration | Independent introduction; assignment, duplicate maintenance and rights revocation more costly. |
| Display AI suggestions in the board | Suggestions in the work context; clear owners for confirmation, status and audit as well as a versioned API required. |
| Own assistant interface | Simpler business boundary; context switching and possible duplicate task displays. Explicitly define the leading task source. |

**[O]** The unconfirmed determinations including leading phases/tasks, roles, exports, data ownership, deadlines and thresholds are captured in appendix C with source traceability. No infrastructure variant is decided. **[E]** See figure 18.

### Figure 18 – Infrastructure options (p. 49)

**Labels as shown in the figure:**

- **[O] No variant decided**
- **Separate [O]:** assistant [O] — ODBC adapter · `postgres` · login; project board [O] — own ODBC adapter · `postgres` · login. Independent releases / failure boundaries; duplicate mapping maintenance and ERP load.
- **Shared [O]:** assistant + project board [O] — shared ODBC adapter; shared PostgreSQL instance; shared login / roles. Shared operation; coupling and failure dependency.
- **Display in the project board [O]:** AI suggestions in the work context; clarify ownership / confirmation / audit and a versioned API.
- **Own interface [O]:** clear assistant boundary; avoid context switching / duplicate displays; define the leading task source [O].
- A shared instance does not automatically mean shared tables. Source and field rights remain in both APIs. All variants are exclusively read-only towards IN-FORM and SMB.

**[E]** Arrows: data flow. Solid: within scope; dashed: open/optional.
**[E]** 2 pt frame: trust zone. All source access exclusively read-only.
**[E]** **Figure 18: Infrastructure options;** logical data flow, not a network plan. Reading note: data storage, identity and display location are combinable, still open decisions.
# Appendix A – Technical appendix

## A.1 Recommended project structure

**[E]** Modular backend codebase; `erp-sync` is the service name, `erp_sync/` the Python adapter folder.

```text
company-ai-assistant/
  backend/
    api/ auth/ database/
    ingestion/ vision/ retrieval/
    assistant/ risks/ rules/ workers/ erp_sync/
  frontend/ tests/
  infrastructure/ docs/
```

## A.2 Metadata contract

**[E]** `source_file_id`, `access_scope_id` and `model_version` remain separate references. Customer name and example folder are search metadata, not join keys. Machine labels are unconfirmed candidates; confirmed absence requires documented evidence. The JSON examples of the original document are replaced by the explicit contracts in A.3/A.5 so that no invented company data appears as example values.

## A.3 API response contract

**[E]** Response object: `answer`, `sources`, `insufficient_evidence`. Every source contains `source_file_id`, `page_ref`, `chunk_id`, `source_ref` and `source_as_of`, insofar as these exist for the source type; missing details are reported as unknown. Every business value contains `value`, `value_state`, `source_ref`, `source_as_of`, `imported_at` and `freshness_state`. `value=null` alone is not proof of state; `value_state=unknown` makes the lack of knowledge explicit.

## A.4 Source situation and status

**[E]** The evidence source of this revision is architecture v1.2 (48 pages). The project requirements adopted from it are retained. **[O]** The original project plan and blueprint are to be reviewed separately. AD/Windows integration, container approval, ODBC installation, data inventory, folder names, ACLs and file links are open. The pilot is exclusively read-only towards SMB and IN-FORM.

## A.5 Enum and identifier catalogue

**[E]** The following values apply uniformly as a proposed technical contract. Existing open business decisions are not approved by this. Newly completed values for `freshness_state`, suggestions, task candidates, index/sync and `sensitivity_class` require confirmation (OP-20).

| Field / enum | Permitted values **[E]** |
| --- | --- |
| `value_state` | `known`, `unknown`, `not_applicable`, `confirmed_absent` |
| `freshness_state` | `fresh`, `stale`, `unknown` |
| `match_status` | `ungeklärt` (unresolved), `Kandidat` (candidate), `bestätigt` (confirmed), `verworfen` (rejected) |
| `suggestions.status` | `draft`, `confirmed`, `dismissed` |
| `risks.status` | `erkannt` (detected), `in Prüfung` (in review), `bestätigt` (confirmed), `gelöst` (resolved), `verworfen` (dismissed) |
| `task_candidates.state` | `Kandidat` (candidate), `bestätigter Kandidat` (confirmed candidate), `verworfen` (dismissed) |
| `source_files.ingestion_status` / `index_jobs.job_status` | `pending`, `processing`, `ready`, `error` |
| `sync_runs.status` | `running`, `succeeded`, `failed` |
| `sensitivity_class` | `amount_free_verified`, `restricted`, `unknown` |

**[E]** Display name "Draft" = `suggestions.status=draft`; "confirmed" = `confirmed`; "dismissed" = `dismissed`. "Confirmable" is derived from complete mandatory fields and current evidence. Risk Acknowledge = in review; Confirm = confirmed; Resolve = resolved; Dismiss = dismissed. The process displays *Fresh*, *Run active*, *Error*, *Outdated*, *Fallback state* and *Return/reconciliation* are not `value_state` values. `freshness_state=stale` concerns ageing, not business absence.

**[E]** The index status `ready` is set only after atomic publication. Task events are not states; a confirmed candidate means neither an operational task nor an ERP action. The intended transitions for dismissing task candidates are to be approved by the business side **[O]**.

| Identifier group | Canonical names **[E]** |
| --- | --- |
| Container | `reverse-proxy`, `web`, `api`, `indexer`, `erp-sync`, `postgres`, `qdrant`, `ollama`, `redis` (optional) |
| Roles | `monitor`, `staff`, `office`, Technical Administration |
| Functional rights | `finance.read`, `export.execute`; concrete names of further review/business rights **[O]** |
| Tables / collections | `source_files`, `customers`, `projects`, `source_records`, `order_file_links`, `photos`, `photo_labels`, `documents`, `document_chunks`, `acl_entries`, `index_jobs`, `outbox`, `audit_events`, `source_systems`, `field_catalog`, `field_values`, `sync_runs`, `fallback_imports`, `rule_versions`, `rule_runs`, `task_candidates`, `suggestions`, `risks`, `risk_evidence`, `project_phase_events`, `photo_embeddings`, `text_chunks` |
| Tools | `search_photos`, `search_documents`, `open_file`, `get_risks`, `get_project_facts`, `get_sync_status`, `get_task_candidates`, `draft_suggestion` |
| Response/transport fields | `source_ref`, `source_refs`, `source_as_of`, `imported_at`, `data_as_of`, `age_seconds`, `freshness_state`, `value_state`, `object_version`, `answer`, `sources`, `insufficient_evidence` |
| Filters and search parameters | `scope_filter`, `label_filter`; all values validated server-side |

## A.6 Metrics and thresholds

**[E]** Figures are not approved by this editorial revision. Technical identifier numbers (API version, HTTP codes, rule/chapter numbers), date/version details and purely example values are not business thresholds; they are captured separately in the complete source inventory.

| Value | Status [P]/[E]/[O] | To be approved by **[E]** |
| --- | --- | --- |
| 60 s maximum ACL age | **[O]** discussion value | IT |
| Precision@10 ≥ 85 %; ≥ 9 correct with 10 hits | **[E]** discussion value; approval **[O]** | Business department |
| Recall@20 ≥ 85 %; 20/0.85 ≈ 23.5; >23 relevant photos problematic | **[E]** discussion value; alternative **[O]** | Business department |
| ≤20 relevant photos or R-precision / Recall@max(20, number of relevant photos) | **[E]** discussion proposal | Business department |
| 95 % correct sources; number of questions unknown | **[O]** discussion value / test scope open | Business department |
| 0 permission leaks | **[E]** acceptance discussion value; approval **[O]** | IT / Data Protection Officer |
| approx. 2 min ERP sync | **[P]** project goal; measurement boundary and tolerance **[O]**; check blueprint | IT / Business department |
| 5–7 days follow-up | **[O]** to be checked against blueprint | Business department |
| 10 calendar days OPOS | **[O]** to be checked against blueprint and applicability | Business department |
| 1,000 pilot photos | **[E]** discussion value | Business department |
| 10–20 search queries; 100–200 label images | **[E]** discussion values | Business department |
| 10–20 evidenced risk examples | **[E]** discussion value | Business department |
| 24 / 48 GB VRAM; possibly more | **[O]** test hypotheses; benchmark before procurement | IT |
| 10 real pilot cases / ten-path matrix | **[P]** project requirement; selection **[O]** | Business department |
| at least 2 identities; test with 2 PCs | **[E]** review requirement; execution **[O]** | IT |
| 3–5 pilot rules; catalogue R1–R5, R4 initially excluded | **[E]** discussion value; selection **[O]** | Business department |
| 7 phases; 4 standard tasks | **[P]** adopted requirement; check blueprint **[O]** | Business department |
| 1 candidate per occasion; 0 duplicates | **[P]** occasion principle; **[E]** technical acceptance | Business department / IT |
| daily outbox/Qdrant reconciliation | **[E]** operating recommendation | IT |
| 1 web; 1 api; 1 indexer; 1 erp-sync; at least 1 AI runtime | **[E]** minimum deployment | IT |
| 1 GPU machine; 32/64-bit compatibility | **[O]** hardware/driver check | IT |
| P95 latency; threshold unknown | **[O]** agree metric and limit | IT / Business department |

# Appendix B – IT checklist

**[E]** Single operational checklist; every line requires evidenced proof. The question groups of both previous checklists are merged. Roles and gate assignment are proposals.

| Check question | Evidence | Responsible **[E]** | Blocks gate **[E]** | Status |
| --- | --- | --- | --- | --- |
| What is the UNC mapping (target unknown **[O]**) really? | UNC target (`\\server\share`), SMB version, owner, read access and permissible scope. | IT / Business department | Phase 0 | **[O]** Evidence pending; OP-03 |
| Who logs on? | Windows account, local identity, AD/Entra or guest access; test with two PCs. | IT | Phase 0 | **[O]** Evidence pending; OP-04 |
| Are rights really identical? | Compare effective rights on public and restricted folders with two accounts. | IT | Phase 0 | **[O]** Evidence pending; OP-04 |
| ACL on revocation? | Test revocation: search hits, snippet, preview, RAG and risk must no longer output anything. | IT | Phase 0 | **[O]** Evidence pending; OP-04 |
| Where do orders live? | **[P/O]** Check IN-FORM DSN, driver/32-bit compatibility, DBMS, read-only access, modules, tables, voucher references and data owners. | IT / ERP responsibility | Phase 0 | **[O]** Evidence pending; OP-01 |
| What are the folders called? | **[P]** Merge ten real cases with the business team (roles still open) using the ten-path check; check customer, project ID, date and voucher reference. | Business department | Phase 0 | **[O]** Evidence pending; OP-07 |
| Which join key? | **[P]** Document a unique project/case ID including collisions and alias cases; no identity from customer names. | Business department / IT | Phase 0 | **[O]** Evidence pending; OP-02 |
| Who corrects labels? | Business roles only; change history and an independently frozen test set. | IT / Business department | Phase 0 | **[O]** Evidence pending; OP-08 |
| Works council / DPIA? | HR and DPO review co-determination and the necessity of a DPIA. | Data Protection Officer / works council, where one exists | Phase 0 / Pilot approval | **[O]** Evidence pending; OP-13 |
| IN-FORM on site **[P]** | DSN, DBMS, read-only account; test driver/process bitness and container/bridge capability; log modules, available fields and voucher references. | IT / ERP responsibility | Phase 0 | **[O]** Evidence pending; OP-01 |
| Ten cases and paths **[P]** | Select ten real cases with the business team (roles still open); assign the existing ten path checks to these cases. Document IDs, sources, as-of dates and missing links. | Business department | Phase 0 | **[O]** Evidence pending; OP-07 |
| Field catalogue **[P]** | Confirm source, source ID, field, as-of date, maintenance responsibility and fallback path per required field. Inaccessible fields explicitly open. | Data maintenance / Business department | Phase 0 | **[O]** Evidence pending; OP-05 |
| IDs and duplicates **[P]** | Test customers with the same name, multiple cases, repeated import and parallel replay; no name joins as identity. | Business department / IT | Phase 0 | **[O]** Evidence pending; OP-02 |
| Sync failure **[P]** | Test abort, partial import, last success, stale display and the two-minute target under load; document freshness limits. | IT / Data maintenance | Phase 0 / Pilot approval | **[O]** Evidence pending; OP-06 |
| Excel fallback **[P]** | Approve responsible person and import template; test provenance, as-of date, conflicts and return to ERP traceably. | Data maintenance / Business department | Phase 0 | **[O]** Evidence pending; OP-05 |
| Roles and monitor **[P]** | Block amounts also in citations/files; commercial details/export only with confirmed right. Live ACL check and revocation with at least two identities. | IT / Business department | Phase 0 | **[O]** Evidence pending; OP-08 |
| Rules and suggestions **[P]** | Evidence business phases, deadlines, occasion keys, sources, responsible persons, confirmation and review; no binding AI actions. | Business department | Pilot approval | **[O]** Evidence pending; OP-09 |
| Shared infrastructure **[O]** | Record in writing the decision on adapter, PostgreSQL, login/roles, leading tasks and display location. | IT / Business department | Before shared use | **[O]** Evidence pending; OP-11 |
| DPO and works council **[O]** | Work through the open review assignments from chapter 11 including Art. 22/35 GDPR and § 87 (1) No. 6 BetrVG. | Data Protection Officer / works council, where one exists | Phase 0 / Pilot approval | **[O]** Evidence pending; OP-13 |
| EU AI Act | Review result without any anticipated claim of obligations | Data Protection Officer | Phase 0 / Pilot approval | **[O]** OP-18 |
| Monitor allowlist | Server-side default-deny; amount-free document types and negative tests | IT / Business department | Before monitor approval | **[O]** OP-15 |

**Approval to start the technical pilot phase** The file server is reachable read-only only. The accounts used and effective access rights are tested. A maximum staleness and live check are defined. Pilot data and ODBC queries are approved in writing. Data protection and, where applicable, the works council are involved at an early stage.
# Appendix C – Register of open items

**[E]** Consolidated decision topics; all individual evidence remains in the traceability section. Responsibilities and gate assignment are proposals, not person assignments. Multi-part source items are retained in full text; the OP ID is their coordinating topic.

| ID | Question / decision | Category | Responsible (role) **[E]** | Blocks gate **[E]** | Status | Chapters |
| --- | --- | --- | --- | --- | --- | --- |
| OP-01 | Which IN-FORM version, DBMS, ODBC driver, bitness, DSN, modules and readable voucher references are evidenced? | Source installation | IT / ERP responsibility | Phase 0 | **[O]** | 04, 06, 12 |
| OP-02 | Which unique project/case IDs, voucher relationships, file links and business terms are evidenced? | Source identity | Business department / IT | Phase 0 | **[O]** | 05 |
| OP-03 | What are the UNC path, SMB version, owner, pilot scope and meaning of the folder names? | File storage | IT / Business department | Phase 0 | **[O]** | 01, 04 |
| OP-04 | Which identity source, live ACL check, revocation logic and maximum ACL age are approved? AD/SSO remains open. | Identity and rights | IT | Phase 0 | **[O]** | 05, 11 |
| OP-05 | Which fields, source timestamps, responsibilities, fallback paths and conflict decisions are evidenced? | Field catalogue and data maintenance | Data maintenance / Business department | Phase 0 | **[O]** | 05, 06 |
| OP-06 | How are the two-minute target, tolerances, data age, failure escalation and maintenance windows defined? | Sync and freshness | IT / Data maintenance | Phase 0 / Pilot approval | **[O]** | 06, 12, 14 |
| OP-07 | Which ten cases, paths, permission variants and positive/negative examples are fully covered; who forms the business team? | Pilot cases and business team | Business department | Phase 0 | **[O]** | 14, 15, B |
| OP-08 | Who receives `monitor`, `staff`, `office`, Administration, `finance.read`, `export.execute`, label correction, review and confirmation? | Roles and functions | IT / Business department | Phase 0 | **[O]** | 10, 11 |
| OP-09 | Which selection R1–R5, occasion definitions, severity, deadlines, responsibilities, reopenings and precision limits are approved? R4 remains excluded. | Rules and review | Business department | Pilot approval | **[O]** | 09, 14 |
| OP-10 | Where are phases, material checks, tasks and approvals maintained as the leading source; how does any handover take place? | Phases and tasks | Business department / IT | Before R4 / Integration | **[O]** | 09, 16 |
| OP-11 | Which shared/separate adapters, PostgreSQL instances, logins and display locations are operated, and by whom? | Infrastructure | IT / Business department | Before shared use | **[O]** | 04, 12, 16 |
| OP-12 | Which hardware, parallelism, containerisation, runners, model licences and benchmarks are approved? | Hardware and models | IT | Phase 0 / Procurement | **[O]** | 12, 13 |
| OP-13 | What results do Art. 22/35 GDPR and § 87 (1) No. 6 BetrVG deliver; purposes, deletion periods, audit and involvement? Do not anticipate any legal decision. | Data protection and involvement | Data Protection Officer / works council, where one exists | Phase 0 / Pilot approval | **[O]** | 11 |
| OP-14 | Are later candidates, a separate write channel or a manual channel for external general questions desired? Not part of the pilot. | Later extensions | Business department / IT / Data Protection Officer | Before extension | **[O]** | 03, 09, 16 |
| OP-15 | Confirm default-deny for free text/chunks and `sensitivity_class`; define amount-free document types, verification and revocation of the allowlist. | Monitor allowlist | IT / Business department | Before monitor approval | **[O]** | 05, 11 |
| OP-16 | Approve the F9 alternative, number of RAG test questions, evaluation denominator and thresholds before measurement. | Search and source metrics | Business department | Before evaluation | **[O]** | 07, 14 |
| OP-17 | Check 5–7 days, 10 calendar days, seven phases, four standard tasks and the two-minute target against the blueprint to be submitted separately. Existing **[P]** remain in place. | Blueprint evidence | Business department | Phase 0 | **[O]** | 06, 09, 14 |
| OP-18 | Review the concrete use with regard to the EU AI Act; no claim of obligations by this architecture. | EU AI Act | Data Protection Officer | Phase 0 / Pilot approval | **[O]** | 11 |
| OP-19 | Confirm the roles of the four named persons; do not derive a role from a name. | Person assignment | Business department | Phase 0 | **[O]** | Document control |
| OP-20 | Confirm rule engine, risk mapping, neutral IDs, enums, schema additions and optional export API. | Technical proposals | IT / Business department | Before implementation of the respective contract | **[O]** | 04, 05, 09, 10, A |
| OP-21 | Explicitly approve all metrics, test scopes and thresholds from A.6 including zero permission leaks; no automatic contractual determination. | Approval values | IT / Business department | Before evaluation / Pilot approval | **[O]** | A.6 |
| OP-22 | Evidence missing original documents and open scope/status questions; do not assume any optional document contents. | Source status and delimitation | Author / Business department | Phase 0 | **[O]** | 01, 03, A.4 |

## Traceability

| Old item / new addition | OP ID | Retained review mandate / context |
| --- | --- | --- |
| p. 1, block 14 | OP-11 | IN-FORM and stable IDs; source and as-of date per value; sync failure and Excel fallback channel; rule-bound standard tasks; phase logic; monitor and export rights; ten shared pilot cases. Shared infrastructure remains open. |
| p. 1, block 15 | OP-22 | **[P]** project requirement **[E]** recommendation **[O]** open |
| p. 2, block 17, row 6 | OP-10 | 6 standard tasks / 03, 05, 09–10, 14–16, B / fixed rules and one candidate per occasion; leading task list open. |
| p. 2, block 17, row 10 | OP-11 | 10 shared infrastructure / 03–04, 12, 15–16, A/B / leave adapter, PostgreSQL, identity and display location open with options. |
| p. 3, block 24, row 1 | OP-01 | ERP/ODBC only presumed; DB type unknown (01/04). / IN-FORM is named, ODBC read-only. / Adopt ERP name **[P]**; DBMS, installation, drivers and modules remain **[O]**. |
| p. 3, block 24, row 2 | OP-02 | Provisional customer links and name mapping (04/05/15/16). / Unique project/case IDs. / Names remain a search aid. Reliable link only with a confirmed source ID; unclear assignments open. |
| p. 3, block 24, row 5 | OP-09 | No LLM write access (03/10/11). / Write-back only via a confirmed channel; operational tasks/phases in the board. / Read-only pilot remains. Local candidates/review permissible; ERP writing and leading board tasks remain a separate open decision. |
| p. 3, block 24, row 8 | OP-05 | Consultation proposal without mandatory schema (08). / Source, person, deadline and human confirmed. / Draft may show open fields; confirmable only once complete. No binding effect from an AI output. |
| p. 4, block 26, row 1 | OP-11 | Customer/project metadata locally leading (04/05). / IN-FORM supplies business data; board maintains operational additions. / Separate local technical metadata from business data ownership; disclose responsibility per field and shared infrastructure. |
| p. 4, block 28 | OP-02 | All resolutions are architecture proposals within the project requirements. Open company and IT decisions are not presented as already confirmed. |
| p. 6, block 60 | OP-04 | Observed: employees open a mapped network drive in Windows Explorer in the manner of a UNC mapping (target unknown **[O]**) without a separate password prompt. **[P]** IN-FORM is named as the ERP; the intended access is read-only via ODBC. **[O]** Photos and documents are still presumed to reside on an SMB share; technical connections are to be confirmed on site. Unresolved: whether Windows uses automatic logon, whether rights apply per person, whether folders carry customer names and whether ERP order numbers are linked to files. |
| p. 7, block 83 | OP-11 | **[O]** Installation, available fields, role approvals and shared infrastructure are to be confirmed on site. |
| p. 7, block 86, row 14 | OP-02 | 16 / Open architecture decisions |
| p. 8, block 91 | OP-11 | Project requirement: originates from the provided project plan. Recommendation: architecture addition for implementation. Open: requires agreement with the business department or IT. The diagrams show logical data flows. They replace neither a final network approval nor complete infrastructure planning. |
| p. 8, block 98 | OP-17 | **[P]** project requirement also designates the requirements of the project board blueprint adopted in this revision. **[E]** recommendation designates their technical implementation, not an already confirmed company decision. **[O]** open designates missing evidence, assumptions or pending decisions. The markers work without colour. An unmarked existing section retains its previous status; new additions carry a marker. The preceding parts A and B document change impact and conflicts. Part C contains the complete architecture with unchanged chapter numbering 01 to 16 as well as appendices A and B. Part D bundles at most ten questions for the company and IT. |
| p. 10, block 135 | OP-22 | **[P]** Every displayed business value has a source and an as-of date. Unknown means neither zero nor not present. Missing mandatory data leads to a review flag. Every AI recommendation contains source, responsible person and deadline and requires human confirmation. If person or deadline cannot yet be determined, they remain explicitly open; the draft is not executable until completed and confirmed. |
| p. 10, block 146 | OP-17 | **[O]** Calendar, service and minor-repair list, commercial finance view, cut-off date export, post-calculation, deployment planning and route planning belong to the separate project board. The assistant does not take over any of these operating functions. What remains relevant from the blueprint are its data, permission and phase rules. After-sales service appointments and their automatic creation are also not to be implemented here. The display of AI suggestions within the board is an open integration option in chapter 16. |
| p. 12, block 165 | OP-04 | In Windows, a network drive apparently appears in the manner of a UNC mapping (target unknown **[O]**). This is normally a local mapping on the workstation PC, not a permanently valid path for the AI server. After IT approval, the server connects via a UNC path such as `\\fileserver\share`. The real name is still unknown. |
| p. 12, block 170, row 2 | OP-01 | Business data **[P/O]** / ODBC to IN-FORM; fixed read-only adapter. / IN-FORM named; DBMS, driver, bitness, modules, tables and voucher references open on site. |
| p. 12, block 170, row 3 | OP-02 | Linking / **[P]** unique project/case ID; names only as a search aid. Check file reference in the file register. / **[O]** Verify the meaning of folder names and a reliable link to the IN-FORM ID. |
| p. 12, block 170, row 4 | OP-04 | User rights / app login and roles; file rights from the actual source. / Open: Windows could authenticate transparently. |
| p. 14, block 207 | OP-12 | **[P]** Projects and cases are linked via unique source IDs. Customer names, folder designations and similarity are only search aids; without a confirmed ID mapping a file link remains unresolved. A language model does not confirm a mapping. |
| p. 14, block 212 | OP-11 | **[E]** A separate ERP sync worker uses fixed, parameterised read queries and normalises approved fields. PostgreSQL holds local metadata and review states; IN-FORM remains the source of the business data maintained there. No operational project board data ownership is defined here. **[O]** Shared adapter, shared database, login and display location of the suggestions remain variants in chapter 16. |
| p. 15, block 222, row 2 | OP-02 | `customers` / `projects` / **[P/E]** internal ID plus unique source project/case ID. Name and alias only search metadata; unresolved mapping remains open. |
| p. 18, block 270 | OP-02 | **[E]** `value_state` distinguishes `known`, `unknown`, `not_applicable` and `confirmed_absent`; `stale` is a separate freshness attribute and not a value. Null remains distinct from `unknown`. `source_as_of` designates the business source as-of date, `imported_at` the import time. A missing source timestamp is shown as unknown; an import time does not replace it. |
| p. 21, block 315 | OP-06 | **[P]** On failure the interface shows the last successful sync, the error status and the outdated marker. **[O]** The measurement point, permissible delay and business freshness limits per rule are decided before the pilot. |
| p. 21, block 328 | OP-14 | **[P]** Writing back is conceivable only via a confirmed channel and is not part of the read-only pilot. There is no LLM write access and no generic SQL write interface. **[O]** A later business write channel requires a separate interface and approval decision. |
| p. 22, block 342 | OP-02 | • Uncertain hits: door present, window status unknown or low confidence. |
| p. 24, block 385 | OP-05 | **[E]** The output contains `status=draft`, `source_refs`, `data_as_of`, `proposed_owner_id` and `proposed_due_at`. Persons and deadlines are taken from approved specifications or marked as to be confirmed; they are not invented as known company decisions. A human with business authorisation completes open fields and confirms. The API then checks rights, current evidence and object version again. A confirmation documents a recommendation; it does not trigger an ERP posting or assembly release. |
| p. 25, block 409 | OP-22 | • Delivery date exceeded and order still open according to the source system. |
| p. 25, block 410 | OP-14 | • **[O]** Review multiple complaints only later: NLP supplies candidates; case assignment and fixed risk rule are to be confirmed by the business side. |
| p. 26, block 413 | OP-14 | • **[O]** Review unanswered quotations and photo damage later; only fixed rules with authorised evidence create risks. AI image findings remain candidates. A "missing document" must not appear as a business risk in the case of OCR errors, unsorted files or incomplete indexing. In such cases a data quality problem is displayed. Risks with multiple pieces of evidence are shown in the pilot only if the user has access to all associated sources. Initially the dashboard contains no personal processing-time metrics. "Ask AI" loads exclusively approved evidence. |
| p. 26, block 428, row 2 | OP-17 | Follow-up / rule task after despatch, according to the blueprint configurable after 5–7 days. **[O]** The concrete value and deadline calculation are to be approved. Order leads to AV in business terms; cancellation ends the resubmission. |
| p. 27, block 436 | OP-11 | **[P]** Standard tasks are rule-bound: follow-up after quotation despatch, order-confirmation check after ordering, feedback after assembly or end of appointment, and OPOS check at due date. One task per occasion. **[E]** For this purpose the assistant stores confirmable task candidates; the leading operational task list and its handover remain open until the infrastructure decision. A rule generates the candidate deterministically; the AI may formulate the explanation. |
| p. 27, block 438, row 2 | OP-22 | R2 Delivery overdue / verified delivery date, currently open order and reliable delivery status. A missing delivery status means unknown. |
| p. 27, block 438, row 4 | OP-09 | R4 Due standard task open / unambiguous occasion, approved deadline rule and known current task status. A missing board connection does not prove an uncompleted task. |
| p. 28, block 451 | OP-09 | **[E]** Lifecycle: detected → in review → confirmed → resolved or dismissed. Responsible reviewer, deadline, reason and timestamp are audited; permitted transitions are defined server-side. Unconfirmed AI candidates sit separately in the *draft* state. New evidence leads to a new assessment; a closed occasion is not silently reopened. **[O]** Responsibility and reopening rules for the review are decided by the business side. |
| p. 30, block 478, row 5 | OP-05 | `POST /api/v1/suggestions` / draft with source and optionally open mandatory fields; no operational execution. |
| p. 30, block 481 | OP-11 | **[P]** Source and as-of date apply also to search hits, citations, dashboard values and exports. **[E]** A shared metadata format prevents divergent display contracts. Missing fields are explicitly delivered as unknown. Monitor responses contain neither financial fields nor hidden raw values. |
| p. 30, block 486 | OP-09 | **[E]** HTTP 403 for missing functional rights, 409 for version/occasion conflicts and 422 for incomplete confirmations. Object existence must not be disclosed to unauthorised parties; consistent error handling is to be tested. Export remains optional, requires its own right and field filters. The model may read and propose drafts but must not itself execute any confirm, import, review-write or export approval. |
| p. 33, block 533 | OP-13 | **[O]** To be clarified with the Data Protection Officer: review Art. 22 GDPR in the concrete decision and confirmation process; document the scope and effectiveness of human review. No legal classification is anticipated by this architecture. |
| p. 33, block 537 | OP-13 | **[O]** To be clarified with the Data Protection Officer: necessity of a DPIA under Art. 35 GDPR, processing purposes, data minimisation, data subject rights and retention/deletion periods including vectors, suggestions and audit data. |
| p. 33, block 541 | OP-13 | **[O]** To be clarified with the works council, where one exists: possible co-determination under § 87 (1) No. 6 BetrVG for dashboard, tasks, responsibility assignment and logs. Personal performance or behaviour evaluation is not an approved function. Agree limits and access rights in writing. Reference for review: GDPR Art. 22 and 35, https://eur-lex.europa.eu/eli/reg/2016/679/oj ; BetrVG § 87, https://www.gesetze-im-internet.de/betrvg/__87.html . These points are open review assignments, not legal advice or approval. |
| p. 35, block 579 | OP-01 | **[E]** Separate `erp-sync` service with a read-only ODBC account and limited connection load. If only a 32-bit driver is available, a compatible isolated adapter or an approved driver change is examined. A Windows bridge service may be an option; platform and container capability are not assumed and remain open. |
| p. 35, block 588 | OP-11 | **[E]** Restore and replay must create neither duplicate standard tasks nor unmarked partial states. ODBC failure, broken driver, fallback import and return to the ERP source are rehearsed in the operations manual. **[O]** Responsible persons, escalation path, maintenance windows and freshness limits are defined by IT together with data maintenance. |
| p. 38, block 639 | OP-07 | **[P]** The ten real cases are selected in Phase 0 with the business team (roles still open) and merged with the existing ten-path check from appendix B. For each case a matrix is created from project/case ID, ERP vouchers, actual file paths, as-of date, permission variants and target behaviour. Missing file paths or uncovered variants remain open; ten complete cases are not claimed. |
| p. 38, block 640, row 2 | OP-16 | Rule quality / precision per rule = business-correct risk notifications / reviewed risk notifications. Report number and test cases, false alarms, missed cases and exclusions due to `unknown`/`stale`; without notifications precision is not computable. Approve the threshold per rule **[O]** before evaluation. |
| p. 38, block 640, row 5 | OP-07 | Two-minute target / measure end-to-end from a visible ERP change to API/display under pilot load; report run time, P95 and failures. Target approx. 2 minutes **[P]**; final measurement boundary and tolerance **[O]**. |
| p. 38, block 640, row 6 | OP-02 | Unknown values / unknown, null, confirmed absent and not applicable remain distinguishable; unknown does not produce a negative factual claim. |
| p. 39, block 649 | OP-12 | The sequence minimises technical dependencies and leads early to verifiable results. Timings are deliberately open because GPU, data access, file volumes and team capacity are not yet fixed. |
| p. 40, block 664, row 1 | OP-13 | 0 Preliminary clarification **[P]** / ten cases with the business team (roles still open) plus ten-path matrix; check IN-FORM/ODBC/32-bit/modules/voucher reference; field catalogue and source IDs; ACL gate, role draft as well as data protection/works council questions. Present open shared infrastructure as a decision. |
| p. 40, block 664, row 5 | OP-10 | 4 Document RAG **[P/E]** / references, as-of date and phase context; unknown data leads to review flags. |
| p. 40, block 664, row 9 | OP-14 | 8 Further development **[O]** / board integration or confirmed write-back channel only after a separate decision. Calendar, service, finance view and deployment planning remain outside the assistant. |
| p. 41, block 672 | OP-12 | The following questions originate from open points of the project plan or from this technical elaboration. They influence security, data model or performance and should be clarified before larger implementation steps. |
| p. 41, block 676, row 1 | OP-07 | Meaning of folder "Müller" / customer name is an assumption. Confirm folder structure with real examples. Business department. |
| p. 41, block 676, row 2 | OP-04 | Access to file permissions / UNC mapping (target unknown **[O]**) = mapping; demonstrate real UNC path, Windows SSO, ACL sync and live check. IT. |
| p. 41, block 676, row 3 | OP-12 | Server hardware and parallelism / GPU, RAM, storage media, number of concurrent users. IT/operations. |
| p. 41, block 676, row 4 | OP-02 | Order and project IDs / **[P/O]** check IN-FORM access and unique project/case ID including voucher/file reference on site. Name mapping is not proof of identity. ERP/IT. |
| p. 41, block 676, row 5 | OP-13 | Approvals for data processing / data protection/DPIA, works council if present, purpose and deletion periods. HR/data protection. |
| p. 41, block 676, row 6 | OP-07 | Evidence for risk rules / order assignment, index coverage and 10–20 real examples. Business department. |
| p. 41, block 676, row 7 | OP-08 | Preview and export rights / demonstrate source rights live; additionally define authorisation for label correction. IT. |
| p. 41, block 676, row 8 | OP-14 | External general questions / optional purely manual copy-paste channel only after separate approval. Not in the MVP. |
| p. 41, block 678 | OP-22 | • Approved pilot data and its lawful processing. |
| p. 41, block 679 | OP-04 | • Effective rights source, maximum ACL age and live check as a Phase-0 gate. |
| p. 41, block 681 | OP-12 | • An available GPU server and permitted containerisation. |
| p. 41, block 682 | OP-02 | • **[P]** Confirm file references to unique IN-FORM project/case IDs by means of real samples; names only as a search aid. |
| p. 42, block 685 | OP-07 | • A small business team that assesses test examples and search quality. |
| p. 42, block 687 | OP-02 | **[P/O]** The relationship between assistant and project board is to be decided by the company and IT. The following variants can be combined; none is presented as decided. |
| p. 43, block 693 | OP-01 | **[O]** IN-FORM driver and DBMS, modules and fields, project/case ID relationships, voucher/file references, leading operational phases and tasks, maintenance responsibility and deadlines must be evidenced in the field catalogue. The thresholds for data freshness, rule precision and sync measurement are open. Roles and exports are not derived from the designation "office". |
| p. 43, block 699 | OP-04 | **[O]** The ten bundled questions in part D serve the kick-off. The existing open points on UNC, ACL, hardware, data processing and evidence remain. |
| p. 44, block 750 | OP-04 | Source: provided project plan "Company AI Assistant: Project Summary". Initial decisions: local, RAG, photo and document search, risk dashboard, Python/FastAPI, Docker, PostgreSQL, Qdrant, Ollama, AD, read-only data access. New recommendations of this draft: modular monolith, uniform file register, explicit double ACL check, job versioning, specific API sketch, data model, architecture tests and acceptance checks. Added in version 1.2: provenance per value, IN-FORM sync status, occasion keys and human suggestion confirmation. Validity: target architecture for a pilot in version 1.2. IN-FORM is named as the ERP. Observations on the UNC mapping (target unknown **[O]**) are not IT confirmation; ODBC installation, data inventory, folder names, ACLs and file links remain open until on-site evidence. |
| p. 44, block 755 | OP-07 | **[E]** A business value is output with `value`, `value_state`, `source_ref`, `source_as_of`, `imported_at` and `freshness_state`. Example without invented company data: `value=null`, `value_state=unknown`, `source_ref=<verified source ID>`, `source_as_of=null`. The display reads *data as-of date unknown*; the import time is stated separately. |
| p. 45, block 760 | OP-02 | Rule reference as well as an object version. Missing mandatory values remain open and prevent confirm. A risk finding contains `rule_run_id` and authorised evidence states; an AI suggestion does not replace it. |
| p. 45, block 766 | OP-11 | **[P]** In addition to architecture v1.1 of 03.11.2026, the business requirements of the provided project board blueprint were integrated. IN-FORM is named as the ERP; its concrete installation is not confirmed. **[E]** New table, endpoint and status names are implementation proposals. **[O]** Shared infrastructure and data ownership are not decided. The layout reference document supplies exclusively design, no architectural requirements. |
| p. 45, block 775, row 1 | OP-03 | What is the UNC mapping (target unknown **[O]**) really? / UNC target (`\\server\share`), SMB version, owner, read access and permissible scope. |
| p. 45, block 775, row 2 | OP-04 | Who logs on? / Windows account, local identity, AD/Entra or guest access; test with two PCs. |
| p. 45, block 775, row 3 | OP-02 | Are rights really identical? / Compare effective rights on public and restricted folders with two accounts. |
| p. 45, block 775, row 4 | OP-04 | ACL on revocation? / Test revocation: search hits, snippet, preview, RAG and risk must no longer output anything. |
| p. 45, block 775, row 5 | OP-01 | Where do orders live? / **[P/O]** check IN-FORM DSN, driver/32-bit compatibility, DBMS, read-only access, modules, tables, voucher references and data owners. |
| p. 45, block 775, row 6 | OP-07 | What are the folders called? / **[P]** merge ten real cases with the business team (roles still open) using the ten-path check; check customer, project ID, date and voucher reference. |
| p. 46, block 777, row 1 | OP-07 | Which join key? / **[P]** document a unique project/case ID including collisions and alias cases; no identity from customer names. |
| p. 46, block 777, row 2 | OP-08 | Who corrects labels? / business roles only; change history and an independently frozen test set. |
| p. 46, block 777, row 3 | OP-13 | Works council / DPIA? / HR and DPO review co-determination and the necessity of a DPIA. |
| p. 46, block 789, row 1 | OP-01 | IN-FORM on site **[P]** / DSN, DBMS, read-only account; test driver/process bitness and container/bridge capability; log modules, available fields and voucher references. |
| p. 46, block 789, row 2 | OP-07 | Ten cases and paths **[P]** / select ten real cases with the business team (roles still open); assign the existing ten path checks to these cases. Document IDs, sources, as-of dates and missing links. |
| p. 46, block 789, row 3 | OP-05 | Field catalogue **[P]** / confirm source, source ID, field, as-of date, maintenance responsibility and fallback path per required field. Inaccessible fields explicitly open. |
| p. 47, block 791, row 1 | OP-02 | IDs and duplicates **[P]** / test customers with the same name, multiple cases, repeated import and parallel replay; no name joins as identity. |
| p. 47, block 791, row 2 | OP-06 | Sync failure **[P]** / test abort, partial import, last success, stale display and the two-minute target under load; document freshness limits. |
| p. 47, block 791, row 3 | OP-05 | Excel fallback **[P]** / approve responsible person and import template; test provenance, as-of date, conflicts and return to ERP traceably. |
| p. 47, block 791, row 4 | OP-04 | Roles and monitor **[P]** / block amounts also in citations/files; commercial details/export only with confirmed right. Live ACL check and revocation with at least two identities. |
| p. 47, block 791, row 5 | OP-09 | Rules and suggestions **[P]** / evidence business phases, deadlines, occasion keys, sources, responsible persons, confirmation and review; no binding AI actions. |
| p. 47, block 791, row 6 | OP-11 | Shared infrastructure **[O]** / record in writing the decision on adapter, PostgreSQL, login/roles, leading tasks and display location. |
| p. 47, block 791, row 7 | OP-13 | DPO and works council **[O]** / work through the open review assignments from chapter 11 including Art. 22/35 GDPR and § 87 (1) No. 6 BetrVG. |
| p. 48, part D, question 1 | OP-01 | Which IN-FORM version, which DBMS, which ODBC drivers and which 32/64-bit processes are actually available; which modules and voucher references may be read? |
| p. 48, part D, question 2 | OP-02 | Which unique project/case IDs and relationships apply, and how are ERP vouchers and SMB files demonstrably assigned to these IDs? |
| p. 48, part D, question 3 | OP-05 | Which fields are available, who maintains them and which source timestamp or fallback path applies per field; who checks conflicts from Excel? |
| p. 48, part D, question 4 | OP-06 | How is the target of roughly two minutes measured, which failure escalation and which maximum data ages apply per rule and view? |
| p. 48, part D, question 5 | OP-07 | Which ten cases does the business team select (roles still open), and which actual paths, permission variants and positive/negative cases do they cover? |
| p. 48, part D, question 6 | OP-08 | Which persons may use monitor, business view, commercial details, export, label correction, review and confirmation; how are UNC/source rights checked and revoked live? |
| p. 48, part D, question 7 | OP-09 | Which three to five rules, occasion definitions, deadlines, responsibilities, review transitions and minimum precision per rule are approved by the business side? |
| p. 48, part D, question 8 | OP-10 | Where are phases, material checks, tasks and human approvals maintained as the leading source, and how are completion, complaint reopening and task per occasion confirmed? |
| p. 48, part D, question 9 | OP-11 | Which combination of shared/separate ODBC adapter, PostgreSQL, login/roles and display of AI suggestions in the board is chosen; who operates them and which hardware is available? |
| p. 48, part D, question 10 | OP-13 | What results and approvals do the reviews with DPO and works council produce on Art. 22/35 GDPR, § 87 (1) No. 6 BetrVG, processing purposes, deletion and audit; is a later confirmed write channel desired at all? |
| New: F8 monitor default-deny and `sensitivity_class` | OP-15 | **[O]** Confirm default-deny for free text/chunks and `sensitivity_class`; define amount-free document types, verification and revocation of the allowlist. |
| New: F9 test questions, Recall alternative and metrics | OP-16 | **[O]** Approve the F9 alternative, number of RAG test questions, evaluation denominator and thresholds before measurement. |
| New: F16 missing blueprint | OP-17 | **[O]** Check 5–7 days, 10 calendar days, seven phases, four standard tasks and the two-minute target against the blueprint to be submitted separately. Existing **[P]** remain in place. |
| New: R9 EU AI Act | OP-18 | **[O]** Review the concrete use with regard to the EU AI Act; no claim of obligations by this architecture. |
| New: F20 roles of the four persons | OP-19 | **[O]** Confirm the roles of the four named persons; do not derive a role from a name. |
| New: F1/F4/F6/F19 technical proposals and new enums | OP-20 | **[O]** Confirm rule engine, risk mapping, neutral IDs, enums, schema additions and optional export API. |
| New: F18 approval of metrics | OP-21 | **[O]** Explicitly approve all metrics, test scopes and thresholds from A.6 including zero permission leaks; no automatic contractual determination. |
| New: optional sources not submitted | OP-22 | **[O]** Evidence missing original documents and open scope/status questions; do not assume any optional document contents. |
# Appendix D – Architecture decisions and conflict resolutions

| Requirement | Resolution | Status |
| --- | --- | --- |
| ERP/ODBC only presumed; DB type unknown (01/04). / IN-FORM is named, ODBC read-only. | Adopt the ERP name **[P]**; DBMS, installation, drivers and modules remain **[O]**. | **[E]** Resolution proposal; contained **[O]** items remain open |
| Provisional customer links and name mapping (04/05/15/16). / Unique project/case IDs. | Names remain a search aid. A reliable link only with a confirmed source ID; unclear assignments open. | **[E]** Resolution proposal; contained **[O]** items remain open |
| Indexing preferably outside core hours (06/12). / ERP sync about two minutes. | Clock the ODBC sync independently of OCR/GPU; the existing off-hours recommendation applies only to heavy indexing. | **[E]** Resolution proposal; contained **[O]** items remain open |
| Figure "AI review later" and later AI classification (09). / Rules decide, AI proposes. | AI side path produces candidates only; fixed versioned rules and human review for every dashboard risk finding. | **[E]** Resolution proposal; contained **[O]** items remain open |
| No LLM write access (03/10/11). / Write-back only via a confirmed channel; operational tasks/phases in the board. | The read-only pilot remains. Local candidates/review permissible; ERP writing and leading board tasks remain a separate open decision. | **[E]** Resolution proposal; contained **[O]** items remain open |
| Valid source rights open files (05/11). / Monitor without amounts, details/export only with rights. | Supplement the source ACL with field/function/view rights; redact or block sensitive previews. | **[E]** Resolution proposal; contained **[O]** items remain open |
| Ten paths and separate quality sets (07/14/B). / Ten cases with a named business team. | Shared case-path matrix; photo/RAG evaluation and sufficient rule examples remain additionally required. | **[E]** Resolution proposal; contained **[O]** items remain open |
| Consultation proposal without mandatory schema (08). / Source, person, deadline and human confirmation. | The draft may show open fields; confirmable only once complete. No binding effect from an AI output. | **[E]** Resolution proposal; contained **[O]** items remain open |
| Customer/project metadata locally leading (04/05). / IN-FORM supplies business data; board maintains operational additions. | Separate local technical metadata from business data ownership; disclose responsibility per field and shared infrastructure. | **[E]** Resolution proposal; contained **[O]** items remain open |
| Blueprint uses colours and contains calendar/finance/planning functions. / Black and white and a narrower assistant scope. | Adopt only relevant business rules; indicate status by text. Board operating functions outside scope. | **[E]** Resolution proposal; contained **[O]** items remain open |
| Live source-rights check versus no arrows into sources | Structural diagrams show only outbound permission data from the source. The sequence diagram uses a checking `api` self-action and an outbound check result from the source; no writing source action. | **[E]** R3/R7 before individual drawing specification |
| Permission formula once versus repetition in fig. 16 | Formula only in chapter 11; figure 16 refers to the contract. | **[E]** F15 |
| ERP target approx. 2 minutes versus discussion values | **[P]** project goal remains in place; measurement boundary/tolerance and blueprint evidence remain **[O]**. | **[P]**/**[O]** status integrity |
| Compact container view versus number of all services | The container view groups internal API modules and shows services completely. ER relationships are undirected references, not data flows. | **[E]** Diagram convention |

## Change report

**[E]** Basis: architecture v1.2, 48 pages. Corrections follow F1–F20. The original PDF was not modified. Page breaks and table splits are editorially consolidated; unmarked existing content retains its status.

| Chapter | Old → new / reason |
| --- | --- |
| 01 | F17/F20: neutral initial situation; four unverified assumptions retained; names centralised. |
| 02 | F12/F17: new front matter/appendix structure and a reading key. |
| 03 | R3/R8: scope retained; no operational board function added. |
| 04 | F1/F14: `erp-sync` and rule engine added; modules and minimum deployment; fig. 1/2. |
| 05 | F4/F6/F7/F8/F15/F19: one schema; neutral IDs; `match_status`; `sensitivity_class`; prose instead of pseudocode; fig. 3–6. |
| 06 | F1/F16: independent file/ERP tracks and error states; source remains read-only; fig. 7/8. |
| 07 | F9: existing search logic and test scopes retained; fig. 9. |
| 08 | F3/F19: suggestion contract and status unified; evidence interruption; fig. 10/11. |
| 09 | F4/F5/F16: one rule catalogue, R4 excluded, later candidates open, dashboard boundaries; fig. 12–14. |
| 10 | F2/F3/F4/F14: one endpoint catalogue, one risk PATCH row, export not a tool, new read/draft tools. |
| 11 | F8/F15/R9: monitor default-deny; formula once; EU AI Act review assignment; fig. 15/16. |
| 12 | F1: `erp-sync` and rule job in the Compose table; reference to fig. 2. |
| 13 | No new product selection; model/runner capability as open evidence instead of an unverified current assurance. |
| 14 | F9/F18/F20: metric problem explained, number of test questions open, persons only in the central table. |
| 15 | F10/F17: preliminary development only with synthetic/isolated test data; no production indexing before the gate; fig. 17. |
| 16 | F17/register: open tables in appendix C; narrative infrastructure consideration retained; fig. 18. |

| Area | Old → new |
| --- | --- |
| Front matter | Old parts A/B → short change log and appendix D; control, glossary, indexes added. |
| Appendix A | F1/F11/F12/F13/F18/F19: folders, open AD integration, A.1–A.6, contracts, enum catalogue and metrics. |
| Appendix B | Two checklists → one table; all source check questions retained. |
| Appendix C | Chapter 16, kick-off, unconfirmed determinations, legal reviews, part D, checklists and new points → OP-01 to OP-22 with complete context evidence. |
| Status | No **[O]**→**[E]**/**[P]** or **[E]**→**[P]** approval. A.4 AD corrected to open (F11). R4 excluded as open (F5). Existing mixed [P/E]/[P/O] are not treated as a new approval. |
| Terminology | `order_id`/`order_ref` → `external_case_id`; `suggestions.state` → `suggestions.status`; `proposed_owner` → `proposed_owner_id`. `match_confidence` → `match_status`, optional `match_score`. |
| Examples | A.2/A.3 synthetic JSON examples → explicit metadata/response contracts; no example person or example data as company fact. |

### Individual changes with reference to the source

| Source blocks | Fix | Replacement / reason |
| --- | --- | --- |
| 56–57 (p. 6) | F17 | `### Initial situation and unverified assumptions` |
| 73–73 (p. 7) | F17 | — |
| 85–106 (p. 7) | F12/F17 | `## 02 Content and reading guidance` — the complete translated section 02 text (see chapter 02). |
| 159–159 (p. 11) | F1/figures | **[E]** See figure 1. (image reference `figures/Abb_01_Systemkontext.svg`) **[E]** Figure 1: System context; logical data flow, not a network plan. **[E]** See figure 2. (image reference `figures/Abb_02_Containeransicht.svg`) **[E]** Figure 2: Container view; logical data flow, not a network plan. |
| 194–197 (p. 14) | F1 | **[E]** Minimum deployment: 1 React web interface, 1 FastAPI application, 1 indexer/worker with rule engine, 1 separate `erp-sync` service, PostgreSQL including jobs/outbox, Qdrant and at least 1 local AI runtime. Use Redis/Celery only once PostgreSQL jobs are insufficient. |
| 222–222 (p. 15) | F4/F6/F7/F8/F19 | Table "Table / collection [E] / key fields and purpose [E]" — the complete core schema (see chapter 05). |
| 234–234 (p. 16) | F8 | Table "Collection [E] / payload [E]" with `photo_embeddings` and `text_chunks` (see chapter 05). |
| 246–250 (p. 16) | F15 | **[E]** The API determines permissible scopes and business search filters before the vector search. Candidates are then checked against current source rights and only afterwards ordered. The five server-side checkpoints are described in chapter 11; see figure 16. |
| 258–265 (p. 17) | F6/F7/F8 | `### Provenance, identity and review` — the complete translated section text (see chapter 05). |
| 285–285 (p. 19) | Figures | **[E]** See figure 7. (image reference `figures/Abb_07_Ingestion.svg`) **[E]** Figure 7: Two ingestion tracks; logical data flow, not a network plan. **[E]** See figure 8. (image reference `figures/Abb_08_ERP_Sync.svg`) **[E]** Figure 8: ERP sync states; logical data flow, not a network plan. |
| 358–358 (p. 23) | Figures | **[E]** See figure 10. (image reference `figures/Abb_10_RAG.svg`) **[E]** Figure 10: RAG request path; logical data flow, not a network plan. |
| 403–403 (p. 25) | Figures | **[E]** See figure 12. (image reference `figures/Abb_12_Risikoerkennung.svg`) **[E]** Figure 12: Risk detection; logical data flow, not a network plan. |
| 406–421 (p. 25) | F5 | `### Dashboard boundaries` — the complete translated text (see chapter 09). |
| 439–444 (p. 27) | F5 | **[E]** There is one shared catalogue R1–R5. "Measurement report missing" corresponds to R1, "delivery date exceeded" to R2. Three to five rules remain a discussion value; R4 is excluded until the task-list decision is taken. **[O]** Selection, severity, deadlines and thresholds are approved by the business side. A higher `confidence` replaces neither evidence nor rule condition. |
| 462–490 (p. 28) | F2/F3/F4/F14 | `### REST endpoints` — the complete endpoint catalogue (see chapter 10). |
| 492–492 (p. 31) | Figures | **[E]** See figure 15. (image reference `figures/Abb_15_Vertrauenszonen.svg`) **[E]** Figure 15: Trust zones; logical data flow, not a network plan. **[E]** See figure 16. (image reference `figures/Abb_16_Berechtigungen.svg`) **[E]** Figure 16: Permission check; logical data flow, not a network plan. |
| 651–651 (p. 39) | F10 | `### First development tasks` **[E]** Before the Phase-0 ACL gate is passed, use exclusively synthetic data or explicitly approved isolated test data. No indexing of production files before the gate is passed. |
| 676–685 (p. 41) | F17/register | **[O]** Decisions and priorities are maintained exclusively in appendix C. These include folder meaning, UNC/identity/ACL, hardware, IDs, data processing, rule evidence, preview/export as well as a possible manually approved channel for external general questions outside the MVP. |
| 692–701 (p. 43) | F17/register | **[O]** The unconfirmed determinations including leading phases/tasks, roles, exports, data ownership, deadlines and thresholds are captured in appendix C with source traceability. No infrastructure variant is decided. **[E]** See figure 18. (image reference `figures/Abb_18_Infrastruktur.svg`) **[E]** Figure 18: Infrastructure options; logical data flow, not a network plan. |

**[E]** Additionally global: broken identifier cells repaired (F14), client drive designations replaced by an unknown UNC target (R7), names removed from the main text (F20), process-related headings neutralised (F17), new figures and consistent references inserted.

## QA report

**[E]** Editorial and technical artefact review of the approval template. The review confirms no productive implementation, no actual company rights and no legal approval. Open Phase-0 evidence remains in appendix C.

| Review | Result / evidence |
| --- | --- |
| 1 Markers | Literal markers before / after: [P] 41 / 72, [E] 31 / 190, [O] 26 / 167, [P/E] 6 / 7, [P/O] 4 / 7. Mixed markers counted separately; "after" contains source traceability and register, therefore no quantity comparison as status evidence. |
| Status integrity | No open decision presented as approved. A.4 AD: unmarked initial decision → [O] (F11). R4: [E] rule candidate → [O] pilot status and exclusion (F5). 95 % test scope and blueprint figures clarified as [O]; existing [P] two-minute target retained. All 26 literal [O] occurrences remain in the source inventory with context; open factual questions are assigned to the register. |
| 2 Identifiers | 100 technical field/table names from figures checked against the architecture text; 0 orphaned names. 17 unique method/path contracts; each exactly once in the normative endpoint catalogue. Old names remain only in the change/source inventory as historical evidence. |
| 3 Negative figure review | 0 directed edges into IN-FORM/SMB; 0 `ollama`→`postgres`/`qdrant`; no client drive identifier. No LLM confirm/import/review-write/export. Project board only dashed and [O]. Structural/sequence conflict explained in appendix D. |
| 4 Cross-references | 18 inclusions in order 1–18, 18 titles, chapters 01–16 and appendices A–D. Table of contents and list of figures match the baseline. |
| 5 Black and white | All figures rendered as greyscale PNG at 300 dpi and visually checked. Drawing width 390 pt = 13.76 cm; diagram including caption 510 pt = 17.99 cm. Font at least 8 pt. |
| 6 Consistency | R1–R5 in one catalogue; R4 excluded. Risk/suggestion/task states and value/freshness states in A.5. Tool table only read/draft. One permission formula in chapter 11. |
| 7 Layout | Serif body text, monospace identifiers; each figure on its own page together with legend, reading note and caption. Header: Company AI Assistant · Architecture 1.3. Table headers are repeated. |
| 8 Placeholders | No [FILL IN] placeholders. Signature data deliberately empty. No roles derived from person names. Standard assumptions confirmed by the user; missing original sources and approvals explicitly open. |

### Status changes and additions

| Old | New | Reason |
| --- | --- | --- |
| A.4 AD as an unmarked initial decision | [O] AD/Windows integration | F11; conflict with chapter 11 resolved. |
| R4 under [E] rule candidates | [O] pilot status; not in the first pilot set | F5; leading task list not yet decided. |
| Unmarked discussion figures / missing number of test questions | [E] discussion values and [O] approval/evidence requirement | F9/F16/F18; no new value decision. |
| Unmarked / mixed schema drafts | [E] unified technical contracts | F1–F8/F19; underlying [P] obligations retained in the main text. |
| Open points in several sections | [O] OP-01–OP-22 plus traceability | Consolidation, no completion or status upgrade. |

## Limits of the review

**[O]** No company installation, no live ACL test, no model/hardware benchmarks and no business or legal approval were part of the editorial work. The blueprint and the original project plan were not reviewed as additional sources. ER cards explicitly name foreign-key references; unknown cardinalities remain [O]. Compact figures bundle steps without establishing additional services or business decisions.

## Decisions for the author

**[E]** The following proposals require confirmation; all open company decisions remain in appendix C.

| Reference | Proposal to be confirmed [E] | Status |
| --- | --- | --- |
| F1 | Rule engine as module `rules/` in the `indexer` worker after every sync/index run; separate `erp-sync`. | **[O]** Not approved |
| F4 | Risk mapping and `confirmed_at`/`rule_run_id`; server-side human transitions. | **[O]** Not approved |
| F6 | Neutral `external_project_id`/`external_case_id` and separate `customers`/`projects`/`source_records`; business terms remain open. | **[O]** Not approved |
| F7 | `match_status` with human-confirmed ID; `match_score` informative only. | **[O]** Not approved |
| F8 | `sensitivity_class` and monitor default-deny including allowlist evidence. | **[O]** Not approved |
| F9 | Metric variant, number of test questions, evaluation denominator and thresholds. | **[O]** Not approved |
| F13 | Glossary definitions as proposed definitions, given the missing blueprint. | **[O]** Not approved |
| F19 | Completed enums and technical schema fields; in particular suggestion status, sync, index and sensitivity values. | **[O]** Not approved |
| F2/F3 | Optional human export API and unified tool contracts; no model export. | **[O]** Not approved |
| Part 3 | Responsibility roles and gate assignments in the open register. | **[O]** Not approved |
| Figures | Conflict resolutions for arrow direction, single permission formula and ER references. | **[O]** Not approved |
| Assumptions | **[E]** Confirmed by the user: standard format Markdown plus SVG/PDF/PNG, standard release details and one complete PDF with all components. Document date 04.11.2026; signature data empty. The four persons receive no derived roles. Only the named PDF is an input source. New technical values are drafts, not IN-FORM facts. | |

## Source inventory

**[E]** Complete capture from the 48-page PDF. Counting of literal markers; mixed markers counted separately. Numbers also include page/chapter numbers, version numbers and examples so that no number is silently missing.

| Marker | Before | After (architecture text incl. traceability) |
| --- | --- | --- |
| P | 41 | 72 |
| E | 31 | 190 |
| O | 26 | 167 |
| P/E | 6 | 7 |
| P/O | 4 | 7 |

**[E]** 16 main chapters, 5 source figures, 45 table fragments (including tables continued across pages), appendices A/B and preceding parts A–D.

### Identifiers in the source text

`access_scope_id`, `acknowledged_at`, `acl_entries`, `actor_id`, `adjacent_window_state`, `age_seconds`, `applied_at`, `audit_events`, `business_as_of`, `check_current_source_rights`, `checked_at`, `chunk_id`, `chunk_index`, `completed_at`, `confirmed_absent`, `confirmed_at`, `confirmed_by`, `coverage_state`, `customer_id`, `data_as_of`, `deleted_at`, `detected_at`, `dismissal_reason`, `doc_type`, `document_chunk_id`, `document_chunks`, `document_id`, `door_state`, `door_type`, `due_at`, `effective_at`, `error_code`, `event_at`, `event_id`, `evidence_ref`, `evidence_scope`, `expires_at`, `external_project_id`, `extracted_at`, `fallback_imports`, `fallback_path`, `field_catalog`, `field_key`, `field_values`, `file_hash`, `file_id`, `freshness_limit`, `freshness_state`, `get_risks`, `glass_state`, `imported_at`, `imported_by`, `index_jobs`, `ingestion_status`, `insufficient_evidence`, `job_status`, `label_filter`, `last_success_at`, `maintenance_owner`, `match_confidence`, `match_source`, `model_version`, `not_applicable`, `object_class`, `occasion_key`, `open_file`, `order_file_links`, `order_id`, `order_ref`, `owner_id`, `page_ref`, `parse_photo_constraints`, `pg_trgm`, `photo_embeddings`, `photo_id`, `photo_labels`, `principal_id`, `processing_version`, `project_id`, `project_phase_events`, `proposed_due_at`, `proposed_owner`, `proposed_owner_id`, `required_fields`, `resolve_scopes`, `resolved_at`, `reviewed_by`, `risk_evidence`, `risk_type`, `rule_id`, `rule_run_id`, `rule_runs`, `rule_version`, `rule_versions`, `scope_filter`, `scope_id`, `search_documents`, `search_photos`, `source_as_of`, `source_event_id`, `source_field`, `source_file_id`, `source_files`, `source_id_field`, `source_label`, `source_path`, `source_record_id`, `source_records`, `source_ref`, `source_refs`, `source_system`, `source_system_id`, `source_systems`, `stable_key`, `started_at`, `sync_run_id`, `sync_runs`, `taken_at`, `target_id`, `task_candidates`, `task_type`, `text_chunks`, `text_hash`, `value_state`, `vector_id`, `visible_area`, `visible_scope`

## All number occurrences (pp. 74–86 of the original)

> **Translator's note.** This section of the original is a machine-generated inventory: every numeral appearing in
> architecture v1.2 is listed with a row number, the value and a raw excerpt of surrounding text. After the entry
> table the original continues with further inventories (see below). The structure and purpose are translated here;
> the raw excerpt rows are not reproduced, because each excerpt is a truncated German mid-sentence fragment
> (e.g. "ige lautet Datenstand unbekannt; der Importzeitpunkt wird separat genannt.") that cannot be meaningfully
> translated without the sentence it was cut from, and the inventory itself is a QA artefact of the German source,
> not architecture content. The full row-by-row inventory remains available in the German original (pp. 74–93).

**Table structure of the original:**

| Column | Content |
| --- | --- |
| No. | Sequential row number |
| Value | The numeral as it appears (e.g. 1, 1.2, 04.11.2026, 01, 04–06, 32) |
| Source context | Raw German excerpt around the numeral, truncated to a fixed character window |

**Purpose (as stated in the source inventory):** to prove that no number in the document was silently changed or
dropped, including page numbers, chapter numbers, version numbers and example values.

## All status markers (approximately pp. 86–93 of the original)

**Table structure of the original:**

| Column | Content |
| --- | --- |
| No. | Sequential row number |
| Marker | The literal status marker: `[P]`, `[E]`, `[O]`, `[P/E]` or `[P/O]` |
| Source context | Raw German excerpt around the marker, truncated to a fixed character window |

The counts in the source inventory (P 41 → 72, E 31 → 190, O 26 → 167, P/E 6 → 7, P/O 4 → 7) refer to this
inventory. Its function is to show that every open point `[O]` of the original was preserved with its context and
assigned to the register of open items (appendix C) — not to add content.
