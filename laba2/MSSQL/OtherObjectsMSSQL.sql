CREATE INDEX idx_usr_auth ON Users(Email);
CREATE INDEX idx_ord_date ON Orders(OrderDate);

DROP INDEX idx_usr_auth on Users;
DROP INDEX idx_ord_date on Orders;

GO
CREATE OR ALTER VIEW order_summary_v AS
SELECT o.OrderID, c.FullName AS Client, s.StatusName, o.Price, o.OrderDate
FROM Orders o
JOIN Users c ON o.ClientID = c.UserID
JOIN OrderStatus s ON o.StatusID = s.StatusID;
GO
DROP VIEW order_summary_v;

CREATE SEQUENCE order_ref_seq START WITH 100 INCREMENT BY 1;
DROP SEQUENCE order_ref_seq;

