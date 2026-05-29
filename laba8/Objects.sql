SET SERVEROUTPUT ON;

DROP VIEW employee_obj_view;
DROP VIEW vacation_obj_view;
DROP TABLE employee_obj_table;
DROP TABLE vacation_obj_table;
DROP TYPE employee_type FORCE;
DROP TYPE vacation_type FORCE;

--2
CREATE OR REPLACE TYPE employee_type AS OBJECT (
    empid NUMBER,
    fullname VARCHAR2(150),
    email VARCHAR2(100),
    hiredate DATE,
    vacationdaystaken NUMBER,
    gender CHAR(1),
    CONSTRUCTOR FUNCTION employee_type(p_id NUMBER, p_name VARCHAR2, p_email VARCHAR2, p_gender CHAR) RETURN SELF AS RESULT,
    ORDER MEMBER FUNCTION compare_experience(other employee_type) RETURN INTEGER,
    MEMBER FUNCTION get_remaining_vacation RETURN NUMBER DETERMINISTIC,
    MEMBER PROCEDURE add_vacation(p_days NUMBER)
);
/

CREATE OR REPLACE TYPE BODY employee_type AS
    CONSTRUCTOR FUNCTION employee_type(p_id NUMBER, p_name VARCHAR2, p_email VARCHAR2, p_gender CHAR) RETURN SELF AS RESULT IS
    BEGIN
        SELF.empid := p_id; SELF.fullname := p_name; SELF.email := p_email;
        SELF.hiredate := SYSDATE; SELF.vacationdaystaken := 0; 
        SELF.gender := p_gender; RETURN;
    END;
    ORDER MEMBER FUNCTION compare_experience(other employee_type) RETURN INTEGER IS
    BEGIN
        IF SELF.hiredate < other.hiredate THEN RETURN 1; 
        ELSIF SELF.hiredate > other.hiredate THEN RETURN -1; 
        ELSE RETURN 0; END IF;
    END;
    MEMBER FUNCTION get_remaining_vacation RETURN NUMBER DETERMINISTIC IS
    BEGIN RETURN 28 - SELF.vacationdaystaken; END;
    MEMBER PROCEDURE add_vacation(p_days NUMBER) IS
    BEGIN SELF.vacationdaystaken := SELF.vacationdaystaken + p_days; END;
END;
/

CREATE OR REPLACE TYPE vacation_type AS OBJECT (
    vacid NUMBER,
    empid NUMBER,
    startdate DATE,
    duration NUMBER,
    vaccategory VARCHAR2(50),
    isapproved NUMBER(1),
    CONSTRUCTOR FUNCTION vacation_type(p_vid NUMBER, p_eid NUMBER, p_dur NUMBER, p_appr NUMBER) RETURN SELF AS RESULT,
    MEMBER FUNCTION get_end_date RETURN DATE DETERMINISTIC,
    MEMBER PROCEDURE extend_vacation(p_extra NUMBER)
);
/

CREATE OR REPLACE TYPE BODY vacation_type AS
    CONSTRUCTOR FUNCTION vacation_type(p_vid NUMBER, p_eid NUMBER, p_dur NUMBER, p_appr NUMBER) RETURN SELF AS RESULT IS
    BEGIN
        SELF.vacid := p_vid; SELF.empid := p_eid; SELF.startdate := SYSDATE;
        SELF.duration := p_dur; SELF.vaccategory := 'Трудовой'; 
        SELF.isapproved := p_appr; RETURN;
    END;
    MEMBER FUNCTION get_end_date RETURN DATE DETERMINISTIC IS
    BEGIN RETURN SELF.startdate + SELF.duration; END;
    MEMBER PROCEDURE extend_vacation(p_extra NUMBER) IS
    BEGIN SELF.duration := SELF.duration + p_extra; END;
END;
/

--3
CREATE TABLE employee_obj_table OF employee_type (empid PRIMARY KEY);
CREATE TABLE vacation_obj_table OF vacation_type (vacid PRIMARY KEY);

INSERT INTO employee_obj_table
SELECT employee_type(u.UserID, u.FullName, u.Email, CASE WHEN MOD(u.UserID, 2) = 0 THEN 'M' ELSE 'F' END) 
FROM Users u WHERE u.RoleID = 2;

INSERT INTO vacation_obj_table
SELECT vacation_type(a.AppID, a.CandidateID, 14, 1) FROM Applications a;
COMMIT;

