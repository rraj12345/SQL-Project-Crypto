# Cryptocurrency Market & Trading Analysis | PostgreSQL

A SQL portfolio project using historical Bitcoin (BTC) and Ethereum (ETH) market data alongside member and transaction records. The original SQL script builds the relational tables and explores market-price behaviour, member geography, and trading activity.

## Project objective

The project demonstrates how SQL can combine market observations with trading and member information to support questions relevant to a cryptocurrency platform:

- How does each asset's market price behave over time?
- How frequently do recorded prices finish above or below their opening price?
- How is trading activity split between buys and sells?
- Which members and regions appear in the supplied member dataset?
- What patterns can be explored in member-level BTC activity?

This is a historical dataset exercise, not a live market tracker or investment recommendation.

## Dataset overview

The repository contains three CSV source files and an SQL script with table definitions and insert statements.

| File / table | Grain | Main fields |
|---|---|---|
| `members.csv` / `members` | One row per member | `member_id`, `first_name`, `region` |
| `prices.csv` / `prices` | One row per asset per market date | `ticker`, `market_date`, `price`, `open`, `high`, `low`, `volume`, `change` |
| `transactions.csv` / `transactions` | One row per transaction | `txn_id`, `member_id`, `ticker`, `txn_date`, `txn_type`, `quantity`, `percentage_fee` |

The supplied data includes BTC and ETH market records for 2020. The original SQL script contains insert statements for all three tables: 732 price records, 5,047 transaction records, and 14 member records. The `members.csv` file is also provided separately as a source-data copy.

## Analysis performed in the original SQL

### 1. Member and regional analysis

- Sort members alphabetically and retrieve the first three records.
- Filter members from the United States.
- Retrieve member IDs and names for members outside Australia.
- List distinct regions in reverse alphabetical order.
- Count members by region and rank regions by member count.
- Group members into United States and non-United States categories.

**Business relevance:** A platform team could use member distribution to understand the geographic composition of the supplied user base and to frame regional engagement or customer-support questions.

### 2. Market data coverage and quality

- Count records in the price table.
- Count records by cryptocurrency ticker.
- Retrieve the minimum and maximum market dates for each ticker.
- Compare total market-date records with distinct market dates by ticker.
- Count BTC records where the daily high is above 20,000.

**Business relevance:** These checks help establish the time coverage and completeness of market observations before calculating trends or comparing assets. The BTC high-price filter identifies dates meeting a chosen historical threshold in this dataset; it is not a current-price signal.

### 3. Price movement and breakout analysis

- Calculate monthly average ETH price for 2020, rounded to two decimal places.
- Count breakout days by ticker, where recorded `price > open`.
- Count non-breakout days where `price < open`.
- Calculate breakout and non-breakout percentages by ticker.

**Business relevance:** These metrics can help compare the frequency of positive versus negative close/open sessions and summarize monthly price levels. They are descriptive indicators, not a complete volatility or investment-performance model.

**Definition note:** In this SQL, a breakout day is defined as `price > open`. The percentage query groups `price <= open` into the non-breakout bucket, so a day where price equals open is included there even though the separate non-breakout count uses strictly less than open.

### 4. Trading activity and member behaviour

- Count BTC buy and sell transactions by transaction type.
- Calculate BTC quantity sold by member and return members below the 500 BTC threshold.
- Calculate a member-level buy-to-sell ratio using transaction counts.
- Join transactions to members and attempt to rank members by BTC quantity.

**Business relevance:** These queries form a starting point for understanding transaction mix, identifying active members, and exploring member-level trading behaviour. A production analytics team could extend this into customer segmentation, trading frequency, and asset-level activity reporting.

## Business insights and interpretation opportunities

The original queries can support the following business discussions:

- **Geographic footprint:** Regional member counts provide a basic view of where the listed members are located. This can inform questions about regional adoption and engagement.
- **Market movement:** Monthly ETH averages and BTC/ETH breakout percentages provide a compact summary of historical price behaviour during 2020.
- **Trading mix:** BTC buy-versus-sell counts help describe the composition of recorded trading activity.
- **Member activity:** Member-level sell quantities can help identify higher-volume sellers and members below a selected trading threshold.
- **Data reliability:** Date-range and duplicate-date checks help determine whether market series are suitable for daily or monthly reporting.

These are business interpretations of the questions encoded in the original SQL, not claims that a particular region, member, or cryptocurrency performed best. No numeric findings are stated because query outputs have not been captured and validated in this repository.

## SQL concepts demonstrated

| Concept | Application in the project |
|---|---|
| DDL and constraints | Creating tables and primary keys |
| Data loading | Populating tables through SQL `INSERT` statements |
| Filtering | Region, ticker, transaction type, year, and price conditions |
| Sorting and limiting | Alphabetical member lists and ranked outputs |
| Aggregation | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` |
| Grouping | Region, ticker, month, and transaction-type summaries |
| Conditional aggregation | `CASE WHEN` for breakout and transaction categories |
| CTEs | Aggregating BTC sales by member before filtering |
| Joins | Connecting transactions to member information |
| Date functions | `EXTRACT` and monthly/year-based analysis |
| Numeric calculations | Percentages and buy/sell comparisons |

## Repository structure

```text
SQL-Project-Crypto/
├── CRYPTO.sql          # Creates and populates tables, followed by analysis queries
├── members.csv         # Member reference data
├── prices.csv          # Historical BTC/ETH market data
├── transactions.csv    # Buy/sell transaction records
└── README.md           # Project documentation
```

## Technology

- PostgreSQL
- SQL
- CSV datasets

## How to run

1. Create a PostgreSQL database.
2. Open a PostgreSQL terminal or use pgAdmin.
3. Execute the original SQL script:

```bash
psql -d your_database_name -f CRYPTO.sql
```

The script creates and populates `prices`, `transactions`, and `members`, then runs the exploratory queries near the end of the file. The separate CSV files are included as source data; the SQL script uses embedded insert statements rather than importing those CSVs.

## Important SQL review notes

The original analysis is preserved and documented, but a few queries should be reviewed before using their outputs for business decisions:

- The buy-to-sell ratio query sums 1/0 flags, so it counts transactions rather than traded quantity. Its integer division can also truncate fractional ratios, and a member with no sell transactions can cause a division-by-zero issue. A robust version should use decimal arithmetic and `NULLIF()`.
- The final BTC quantity query is labelled as a member holdings calculation, but both branches of its `CASE` expression currently add quantity for `BUY`. It does not subtract `SELL` quantities, and it has no explicit descending sort before `LIMIT 3`. Therefore, it should not be interpreted as a validated net-holdings ranking.
- The breakout percentage query treats `price = open` as non-breakout, while the separate non-breakout count uses `price < open`.
- The meaning and calculation basis of `percentage_fee` are not defined in the repository. Avoid converting it into a currency fee without confirming its business definition.
- The market `price` field is a daily market observation. It should not automatically be treated as the execution price for an individual transaction.
- The repository does not currently identify the original data publisher or dataset licence. Add source attribution and permitted-use details if available.

## Future enhancements

- Validate and correct the member buy/sell ratio and net BTC holdings logic.
- Add validated result screenshots or result tables for the major analysis sections.
- Document the definition and unit of `percentage_fee`.
- Add data-quality checks for transaction member references, duplicate transaction IDs, and matching transaction dates to market dates.
- Add a concise data dictionary and dataset provenance.

## Author

**Raj Kishore Agrawal**

- [GitHub](https://github.com/rraj12345)
- [LinkedIn](https://www.linkedin.com/in/rajagrawal1/)
