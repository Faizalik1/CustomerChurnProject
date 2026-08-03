
Feedback and suggestions are always welcome.
# Telco Customer Churn — SQL Cleaning & Analysis

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)
![Status](https://img.shields.io/badge/status-tested-brightgreen)

SQL companion to the Python/Jupyter churn project — the same dataset, the same questions, answered at the database layer instead of in pandas. Every query in `Churn_Analysis.sql` has been run end-to-end against the real 7,043-row dataset; the numbers below are the actual output, not projected ones.

## Why a SQL version exists alongside the Python one

In a real job, company data usually isn't a CSV someone hands you — it's sitting in a database or warehouse, and pulling it yourself is part of the job. This file shows the same cleaning and analysis logic from the Python build, done directly in SQL: schema design, data-quality checks, cleaning, grouped analysis, and two "beyond basic SELECT" techniques — window functions and a CTE.

## Data quality finding (same trap as the Python side)

`TotalCharges` passes a plain `IS NULL` check with zero results — looks clean. It isn't: 11 rows hold an empty string instead of a number, invisible to `IS NULL` because a blank string isn't a SQL `NULL`. All 11 belong to customers with `tenure = 0` — brand-new customers who haven't been billed yet, so the correct fix is `0`, not a dropped row or a guessed average.

## What's in the file

| Section | Contents |
|---|---|
| 1. Schema + load | `CREATE TABLE customers_raw`, with `TotalCharges` deliberately typed `TEXT` |
| 2. Data quality checks | The `IS NULL` vs. blank-string check above, plus a duplicate-ID check |
| 3. Cleaning | Builds `customers_clean`: fixes `TotalCharges`, encodes `Churn` as 0/1 |
| 4. Exploratory analysis | Churn rate by contract, internet service, and tenure bucket |
| 5. Advanced analysis | `CORR()`, a `RANK()` window function, a CTE + `ROW_NUMBER()` |
| 6. Business output | A retention target list of current at-risk customers |

## Results

**Churn rate by contract**

| Contract | Customers | Churn Rate |
|---|---|---|
| Month-to-month | 3,875 | 42.71% |
| One year | 1,473 | 11.27% |
| Two year | 1,695 | 2.83% |

**Churn rate by internet service**

| Internet Service | Customers | Churn Rate |
|---|---|---|
| Fiber optic | 3,096 | 41.89% |
| DSL | 2,421 | 18.96% |
| No internet | 1,526 | 7.40% |

**Churn rate by tenure**

| Tenure | Customers | Churn Rate |
|---|---|---|
| 0–12 months | 2,186 | 47.44% |
| 13–24 months | 1,024 | 28.71% |
| 25–48 months | 1,594 | 20.39% |
| 49+ months | 2,239 | 9.51% |

**Churned vs. stayed**

| Status | Avg Monthly | Avg Total | Avg Tenure |
|---|---|---|---|
| Stayed | $61.27 | $2,549.91 | 37.6 months |
| Churned | $74.44 | $1,531.80 | 18.0 months |

**Correlation check** — `tenure`/`TotalCharges` = 0.826, `MonthlyCharges`/`TotalCharges` = 0.651, `tenure`/`MonthlyCharges` = 0.248. The first two are high enough to flag as multicollinearity, same caveat as the Python model's coefficients — don't read `MonthlyCharges` and `TotalCharges` as two independent findings.

**Riskiest payment method, per contract type (CTE + `ROW_NUMBER()`)** — Electronic check comes out riskiest inside every contract tier: 53.7% churn in month-to-month, 18.4% in one-year, 7.7% in two-year. A pattern a single `GROUP BY` can't surface on its own.

## One deliberate difference from the Python version

`customerID` is kept in `customers_clean`. In the Python model it was dropped because an ID column adds nothing to a prediction and can confuse a model — but in SQL it doesn't hurt a query and is genuinely useful (joins, the retention target list). Same dataset, a different reason for a different choice in each tool.

## How to run it

```bash
createdb churn_db
psql -d churn_db -f Churn_Analysis.sql
```
Uncomment the `\copy` line near the top first, and point it at wherever `Customer_Churn.csv` sits on your machine.

## Repo structure

```
├── Churn_Analysis.sql          # this file's queries
├── Customer_Churn.csv          # source data
└── SQL_README.md               # this file
```

## Limitations

- Tenure buckets (0–12, 13–24, etc.) are a reasonable default split, not a business-validated one — worth revisiting with real retention-team input.
- `RANK()`/`ROW_NUMBER()` and `CORR()` are PostgreSQL syntax; MySQL and older SQL Server versions need small adjustments for window functions, and don't have a built-in `CORR()` at all.

## Connect

[![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white)](https://github.com/YOUR-USERNAME)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?logo=linkedin&logoColor=white)](https://linkedin.com/in/YOUR-PROFILE)
[![Email](https://img.shields.io/badge/Email-D14836?logo=gmail&logoColor=white)](mailto:YOUR-EMAIL@example.com)
