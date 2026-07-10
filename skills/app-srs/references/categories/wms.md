# Category Archetype: WMS (Warehouse Management System)

Load this reference when the user names WMS, warehouse management, 仓库管理,
仓储, inventory management as the product category. It defines the canonical
module set, standard entities, status taxonomies, and the professional surface
domain users expect. The archetype is the scope floor for a category request;
user-named special requirements are additive.

Scale calibration: this archetype targets single-warehouse first versions
(including R&D / lab stores). Multi-warehouse, waves, labor management, and
billing are explicitly out of the first-version archetype unless requested.

## Canonical Module Set

| Module | Tier | Contents |
|---|---|---|
| Dashboard 工作台/仪表盘 | core surface | pending receipts, expiry/stock risks, pending issues/outbound, stock overview cards — real counts, each card routes to its module |
| Materials master 物料档案 | master-data | material catalog CRUD: code, name, category, spec, unit, shelf life, storage requirements |
| Locations 库位管理 | master-data | zone/rack/bin structure CRUD, capacity/type notes, occupancy view |
| Inbound 入库管理 | core-flow | receive (optionally against a pre-receipt), assign location, create batch/lot with production+expiry dates |
| Outbound 出库管理 | core-flow | issue/dispatch with batch recommendation (FIFO/FEFO), pick confirmation, stock deduction |
| Inventory 库存管理 | core-flow | ledger by material/batch/location with counts AND operations: adjust, transfer, freeze/unfreeze |
| Expiry/stock alerts 预警 | supporting | near-expiry/expired/below-minimum lists, acknowledge action, thresholds visible |

Common optional modules (add when the user's flow implies them): pre-receipt/ASN
预收货 (announced deliveries, partial receiving), returns 退料, stocktake 盘点.

Tier semantics (inherited by the builder):

- **core-flow** modules are fully operable end to end;
- **master-data** modules are standard CRUD with realistic seeds;
- **supporting** modules are small but real — an acknowledge button and a
  threshold display beat a fake configuration panel.
- The full confirmed set appears in navigation. Nothing exposed is fake — this
  archetype must still pass the scaffold's write-path and operability gates.

## Standard Entities and Fields

| Entity | Standard fields |
|---|---|
| Material 物料 | code (`YL-001` style, human-readable), name, category (raw/auxiliary/packaging/finished), spec/model, unit (kg/pcs/L), shelf_life_days, storage_condition (ambient/cool/cold), min_stock |
| Batch/Lot 批次 | lot_no (date-derived, e.g. `CB20240801`), material ref, quantity + unit, production_date, expiry_date, status, location ref, supplier ref |
| Location 库位 | code (`A-01-01` zone-rack-bin style), zone, type (normal/cool/quarantine), enabled |
| Inbound/Outbound doc 出入库单 | doc no (prefixed, date-derived), lines (material, batch, qty, location), status, operator, timestamps |
| Pre-receipt 预收货单 (when requested) | doc no, supplier, expected date, lines with expected qty, received qty (partial receiving), status |

## Status Taxonomies

- **Batch stock status**: 正常 normal / 临期 near-expiry / 过期 expired / 冻结 frozen.
  Near-expiry threshold is material-dependent (default 30 days; short-life
  categories like dairy/fresh use 7); show the threshold, don't hard-code it
  invisibly.
- **Documents**: draft 草稿 → pending 待执行 → in progress 执行中 → completed 已完成
  (+ cancelled), adapted per doc type (pre-receipt: 待到货/部分收货/已完成).
- **Issue policies**: FIFO by production/receipt date is the default
  recommendation; FEFO (earliest expiry first) for shelf-life-managed
  materials — state which policy each recommendation used.

## Professional Surface (what makes it look like a real WMS)

Per-module furniture domain users expect — this is the difference between
"professional" and "bare":

- **Inventory ledger**: search box + status filter chips **with live counts**
  (全部 6 / 正常 3 / 临期 2 / 过期 1 / 冻结 0), colored status badges, expiry
  dates annotated with remaining days (`2026-07-16 (6天)`), quantity with unit,
  and a page-level alert banner when near-expiry/expired stock exists
  ("2 项物料即将过期，1 项已过期").
- **Batch/lot visibility everywhere**: inventory rows show material + lot_no +
  location together; issue screens show which batch the FIFO/FEFO rule picked
  and why (oldest production date / earliest expiry).
- **Dashboards**: stat cards fed by seeded data (never invented numbers), a
  risk list that links to the alert module, pending-work lists that link to
  their documents.
- **Documents**: doc numbers visible, line tables with material code + name,
  status timeline on detail pages.
- **Seed data** must exercise every status: include at least one near-expiry,
  one expired, and one frozen batch so filters, badges, and banners all show
  live on first open.

## First-Version Boundaries (do NOT expand into)

Multi-warehouse, wave picking, packing/cartonization, labor/task management,
billing, barcode hardware integration, WCS/automation, serial-number tracking —
unless the user asks. Keep the archetype lean in depth, complete in shape.
