
-- ========== PART 1: BASIC QUERIES (Q1-Q5) ==========

-- Q1. List all patients with their main information
-- Expected: file_number, full_name, date_of_birth, phone, city

SELECT p.file_number,        
       CONCAT( p.last_name , ' ' , p.first_name ) AS full_name, 
       p.date_of_birth, 
       p.phone , 
       p.city
FROM  patients p;


-- Q2. Display all doctors with their specialty
-- Expected: doctor_name, specialty_name, office, active

SELECT    CONCAT( d.last_name , ' ' , d.first_name ) AS doctor_name,  
          s.speciality_name , 
          d.office , 
          d.active
FROM doctors d
JOIN specialities s ON s.speciality_id = d.speciality_id;

-- Q3. Find all medications with price less than 500 DA
-- Expected: medication_code, commercial_name, unit_price, available_stock

SELECT m.medication_code , 
       m.commercial_name , 
       m.unit_price ,
       m.available_stock
FROM medications m
WHERE unit_price < 500.00;


-- Q4. List consultations from January 2025
-- Expected: consultation_date, patient_name, doctor_name, status

SELECT c.consultation_date , 
       CONCAT(p.last_name , ' ' , p.first_name) AS patient_name, 
       CONCAT(d.last_name , ' ' , d.first_name) AS doctor_name, 
	   c.status
FROM consultations c
JOIN patients p ON p.patient_id = c.patient_id
JOIN doctors d ON d.doctor_id = c.doctor_id
WHERE c.consultation_date >= '2025-01-01';


-- Q5. Display medications where stock is below minimum stock
-- Expected: commercial_name, available_stock, minimum_stock, difference

SELECT m.commercial_name , 
       m.available_stock , 
       m.minimum_stock ,
       (m.minimum_stock - m.available_stock) AS difference
FROM medications m
WHERE m.available_stock < m.minimum_stock;


-- ========== PART 2: QUERIES WITH JOINS (Q6-Q10) ==========

-- Q6. Display all consultations with patient and doctor names
-- Expected: consultation_date, patient_name, doctor_name, diagnosis, amount

SELECT c.consultation_date ,
       CONCAT(p.last_name , ' ' , p.first_name) AS patient_name, 
       CONCAT(d.last_name , ' ' , d.first_name) AS doctor_name, 
       c.diagnosis , 
       c.amount
FROM consultations c
LEFT JOIN doctors d ON d.doctor_id = c.doctor_id
LEFT JOIN patients p ON p.patient_id = c.patient_id;


-- Q7. List all prescriptions with medication details
-- Expected: prescription_date, patient_name, medication_name, quantity, dosage_instructions

SELECT pr.prescription_date,
      CONCAT(p.last_name , ' ' , p.first_name) AS patient_name, 
       CONCAT( m.commercial_name , ' ' , m.generic_name ) AS medication_name,
       prd.quantity,
       prd.dosage_instructions
FROM prescriptions pr
JOIN consultations c ON c.consultation_id = pr.consultation_id
JOIN patients p ON p.patient_id = c.patient_id
JOIN prescription_details prd ON prd.prescription_id = pr.prescription_id
JOIN medications m ON m.medication_id = prd.medication_id;
       

-- Q8. Display patients with their last consultation date
-- Expected: patient_name, last_consultation_date, doctor_name

SELECT p.last_name,
       p.first_name,
       c.consultation_date,
       CONCAT(d.last_name , ' ' , d.first_name) AS doctor_name
FROM patients p
JOIN consultations c ON c.patient_id = p.patient_id
JOIN doctors d ON d.doctor_id = c.doctor_id
JOIN (
SELECT c.patient_id,
	  MAX(c.consultation_date) AS last_consultation
FROM consultations c
GROUP BY c.patient_id
) lc 
ON lc.patient_id = c.patient_id
AND lc.last_consultation = c.consultation_date
ORDER BY c.consultation_date DESC;

-- Q9. List doctors and the number of consultations performed
-- Expected: doctor_name, consultation_count

SELECT  CONCAT(d.last_name , ' ' , d.first_name) AS doctor_name, 
        COUNT(consultation_id) AS consultation_count
FROM doctors d
JOIN consultations c ON c.doctor_id = d.doctor_id
GROUP BY c.doctor_id;


-- Q10. Display revenue by medical specialty
-- Expected: specialty_name, total_revenue, consultation_count

SELECT s.speciality_name,
       SUM(c.amount) AS total_revenue,
       COUNT(c.consultation_id) AS consultation_count
FROM specialities s 
JOIN doctors d ON  d.speciality_id = s.speciality_id
JOIN consultations c ON c.doctor_id = d.doctor_id
GROUP BY c.doctor_id;

-- ========== PART 3: AGGREGATE FUNCTIONS (Q11-Q15) ==========

-- Q11. Calculate total prescription amount per patient
-- Expected: patient_name, total_prescription_cost

SELECT 
       CONCAT ( p.last_name , ' ' , p.first_name ) AS patient_name,
       SUM(prd.total_price) AS total_prescription_cost
