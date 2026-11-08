# Cryptocurrency Market & Trading Analysis

**SQL portfolio project | PostgreSQL | Market analysis | Transaction analytics | Member segmentation**

A descriptive analytics project built with historical Bitcoin (BTC) and Ethereum (ETH) market observations, member reference data, and buy/sell transactions for 2020. The project uses PostgreSQL to explore price behaviour, transaction mix, member activity, and the relationship between trading records and market data.

> **Project structure:** This README follows a CRISP-DM-inspired analytics narrative: Business Understanding → Data Understanding → Data Preparation → Analysis → Findings & Business Implications → Reproducibility.

## 1. Business understanding

### Business problem

A cryptocurrency platform needs a simple way to understand historical asset-price behaviour and customer trading activity. Looking at market prices alone does not explain how members trade; transaction data alone does not show the market context around those trades.

This project combines three related datasets to explore:

- **Market monitoring:** How did BTC and ETH prices vary during 2020?
- **Market movement:** How often was the recorded price above or below the opening price?
- **Trading activity:** How many buy and sell transactions were recorded for each asset?
- **Member analytics:** How are members distributed across regions, and which members recorded higher BTC net transaction quantities?
- **Data reliability:** Are price dates unique by ticker, and do transaction records link to the member table?

### Project objectives

1. Understand the coverage and structure of the market-price data.
2. Summarize monthly ETH price levels and BTC/ETH price-versus-open patterns.
3. Measure buy/sell transaction counts and quantities by asset.
4. Explore member-level and regional activity.
5. Correct calculation logic where the original SQL did not match the stated business question.

## 2. Data understanding

The repository contains three CSV source files and a SQL script with table creation and insert statements.

| Dataset | Records | Columns | Grain | Role |
|---|---:|---:|---|---|
| `prices.csv` | 732 | 8 | One row per asset per market date | BTC/ETH recorded price, open, high, low, volume and daily change |
| `transactions.csv` | 5,047 | 7 meaningful fields | One row per transaction | Member, asset, date, BUY/SELL type, quantity and percentage fee |
| `members.csv` | 14 | 3 | One row per member | Member ID, first name and region |

**Coverage:** The price dataset contains **366 daily observations for BTC and 366 for ETH**, covering 1 January to 31 December 2020. The transaction dataset contains **5,047 unique transaction IDs** and references all 14 members.

### Data model

```mermaid
erDiagram
    MEMBERS ||--o{ TRANSACTIONS : "member_id"
    PRICES {
        varchar ticker
        date market_date
        numeric price
        numeric open
        numeric high
        numeric low
        varchar volume
        varchar change
    }
    MEMBERS {
        varchar member_id PK
        varchar first_name
        varchar region
    }
    TRANSACTIONS {
        integer txn_id PK
        varchar member_id FK
        varchar ticker
        date txn_date
        varchar txn_type
        numeric quantity
        numeric percentage_fee
    }
```

The member relationship is `members.member_id = transactions.member_id`. Market observations are identified by `ticker + market_date`; they can be compared with transactions by asset and date, but the recorded daily market price is not necessarily the execution price of an individual trade.

## 3. Data preparation and quality

The original `CRYPTO.sql` creates and populates all three tables: `prices`, `transactions`, and `members`. The CSV files are also included separately as source-data files.

The audit identified the following:

- `prices.csv` contains 732 rows: 366 BTC and 366 ETH observations.
- Each ticker has 366 distinct market dates; no duplicate ticker/date pairs were found in the supplied price CSV.
- `transactions.csv` contains 5,047 meaningful transaction records, but its header and rows also contain **four trailing empty columns**. Clean those columns before attempting a direct CSV import into the seven-column table.
- The transaction insert dates appear in two textual forms: **1,944 slash-separated DD/MM/YYYY values** and **3,103 hyphen-separated DD-MM-YYYY values**. The companion SQL applies the matching date mask to all **5,047 transaction inserts**, consistent with the day-month-year dates in `transactions.csv`.
- The original buy/sell ratio query counts transactions rather than summing quantities, and integer division can truncate the ratio.
- The original final BTC quantity query adds BUY quantity in both branches of its `CASE` expression, so it does not subtract SELL quantity. It also has no descending sort before `LIMIT 3`.
- The original breakout percentage query treats `price = open` as non-breakout, while its separate non-breakout count uses `price < open`. The supplied dataset has no equal-price rows, but the companion script uses a consistent definition.
- The original monthly ETH question comment says 2007, while the dataset and SQL filter are for 2020. The companion comment corrects the year to 2020.

A corrected companion script is provided as **[`add_CRYPTO.sql`](add_CRYPTO.sql)**. It retains the original table definitions and data inserts, corrects the transaction date masks, and revises the analysis queries while preserving their original business-question intent. The original `CRYPTO.sql` is unchanged.

## 4. Analysis performed

### A. Member and regional analysis

Original questions include:

- Top three members alphabetically.
- Members from the United States.
- Member IDs and names for members outside Australia.
- Distinct regions in reverse alphabetical order.
- Member count by region.
- United States versus non-United States member counts.

Some original SQL comments use the word “mentor”; the table and data are member records, so this README uses **member**.

### B. Market data coverage and quality

Original questions include:

- Total price records and records per ticker.
- Minimum and maximum market date for each ticker.
- Whether duplicate market dates exist for a ticker.
- Number of BTC observations where the daily high is above 20,000.

### C. Price movement analysis

Original questions include:

- Monthly average ETH price in 2020.
- Number of breakout days where recorded `price > open`.
- Number of non-breakout days where recorded `price < open`.
- Breakout and non-breakout percentages for each ticker.

