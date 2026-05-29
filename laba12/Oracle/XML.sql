--2
CREATE OR REPLACE PROCEDURE GenerateXML(p_xml OUT XMLTYPE) AS
BEGIN
    SELECT XMLELEMENT("FreightReport",
             XMLATTRIBUTES(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS "GeneratedAt"),
             XMLAGG(
               XMLELEMENT("Client",
                 XMLATTRIBUTES(
                    U.FullName AS "ClientName",
                    (SELECT SUM(Price) FROM Orders WHERE ClientID = U.UserID) AS "TotalSpent"
                 ),
                 (SELECT XMLAGG(
                           XMLELEMENT("Order",
                             XMLATTRIBUTES(O.OrderID AS "ID"),
                             XMLELEMENT("Pickup", O.PickupAddress),
                             XMLELEMENT("Drop", O.DropAddress),
                             XMLELEMENT("Price", O.Price),
                             XMLELEMENT("Status", S.StatusName)
                           )
                         )
                  FROM Orders O
                  JOIN OrderStatus S ON O.StatusID = S.StatusID
                  WHERE O.ClientID = U.UserID)
               )
             )
           )
    INTO p_xml
    FROM Users U
    JOIN Roles R ON U.RoleID = R.RoleID
    WHERE R.RoleName = 'Client';
END;
/


DECLARE
    v_xml XMLTYPE;
BEGIN
    GenerateXML(v_xml);
END;
/

--3
CREATE OR REPLACE PROCEDURE InsertReport(p_xml IN XMLTYPE) AS
BEGIN
    INSERT INTO Report (XmlData) VALUES (p_xml);
    COMMIT;
END;
/

DECLARE
    v_xml XMLTYPE;
BEGIN
    GenerateXML(v_xml);
    InsertReport(v_xml);
END;
/

select * from REPORT;

--4
CREATE INDEX idx_xml_report ON Report(XmlData) INDEXTYPE IS XDB.XMLINDEX;
/

--5
CREATE OR REPLACE PROCEDURE ExtractClientOrders(p_client_name IN VARCHAR2) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Заказы клиента: ' || p_client_name || ' ---');
    FOR r IN (
        SELECT xt.OrderID, xt.Price, xt.Status
        FROM Report r,
             XMLTABLE('/FreightReport/Client[@ClientName=$client]/Order'
                      PASSING r.XmlData, p_client_name AS "client"
                      COLUMNS 
                        OrderID NUMBER PATH '@ID',
                        Price NUMBER PATH 'Price',
                        Status VARCHAR2(50) PATH 'Status') xt
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Заказ ID: ' || r.OrderID || ' | Цена: ' || r.Price || ' | Статус: ' || r.Status);
    END LOOP;
END;
/

EXEC ExtractClientOrders('ООО Ромашка');
/

DROP INDEX idx_xml_report;

DROP PROCEDURE GenerateXML;
DROP PROCEDURE InsertReport;
DROP PROCEDURE ExtractClientOrders;