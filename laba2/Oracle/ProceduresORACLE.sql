CREATE OR REPLACE PROCEDURE create_new_order(p_cid IN NUMBER, p_paddr IN VARCHAR2, p_daddr IN VARCHAR2, p_dist IN NUMBER, p_w IN NUMBER) IS
BEGIN
  INSERT INTO Orders (ClientID, PickupAddress, DropAddress, Price, StatusID) 
  VALUES (p_cid, p_paddr, p_daddr, calc_delivery_cost(p_dist, p_w), 1);
END;
/

CREATE OR REPLACE PROCEDURE assign_driver_to_order(p_oid IN NUMBER, p_vid IN NUMBER) IS
BEGIN
  UPDATE Orders SET VehicleID = p_vid, StatusID = 2 WHERE OrderID = p_oid;
END;
/

CREATE OR REPLACE PROCEDURE verify_driver_status(p_uid IN NUMBER) IS
BEGIN
  UPDATE Users SET Phone = Phone || ' [VERIFIED]' WHERE UserID = p_uid;
END;
/

CREATE OR REPLACE PROCEDURE assign_optimal_vehicle_to_order(
    p_orderId IN NUMBER,
    p_requiredCapacityKG IN NUMBER
) IS
    v_vehicleId NUMBER;
BEGIN
    SELECT VehicleID INTO v_vehicleId FROM (
        SELECT v.VehicleID
        FROM Vehicles v
        JOIN Users u ON v.DriverID = u.UserID
        WHERE v.CapacityKG >= p_requiredCapacityKG
          AND u.Phone LIKE '%VERIFIED%'
          AND NOT EXISTS (
              SELECT 1 FROM Orders o
              WHERE o.VehicleID = v.VehicleID AND o.StatusID = 2
          )
    ) WHERE ROWNUM <= 1;

    UPDATE Orders SET VehicleID = v_vehicleId, StatusID = 2 WHERE OrderID = p_orderId;
    DBMS_OUTPUT.PUT_LINE('На заказ ' || p_orderId || ' назначена машина с ID ' || v_vehicleId);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Свободных и подходящих машин не найдено.');
END;
/

CREATE OR REPLACE PROCEDURE handle_vehicle_breakdown(
    p_brokenVehicleId IN NUMBER
) IS
    v_affectedOrders NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_affectedOrders
    FROM Orders
    WHERE VehicleID = p_brokenVehicleId AND StatusID = 2;

    IF v_affectedOrders > 0 THEN
        UPDATE Orders
        SET StatusID = 1
        WHERE VehicleID = p_brokenVehicleId AND StatusID = 2;

        DBMS_OUTPUT.PUT_LINE('ТС с ID ' || p_brokenVehicleId || ' выведено из строя!');
        DBMS_OUTPUT.PUT_LINE('Заказов сброшено в очередь на переназначение: ' || v_affectedOrders);
    ELSE
        DBMS_OUTPUT.PUT_LINE('У ТС с ID ' || p_brokenVehicleId || ' нет активных заказов. Поломка зафиксирована.');
    END IF;
END;
/

DROP PROCEDURE create_new_order;
DROP PROCEDURE assign_driver_to_order;
DROP PROCEDURE verify_driver_status;
DROP PROCEDURE assign_optimal_vehicle_to_order;
DROP PROCEDURE handle_vehicle_breakdown;


