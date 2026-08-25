# FullTractor Analytics Pipeline

An ELT pipeline that turns the transactional data of an e-commerce application into a sales reporting model, built with dbt, PostgreSQL and Docker.

## Why this project exists

FullTractor is a .NET e-commerce application I built, backed by SQL Server. Its schema is designed for transactions — placing orders, updating stock — not for answering questions like "how much did each product category sell per month".

Running those queries against the production database is a bad idea: analytical scans lock tables and slow down the application, and the data keeps moving while the report is being calculated. So the data is copied into a separate warehouse, where heavy queries are safe and the numbers stay stable while they are read.

This repository is that warehouse and the transformations that run on top of it.

## Architecture

```
raw  →  staging  →  intermediate  →  marts
```

| Layer | What it does | Materialization |
|---|---|---|
| `raw` | Source tables, loaded as-is from the application. Never modified by dbt. | tables |
| `staging` | One model per source table. Renames columns to warehouse conventions, standardizes types, computes row-level values such as `line_amount`. No joins. | view |
| `intermediate` | Reusable joins. `int_sales_lines` combines order lines with their order, product and category so that several marts can consume it without repeating the logic. | view |
| `marts` | Final tables consumed by dashboards. `fct_sales_monthly` aggregates revenue by category and month. | table |

Staging models are views because they are cheap to compute and rarely queried directly — the cost of recomputing them on read is lower than the cost of storing them. The mart is a table because a dashboard reads it repeatedly and should not re-run four joins every time.

Every model references others through `ref()`, and only staging models touch the sources through `source()`. dbt uses those references to build the dependency graph and decide execution order — no orchestration is hardcoded.

## Stack

- **dbt (dbt-postgres)** — transformations, tests, documentation
- **PostgreSQL 16** — warehouse, running in Docker
- **Docker Compose** — reproducible local environment
- **Python** — synthetic data generation and bulk loading
- **GitHub Actions** — CI running the full build on every pull request

## Data quality

Tests run on every `dbt build`, and in CI before any pull request can be merged.

**Generic tests** declared in YAML: `unique` and `not_null` on primary keys, and `relationships` to verify that every foreign key resolves — orphan rows are caught even though the warehouse does not enforce constraints.

**A custom test** (`tests/assert_order_total_matches_items.sql`) reconciles the order total stored by the application against the sum of its line items. The two values are redundant by design, which means they can drift apart — and that drift is exactly the kind of discrepancy that makes a revenue dashboard disagree with the source system. The test compares them per order and fails when the difference exceeds one cent, using a tolerance rather than strict equality to avoid false positives from decimal rounding.

## Documentation

`dbt docs generate && dbt docs serve` builds a browsable catalog with the full lineage graph. Column descriptions capture the things that are not obvious from the schema — for example, that `order_total_amount` must not be summed in reports because it belongs to the order grain, and summing it after joining to order lines counts the same revenue several times.

## Running it locally

```bash
# 1. Environment variables
cp .env.example .env        # then fill in the values

# 2. Warehouse
docker compose up -d

# 3. Python environment
python -m venv venv
venv\Scripts\activate        # Windows
pip install -r requirements.txt

# 4. Generate and load the source data
python generate_data.py
psql -h localhost -p 5433 -U dbt_user -d fulltractor -f schema.sql
python load_data.py

# 5. Build and test the models
cd fulltractor_dbt
dbt build
```

Credentials are never committed. `docker-compose.yml` reads them from `.env`, which is gitignored; `.env.example` documents which variables are required. In CI they come from the workflow environment.

The data generator is seeded, so every run produces the same dataset. That is what makes CI possible: the pipeline can be rebuilt from scratch on a clean runner and the tests assert against known values.

## Continuous integration

`.github/workflows/ci.yml` runs on every pull request. It spins up a PostgreSQL service, generates and loads the dataset, and runs `dbt build` — which builds each model and immediately runs its tests, skipping anything downstream of a failure. A pull request cannot be merged unless the entire pipeline builds and every test passes.

## Next steps

- Incremental materialization for the fact table, with a lookback window to capture late-arriving records
- Snapshots on the customer dimension to preserve history when attributes such as city change
- Deploy the same models to Amazon Redshift and expose the marts through Amazon QuickSight