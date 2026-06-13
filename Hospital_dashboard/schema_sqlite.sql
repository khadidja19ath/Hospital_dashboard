-- ============= SQLITE SCHEMA (adapted from MySQL) =============

CREATE TABLE specialities(
speciality_id INTEGER PRIMARY KEY AUTOINCREMENT,
speciality_name VARCHAR(100) NOT NULL UNIQUE,
description TEXT,
consultation_fee DECIMAL(10, 2) NOT NULL
);

CREATE TABLE doctors(
doctor_id INTEGER PRIMARY KEY AUTOINCREMENT,
last_name VARCHAR(50) NOT NULL,
first_name VARCHAR(50) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
phone VARCHAR(20),
speciality_id INTEGER NOT NULL,
license_number VARCHAR(20) UNIQUE NOT NULL,
hire_date DATE,
office VARCHAR(100),
active BOOLEAN DEFAULT 1,
FOREIGN KEY (speciality_id) REFERENCES specialities(speciality_id)
);

CREATE TABLE patients (
patient_id INTEGER PRIMARY KEY AUTOINCREMENT,
file_number VARCHAR(20) UNIQUE NOT NULL,
last_name VARCHAR(50) NOT NULL,
first_name VARCHAR(50) NOT NULL,
date_of_birth DATE NOT NULL,
gender VARCHAR(1) NOT NULL CHECK (gender IN ('M','F')),
blood_type VARCHAR(5),
email VARCHAR(100),
phone VARCHAR(20) NOT NULL,
address TEXT,
city VARCHAR(50),
province VARCHAR(50),
registration_date DATE DEFAULT (CURRENT_DATE),
insurance VARCHAR(100),
insurance_number VARCHAR(50),
allergies TEXT,
medical_history TEXT
);

CREATE TABLE consultations (
consultation_id INTEGER PRIMARY KEY AUTOINCREMENT,
patient_id INTEGER NOT NULL,
doctor_id INTEGER NOT NULL,
consultation_date DATETIME NOT NULL,
reason TEXT NOT NULL,
diagnosis TEXT,
observations TEXT,
blood_pressure VARCHAR(20),
temperature DECIMAL(4, 2),
weight DECIMAL(5, 2),
height DECIMAL(5, 2),
status VARCHAR(20) DEFAULT 'Scheduled' CHECK (status IN ('Scheduled','In Progress','Completed','Cancelled')),
amount DECIMAL(10, 2),
paid BOOLEAN DEFAULT 0,
FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

CREATE TABLE medications(
medication_id INTEGER PRIMARY KEY AUTOINCREMENT,
medication_code VARCHAR(20) UNIQUE NOT NULL,
commercial_name VARCHAR(150) NOT NULL,
generic_name VARCHAR(150),
form VARCHAR(50),
dosage VARCHAR(50),
manufacturer VARCHAR(100),
unit_price DECIMAL(10, 2) NOT NULL,
available_stock INTEGER DEFAULT 0,
minimum_stock INTEGER DEFAULT 10,
expiration_date DATE,
prescription_required BOOLEAN DEFAULT 1,
reimbursable BOOLEAN DEFAULT 0
);

CREATE TABLE prescriptions(
prescription_id INTEGER PRIMARY KEY AUTOINCREMENT,
consultation_id INTEGER NOT NULL,
prescription_date DATETIME DEFAULT CURRENT_TIMESTAMP,
treatment_duration INTEGER,
general_instructions TEXT,
FOREIGN KEY (consultation_id) REFERENCES consultations(consultation_id) ON DELETE CASCADE
);

CREATE TABLE prescription_details(
detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
prescription_id INTEGER NOT NULL,
medication_id INTEGER NOT NULL,
quantity INTEGER NOT NULL CHECK (quantity > 0),
dosage_instructions VARCHAR(200) NOT NULL,
duration INTEGER NOT NULL,
total_price DECIMAL(10, 2),
FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE,
FOREIGN KEY (medication_id) REFERENCES medications(medication_id)
);

CREATE INDEX idx_patient ON patients(last_name, first_name);
CREATE INDEX idx_consultation_date ON consultations(consultation_date);
CREATE INDEX idx_patient_consultation ON consultations(patient_id);
CREATE INDEX idx_doctor_consultation ON consultations(doctor_id);
CREATE INDEX idx_med_comercial_name ON medications(commercial_name);
CREATE INDEX idx_presc_consul ON prescriptions(consultation_id);
