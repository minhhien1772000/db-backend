Use hospital; 
-- 
CREATE PROCEDURE SelectDoctorListByShift(IN FROM_TIME TIME, IN TO_TIME time, IN dname varchar(100), IN date DATE)
BEGIN
    SELECT *
    FROM Doctor
	    WHERE dssn IN (
	        SELECT doctor_ssn
	        FROM Shift
	        WHERE fromtime = FROM_TIME
	          AND totime = TO_TIME
	          AND date = shiftdate)
	      AND departmentName = dname;
	END;

-- 
CREATE PROCEDURE SelectDoctorListByDate(IN dname varchar(100), IN date DATE)
BEGIN
    SELECT *
    FROM Doctor
    WHERE dssn in (
        SELECT doctor_ssn
        FROM Shift
        WHERE date = shiftdate)
      AND  departmentName = dname;
end;
--
CREATE PROCEDURE SelectDoctorListByShiftByDateAllDepartment(IN FROM_TIME TIME, IN TO_TIME time, IN date DATE)
BEGIN
    SELECT *
    FROM Doctor
    WHERE dssn in (
        SELECT doctor_ssn
        FROM Shift
        WHERE fromtime > FROM_TIME
          AND  totime < TO_TIME
          AND date = shiftdate
    );
end;
--
CREATE PROCEDURE SelectDoctorListByDateInAllDepartment(IN date DATE)
BEGIN
    SELECT *
    FROM Doctor
    WHERE dssn in (
        SELECT doctor_ssn
        FROM Shift
        WHERE date = shiftdate
    );
end;
--
CREATE PROCEDURE countPatientByShiftAndDateInDepartment(IN FROM_TIME TIME, IN TO_TIME time, IN dname varchar(100),
                                                        IN _date DATE)
BEGIN
    SELECT count(*)
    FROM Examination
    WHERE(
              SELECT id, doctor_ssn
              FROM Shift
              WHERE fromtime > FROM_TIME
                AND totime < TO_TIME
                AND _date = shiftdate
                AND dname = (SELECT departmentName
                             FROM Doctor
                             WHERE dssn = doctor_ssn
              )
          ) is not null
    group by medical_examination_id;
 
end; 
--
CREATE PROCEDURE countInPatientByShiftAndDateInDepartment(IN FROM_TIME TIME, IN TO_TIME time, IN dname varchar(100),
                                                          IN _date DATE)
BEGIN
    SELECT count(*)
    FROM Examination
    WHERE(
              SELECT id, doctor_ssn
              FROM Shift
              WHERE fromtime > FROM_TIME
                AND totime < TO_TIME
                AND _date = shiftdate
                AND patient_ssn in (SELECT issn FROM InPatient)
                AND dname = (SELECT departmentName
                             FROM Doctor
                             WHERE dssn = doctor_ssn
              )
          ) is not null
    group by medical_examination_id;
 end;
--
CREATE PROCEDURE countOutPatientByShiftAndDateInDepartment(IN FROM_TIME TIME, IN TO_TIME time, IN dname varchar(100),
                                                           IN _date DATE)
BEGIN
    SELECT count(*)
    FROM Examination
    WHERE(
              SELECT id, doctor_ssn
              FROM Shift
              WHERE fromtime > FROM_TIME
                AND totime < TO_TIME
                AND _date = shiftdate
                AND patient_ssn in (SELECT ossn FROM OutPatient)
                AND dname = (SELECT departmentName
                             FROM Doctor
                             WHERE dssn = doctor_ssn
              )
          ) is not null
    group by medical_examination_id;
 end; 
--
CREATE PROCEDURE countInPatientByShiftAndDateInAllDepartment(IN FROM_TIME TIME, IN TO_TIME time, IN _date DATE)
BEGIN
    SELECT count(*)
    FROM Examination
    WHERE(
              SELECT id, doctor_ssn
              FROM Shift
              WHERE fromtime > FROM_TIME
                AND totime < TO_TIME
                AND _date = shiftdate
                AND patient_ssn in (SELECT issn FROM InPatient)
          ) is not null
    group by medical_examination_id;
 end;
