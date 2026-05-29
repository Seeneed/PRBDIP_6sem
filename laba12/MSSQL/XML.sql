use TransportationServices;

--2
CREATE PROCEDURE sp_GenerateXML 
    @GeneratedXml XML OUTPUT
AS
BEGIN
    SET @GeneratedXml = (
        SELECT 
            GETDATE() AS '@GeneratedAt',
            (SELECT 
                U.FullName AS '@ClientName',
                (SELECT SUM(Price) FROM Orders WHERE ClientID = U.UserID) AS '@TotalSpent',
                (SELECT 
                    O.OrderID AS '@ID',
                    O.PickupAddress AS 'Pickup',
                    O.DropAddress AS 'Drop',
                    O.Price AS 'Price',
                    S.StatusName AS 'Status'
                 FROM Orders O
                 JOIN OrderStatus S ON O.StatusID = S.StatusID
                 WHERE O.ClientID = U.UserID
                 FOR XML PATH('Order'), TYPE
                )
             FROM Users U
             WHERE U.RoleID = (SELECT RoleID FROM Roles WHERE RoleName = 'Client')
             FOR XML PATH('Client'), TYPE
            )
        FOR XML PATH('FreightReport')
    );
    SELECT @GeneratedXml AS GeneratedXML_Result;
END;
GO

DECLARE @myXml XML;
EXEC sp_GenerateXML @GeneratedXml = @myXml OUTPUT;
GO

--3
CREATE PROCEDURE sp_InsertReport 
    @xmlDoc XML
AS
BEGIN
    INSERT INTO Report (XmlData) VALUES (@xmlDoc);
END;
GO


DECLARE @myXml XML;
EXEC sp_GenerateXML @GeneratedXml = @myXml OUTPUT;
EXEC sp_InsertReport @xmlDoc = @myXml;
GO

SELECT * FROM Report;

--4
CREATE PRIMARY XML INDEX PXML_Report_XmlData ON Report(XmlData);
GO

--5
CREATE PROCEDURE sp_ExtractClientOrders
    @ClientName NVARCHAR(150)
AS
BEGIN
    SELECT 
        OrderNode.value('(@ID)[1]', 'INT') AS OrderID,
        OrderNode.value('(Pickup)[1]', 'NVARCHAR(255)') AS Pickup,
        OrderNode.value('(Price)[1]', 'DECIMAL(10,2)') AS Price,
        OrderNode.value('(Status)[1]', 'NVARCHAR(50)') AS Status
    FROM Report R
    CROSS APPLY R.XmlData.nodes('/FreightReport/Client[@ClientName=sql:variable("@ClientName")]/Order') AS T(OrderNode);
END;
GO

EXEC sp_ExtractClientOrders @ClientName = 'ООО Ромашка';
GO

DROP INDEX PXML_Report_XmlData ON Report;
GO

DROP PROCEDURE sp_GenerateXML;
DROP PROCEDURE sp_InsertReport;
DROP PROCEDURE sp_ExtractClientOrders;
GO