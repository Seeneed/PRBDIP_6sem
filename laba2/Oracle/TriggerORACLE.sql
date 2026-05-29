CREATE OR REPLACE TRIGGER order_audit_trg
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('Данные заказа обновлены');
END;
/

DROP TRIGGER order_audit_trg;