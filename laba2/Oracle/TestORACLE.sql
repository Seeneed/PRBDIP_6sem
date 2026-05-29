SET SERVEROUTPUT ON;

SELECT calc_delivery_cost(500, 20) AS test_price FROM DUAL;
SELECT validate_credentials('client_p@mail.ru', 'pass2') AS user_id_found FROM DUAL;
SELECT check_verification_state(4) AS is_oleg_verified FROM DUAL;
SELECT get_driver_fleet_size(3) AS alex_cars FROM DUAL;
SELECT check_client_discount_eligibility(2) AS IsEligibleForDiscount FROM DUAL;

BEGIN
    create_new_order(2, 'Start Point', 'End Point', 100, 10);
    COMMIT;
END;
/

SELECT OrderID, ClientID, PickupAddress, Price, StatusID 
FROM Orders WHERE OrderID = (SELECT MAX(OrderID) FROM Orders);

BEGIN
    verify_driver_status(3);
    COMMIT;
END;
/

SELECT UserID, FullName, Phone FROM Users WHERE UserID = 3;

DECLARE
    v_latest_order_id NUMBER;
BEGIN
    SELECT MAX(OrderID) INTO v_latest_order_id FROM Orders;
    assign_driver_to_order(v_latest_order_id, 2);
    COMMIT;
END;
/

SELECT OrderID, VehicleID, StatusID 
FROM Orders WHERE OrderID = (SELECT MAX(OrderID) FROM Orders);

BEGIN
    handle_vehicle_breakdown(2);
    COMMIT;
END;
/

SELECT OrderID, VehicleID, StatusID FROM Orders WHERE VehicleID = 2;

BEGIN
    create_new_order(2, 'Another Start', 'Another End', 50, 5);
    COMMIT;
END;
/
DECLARE
    v_newest_order_id NUMBER;
BEGIN
    SELECT MAX(OrderID) INTO v_newest_order_id FROM Orders;
    assign_optimal_vehicle_to_order(v_newest_order_id, 1000);
    COMMIT;
END;
/
SELECT OrderID, VehicleID, StatusID 
FROM Orders WHERE OrderID = (SELECT MAX(OrderID) FROM Orders);

SELECT * FROM order_summary_v;

SELECT order_ref_seq.NEXTVAL FROM DUAL;
SELECT order_ref_seq.NEXTVAL FROM DUAL;