--
CREATE PROCEDURE countOutPatientByShiftAndDateInAllDepartment(IN FROM_TIME TIME, IN TO_TIME time, IN _date DATE)
BEGIN
    SELECT count(*)
    FROM Examination
    WHERE(
              SELECT id, doctor_ssn
              FROM Shift
              WHERE fromtime > FROM_TIME
                AND totime < TO_TIME
                AND _date = shiftdate
                AND patient_ssn in (SELECT ossn FROM OutPatient)
          ) is not null
    group by medical_examination_id;
 end;
--
CREATE PROCEDURE countTestByDateInDepartment(IN dname varchar(100), IN _date DATE)
BEGIN
    SELECT count(*)
    FROM TestResult
    WHERE medicalExamination_id in (SELECT *
                        FROM Examination ME
                        inner join Shift SH on ME.shift_id   = SH.id
                        WHERE dname = (SELECT departmentName FROM  Doctor WHERE SH.doctor_ssn = dssn)
                                      AND SH.shiftdate = _date
    );
 end;
--
CREATE PROCEDURE countTestByDateInAllDepartment(IN _date DATE)
BEGIN
    SELECT count(*)
    FROM TestResult
    WHERE medicalExamination_id in (SELECT *
                                    FROM Examination ME
                                             inner join Shift SH on ME.shift_id = SH.id
                                    WHERE SH.shiftdate = _date
    );
 end;
--
create procedure listAllExamPatientByDoctorAndDate(in doctorSsn char(9), in _date DATE)
BEGIN
    select *
    from Patient
    where ssn in (
        select patient_ssn
        from Examination
        where shift_id in (select id
                           from Shift
                           where _date = shiftdate
                             and doctorSsn = doctor_ssn
        )
    );
end;
--
create procedure listAllExamPatientByDoctorAndDate(in doctorSsn char(9), in patientSsn char(9))
BEGIN
    select *
    from Patient
    where ssn in (
        select patient_ssn
        from Examination
        where shift_id in (select id
                           from Shift
                           where _date = shiftdate
                             and doctorSsn = doctor_ssn
        )
    );
end;
--
create procedure listAllMedicationOfInpatient(in doctorSsn char(9), in patientSsn char(9))
BEGIN
    select medicine_name
    from PrescriptionHaveMedicine med
             inner join Prescription P on med.prescription_id = P.pid
             inner join Examination ME on P.medicalExamination_id = ME.medical_examination_id
    where ME.patient_ssn = patientSsn
      and doctorSsn = (select doctor_ssn from Shift where shift_id = ME.shift_id);
    ;
end;
 
create procedure listAllDiagnose(in doctorSsn char(9), in patientSsn char(9))
BEGIN
    select diag_name
    from MedicalExamination
    where mid in (
        select medical_examination_id
        from Examination
        where shift_id in (
            select id
            from Shift
            where doctor_ssn = doctorSsn
        )
          and patient_ssn = patientSsn
    );
end;
--
create procedure listAllAssignTest(in doctorSsn char(9), in patientSsn char(9))
BEGIN
    select *
    from TestResult
             inner join Examination on medical_examination_id = medicalExamination_id
    where doctor_assign_ssn = doctorSsn
      and patient_ssn = patientSsn;
end;
--
create procedure listAllAssignFilm(in doctorSsn char(9), in patientSsn char(9))
BEGIN
    select *
    from FilmResult
             inner join Examination on medical_examination_id = medicalExamination_id
    where doctor_assign_ssn = doctorSsn
      and patient_ssn = patientSsn;
end; 
--
create procedure listAllPatientWithSameIllness(in doctorSsn char(9), in illName varchar(255))
BEGIN
    select *
    from Patient
             inner join InPatientMedicalRecord rec on ssn = inpatient_ssn
             inner join InpatientMedicalRecordHaveIllness recI on rec.id = recI.id
    where illness_name = illName
      and (doctorSsn, inpatient_ssn) in (select doctor_ssn, patient_ssn
                                         from Shift
                                                  left join Examination E on Shift.id = E.shift_id
                                         where doctor_ssn = doctorSsn);
end;
--
create procedure listAllPatientWithSameIllnessWithCaution(in doctorSsn char(9), in illName varchar(255))
BEGIN
    select *
    from Patient
             inner join InPatientMedicalRecord rec on ssn = inpatient_ssn
             inner join InpatientMedicalRecordHaveIllness recI on rec.id = recI.id
    where illness_name = illName
      and note like '%caution%'
      and (doctorSsn, inpatient_ssn) in (select doctor_ssn, patient_ssn
                                         from Shift
                                                  left join Examination E on Shift.id = E.shift_id
                                         where doctor_ssn = doctorSsn);
