CREATE OR ALTER FUNCTION calc_delivery_cost (@distance INT, @weight DECIMAL(10,2)) 
RETURNS DECIMAL(18,2) AS BEGIN
    RETURN (@distance * 12) + (@weight * 8);
END;
GO

CREATE OR ALTER FUNCTION validate_credentials (@email NVARCHAR(100), @pass NVARCHAR(255)) 
RETURNS INT AS BEGIN
    RETURN (SELECT UserID FROM Users WHERE Email = @email AND PasswordHash = @pass);
END;
GO

CREATE OR ALTER FUNCTION check_verification_state (@uId INT) RETURNS BIT AS BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE UserID = @uId AND Phone LIKE '%VERIFIED%') RETURN 1;
    RETURN 0;
END;
GO

CREATE OR ALTER FUNCTION get_driver_fleet_size (@dId INT) RETURNS INT AS BEGIN
    RETURN (SELECT COUNT(*) FROM Vehicles WHERE DriverID = @dId);
END;
GO

CREATE OR ALTER FUNCTION dbo.check_client_discount_eligibility (@clientId INT)
RETURNS BIT
AS
BEGIN
    DECLARE @completedOrders INT;
    SELECT @completedOrders = COUNT(*)
    FROM dbo.Orders
    WHERE ClientID = @clientId AND StatusID = 3;

    IF @completedOrders > 5
        RETURN 1;

    RETURN 0;
END;
GO

DROP FUNCTION calc_delivery_cost;
DROP FUNCTION validate_credentials;
DROP FUNCTION check_verification_state;
DROP FUNCTION get_driver_fleet_size;
DROP FUNCTION check_client_discount_eligibility;
