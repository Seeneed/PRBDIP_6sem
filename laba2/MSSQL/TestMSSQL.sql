DECLARE @newOrderId INT;
DECLARE @anotherOrderId INT;

SELECT dbo.calc_delivery_cost(500, 20) AS test_price;
SELECT dbo.validate_credentials('client_p@mail.ru', 'pass2') AS user_id_found;
SELECT dbo.check_verification_state(4) AS is_oleg_verified;
SELECT dbo.get_driver_fleet_size(3) AS alex_cars;
SELECT dbo.check_client_discount_eligibility(2) AS IsEligibleForDiscount;

EXEC dbo.create_new_order 2, N'Start Point', N'End Point', 100, 10;
SET @newOrderId = (SELECT MAX(OrderID) FROM Orders);

EXEC dbo.verify_driver_status 3;

EXEC dbo.assign_driver_to_order @oId = @newOrderId, @vId = 2;

EXEC dbo.handle_vehicle_breakdown @brokenVehicleId = 2;

EXEC dbo.create_new_order 2, N'Another Start', N'Another End', 50, 5;
SET @anotherOrderId = (SELECT MAX(OrderID) FROM Orders WHERE OrderID = @newOrderId);

EXEC dbo.assign_optimal_vehicle_to_order @orderId = @anotherOrderId, @requiredCapacityKG = 1000;

SELECT * FROM order_summary_v;

SELECT NEXT VALUE FOR order_ref_seq;