These are descriptive price-versus-open measures. They are not a full volatility model, investment return calculation, or trading strategy backtest.

### D. Trading and member behaviour

Original questions include:

- BTC buy and sell transaction counts.
- Members with less than 500 BTC sold, ordered from the largest quantity sold to the smallest.
- Member buy-to-sell ratio by quantity.
- Top three members by BTC quantity at the end of the period.

The corrected ratio is calculated **separately for BTC and ETH** because quantities of different cryptocurrencies are not directly comparable. The corrected top-three calculation is net recorded BTC transaction quantity (BUY minus SELL); it is not a verified wallet balance because no opening balance is supplied.

## 5. Quantitative findings

The following figures were calculated directly from the committed CSV datasets using the definitions described below. They are historical descriptive measures for 2020, not live market data.

### Market-price summary

| Metric | BTC | ETH |
|---|---:|---:|
| Daily observations | 366 | 366 |
| Average recorded price | 11,111.63 | 307.30 |
| Minimum recorded price | 4,826.00 | 107.90 |
| Maximum recorded price | 28,949.40 | 751.80 |
| Days with `price > open` | 207 (56.56%) | 200 (54.64%) |
| Days with `price < open` | 159 (43.44%) | 166 (45.36%) |

The source repository does not explicitly document the currency unit for the price fields, so the table reports the recorded numeric price values without assigning a currency symbol.

Additional market observations:

- BTC had **16 days** where the recorded daily high exceeded 20,000.
- ETH's monthly average recorded price increased from **156.65 in January** to **622.35 in December**.
- No duplicate market-date observations were found for either ticker in the supplied price data.

### Transaction activity

| Asset | Transactions | BUY count | SELL count | BUY quantity | SELL quantity | Net recorded quantity |
|---|---:|---:|---:|---:|---:|---:|
| BTC | 2,806 | 2,350 | 456 | 11,748.757556 | 2,301.977496 | 9,446.780059 |
| ETH | 2,241 | 1,833 | 408 | 9,284.277639 | 2,026.187564 | 7,258.090076 |
| **Total** | **5,047** | **4,183** | **864** | — | — | — |

Net recorded quantity is calculated as BUY quantity minus SELL quantity for the supplied transaction records. BTC and ETH quantities are kept separate and are not added together.

### Member distribution

| Region | Members |
|---|---:|
| United States | 7 |
| Australia | 4 |
| Africa | 1 |
| India | 1 |
| Asia | 1 |
| **Total** | **14** |

The United States accounts for 7 of the 14 supplied member records (50%); Australia accounts for 4 (about 28.57%).

### Top three members by net recorded BTC transaction quantity

| Member | Region | Net BTC transaction quantity |
|---|---|---:|
| Ayush | United States | 954.855948 |
| Leah | Asia | 921.610895 |
| Abe | United States | 859.371878 |

This is a net transaction-flow measure, not a wallet balance or proof of current holdings.

## 6. Business interpretation

- **Trading mix:** BUY transactions account for 4,183 of 5,047 transactions (about 82.88%); SELL transactions account for 864 (about 17.12%). This describes the records in the dataset, not platform-wide market demand.
- **Asset activity:** BTC has 2,806 transaction records versus 2,241 for ETH in this sample.
- **Price-versus-open pattern:** BTC's recorded price is above open on 56.56% of days; ETH's is above open on 54.64%. This is a simple daily direction indicator, not a measure of return magnitude.
- **Member footprint:** Half of the supplied member records are from the United States. The small 14-member sample is not sufficient to generalize to a full customer base.
- **Net transaction quantity:** Ayush, Leah and Abe have the three largest net BTC transaction quantities under BUY-minus-SELL logic. This does not account for balances held before the transaction period or transfers outside the dataset.

## 7. SQL skills demonstrated

- Relational table design and primary keys
- Bulk data population with SQL `INSERT` statements
- Filtering, sorting and limiting
- Aggregations: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- Conditional aggregation with `CASE`
- CTEs for member-level transaction summaries
- Joins between transaction and member tables
- Date functions: `EXTRACT`
- Duplicate-date checks
- Numeric ratio calculations with `NULLIF()`
- Net transaction quantity calculations

## 8. How to run

Requirements: PostgreSQL.

1. Create an empty PostgreSQL database.
2. Run the corrected companion script:

```bash
psql -d your_database_name -f add_CRYPTO.sql
```

The script creates and populates the `prices`, `transactions`, and `members` tables, then runs the analysis queries. It uses embedded SQL insert statements; the separate CSVs are retained as source files and are not required by the script's loading process.

## 9. Limitations and next steps

- The price currency is not documented in the repository.
- `volume` and `change` are stored as text in the original price-table design; normalize them before numeric analysis.
- The definition and calculation basis of `percentage_fee` are not documented.
- The daily market price should not be treated as the actual execution price for each transaction.
- Net transaction quantity is not the same as a wallet balance because opening balances and transfers are not included.
- The small member sample should not be generalized to a wider customer population.
- Add original dataset source attribution and licensing details if available.
- Add validated SQL result screenshots or a small dashboard for presentation.

## Repository structure

```text
SQL-Project-Crypto/
├── CRYPTO.sql          # Original SQL script (preserved)
├── add_CRYPTO.sql      # Corrected companion SQL script
├── members.csv         # Member reference data
├── prices.csv          # 2020 BTC/ETH daily market observations
├── transactions.csv    # Buy/sell transaction source data
└── README.md
```

## Author

**Raj Kishore Agrawal**

- [GitHub](https://github.com/rraj12345)
- [LinkedIn](https://www.linkedin.com/in/rajagrawal1/)
