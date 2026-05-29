CREATE OR ALTER PROCEDURE dbo.create_new_order @cId INT, @pAddr NVARCHAR(255), @dAddr NVARCHAR(255), @dist INT, @weight DECIMAL(10,2)
AS BEGIN
    DECLARE @cost DECIMAL(10,2) = dbo.calc_delivery_cost(@dist, @weight);
    
    INSERT INTO dbo.Orders (ClientID, PickupAddress, DropAddress, Price, StatusID) 
    VALUES (@cId, @pAddr, @dAddr, @cost, 1);
    
    SELECT * FROM dbo.Orders WHERE OrderID = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE dbo.assign_driver_to_order @oId INT, @vId INT
AS BEGIN
    UPDATE dbo.Orders 
    SET VehicleID = @vId, StatusID = 2 
    WHERE OrderID = @oId;
    
    SELECT OrderID, ClientID, VehicleID, StatusID 
    FROM dbo.Orders WHERE OrderID = @oId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.verify_driver_status @uId INT
AS BEGIN
    UPDATE dbo.Users 
    SET Phone = ISNULL(Phone, '') + ' [VERIFIED]' 
    WHERE UserID = @uId AND Phone NOT LIKE '%[VERIFIED]%';
    
    SELECT UserID, FullName, Phone 
    FROM dbo.Users WHERE UserID = @uId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.assign_optimal_vehicle_to_order
    @orderId INT,
    @requiredCapacityKG DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @vehicleId INT;

    SELECT TOP 1 @vehicleId = v.VehicleID
    FROM dbo.Vehicles v
    JOIN dbo.Users u ON v.DriverID = u.UserID
    WHERE v.CapacityKG >= @requiredCapacityKG
      AND u.Phone LIKE '%VERIFIED%' 
      AND NOT EXISTS (
          SELECT 1 FROM dbo.Orders o
          WHERE o.VehicleID = v.VehicleID AND o.StatusID = 2
      );

    IF @vehicleId IS NOT NULL
    BEGIN
        UPDATE dbo.Orders
        SET VehicleID = @vehicleId, StatusID = 2
        WHERE OrderID = @orderId;
        
        PRINT 'На заказ ' + CAST(@orderId AS VARCHAR) + ' назначена машина с ID ' + CAST(@vehicleId AS VARCHAR);
        SELECT OrderID, VehicleID, StatusID FROM dbo.Orders WHERE OrderID = @orderId;
    END
    ELSE
    BEGIN
        PRINT 'Свободных и подходящих машин не найдено.';
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.handle_vehicle_breakdown
    @brokenVehicleId INT
AS
BEGIN
    DECLARE @affectedOrders INT;

    SELECT @affectedOrders = COUNT(*)
    FROM dbo.Orders
    WHERE VehicleID = @brokenVehicleId AND StatusID = 2;

    IF @affectedOrders > 0
    BEGIN
        UPDATE dbo.Orders
        SET StatusID = 1
        WHERE VehicleID = @brokenVehicleId AND StatusID = 2;

        PRINT 'ТС с ID ' + CAST(@brokenVehicleId AS VARCHAR) + ' выведено из строя!';
        PRINT 'Заказов сброшено в очередь на переназначение: ' + CAST(@affectedOrders AS VARCHAR);
        
        SELECT OrderID, ClientID, VehicleID, StatusID 
        FROM dbo.Orders 
        WHERE VehicleID = @brokenVehicleId AND StatusID = 1;
    END
    ELSE
    BEGIN
        PRINT 'У ТС с ID ' + CAST(@brokenVehicleId AS VARCHAR) + ' нет активных заказов. Поломка зафиксирована безопасно.';
    END
END;
GO

DROP PROCEDURE assign_optimal_vehicle_to_order;
DROP PROCEDURE create_new_order;
DROP PROCEDURE handle_vehicle_breakdown;
DROP PROCEDURE assign_driver_to_order;
DROP PROCEDURE verify_driver_status;