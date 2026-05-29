BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX idx_usr_auth';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_usr_auth ON Users(FullName);

BEGIN
  EXECUTE IMMEDIATE 'DROP INDEX idx_ord_date';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE INDEX idx_ord_date ON Orders(OrderDate);

CREATE OR REPLACE VIEW order_summary_v AS
SELECT o.OrderID, c.FullName, s.StatusName, o.Price
FROM Orders o
JOIN Users c ON o.ClientID = c.UserID
JOIN OrderStatus s ON o.StatusID = s.StatusID;
DROP VIEW order_summary_v;

CREATE SEQUENCE order_ref_seq START WITH 1 INCREMENT BY 1;
DROP SEQUENCE order_ref_seq;