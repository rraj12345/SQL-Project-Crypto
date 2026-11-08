# Cryptocurrency Market & Trading Analysis

**SQL portfolio project | PostgreSQL | BTC & ETH | Member segmentation | Trading activity**

## 1. Project at a glance

This project uses PostgreSQL to explore historical Bitcoin (BTC) and Ethereum (ETH) market data alongside member and buy/sell transaction records. It combines market trends, transaction activity, and member geography to demonstrate how a data analyst can turn raw financial records into operational and business summaries.

The original work is contained in `CRYPTO.sql`. It creates and populates three tables, then runs exploratory SQL queries. The repository also includes the corresponding CSV datasets.

| Project measure | Dataset coverage |
|---|---:|
| Market-price records | **732** |
| Price records per asset | **366 BTC + 366 ETH** |
| Transaction records | **5,047** |
| Member records | **14** |
| Assets covered | **2 (BTC and ETH)** |
| Date coverage | **1 Jan 2020 – 31 Dec 2020** |

*Quantitative findings in this README were calculated from the supplied CSV files and checked against the SQL logic. They describe this historical sample, not current cryptocurrency markets.*

## 2. Business context and questions

A digital-asset platform may need to understand market behaviour, customer activity, and the composition of trading. This project explores questions relevant to product analytics, customer segmentation, and trading operations:

- How many market observations are available for each asset?
- What is the price range and monthly average for ETH?
- How often is the recorded price above or below the opening price?
- On how many days did BTC's recorded high exceed 20,000?
- How many buy and sell transactions were recorded for each asset?
- What quantity was bought and sold?
- How are members distributed across regions?
- Which members recorded BTC sell quantities below 500?
- Are the market and transaction datasets complete enough for analysis?

## 3. Data sources and relational model

### Source files

| File | Grain | Main fields |
|---|---|---|
| `prices.csv` | One row per asset per market date | `ticker`, `market_date`, `price`, `open`, `high`, `low`, `volume`, `change` |
| `transactions.csv` | One row per transaction | `txn_id`, `member_id`, `ticker`, `txn_date`, `txn_type`, `quantity`, `percentage_fee` |
| `members.csv` | One row per member | `member_id`, `first_name`, `region` |

### Tables created by `CRYPTO.sql`

| Table | Primary key | Purpose |
|---|---|---|
| `prices` | `(ticker, market_date)` | Daily market observations for BTC and ETH |
| `transactions` | `txn_id` | Member buy/sell activity |
| `members` | `member_id` | Member lookup and region attributes |

The analysis joins `transactions.member_id` to `members.member_id`. The asset ticker and transaction date can be used to relate trading records to the relevant market-price series. The original schema defines primary keys but does not declare foreign-key constraints between the tables.

## 4. Analysis workflow and quantitative findings

### A. Member and regional analysis

The original SQL sorts members, filters by region, lists distinct regions, and counts members per region.

**Member distribution**

| Region | Members | Share of listed members |
|---|---:|---:|
| United States | **7** | **50.0%** |
| Australia | **4** | **28.6%** |
| Africa | **1** | **7.1%** |
| India | **1** | **7.1%** |
| Asia | **1** | **7.1%** |
| **Total** | **14** | **100%** |

**Business interpretation:** The sample is concentrated in the United States and Australia. A platform could use regional member counts as a starting point for regional engagement or support planning. This is a very small sample and should not be treated as representative of a real customer base.

### B. Market coverage and price behaviour

The SQL counts price records by ticker, checks date ranges, calculates monthly average ETH prices, counts BTC days where the high exceeded 20,000, and compares the `price` field with `open`.

**Price dataset summary**

| Asset | Daily records | Average recorded price | Minimum | Maximum |
|---|---:|---:|---:|---:|
| BTC | **366** | **11,111.63** | **4,826.00** | **28,949.40** |
| ETH | **366** | **307.30** | **107.90** | **751.80** |

Both assets have one record for each day from 1 January through 31 December 2020.

**Price-versus-open comparison**

| Asset | Price above open | Price below open | Above-open share |
|---|---:|---:|---:|
| BTC | **207 days** | **159 days** | **56.6%** |
| ETH | **200 days** | **166 days** | **54.6%** |

There are no equal-price/open records in the supplied data. In the original SQL, a breakout day is defined as `price > open`.

The original BTC threshold query returns **16 days** where the recorded daily high was above 20,000.

**Monthly average ETH price**

| Month | Average price |
|---|---:|
| Jan | 156.65 |
| Feb | 238.76 |
| Mar | 160.18 |
| Apr | 171.29 |
| May | 207.45 |
| Jun | 235.92 |
| Jul | 259.57 |
| Aug | 401.73 |
| Sep | 367.77 |
| Oct | 375.79 |
| Nov | 486.73 |
| Dec | 622.35 |

**Business interpretation:** The monthly average table summarizes the change in recorded ETH price levels over the year. The above-open measure describes how frequently the daily `price` field finished above the `open` field. Neither measure alone captures volatility, risk-adjusted returns, or a trading strategy's profitability.

### C. Trading activity and transaction mix

The original SQL counts BTC buy and sell transactions, aggregates BTC sell quantity by member, and attempts to calculate a buy-to-sell ratio.

