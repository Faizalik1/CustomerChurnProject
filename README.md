# 📊 Customer Churn Prediction using Machine Learning

![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![MySQL](https://img.shields.io/badge/MySQL-Database-orange?logo=mysql)
![Scikit-Learn](https://img.shields.io/badge/Scikit--Learn-Machine%20Learning-orange?logo=scikitlearn)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)
![Status](https://img.shields.io/badge/status-completed-brightgreen)

---

# Why this project exists

Customer retention is one of the biggest challenges faced by subscription-based businesses. Acquiring a new customer costs significantly more than retaining an existing one. The objective of this project is to identify customers who are most likely to churn and provide business recommendations that help reduce customer loss.

This project demonstrates an end-to-end Machine Learning workflow, from SQL data extraction and preprocessing to predictive modeling and business intelligence reporting.

---

# Business Problem

The management team wants answers to the following questions:

- Why are customers leaving?
- Which customers are most likely to churn?
- Which factors influence churn the most?
- Can we predict churn before it happens?
- What actions can reduce customer loss?

The goal is not only to build a machine learning model but also to provide actionable business insights.

---

# Project Workflow

```

Business Understanding

↓

SQL Data Extraction

↓

Data Cleaning

↓

Exploratory Data Analysis (EDA)

↓

Feature Engineering

↓

Data Preprocessing

↓

Machine Learning Models

↓

Model Evaluation

↓

Business Insights

↓

Power BI Dashboard

↓

Business Recommendations

```

---

# Technologies Used

| Category | Tools |
|----------|------|
| Programming | Python |
| Database | MySQL |
| Machine Learning | Scikit-Learn, XGBoost |
| Data Analysis | Pandas, NumPy |
| Visualization | Matplotlib, Seaborn |
| Dashboard | Power BI |
| Development | Jupyter Notebook |

---

# Dataset

IBM Telco Customer Churn Dataset

- 7,043 Customers
- 21 Features
- Binary Classification Problem

Target Variable

```

Churn

Yes / No

```

Main Features

- Gender
- Senior Citizen
- Partner
- Dependents
- Tenure
- Phone Service
- Internet Service
- Contract
- Payment Method
- Monthly Charges
- Total Charges

---

# SQL Data Preparation

The SQL phase focuses on extracting and validating the dataset before modeling.

Tasks performed include:

- Customer count
- Churn rate calculation
- Duplicate detection
- Missing value detection
- Contract analysis
- Internet service analysis
- Payment method analysis
- Monthly sales analysis
- Customer segmentation
- Retention target identification

---

# Data Cleaning

The dataset contained several preprocessing challenges.

Cleaning steps performed:

- Converted **TotalCharges** from text to numeric.
- Replaced blank values for new customers with zero.
- Removed unnecessary identifier columns from the ML dataset.
- Converted categorical variables into machine-readable format.
- Verified data consistency.

---

# Exploratory Data Analysis

The analysis answered important business questions such as:

- Which contract has the highest churn?
- Which internet service loses the most customers?
- Does tenure affect churn?
- How do monthly charges influence churn?
- Which payment methods are associated with higher churn?

Visualizations include:

- Churn Distribution
- Contract Analysis
- Monthly Charges Distribution
- Tenure Analysis
- Feature Correlation
- Customer Demographics

---

# Feature Engineering

The following preprocessing techniques were applied:

- Label Encoding
- One-Hot Encoding
- Standard Scaling
- Train/Test Split
- Pipeline Construction

These steps ensure the data is suitable for machine learning algorithms.

---

# Machine Learning Models

The following algorithms were trained and compared:

| Model | Purpose |
|--------|---------|
| Logistic Regression | Baseline Classification |
| Random Forest | Ensemble Learning |
| XGBoost | Gradient Boosting |

Each model was evaluated to identify the best-performing classifier.

---

# Model Evaluation

Performance was measured using:

- Accuracy
- Precision
- Recall
- F1 Score
- ROC-AUC
- Confusion Matrix

These metrics provide a balanced evaluation of model performance.

---

# Key Business Insights

The analysis revealed several important findings:

- Month-to-month customers have the highest churn rate.
- Customers with shorter tenure are significantly more likely to leave.
- Fiber optic users show higher churn compared to DSL users.
- Higher monthly charges are associated with increased churn.
- Long-term contracts greatly improve customer retention.

---

# Business Recommendations

Based on the findings, the company should:

- Target high-risk customers with personalized retention offers.
- Encourage customers to switch to long-term contracts.
- Improve customer support for high-value customers.
- Launch loyalty programs for early-stage customers.
- Monitor customers with high monthly charges.

---

# Repository Structure

```

Customer-Churn-Prediction/

├── data/

│ └── Customer_Churn.csv

│

├── sql/

│ └── Churn_Analysis.sql

│

├── notebooks/

│ └── churn_prediction.ipynb

│

├── dashboard/

│ └── Customer_Churn.pbix

│

├── images/

│ ├── churn_distribution.png

│ ├── confusion_matrix.png

│ ├── feature_importance.png

│ └── dashboard_preview.png

│

├── README.md

├── requirements.txt

└── LICENSE

```

---

# Future Improvements

Future versions of this project may include:

- Hyperparameter Optimization
- Cross Validation
- SHAP Explainability
- Streamlit Web Application
- REST API Deployment
- Docker Containerization
- Cloud Deployment (Azure / AWS)

---

# Project Screenshots

Include screenshots of:

- SQL Queries
- Data Cleaning
- EDA Visualizations
- Model Performance
- Power BI Dashboard

---

# Author

## Faiz Ali Khaskheli

**Junior Data Analyst | Aspiring Data Scientist | Machine Learning Enthusiast**

📧 faizalics1@gmail.com

💻 GitHub: https://github.com/Faizalik1

🔗 LinkedIn: (Your LinkedIn Profile)

---

⭐ If you found this project useful, consider giving it a star.

Feedback and suggestions are always welcome.
