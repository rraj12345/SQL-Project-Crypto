# Cryptocurrency Transactions & Market Analysis | PostgreSQL

A SQL portfolio project built around cryptocurrency market prices, member information, and buy/sell transaction records. It provides a relational dataset for exploring trading activity, member segments, and historical BTC/ETH price movements using PostgreSQL.

> **Scope note:** The repository currently contains database setup and source data. The additional analytical query pack in `sql/02_analysis_queries.sql` makes the intended business questions reproducible. Query outputs are not presented as findings until they have been run and validated.

## Project overview

The project brings together three data entities:

- **Members** — member identifier, first name, and region.
- **Prices** — ticker, market date, price, open, high, low, volume, and daily change.
- **Transactions** — transaction identifier, member, asset ticker, transaction date, buy/sell type, quantity, and recorded percentage fee.

The supplied examples include Bitcoin (BTC) and Ethereum (ETH) records and historical dates from 2020.

## Business questions

The SQL analysis pack is designed to answer:

1. How many buy and sell transactions were recorded for each cryptocurrency?
2. What quantity was traded by asset and transaction type?
3. Which regions have the most active members?
4. Which members have the highest transaction counts?
5. How did each asset's recorded market price change over time?
6. What is the daily high-low trading range for each asset?
7. What is the estimated transaction notional when quantity is matched to the same day's recorded market price?

## SQL skills demonstrated

- Relational table design and primary keys
- Data loading and date conversion
- Filtering, grouping, and aggregation
- Multi-table joins
- Common table expressions
- Window functions with `LAG()`
- Numeric calculations and `NULLIF()`
- Business interpretation of transaction and market data

## Repository structure

```text
SQL-Project-Crypto/
├── CRYPTO.sql                 # Creates and populates prices and transactions
├── members.csv                # Member lookup data
├── prices.csv                 # Historical market-price source data
├── transactions.csv           # Transaction source data
├── README.md
└── sql/
    ├── 01_members_schema.sql   # Creates and imports the members table
    └── 02_analysis_queries.sql # Reproducible analytical SQL examples
```

## Tech stack

- PostgreSQL
- SQL
- CSV datasets

## Run the project

Use a PostgreSQL database and run the commands from the repository root.

### 1. Create the price and transaction tables

```bash
psql -d your_database_name -f CRYPTO.sql
```

The existing script creates and populates the `prices` and `transactions` tables.

### 2. Create and load the members table

```bash
psql -d your_database_name -f sql/01_members_schema.sql
```

The members setup script creates the table and uses `psql \\copy` to load `members.csv`. Run it from the repository root so the relative CSV path resolves.

### 3. Run the analysis queries

```bash
psql -d your_database_name -f sql/02_analysis_queries.sql
```

If you use pgAdmin instead of `psql`, create the members table using the DDL in `sql/01_members_schema.sql`, then import `members.csv` with the Import/Export feature. The `\\copy` line is a psql client command, not standard SQL.

## Data and interpretation notes

- `CRYPTO.sql` contains table creation and bulk `INSERT` statements for `prices` and `transactions`. The member lookup is supplied separately as `members.csv`.
- `transactions.csv` currently includes extra trailing empty columns in its CSV header/rows. The existing SQL insert script is the straightforward route for loading transactions; do not import that CSV directly into the seven-column table without cleaning or staging it first.
- The notional-value query uses the recorded daily `price` as a proxy for execution price. It is an estimate, not an exchange-confirmed fill value.
- The meaning and scale of `percentage_fee` are not documented, so the analysis pack does not convert it into a currency fee or assume a percentage convention.
- The repository does not currently identify the original data publisher or dataset licence. Add provenance and permitted-use details if available.
- This is a historical dataset exercise, not investment advice or a representation of current market prices.

## Possible next improvements

- Add validated query output tables and a concise findings section.
- Add a data dictionary and document the source and licence of each dataset.
- Add data-quality checks for missing member references, duplicate transaction IDs, and unmatched price dates.
- Consider indexes on `transactions(member_id)`, `transactions(ticker, txn_date)`, and `prices(ticker, market_date)` after measuring query performance.

## Author

**Raj Kishore Agrawal**

- [LinkedIn](https://www.linkedin.com/in/rajagrawal1/)
- [GitHub](https://github.com/rraj12345)