FROM prescription_details prd 
JOIN prescriptions pr ON pr.prescription_id = prd.prescription_id
JOIN consultations c ON c.consultation_id = pr.consultation_id
JOIN patients p ON p.patient_id = c.patient_id
GROUP BY p.patient_id;


-- Q12. Count the number of consultations per doctor
-- Expected: doctor_name, consultation_count

SELECT CONCAT(d.last_name , ' ' , d.first_name ) AS doctor_name,
       COUNT( c.consultation_id) AS consultation_count
FROM doctors d 
JOIN consultations c ON c.doctor_id = d.doctor_id
GROUP BY d.doctor_id;


-- Q13. Calculate total stock value of pharmacy
-- Expected: total_medications, total_stock_value

SELECT SUM(m.available_stock) AS total_medications,
       SUM(m.unit_price) AS total_stock_value 
FROM medications m;


-- Q14. Find average consultation price per specialty
-- Expected: specialty_name, average_price

SELECT s.speciality_name,
       AVG(c.amount) AS average_price
FROM specialities s
JOIN doctors d ON d.speciality_id = s.speciality_id
JOIN consultations c ON c.doctor_id = d.doctor_id
WHERE c.paid = TRUE
GROUP BY s.speciality_id;

-- Q15. Count number of patients by blood type
-- Expected: blood_type, patient_count

SELECT p.blood_type,
       COUNT(p.patient_id) AS patient_count
FROM patients p
GROUP BY p.blood_type;

-- ========== PART 4: ADVANCED QUERIES (Q16-Q20) ==========

-- Q16. Find the top 5 most prescribed medications
-- Expected: medication_name, times_prescribed, total_quantity


SELECT CONCAT( m.commercial_name , ' ' , m.generic_name ) AS medication_name,
       COUNT( prd.medication_id ) AS times_prescribed,
       SUM(prd.quantity) AS total_quantity
FROM medications m
JOIN prescription_details prd ON prd.medication_id = m.medication_id
GROUP BY prd.medication_id
ORDER BY times_prescribed DESC
LIMIT 5;


-- Q17. List patients who have never had a consultation
-- Expected: patient_name, registration_date

SELECT CONCAT(p.last_name , ' ' , p.first_name) AS patient_name,
       p.registration_date
FROM patients p 
WHERE patient_id NOT IN (
SELECT d.patient_id
FROM consultations d
);
	   
       
-- Q18. Display doctors who performed more than 2 consultations
-- Expected: doctor_name, specialty, consultation_count


SELECT CONCAT(d.last_name , ' ' , d.first_name ) AS doctor_name,
       s.speciality_name,
       COUNT(c.consultation_id) AS consultation_count
FROM doctors d 
JOIN consultations c ON c.doctor_id = d.doctor_id
JOIN specialities s ON s.speciality_id = d.speciality_id
GROUP BY d.doctor_id 
HAVING consultation_count > 2
ORDER BY consultation_count DESC;



-- Q19. Find unpaid consultations with total amount
-- Expected: patient_name, consultation_date, amount, doctor_name


SELECT CONCAT(p.last_name , ' ' , p.first_name ) AS patient_name,
       c.consultation_date,
       c.amount,
       CONCAT(d.last_name , ' ' , d.first_name ) AS doctor_name
 FROM patients p
 JOIN consultations c ON c.patient_id = p.patient_id
 JOIN doctors d ON d.doctor_id = c.doctor_id
 WHERE c.paid = FALSE;


-- Q20. List medications expiring in less than 6 months from today
-- Expected: medication_name, expiration_date, days_until_expiration


SELECT CONCAT(m.commercial_name ,' ',m.generic_name) AS medication_name,
       m.expiration_date,
       -- difference beteween current day and date of expiration
       DATEDIFF( m.expiration_date , CURDATE() ) AS days_until_expiration
FROM medications m
-- we will not display the medication expired : expiration_date < current date - so we use 'between'
-- DATE_ADD is a function which add to a time a specefied number ( interval ) like 6 month from current date 
WHERE m.expiration_date BETWEEN CURDATE() AND DATE_ADD(curdate() , INTERVAL 6 MONTH)
ORDER BY days_until_expiration;





-- ========== PART 5: SUBQUERIES (Q21-Q25) ==========

-- Q21. Find patients who consulted more than the average
-- Expected: patient_name, consultation_count, average_count

SELECT CONCAT(p.last_name ,' ', p.first_name) AS patient_name,
       COUNT(c.consultation_id) AS consultation_count
FROM patients p
JOIN consultations c ON c.patient_id = p.patient_id
GROUP BY p.patient_id
HAVING COUNT(c.consultation_id) > (
							 -- calculating the avrege of the number of consultations of all patients
                          SELECT  AVG(avr_count) AS average_consultations
				          FROM  (
							 -- finding the number of consultation for each patient
				                  SELECT COUNT(c.consultation_id) AS avr_count
							      FROM consultations c 
							      GROUP BY patient_id
					            ) AS t
						); 
       
-- Q22. List medications more expensive than average price
-- Expected: medication_name, unit_price, average_price

SELECT  CONCAT(m.commercial_name ,' ', m.generic_name) AS medication_name,
         m.unit_price