**Transaction counts**

| Asset | Buy transactions | Sell transactions | Total |
|---|---:|---:|---:|
| BTC | **2,350** | **456** | **2,806** |
| ETH | **1,833** | **408** | **2,241** |
| **Total** | **4,183** | **864** | **5,047** |

Across both assets, **82.9%** of recorded transactions are buys and **17.1%** are sells.

**Recorded quantity by transaction type**

| Asset | Buy quantity | Sell quantity | Buy-to-sell quantity ratio |
|---|---:|---:|---:|
| BTC | **11,748.76 BTC** | **2,301.98 BTC** | **5.10 : 1** |
| ETH | **9,284.28 ETH** | **2,026.19 ETH** | **4.58 : 1** |

These ratios are calculated from the quantity column in the CSV data. They are not the output of the original SQL ratio query, which currently counts transactions rather than summing quantities.

**BTC sell quantity by member**

The original query filters members whose total BTC sell quantity is below 500 and sorts them from highest to lowest. In this dataset, all **14 members** fall below that threshold. The highest total among them is Danny at approximately **331.52 BTC**.

**Business interpretation:** Transaction counts describe activity frequency, while quantity totals describe the volume recorded. They answer different questions and should not be substituted for one another. A trading platform could use both to understand transaction mix and member activity.

### D. Data quality and reconciliation

- Each ticker has 366 market records, covering the full 2020 calendar year.
- The SQL checks total market-date rows against distinct market dates by ticker.
- All 5,047 transaction rows in the CSV reference one of the 14 member IDs in `members.csv`.
- The transaction CSV contains seven populated data fields followed by four empty trailing columns. Clean or stage the file before importing it directly into the seven-column SQL table.

## 5. SQL logic review: important caveats

The original SQL is documented as submitted, but two calculations should not be used as validated business metrics without correction:

1. **Buy-to-sell ratio query:** The `CASE` expressions add 1 for each BUY or SELL transaction. This calculates transaction counts, not quantities. The division is integer division in PostgreSQL, so fractional ratios are truncated. Use decimal arithmetic and `NULLIF()` for a robust ratio; sum `quantity` if the intended metric is quantity-based.
2. **Final BTC quantity query:** Both `CASE` branches currently add `quantity` for BUY transactions. The SELL branch is duplicated instead of subtracting sales, and the query has no `ORDER BY` before `LIMIT 3`. It therefore does not calculate or rank net BTC holdings correctly.

Other interpretation notes:

- The breakout-percentage query treats `price <= open` as non-breakout, while the separate non-breakout count uses `price < open`. There are no equal values in this CSV, so this distinction does not change the current dataset's counts.
- `percentage_fee` is present in the schema, but its unit and calculation basis are not documented. It is not converted into a currency amount here.
- The daily `price` field is not proven to be the execution price for each transaction. Transaction notional or realized profit/loss should not be inferred by joining it as though it were an actual fill price.
- The original comments refer to members as "mentors" in a few places; the table and data represent members.

## 6. SQL skills demonstrated

- Creating relational tables and primary keys
- Loading and exploring structured data
- Filtering, sorting, and limiting records
- Aggregations using `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`
- Grouping by ticker, transaction type, month, and region
- Conditional aggregation with `CASE`
- Common table expressions (CTEs)
- Joins between transactions and members
- Date functions with `EXTRACT`
- Numeric ratios and percentage calculations
- Basic data-quality and completeness checks

## 7. Repository structure

```text
SQL-Project-Crypto/
├── CRYPTO.sql          # Table definitions, INSERT statements and analysis queries
├── members.csv         # Member lookup data
├── prices.csv          # BTC and ETH daily market observations
├── transactions.csv    # Buy/sell transaction records
└── README.md           # Project overview, findings and instructions
```

## 8. How to reproduce the analysis

1. Install PostgreSQL and create a database.
2. Download or clone this repository.
3. Run the original SQL script:

```bash
psql -d your_database_name -f CRYPTO.sql
```

The SQL script creates and populates `prices`, `transactions`, and `members`, then executes the exploratory queries near the end of the file. It already contains the insert statements, so do not import the same CSV data again into those tables unless you first clear or recreate them.

If importing the CSVs separately:
- `members.csv` has three populated columns.
- `prices.csv` has eight populated columns and uses a month/day/year date format.
- `transactions.csv` has seven populated columns plus four empty trailing columns; stage or clean it before loading into the seven-column table.

## 9. Limitations and next steps

- The data covers only 2020 and is not suitable for describing current crypto-market conditions.
- Only BTC and ETH are represented.
- The member sample contains 14 records and should not be generalized to a wider customer population.
- The source does not document the currency denomination for price values or the business definition of `percentage_fee`.
- Correct the two flawed member trading calculations before presenting them as holdings or buy/sell-ratio KPIs.
- Add source attribution and dataset licence details if available.

Possible extensions include member-level net quantity by asset, trading-frequency segmentation, daily price volatility, market-price/transaction-date matching checks, and a documented fee calculation once its definition is known.

## Author

**Raj Kishore Agrawal**

- [GitHub](https://github.com/rraj12345)
- [LinkedIn](https://www.linkedin.com/in/rajagrawal1/)
