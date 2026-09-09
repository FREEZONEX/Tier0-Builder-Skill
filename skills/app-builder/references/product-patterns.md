# Product Patterns

Read relevant examples when planning a committed workflow or category surface.
They do not add scope beyond the SRS.

## Capability Loops

When these concepts appear as committed capabilities or visible UI, make the
loop operable:

| Archetype | Minimum loop |
|---|---|
| Exception / deviation | reason form -> saved record -> status change -> history |
| Approval / review | submit -> approve/reject with reason -> status transition |
| Alert handling | acknowledge -> assign/escalate/resolve -> recorded note |
| Adjustment / correction | validated form -> before/after delta -> audit record |
| Hold / freeze / release | impact preview -> confirm -> status transition |
| Assignment / dispatch | select target -> preview work -> owner/status change |
| Resource use / fulfillment | select demand -> choose resource -> confirm use/issue/dispatch -> quantity/status change |
| Recommendation / automation | basis -> affected records -> adjust/confirm -> execution record |

Do not expose these words in product UI unless the loop works.


## Category Surface And Professional Density

- When the SRS carries a category archetype (WMS, CRM, MES, ...), deliver the
  full confirmed module surface in navigation and implement each module to its
  SRS depth tier (core-flow: end-to-end operable; master-data: standard CRUD
  with seeds; supporting: minimal but real). A category app missing its
  canonical master-data or core-flow modules reads as incomplete to domain
  users no matter how deep the special features go. Depth stays lean;
  shape stays complete.
- Professional density baseline for list/ledger pages: search plus status
  filter chips with live counts, colored status badges from the category's
  status taxonomy, risk-carrying dates annotated with remaining days, and a
  page-level alert banner when risk states exist in the data.
- Use the category's standard terminology and identifiers (document numbers,
  material/lot/location codes) from the SRS; generic labels read as amateur.
- Dashboards aggregate real seeded counts and route to work — stat cards never
  show invented numbers, and every card links to its module.
- Seed data exercises every declared status so chips, badges, and banners are
  alive on first open.
- All of this still obeys the operability rules: every exposed module has an
  executable path; minimal-tier modules are small but never fake.