SELECT VALUE(e) FROM employee_obj_table e WHERE empid = 3;

SELECT e.FullName, e.get_remaining_vacation() AS "Остаток отпуска"
FROM employee_obj_table e;

SELECT e.fullname, e.hiredate 
FROM employee_obj_table e 
ORDER BY VALUE(e) DESC;

DECLARE
    emp employee_type;
BEGIN
    SELECT VALUE(e) INTO emp FROM employee_obj_table e WHERE empid = 3;
    emp.add_vacation(5);
    UPDATE employee_obj_table e SET VALUE(e) = emp WHERE empid = 3;
    DBMS_OUTPUT.PUT_LINE('Сотрудник: ' || emp.fullname);
    DBMS_OUTPUT.PUT_LINE('Количество дней: ' || emp.vacationdaystaken);
END;
/

DECLARE
    vac vacation_type;
BEGIN
    SELECT VALUE(v) INTO vac FROM vacation_obj_table v WHERE vacid = 1;
    vac.extend_vacation(5);
    UPDATE vacation_obj_table v SET VALUE(v) = vac WHERE vacid = 1;
    DBMS_OUTPUT.PUT_LINE('Обновлен отпуск ID: ' || vac.vacid);
    DBMS_OUTPUT.PUT_LINE('Новая длительность: ' || vac.duration || ' дней');
    COMMIT;
END;
/

--4
CREATE OR REPLACE VIEW employee_obj_view OF employee_type
WITH OBJECT IDENTIFIER (empid) AS
SELECT 
    CAST(UserID AS NUMBER), 
    CAST(FullName AS VARCHAR2(150)), 
    CAST(Email AS VARCHAR2(100)), 
    CAST(SYSDATE AS DATE), 
    CAST(0 AS NUMBER), 
    CAST('M' AS CHAR(1)) 
FROM Users;

CREATE OR REPLACE VIEW vacation_obj_view OF vacation_type
WITH OBJECT IDENTIFIER (vacid) AS
SELECT 
    CAST(AppID AS NUMBER), 
    CAST(CandidateID AS NUMBER), 
    CAST(ApplyDate AS DATE), 
    CAST(14 AS NUMBER), 
    CAST('Заявка' AS VARCHAR2(50)), 
    CAST(1 AS NUMBER(1)) 
FROM Applications;

BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Данные из объектных таблиц и представлений ---');
    FOR r IN (SELECT e.fullname, e.get_remaining_vacation() as rem FROM employee_obj_table e WHERE ROWNUM <= 3) LOOP
        DBMS_OUTPUT.PUT_LINE('Сотрудник: ' || r.fullname || ', Остаток: ' || r.rem);
    END LOOP;
END;
/

BEGIN
    FOR r IN (SELECT v.vacid, v.vaccategory, v.get_end_date() as end_d 
              FROM vacation_obj_view v 
              WHERE ROWNUM <= 3) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Отпуск ID: ' || r.vacid || 
                             ', Категория: ' || r.vaccategory || 
                             ', Дата окончания: ' || TO_CHAR(r.end_d, 'DD.MM.YYYY'));
    END LOOP;
END;
/

--5
CREATE INDEX idx_emp_name ON employee_obj_table (fullname);
CREATE BITMAP INDEX idx_vacation_func ON employee_obj_table e (e.get_remaining_vacation());
CREATE INDEX idx_vac_category ON vacation_obj_table (vaccategory);
CREATE BITMAP INDEX idx_vac_end_func ON vacation_obj_table v (v.get_end_date());

EXPLAIN PLAN FOR SELECT /*+ INDEX(e idx_emp_name) */ * FROM employee_obj_table e WHERE e.fullname = 'Кандидат 1';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR SELECT /*+ INDEX(e idx_vacation_func) */ * FROM employee_obj_table e WHERE e.get_remaining_vacation() < 15;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR SELECT /*+ INDEX(v idx_vac_category) */ * FROM vacation_obj_table v WHERE v.vaccategory = 'Трудовой';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR SELECT /*+ INDEX(v idx_vac_end_func) */ * FROM vacation_obj_table v WHERE v.get_end_date() > SYSDATE;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

DROP INDEX idx_emp_name;
DROP INDEX idx_vacation_func;
DROP INDEX idx_vac_category;
DROP INDEX idx_vac_end_func;