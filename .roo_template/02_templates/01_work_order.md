# Work Order Template

- WO ID:
- Title:
- Requester:
- Owner:
- Branch (`wo/WO-YYYYMMDD-XXX-short`):
- Priority:
- Due Date:

## Objective

## Scope

### In Scope

### Out of Scope

## Acceptance Mapping

| Spec Clause | Done Criteria |
|---|---|

## Role Assignment (Mandatory)

| Role | Assignee | Responsibilities | Deliverables |
|---|---|---|---|
| Orchestrator | TBD | WO planning, branch control, stage dispatch, merge decision | `01_WorkOrder.md`, branch policy checks |
| Code | TBD | Implementation and required workflow artifacts in lean path | `src/*`, quality and delivery docs |
| Reviewer | TBD | Independent acceptance and PASS/FAIL verdict | `.roo_template/08_review_reports/{WO}/01_Review.md` |
| Librarian (Optional) | TBD or N/A | Context and delivery curation when explicitly needed | context/delivery pack updates |
| Architect (Optional) | TBD or N/A | architecture planning for risky scope | design notes/contracts |
| QA Runner (Optional) | TBD or N/A | execute checks and evidence capture | quality reports/logs |

## Stage Plan (Mandatory)

| Stage | Owner Role | Entry Criteria | Exit Deliverable |
|---|---|---|---|
| Kickoff | Orchestrator | SPEC digested | WO + branch issued |
| Build | Code | Gate A passed | implementation commit(s) |
| Quality | Code / QA Runner | build done | quality report |
| Review | Reviewer | delivery pack complete | `Verdict: PASS|FAIL` |
| Merge | Orchestrator | PASS + git gate | merge commit |

## Risks

## Dependencies
