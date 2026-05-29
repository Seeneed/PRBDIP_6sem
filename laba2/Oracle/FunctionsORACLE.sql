CREATE OR REPLACE FUNCTION calc_delivery_cost(p_dist IN NUMBER, p_w IN NUMBER) RETURN NUMBER IS
BEGIN
  RETURN (p_dist * 15) + (p_w * 10);
END;
/

CREATE OR REPLACE FUNCTION validate_credentials(p_email IN VARCHAR2, p_pass IN VARCHAR2) RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT UserID INTO v_id FROM Users WHERE Email = p_email AND PasswordHash = p_pass;
  RETURN v_id;
EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
END;
/

CREATE OR REPLACE FUNCTION check_verification_state(p_uid IN NUMBER) RETURN NUMBER IS
  v_check NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_check FROM Users WHERE UserID = p_uid AND Phone LIKE '%VERIFIED%';
  RETURN CASE WHEN v_check > 0 THEN 1 ELSE 0 END;
END;
/

CREATE OR REPLACE FUNCTION get_driver_fleet_size(p_did IN NUMBER) RETURN NUMBER IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM Vehicles WHERE DriverID = p_did;
  RETURN v_count;
END;
/

CREATE OR REPLACE FUNCTION check_client_discount_eligibility (p_clientId IN NUMBER) RETURN NUMBER IS
    v_completedOrders NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_completedOrders FROM Orders WHERE ClientID = p_clientId AND StatusID = 3;
    IF v_completedOrders > 5 THEN 
        RETURN 1; 
    ELSE 
        RETURN 0; 
    END IF;
END;
/

DROP FUNCTION calc_delivery_cost;
DROP FUNCTION validate_credentials;
DROP FUNCTION check_verification_state;
DROP FUNCTION get_driver_fleet_size;
DROP FUNCTION check_client_discount_eligibility;