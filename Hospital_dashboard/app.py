import streamlit as st
import plotly.express as px
from db import query

# ── PAGE CONFIG ──────────────────────────────────────────────────────────────
st.set_page_config(
    page_title="Hospital Dashboard",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ── CUSTOM CSS ───────────────────────────────────────────────────────────────
st.markdown("""
<style>
    :root {
        --teal:   #0D9488;
        --teal2:  #14B8A6;
        --slate:  #1E293B;
        --muted:  #64748B;
        --bg:     #F8FAFC;
        --card:   #FFFFFF;
        --red:    #EF4444;
    }
    .main { background: var(--bg); }
    .kpi-card {
        background: var(--card);
        border-radius: 12px;
        padding: 20px 24px;
        border-left: 4px solid var(--teal);
        box-shadow: 0 1px 4px rgba(0,0,0,0.07);
    }
    .kpi-value { font-size: 2rem; font-weight: 700; color: var(--slate); line-height: 1.1; }
    .kpi-label { font-size: 0.82rem; color: var(--muted); margin-top: 4px;
                  text-transform: uppercase; letter-spacing: .05em; }
    .alert-card {
        background: #FEF2F2; border-left: 4px solid var(--red);
        border-radius: 8px; padding: 14px 18px; margin-bottom: 8px;
    }
    .alert-text { color: #991B1B; font-size: 0.9rem; }
    .section-title {
        font-size: 1.1rem; font-weight: 600; color: var(--slate);
        margin: 24px 0 12px; padding-bottom: 6px; border-bottom: 2px solid var(--teal2);
    }
    [data-testid="stSidebar"] { background: var(--slate); }
    [data-testid="stSidebar"] * { color: #CBD5E1 !important; }
</style>
""", unsafe_allow_html=True)

# ── SIDEBAR ───────────────────────────────────────────────────────────────────
with st.sidebar:
    st.markdown("## 🏥 Hospital")
    st.markdown("---")
    page = st.radio("", [
        "📊 Overview",
        "👥 Patients",
        "👨‍⚕️ Doctors & Specialities",
        "💊 Pharmacy"
    ])
    st.markdown("---")
    st.caption("Data: Hospital DB · Algiers")

# ── HELPERS ──────────────────────────────────────────────────────────────────
TEAL   = "#0D9488"
TEAL2  = "#14B8A6"
SLATE  = "#1E293B"
COLORS = ["#0D9488","#14B8A6","#0EA5E9","#6366F1","#F59E0B","#EF4444"]

def kpi(col, value, label, prefix="", suffix=""):
    col.markdown(f"""
    <div class="kpi-card">
        <div class="kpi-value">{prefix}{value}{suffix}</div>
        <div class="kpi-label">{label}</div>
    </div>""", unsafe_allow_html=True)

def section(title):
    st.markdown(f'<div class="section-title">{title}</div>', unsafe_allow_html=True)

# ════════════════════════════════════════════════════════════════════════════
# PAGE 1 — OVERVIEW
# ════════════════════════════════════════════════════════════════════════════
if page == "📊 Overview":
    st.title("Hospital Overview")
    st.caption("Key performance indicators across the hospital")

    total_patients   = query("SELECT COUNT(*) v FROM patients").iloc[0,0]
    total_consults   = query("SELECT COUNT(*) v FROM consultations").iloc[0,0]
    total_revenue    = query("SELECT COALESCE(SUM(amount),0) v FROM consultations WHERE paid=1").iloc[0,0]
    pending_payments = query("SELECT COALESCE(SUM(amount),0) v FROM consultations WHERE paid=0 AND status='Completed'").iloc[0,0]

    c1,c2,c3,c4 = st.columns(4)
    kpi(c1, f"{total_patients:,}",   "Total Patients")
    kpi(c2, f"{total_consults:,}",   "Total Consultations")
    kpi(c3, f"{total_revenue:,.0f}", "Revenue Collected (DA)", suffix=" DA")
    kpi(c4, f"{pending_payments:,.0f}", "Pending Payments (DA)", suffix=" DA")

    st.markdown("<br>", unsafe_allow_html=True)
    col_l, col_r = st.columns(2)

    with col_l:
        section("📅 Consultations per Month")
        df_month = query("""
            SELECT strftime('%Y-%m', consultation_date) AS month,
                   COUNT(*) AS consultations
            FROM consultations
            GROUP BY month ORDER BY month
        """)
        fig = px.line(df_month, x="month", y="consultations",
                      markers=True, color_discrete_sequence=[TEAL])
        fig.update_layout(plot_bgcolor="white", paper_bgcolor="white",
                          xaxis_title="", yaxis_title="Consultations",
                          margin=dict(t=10,b=10,l=10,r=10))
        st.plotly_chart(fig, use_container_width=True)

    with col_r:
        section("💰 Revenue by Specialty")
        df_rev = query("""
            SELECT s.speciality_name, SUM(c.amount) AS revenue
            FROM specialities s
            JOIN doctors d ON d.speciality_id = s.speciality_id
            JOIN consultations c ON c.doctor_id = d.doctor_id
            WHERE c.paid = 1
            GROUP BY s.speciality_id
            ORDER BY revenue DESC
        """)
        fig = px.bar(df_rev, x="revenue", y="speciality_name",
                     orientation="h", color_discrete_sequence=[TEAL2])
        fig.update_layout(plot_bgcolor="white", paper_bgcolor="white",
                          xaxis_title="Revenue (DA)", yaxis_title="",
                          margin=dict(t=10,b=10,l=10,r=10))
        st.plotly_chart(fig, use_container_width=True)

    section("📋 Consultation Status Breakdown")
    df_status = query("SELECT status, COUNT(*) AS count FROM consultations GROUP BY status")
    fig = px.pie(df_status, names="status", values="count",
                 color_discrete_sequence=COLORS, hole=0.45)
    fig.update_layout(margin=dict(t=10,b=10,l=10,r=10))
    st.plotly_chart(fig, use_container_width=True)


# ════════════════════════════════════════════════════════════════════════════
# PAGE 2 — PATIENTS
# ════════════════════════════════════════════════════════════════════════════
elif page == "👥 Patients":
    st.title("Patient Analytics")

    total_p  = query("SELECT COUNT(*) v FROM patients").iloc[0,0]
    insured  = query("SELECT COUNT(*) v FROM patients WHERE insurance IS NOT NULL").iloc[0,0]
    allergic = query("SELECT COUNT(*) v FROM patients WHERE allergies != 'None'").iloc[0,0]
    avg_age  = query("""
        SELECT ROUND(AVG((julianday('now') - julianday(date_of_birth)) / 365.25), 1) v
        FROM patients
    """).iloc[0,0]

    c1,c2,c3,c4 = st.columns(4)
    kpi(c1, f"{total_p:,}",  "Total Patients")
    kpi(c2, f"{avg_age}",    "Average Age", suffix=" yrs")
    kpi(c3, f"{insured:,}",  "Insured Patients")
    kpi(c4, f"{allergic:,}", "Patients with Allergies")

    st.markdown("<br>", unsafe_allow_html=True)
    col_l, col_r = st.columns(2)

    with col_l:
        section("🎂 Age Group Distribution")
        df_age = query("""
            SELECT
                CASE
                    WHEN (julianday('now') - julianday(date_of_birth)) / 365.25 <= 18 THEN '0–18'
                    WHEN (julianday('now') - julianday(date_of_birth)) / 365.25 <= 40 THEN '19–40'
                    WHEN (julianday('now') - julianday(date_of_birth)) / 365.25 <= 60 THEN '41–60'
                    ELSE '60+'
                END AS age_group,
                COUNT(*) AS count
            FROM patients GROUP BY age_group
            ORDER BY age_group
        """)
        fig = px.bar(df_age, x="age_group", y="count", color_discrete_sequence=[TEAL])
        fig.update_layout(plot_bgcolor="white", paper_bgcolor="white",
                          margin=dict(t=10,b=10,l=10,r=10))
        st.plotly_chart(fig, use_container_width=True)

    with col_r:
        section("🩸 Blood Type Distribution")
        df_blood = query("SELECT blood_type, COUNT(*) AS count FROM patients GROUP BY blood_type ORDER BY count DESC")
        fig = px.bar(df_blood, x="blood_type", y="count", color_discrete_sequence=[TEAL2])
        fig.update_layout(plot_bgcolor="white", paper_bgcolor="white",
                          margin=dict(t=10,b=10,l=10,r=10))
        st.plotly_chart(fig, use_container_width=True)

    col_l2, col_r2 = st.columns(2)

    with col_l2:
        section("🏙️ Patients by City (Top 10)")
        df_city = query("""
            SELECT city, COUNT(*) AS count FROM patients
            GROUP BY city ORDER BY count DESC LIMIT 10
        """)
        fig = px.bar(df_city, x="count", y="city", orientation="h", color_discrete_sequence=[TEAL])
        fig.update_layout(plot_bgcolor="white", paper_bgcolor="white",
                          margin=dict(t=10,b=10,l=10,r=10), yaxis_title="")
        st.plotly_chart(fig, use_container_width=True)

    with col_r2:
        section("🏥 Medical History")
        df_hist = query("SELECT medical_history, COUNT(*) AS count FROM patients GROUP BY medical_history ORDER BY count DESC")
        fig = px.pie(df_hist, names="medical_history", values="count", hole=0.4, color_discrete_sequence=COLORS)
        fig.update_layout(margin=dict(t=10,b=10,l=10,r=10))
        st.plotly_chart(fig, use_container_width=True)

    section("🔍 Patient Search")
    search = st.text_input("Search by name or city")
    if search:
        df_search = query(f"""
            SELECT file_number, last_name || ' ' || first_name AS name,
                   date_of_birth, gender, blood_type, city, insurance, allergies
            FROM patients
            WHERE last_name LIKE '%{search}%'
               OR first_name LIKE '%{search}%'
               OR city LIKE '%{search}%'
            LIMIT 50
        """)
        st.dataframe(df_search, use_container_width=True)


# ════════════════════════════════════════════════════════════════════════════
# PAGE 3 — DOCTORS & SPECIALITIES
# ════════════════════════════════════════════════════════════════════════════
elif page == "👨‍⚕️ Doctors & Specialities":
    st.title("Doctors & Specialities")

    active_doc  = query("SELECT COUNT(*) v FROM doctors WHERE active=1").iloc[0,0]
    total_spec  = query("SELECT COUNT(*) v FROM specialities").iloc[0,0]
    avg_consult = query("SELECT ROUND(AVG(c),1) v FROM (SELECT COUNT(*) c FROM consultations GROUP BY doctor_id)").iloc[0,0]

    c1,c2,c3 = st.columns(3)
    kpi(c1, f"{active_doc}",  "Active Doctors")
    kpi(c2, f"{total_spec}",  "Specialities")
    kpi(c3, f"{avg_consult}", "Avg Consultations / Doctor")

    st.markdown("<br>", unsafe_allow_html=True)
    col_l, col_r = st.columns(2)

    with col_l:
        section("👨‍⚕️ Consultations per Doctor")
        df_doc = query("""
            SELECT d.last_name || ' ' || d.first_name AS doctor,
                   s.speciality_name AS speciality,
                   COUNT(c.consultation_id) AS consultations
            FROM doctors d
            JOIN specialities s ON s.speciality_id = d.speciality_id
            JOIN consultations c ON c.doctor_id = d.doctor_id
            GROUP BY d.doctor_id
            ORDER BY consultations DESC
        """)
        fig = px.bar(df_doc, x="consultations", y="doctor",
                     orientation="h", color="speciality", color_discrete_sequence=COLORS)
        fig.update_layout(plot_bgcolor="white", paper_bgcolor="white",
                          margin=dict(t=10,b=10,l=10,r=10), yaxis_title="")
        st.plotly_chart(fig, use_container_width=True)

    with col_r:
        section("💰 Revenue per Doctor (Paid only)")
        df_rev_doc = query("""
            SELECT d.last_name || ' ' || d.first_name AS doctor,
                   SUM(c.amount) AS revenue
            FROM doctors d
            JOIN consultations c ON c.doctor_id = d.doctor_id
            WHERE c.paid = 1
            GROUP BY d.doctor_id
            ORDER BY revenue DESC
        """)
        fig = px.bar(df_rev_doc, x="doctor", y="revenue", color_discrete_sequence=[TEAL2])
        fig.update_layout(plot_bgcolor="white", paper_bgcolor="white",
                          margin=dict(t=10,b=10,l=10,r=10), xaxis_title="", yaxis_title="Revenue (DA)")
        st.plotly_chart(fig, use_container_width=True)

    section("🏆 Top 3 Most Profitable Specialities")
    df_top3 = query("""
        SELECT * FROM (
            SELECT DENSE_RANK() OVER (ORDER BY SUM(c.amount) DESC) AS rank_pos,
                   s.speciality_name, SUM(c.amount) AS total_revenue,
                   COUNT(c.consultation_id) AS consultations
            FROM specialities s
            JOIN doctors d ON d.speciality_id = s.speciality_id
            JOIN consultations c ON c.doctor_id = d.doctor_id
            WHERE c.paid = 1
            GROUP BY s.speciality_id
        ) WHERE rank_pos <= 3
    """)
    st.dataframe(df_top3, use_container_width=True, hide_index=True)

    section("📋 Unpaid Consultations")
    df_unpaid = query("""
        SELECT p.last_name || ' ' || p.first_name AS patient,
               c.consultation_date, c.amount,
               d.last_name || ' ' || d.first_name AS doctor,
               s.speciality_name
        FROM consultations c
        JOIN patients p ON p.patient_id = c.patient_id
        JOIN doctors d ON d.doctor_id = c.doctor_id
        JOIN specialities s ON s.speciality_id = d.speciality_id
        WHERE c.paid = 0 AND c.status = 'Completed'
        ORDER BY c.consultation_date DESC
        LIMIT 20
    """)
    st.dataframe(df_unpaid, use_container_width=True, hide_index=True)


# ════════════════════════════════════════════════════════════════════════════
# PAGE 4 — PHARMACY
# ════════════════════════════════════════════════════════════════════════════
elif page == "💊 Pharmacy":
    st.title("Pharmacy & Medications")

    total_meds  = query("SELECT COUNT(*) v FROM medications").iloc[0,0]
    stock_value = query("SELECT COALESCE(SUM(unit_price*available_stock),0) v FROM medications").iloc[0,0]
    low_stock   = query("SELECT COUNT(*) v FROM medications WHERE available_stock < minimum_stock").iloc[0,0]
    expiring    = query("""
        SELECT COUNT(*) v FROM medications
        WHERE expiration_date BETWEEN date('now') AND date('now','+6 months')
    """).iloc[0,0]

    c1,c2,c3,c4 = st.columns(4)
    kpi(c1, f"{total_meds}",       "Total Medications")
    kpi(c2, f"{stock_value:,.0f}", "Stock Value (DA)", suffix=" DA")
    kpi(c3, f"{low_stock}",        "⚠️ Low Stock Items")
    kpi(c4, f"{expiring}",         "⏰ Expiring < 6 months")

    st.markdown("<br>", unsafe_allow_html=True)

    if low_stock > 0:
        section("⚠️ Medications to Restock")
        df_low = query("""
            SELECT commercial_name, available_stock AS current_stock,
                   minimum_stock,
                   (minimum_stock - available_stock) AS quantity_needed
            FROM medications
            WHERE available_stock < minimum_stock
        """)
        for _, row in df_low.iterrows():
            st.markdown(f"""
            <div class="alert-card">
                <span class="alert-text">
                    <b>{row['commercial_name']}</b> —
                    Stock: {row['current_stock']} / Min: {row['minimum_stock']} —
                    Need to order: <b>{row['quantity_needed']}</b> units
                </span>
            </div>""", unsafe_allow_html=True)

    col_l, col_r = st.columns(2)

    with col_l:
        section("💊 Top 5 Most Prescribed Medications")
        df_top_med = query("""
            SELECT m.commercial_name || ' (' || m.generic_name || ')' AS medication,
                   COUNT(prd.medication_id) AS times_prescribed,
                   SUM(prd.quantity) AS total_quantity
            FROM medications m
            JOIN prescription_details prd ON prd.medication_id = m.medication_id
            GROUP BY m.medication_id
            ORDER BY times_prescribed DESC
            LIMIT 5
        """)
        fig = px.bar(df_top_med, x="times_prescribed", y="medication",
                     orientation="h", color_discrete_sequence=[TEAL])
        fig.update_layout(plot_bgcolor="white", paper_bgcolor="white",
                          margin=dict(t=10,b=10,l=10,r=10), yaxis_title="")
        st.plotly_chart(fig, use_container_width=True)

    with col_r:
        section("⏰ Expiring in < 6 Months")
        df_exp = query("""
            SELECT commercial_name,
                   expiration_date,
                   CAST(julianday(expiration_date) - julianday('now') AS INTEGER) AS days_left
            FROM medications
            WHERE expiration_date BETWEEN date('now') AND date('now','+6 months')
            ORDER BY days_left
        """)
        if df_exp.empty:
            st.info("No medications expiring in the next 6 months.")
        else:
            fig = px.bar(df_exp, x="days_left", y="commercial_name",
                         orientation="h", color="days_left",
                         color_continuous_scale=["#EF4444","#F59E0B","#22C55E"])
            fig.update_layout(plot_bgcolor="white", paper_bgcolor="white",
                              margin=dict(t=10,b=10,l=10,r=10), yaxis_title="")
            st.plotly_chart(fig, use_container_width=True)

    section("📦 Full Medication Inventory")
    df_all = query("""
        SELECT medication_code, commercial_name, generic_name,
               form, dosage, unit_price, available_stock,
               minimum_stock, expiration_date,
               CASE WHEN prescription_required=1 THEN 'Yes' ELSE 'No' END AS prescription,
               CASE WHEN reimbursable=1 THEN 'Yes' ELSE 'No' END AS reimbursable
        FROM medications ORDER BY commercial_name
    """)
    st.dataframe(df_all, use_container_width=True, hide_index=True)
