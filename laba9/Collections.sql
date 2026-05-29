DROP TABLE AutoPark_Storage CASCADE CONSTRAINTS;
DROP TABLE Flat_Trips_Table CASCADE CONSTRAINTS;
DROP TYPE Vehicle_Coll_Type FORCE;
DROP TYPE Vehicle_Type FORCE;
DROP TYPE Trip_Nested_List FORCE;
DROP TYPE Trip_Type FORCE;

CREATE OR REPLACE TYPE Trip_Type AS OBJECT (
    TripDate DATE,
    Distance NUMBER
);
/

CREATE OR REPLACE TYPE Trip_Nested_List AS TABLE OF Trip_Type;
/

CREATE OR REPLACE TYPE Vehicle_Type AS OBJECT (
    VehicleID NUMBER,
    Model VARCHAR2(150),
    Trips Trip_Nested_List,
    
    MAP MEMBER FUNCTION get_id RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY Vehicle_Type AS
    MAP MEMBER FUNCTION get_id RETURN NUMBER IS BEGIN RETURN SELF.VehicleID; END;
END;
/

CREATE OR REPLACE TYPE Vehicle_Coll_Type AS TABLE OF Vehicle_Type;
/

CREATE TABLE AutoPark_Storage (
    ParkID NUMBER PRIMARY KEY,
    Vehicles Vehicle_Coll_Type
) NESTED TABLE Vehicles STORE AS Nested_Vehicles_Tab
  (NESTED TABLE Trips STORE AS Nested_Trips_Tab);


INSERT INTO AutoPark_Storage VALUES (10, 
    Vehicle_Coll_Type(
        Vehicle_Type(1, 'Volvo FH16', Trip_Nested_List(Trip_Type(SYSDATE-20, 1500), Trip_Type(SYSDATE-15, 800))),
        Vehicle_Type(2, 'Scania R500', Trip_Nested_List())
    )
);

INSERT INTO AutoPark_Storage VALUES (20, Vehicle_Coll_Type());
COMMIT;


DECLARE
    v_park_coll Vehicle_Coll_Type;
    test_vehicle Vehicle_Type;
BEGIN
    SELECT Vehicles INTO v_park_coll FROM AutoPark_Storage WHERE ParkID = 10;
    test_vehicle := Vehicle_Type(1, 'Volvo FH16', Trip_Nested_List(Trip_Type(SYSDATE-20, 1500), Trip_Type(SYSDATE-15, 800)));

    DBMS_OUTPUT.PUT_LINE('--- Поиск в коллекции ---');
    IF test_vehicle MEMBER OF v_park_coll THEN
        DBMS_OUTPUT.PUT_LINE('Автомобиль ' || test_vehicle.Model || ' найден в автопарке 10.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Автомобиль не найден.');
    END IF;
END;
/

SELECT PARKID, 'Коллекция пуста' as Status
FROM AUTOPARK_STORAGE
WHERE VEHICLES IS EMPTY;


CREATE TABLE Flat_Trips_Table (
    ParkID NUMBER,
    VehicleID NUMBER,
    Model VARCHAR2(150),
    TripDate DATE,
    Distance NUMBER
);

INSERT INTO Flat_Trips_Table (ParkID, VehicleID, Model, TripDate, Distance)
SELECT 
    p.ParkID,
    v.VehicleID,
    v.Model,
    t.TripDate,
    t.Distance
FROM AutoPark_Storage p,
     TABLE(p.Vehicles) v,        
     TABLE(v.Trips) t;
COMMIT;

SELECT * FROM Flat_Trips_Table;


DECLARE
    v_nested_coll Vehicle_Coll_Type;
    
    TYPE Assoc_Array_Type IS TABLE OF VARCHAR2(150) INDEX BY PLS_INTEGER;
    v_dict Assoc_Array_Type;
    v_idx PLS_INTEGER;
BEGIN
    SELECT Vehicles INTO v_nested_coll FROM AutoPark_Storage WHERE ParkID = 10;
    
    FOR i IN 1..v_nested_coll.COUNT LOOP
        v_dict(v_nested_coll(i).VehicleID) := v_nested_coll(i).Model;
    END LOOP;
    
    v_idx := v_dict.FIRST;
    WHILE v_idx IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE('Машина ID: ' || v_idx || ' -> Модель: ' || v_dict(v_idx));
        v_idx := v_dict.NEXT(v_idx);
    END LOOP;
END;
/


DECLARE
    TYPE Park_List_Type IS TABLE OF Vehicle_Coll_Type;
    v_bulk_parks Park_List_Type;
    
    TYPE Id_List IS TABLE OF NUMBER;
    v_new_park_ids Id_List := Id_List(101, 102, 103);
BEGIN
    SELECT Vehicles BULK COLLECT INTO v_bulk_parks 
    FROM AutoPark_Storage 
    WHERE ParkID = 10;

    FORALL i IN 1..v_new_park_ids.COUNT
        INSERT INTO AutoPark_Storage VALUES (v_new_park_ids(i), v_bulk_parks(1));
        
    DBMS_OUTPUT.PUT_LINE('Массово создано ' || SQL%ROWCOUNT || ' новых автопарков.');
    COMMIT;
END;
/

SELECT * from AUTOPARK_STORAGE;