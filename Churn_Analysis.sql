/* ============================================================
   TELCO CUSTOMER CHURN — SQL CLEANING & ANALYSIS
   ============================================================
   Companion SQL file to the Python/Jupyter churn project.
   Dialect: PostgreSQL (uses CORR(), RANK(), ROW_NUMBER(), CTEs).
   Every query in this file has been run against the real
   7,043-row dataset and checked against the Python results.

   Sections:
     1. Schema + load
     2. Data quality checks (before cleaning)
     3. Cleaning
     4. Exploratory analysis
     5. Advanced analysis (window functions, CTEs, correlation)
     6. Business output (retention target list)
   ============================================================ */


/* ------------------------------------------------------------
   1. SCHEMA + LOAD

   TotalCharges is loaded as TEXT on purpose, not NUMERIC.
   11 rows hold a blank instead of a number, and a raw numeric
   load would either fail or silently mishandle them. Loading
   as TEXT first, then fixing it deliberately in Section 3, is
   the safer and more honest approach.
   ------------------------------------------------------------ */

DROP TABLE IF EXISTS customers_raw;

CREATE TABLE customers_raw (
    customerID       TEXT,
    gender            TEXT,
    SeniorCitizen     INTEGER,
    Partner           TEXT,
    Dependents        TEXT,
    tenure            INTEGER,
    PhoneService      TEXT,
    MultipleLines     TEXT,
    InternetService   TEXT,
    OnlineSecurity    TEXT,
    OnlineBackup      TEXT,
    DeviceProtection  TEXT,
    TechSupport       TEXT,
    StreamingTV       TEXT,
    StreamingMovies   TEXT,
    Contract          TEXT,
    PaperlessBilling  TEXT,
    PaymentMethod     TEXT,
    MonthlyCharges    NUMERIC(10,2),
    TotalCharges      TEXT,
    Churn             TEXT
);

-- Load the CSV (psql only — adjust path to wherever the file sits).
-- \copy customers_raw FROM 'Customer_Churn.csv' WITH (FORMAT csv, HEADER true);


/* ------------------------------------------------------------
   2. DATA QUALITY CHECKS — run these BEFORE trusting the data

   The same trap as the Python side: a plain NULL check says
   the data is clean. It isn't — TotalCharges has blanks that
   IS NULL cannot see, because they're empty text, not SQL NULL.
   ------------------------------------------------------------ */

-- Looks clean:
SELECT COUNT(*) AS null_totalcharges
FROM customers_raw
WHERE TotalCharges IS NULL;                          -- returns 0

-- Isn't clean — the real check:
SELECT COUNT(*) AS blank_totalcharges
FROM customers_raw
WHERE TRIM(TotalCharges) = '';                        -- returns 11

-- Confirm WHY they're blank (should all be brand-new customers):
SELECT tenure, COUNT(*) AS rows_affected
FROM customers_raw
WHERE TRIM(TotalCharges) = ''
GROUP BY tenure;                                       -- tenure = 0, count = 11

-- Duplicate customer check (good habit on any new table):
SELECT customerID, COUNT(*)
FROM customers_raw
GROUP BY customerID
HAVING COUNT(*) > 1;                                   -- returns 0 rows — no duplicates


/* ------------------------------------------------------------
   3. CLEANING

   - TotalCharges: blank -> NULL -> cast to NUMERIC -> fill 0
     (0 is correct here, not a guess: tenure = 0 means no bill
     has been issued yet, confirmed above).
   - Churn: 'Yes'/'No' text -> 1/0, so it can be aggregated
     directly with AVG() to get a rate.
   - customerID is kept (unlike in the Python model features —
     an ID doesn't hurt a SQL query and is useful for joins).
   ------------------------------------------------------------ */

DROP TABLE IF EXISTS customers_clean;

CREATE TABLE customers_clean AS
SELECT
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    MonthlyCharges,
    COALESCE(NULLIF(TRIM(TotalCharges), '')::NUMERIC(10,2), 0) AS TotalCharges,
    CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END AS Churn
FROM customers_raw;