FROM medications m
where m.unit_price > (
       SELECT  AVG (unit_price) AS average_price
       FROM medications
);



-- Q23. Display doctors from the most requested specialty
-- Expected: doctor_name, specialty_name, specialty_consultation_count

		 -- === most requested doctor = most requested speciality since each consultation 
         -- === is done by one doctor in consultation table
             SELECT   CONCAT(d.last_name , ' ' , d.first_name ) AS doctor_name,
                      s.speciality_name,
					  COUNT(c.doctor_id) AS specialty_consultation_count
             FROM consultations c
             JOIN doctors d ON d.doctor_id = c.doctor_id
             JOIN specialities s ON s.speciality_id = d.speciality_id
             GROUP BY c.doctor_id
             ORDER BY specialty_consultation_count DESC ;
			
             
       
       
       
-- Q24. Find consultations with amount higher than average
-- Expected: consultation_date, patient_name, amount, average_amount

SELECT  CONCAT(p.last_name ,' ', p.first_name) AS patient_name,
        c.consultation_date,
        c.amount
FROM patients p
JOIN consultations c ON c.patient_id = p.patient_id
WHERE c.amount > (
          -- count the average of all consultations
          SELECT AVG(c.amount) AS average_amount
          FROM consultations c
          WHERE c.paid = TRUE
                 );          
          
          
-- Q25. List allergic patients who received a prescription
-- Expected: patient_name, allergies, prescription_count

SELECT CONCAT(p.last_name ,' ', p.first_name) AS patient_name,
       p.allergies,
       COUNT(pr.prescription_id) AS prescription_count
FROM patients p
JOIN consultations c ON c.patient_id = p.patient_id
JOIN prescriptions pr ON pr.consultation_id = c.consultation_id
GROUP BY p.patient_id
HAVING p.allergies != 'None';

-- ========== PART 6: BUSINESS ANALYSIS (Q26-Q30) ==========

-- Q26. Calculate total revenue per doctor (paid consultations only)
-- Expected: doctor_name, total_consultations, total_revenue

SELECT CONCAT(d.last_name , ' ' , d.first_name) AS doctor_name, 
       COUNT(c.consultation_id) AS total_consultation,
       SUM(c.amount) AS total_revenue
FROM doctors d
JOIN consultations c ON c.doctor_id = d.doctor_id
WHERE c.paid = TRUE
GROUP BY c.doctor_id;

-- Q27. Display top 3 most profitable specialties
-- Expected: rank, specialty_name, total_revenue

-- ==== the inner SELECT is to get the order of specialities by revenue and the external SELECT is to get 
-- ==== the 3 profitable specialities and if there are more than 1 speciality with same revenue we will 
-- ==== we will display it with the same rank to get true and precise information 

SELECT * FROM (
SELECT DENSE_RANK() OVER (ORDER BY SUM(c.amount) DESC) AS rank_speciality,
       s.speciality_name,
       SUM(c.amount) AS total_revenue
FROM specialities s
JOIN doctors d ON d.speciality_id = s.speciality_id
JOIN consultations c ON c.doctor_id = d.doctor_id
WHERE c.paid = TRUE 
GROUP BY s.speciality_id
) AS t
WHERE rank_speciality < 4 ;


-- Q28. List medications to restock (stock < minimum)
-- Expected: medication_name, current_stock, minimum_stock, quantity_needed

SELECT CONCAT( m.commercial_name , ' ' , m.generic_name) AS medication_name,
       m.available_stock AS current_stock,
       m.minimum_stock
FROM medications m
WHERE  m.available_stock < m.minimum_stock;
     
     
-- Q29. Calculate average number of medications per prescription
-- Expected: average_medications_per_prescription

SELECT AVG(nb_med_per_prs)
FROM ( 
SELECT COUNT(prd.medication_id) AS nb_med_per_prs
FROM prescription_details prd 
GROUP BY prescription_id ) AS t;



-- Q30. Generate patient demographics report by age group
-- Age groups: 0-18, 19-40, 41-60, 60+
-- Expected: age_group, patient_count, percentage

	
SELECT 
       CASE 
           WHEN timestampdiff(YEAR , date_of_birth, curdate() ) BETWEEN 0 AND 18 THEN  ' 0 - 18'
		   WHEN timestampdiff(YEAR , date_of_birth, curdate() ) BETWEEN 19 AND 40 THEN  '19 - 40'
		   WHEN timestampdiff(YEAR , date_of_birth, curdate() ) BETWEEN 41 AND 60 THEN  '41 - 60'
           ELSE '+60'
	   END  
           AS age_group,
COUNT(patient_id)
FROM patients
group by age_group;



-- ========== OR==========


SELECT 
       IF (timestampdiff(YEAR , date_of_birth , curdate()) <= 18, '0-18',
       IF (timestampdiff(YEAR , date_of_birth , curdate()) <= 40, '19-40',
       IF (timestampdiff(YEAR , date_of_birth , curdate()) <= 60,  '41-60' , '+60' )
          )
	   )
AS age_group,
COUNT(patient_id) AS patient_count
FROM patients 
GROUP BY age_group;