end;  
--
create procedure listAllPatientOut(in doctorSsn char(9))
BEGIN
    select *
    from InPatient
    where outdoctorssn = doctorSsn;
end;

--UPDATE BHYT
CREATE PROC add_insurance @new_insurance int, @input_ssn varchar(9)
AS
	IF EXISTS (SELECT * FROM PATIENT where ssn = @input_ssn)
	BEGIN
		UPDATE PATIENT
		SET insurance_id = @NEW_INSURANCE
		WHERE ssn = @input_ssn
	END
	ELSE
	BEGIN
		PRINT 'There is no patient with this ssn in hospital'
	END
GO
 
--Thêm thông tin nhân khẩu
CREATE PROC UPDATE_PATIENT_INFO 
	@SSN VARCHAR(9),
	@N_NAME VARCHAR(225),
	@N_AGE INT,
	@N_ADDRESS VARCHAR(50),
	@N_HOMETOWN VARCHAR(20),
	@N_NATIONALITY VARCHAR(20),
	@N_SEX VARCHAR(1),
	@N_FOLK VARCHAR(20)
AS
	IF EXISTS (SELECT * FROM PATIENT WHERE SSN = @SSN)
	BEGIN
		UPDATE PATIENT
		SET @N_NAME = Patient_name,
			@N_AGE = AGE,
			@N_ADDRESS = ADDRESS,
			@N_HOMETOWN = HOMETOWN,
			@N_NATIONALITY = NATIONALITY,
			@N_SEX = SEX,
			@N_FOLK = FOLK
		WHERE @SSN = SSN
	END
 
	ELSE
	BEGIN
		PRINT 'There is no patient with this ssn in hospital'
	END
GO

--
CREATE PROCEDURE NEAREST_MEDICINE 
	@SSN VARCHAR(9)
AS
	DECLARE @PRESCRIPTION_SSN INT
	SET @PRESCRIPTION_SSN = (SELECT prescription_id 
							FROM Prescription
							WHERE medical_examination_id = (SELECT medical_examination_id
															FROM Examination
															WHERE patient_ssn = @SSN))
	SELECT medicine_name FROM PrescriptionHaveMedicine
	WHERE prescription_id = @PRESCRIPTION_SSN 
		AND TIMEHAVE = MIN(TIMEHAVE);
GO; 
--
create procedure findAllMedicineUsed(in patientSsn char(9))
begin
    select mname
    from Prescription
             inner join PrescriptionHaveMedicine on Prescription.pid = PrescriptionHaveMedicine.prescription_id
             inner join Medicine on PrescriptionHaveMedicine.medicine_name = Medicine.mname
    where medicalExamination_id in (select medical_examination_id from Examination where patient_ssn = patientSsn);
end;  
--
create procedure listAllTestResultInLastExamination(in patientSsn char(9))
BEGIN
    select *
    from TestResult
    where medicalExamination_id = (select medical_examination_id
                                   from Examination
                                   where patient_ssn = patientSsn
                                   order by patient_ssn desc
                                   limit 1);
end;        
--
create procedure listAllTestResultInAllTime(in patientSsn char(9))
BEGIN
    select *
    from TestResult
    where medicalExamination_id = (select medical_examination_id from Examination where patient_ssn = patientSsn);
end;
--
create procedure listAllTestResultInAllTimeWithCaution(in patientSsn char(9))
BEGIN
    select *
    from TestResult
    where medicalExamination_id = (select medical_examination_id from Examination where patient_ssn = patientSsn)
      and note like '%caution%';
end; 
--
create procedure listAllDoctorInLastExamination(in patientSsn char(9))
BEGIN
    select ename
    from Doctor
             inner join Employee E on Doctor.dssn = E.ssn
    where dssn in (select doctor_ssn
                   from Examination ex
                            inner join Shift S on ex.shift_id = S.id
                   where patient_ssn = patientSsn order by ex.medical_examination_id desc limit  1);
end; 
--
create role Manager;
create role Doctor;
create role Patient;



