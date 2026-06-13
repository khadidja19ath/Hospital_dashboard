# 🏥 Hospital Management Dashboard

![Python](https://img.shields.io/badge/Python-3.10-blue)
![Streamlit](https://img.shields.io/badge/Streamlit-Dashboard-FF4B4B)
![SQLite](https://img.shields.io/badge/Database-SQLite-003B57)
![Status](https://img.shields.io/badge/Status-Live-brightgreen)

> An interactive analytics dashboard built on top of a relational hospital database, covering patients, doctors, consultations, and pharmacy management.

🔗 **Live demo:** [hospitaldashboard.streamlit.app](https://hospitaldashboard-fswgvfcytkv3nuryv4dtem.streamlit.app/)

> ⚠️ **Note:** For the clearest view of the numbers and charts, please switch your browser/Streamlit theme to **Light mode** (Settings → Theme → Light).

---

## 📌 Overview

This project simulates a real hospital's data system: patient records, doctor specialities, consultations, prescriptions, and medication inventory. On top of that database, a Streamlit dashboard answers key operational and business questions through SQL queries and interactive visualizations.

---

## 🗄️ Database Design

The database follows a normalized relational schema (7 tables) with proper foreign keys, constraints, and indexes:

- **specialities** — medical departments and consultation fees
- **doctors** — staff linked to specialities
- **patients** — demographics, insurance, allergies, medical history
- **consultations** — visits linking patients and doctors, with vitals and payment status
- **medications** — pharmacy inventory
- **prescriptions** & **prescription_details** — treatments linked to consultations

The dataset includes **500+ synthetic patients** and **800+ consultations**, generated to realistically respect the schema's relationships and constraints.

---

## 📊 Dashboard Pages

### 📊 Overview
- Key KPIs: total patients, consultations, revenue collected, pending payments
- Monthly consultation trends
- Revenue breakdown by specialty
- Consultation status distribution

### 👥 Patients
- Age group and blood type distribution
- Patients by city
- Medical history breakdown
- Patient search by name or city

### 👨‍⚕️ Doctors & Specialities
- Consultations and revenue per doctor
- Top 3 most profitable specialities (using `DENSE_RANK()`)
- List of unpaid completed consultations

### 💊 Pharmacy
- Stock value and low-stock alerts
- Top 5 most prescribed medications
- Medications expiring within 6 months
- Full medication inventory

---

## 🔍 Analytical Highlights

This project applies real SQL analysis techniques, including:

- Multi-table `JOIN`s across the full schema
- Aggregate functions (`SUM`, `AVG`, `COUNT`) for revenue and consultation metrics
- `GROUP BY` + `HAVING` for filtering aggregated results
- Window functions (`DENSE_RANK()`) for ranking specialities by revenue
- Date functions for monthly trends and medication expiration tracking
- Subqueries for above-average consultation/spending analysis

---

## 🛠️ Tools & Libraries

```
Python · Streamlit · SQLite · Pandas · Plotly · SQL
```

---

## ▶️ Run Locally

```bash
git clone https://github.com/your-username/hospital-dashboard.git
cd hospital-dashboard
pip install -r requirements.txt
streamlit run app.py
```

The database (`hospital.db`) is included — no setup required.

---

## 📁 Repository Structure

```
hospital-dashboard/
│
├── app.py              # Streamlit dashboard
├── db.py                # Database connection helper
├── hospital.db          # SQLite database (schema + synthetic data)
├── schema_sqlite.sql    # Database schema
├── queries.sql          # 30 analytical SQL queries
└── requirements.txt
```

---

## 👩‍💻 Author

**Khadidja Aithoici**
AI Engineering Student — ENSTA Algiers (2024–2028)
[LinkedIn](#) · [GitHub](#)