-- Sanity check: same row count, and churn rate matches the Python build (0.2654)
SELECT
    COUNT(*)                                AS total_rows,
    SUM(Churn)                              AS churned,
    ROUND(AVG(Churn::NUMERIC), 4)           AS churn_rate
FROM customers_clean;


/* ------------------------------------------------------------
   4. EXPLORATORY ANALYSIS
   ------------------------------------------------------------ */

-- Churn rate by contract type
SELECT
    Contract,
    COUNT(*)                       AS customers,
    ROUND(AVG(Churn::NUMERIC), 4)  AS churn_rate
FROM customers_clean
GROUP BY Contract
ORDER BY churn_rate DESC;

-- Churn rate by internet service
SELECT
    InternetService,
    COUNT(*)                       AS customers,
    ROUND(AVG(Churn::NUMERIC), 4)  AS churn_rate
FROM customers_clean
GROUP BY InternetService
ORDER BY churn_rate DESC;

-- Churn rate by tenure bucket
SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49+ months'
    END                             AS tenure_group,
    COUNT(*)                        AS customers,
    ROUND(AVG(Churn::NUMERIC), 4)   AS churn_rate
FROM customers_clean
GROUP BY tenure_group
ORDER BY MIN(tenure);

-- Average charges and tenure, churned vs. stayed
SELECT
    CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Stayed' END AS status,
    ROUND(AVG(MonthlyCharges), 2)  AS avg_monthly_charges,
    ROUND(AVG(TotalCharges), 2)    AS avg_total_charges,
    ROUND(AVG(tenure), 1)          AS avg_tenure
FROM customers_clean
GROUP BY Churn;


/* ------------------------------------------------------------
   5. ADVANCED ANALYSIS — correlation, window functions, CTEs
   ------------------------------------------------------------ */

-- Correlation check (mirrors the multicollinearity flag from
-- the Python model's coefficients — same 3 columns, same result)
SELECT
    ROUND(CORR(tenure, TotalCharges)::NUMERIC, 3)         AS tenure_totalcharges_corr,
    ROUND(CORR(MonthlyCharges, TotalCharges)::NUMERIC, 3) AS monthly_totalcharges_corr,
    ROUND(CORR(tenure, MonthlyCharges)::NUMERIC, 3)       AS tenure_monthly_corr
FROM customers_clean;
-- tenure/TotalCharges and MonthlyCharges/TotalCharges are both
-- high (0.83, 0.65) — same warning as the Python coefficients:
-- don't read those two as independent, standalone findings.

-- Window function: rank contract types by churn rate
SELECT
    Contract,
    ROUND(AVG(Churn::NUMERIC), 4) AS churn_rate,
    RANK() OVER (ORDER BY AVG(Churn::NUMERIC) DESC) AS churn_rank
FROM customers_clean
GROUP BY Contract;

-- CTE + window function: riskiest payment method WITHIN each
-- contract type (a question a single GROUP BY can't answer)
WITH churn_by_group AS (
    SELECT
        Contract,
        PaymentMethod,
        COUNT(*)                       AS customers,
        ROUND(AVG(Churn::NUMERIC), 4)  AS churn_rate,
        ROW_NUMBER() OVER (
            PARTITION BY Contract
            ORDER BY AVG(Churn::NUMERIC) DESC
        ) AS rn
    FROM customers_clean
    GROUP BY Contract, PaymentMethod
)
SELECT Contract, PaymentMethod, customers, churn_rate
FROM churn_by_group
WHERE rn = 1
ORDER BY churn_rate DESC;
-- Electronic check comes out as the riskiest payment method
-- inside every single contract type — a real, actionable pattern.


/* ------------------------------------------------------------
   6. BUSINESS OUTPUT — a retention target list

   Currently-active customers who look like the highest-risk
   profile from the analysis above: month-to-month, still new,
   paying a lot. A retention team could act on this directly.
   ------------------------------------------------------------ */

SELECT
    customerID,
    tenure,
    MonthlyCharges,
    Contract,
    InternetService,
    PaymentMethod
FROM customers_clean
WHERE Churn = 0                     -- still an active customer
  AND Contract = 'Month-to-month'
  AND tenure <= 6
ORDER BY MonthlyCharges DESC
LIMIT 20;