grant execute on procedure SelectDoctorListByShift  to Manager;
grant execute on procedure SelectDoctorListByDate  to Manager;
grant execute on procedure SelectDoctorListByShiftByDateAllDepartment  to Manager;
grant execute on procedure SelectDoctorListByDateInAllDepartment to Manager;
grant execute on procedure countPatientByShiftAndDateInDepartment to Manager;
grant execute on procedure countInPatientByShiftAndDateInDepartment to Manager;
grant execute on procedure countOutPatientByShiftAndDateInDepartment to Manager;
grant execute on procedure countInPatientByShiftAndDateInAllDepartment to Manager;
grant execute on procedure countOutPatientByShiftAndDateInAllDepartment to Manager;
grant execute on procedure countTestByDateInDepartment to Manager;
grant execute on procedure countTestByDateInAllDepartment to Manager;
grant execute on procedure listAllExamPatientByDoctorAndDate  to  'TienTran'@'localhost';
grant execute on procedure listAllExamPatientByDoctorAndDate to Patient;
grant execute on procedure  listAllMedicationOfInpatient to Patient;
grant execute on procedure listAllAssignTest to Patient;
grant execute on procedure  listAllAssignFilm to Patient;
grant execute on procedure listAllPatientWithSameIllness to Patient;
grant execute on procedure listAllPatientWithSameIllnessWithCaution to Patient;
grant execute on procedure  listAllPatientOut to Patient;
grant execute on procedure add_insurance  to Doctor;
grant execute on procedure NEAREST_MEDICINE  to Doctor;
grant execute on procedure findAllMedicineUsed to Doctor;
grant execute on procedure listAllTestResultInLastExamination to Doctor;
grant execute on procedure listAllTestResultInAllTime to Doctor;
grant execute on procedure listAllTestResultInAllTimeWithCaution to Doctor;
grant execute on procedure listAllDoctorInLastExamination to Doctor;

create user 'TranMinhHien'@'localhost' identified by 'minhhien17';
grant Doctor to 'TranMinhHien'@'localhost';
create user 'TienTran'@'localhost' identified by 'tientran';
grant Patient to 'TienTran'@'localhost';
create user 'DangPhuc'@'localhost' identified by 'dangphuc';
grant Manager to 'DangPhuc'@'localhost';

##
-- grant execute on procedure SelectDoctorListByShift  to 'Manager@localhost';
-- grant execute on procedure SelectDoctorListByDate  to 'Manager@localhost';
-- grant execute on procedure SelectDoctorListByShiftByDateAllDepartment  to 'Manager@localhost';
-- grant execute on procedure SelectDoctorListByDateInAllDepartment to 'Manager@localhost';
-- grant execute on procedure countPatientByShiftAndDateInDepartment to 'Manager@localhost';
-- grant execute on procedure countInPatientByShiftAndDateInDepartment to 'Manager@localhost';
-- grant execute on procedure countOutPatientByShiftAndDateInDepartment to 'Manager@localhost';
-- grant execute on procedure countInPatientByShiftAndDateInAllDepartment to 'Manager@localhost';
-- grant execute on procedure countOutPatientByShiftAndDateInAllDepartment to 'Manager@localhost';
-- grant execute on procedure countTestByDateInDepartment to 'Manager@localhost';
-- grant execute on procedure countTestByDateInAllDepartment to 'Manager@localhost';
-- grant execute on procedure listAllExamPatientByDoctorAndDate  to  'Doctor@localhost';
-- grant execute on procedure listAllExamPatientByDoctorAndDate to 'Doctor@localhost';
-- grant execute on procedure  listAllMedicationOfInpatient to 'Doctor@localhost';
-- grant execute on procedure listAllAssignTest to 'Doctor@localhost';
-- grant execute on procedure  listAllAssignFilm to 'Doctor@localhost';
-- grant execute on procedure listAllPatientWithSameIllness to 'Doctor@localhost';
-- grant execute on procedure listAllPatientWithSameIllnessWithCaution to 'Doctor@localhost';
-- grant execute on procedure  listAllPatientOut to 'Doctor@localhost';
-- grant execute on procedure add_insurance  to 'Patient@localhost';
-- grant execute on procedure NEAREST_MEDICINE  to 'Patient@localhost';
-- grant execute on procedure findAllMedicineUsed to 'Patient@localhost';
-- grant execute on procedure listAllTestResultInLastExamination to 'Patient@localhost';
-- grant execute on procedure listAllTestResultInAllTime to 'Patient@localhost';
-- grant execute on procedure listAllTestResultInAllTimeWithCaution to 'Patient@localhost';
-- grant execute on procedure listAllDoctorInLastExamination to 'Patient@localhost';


