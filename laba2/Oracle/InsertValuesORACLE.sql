INSERT INTO Roles (RoleName) VALUES ('Administrator');
INSERT INTO Roles (RoleName) VALUES ('Client');
INSERT INTO Roles (RoleName) VALUES ('Driver');

INSERT INTO OrderStatus (StatusName) VALUES ('New');         
INSERT INTO OrderStatus (StatusName) VALUES ('In Progress'); 
INSERT INTO OrderStatus (StatusName) VALUES ('Delivered');   
INSERT INTO OrderStatus (StatusName) VALUES ('Cancelled');   

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (1, 'Ivanov Ivan', 'admin@logistics.com', '+79001112233', 'pass1');

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (2, 'Petrov Petr', 'client_p@mail.ru', '+79995554433', 'pass2');

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (3, 'Sidorov Alex', 'driver_alex@logistics.com', '+78887776655', 'pass3');

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (3, 'Dmitriev Oleg', 'dmitr_o@logistics.com', '+71112223344 [VERIFIED]', 'pass4');

INSERT INTO Vehicles (DriverID, Brand, LicensePlate, CapacityKG, VolumeM3)
VALUES (3, 'Mercedes Sprinter', 'A777AA77', 1500.0, 10.5);

INSERT INTO Vehicles (DriverID, Brand, LicensePlate, CapacityKG, VolumeM3)
VALUES (4, 'Volvo FH16', 'B999BB99', 20000.0, 80.0);

INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price, OrderDate)
VALUES (2, 1, 3, 'Moscow, Tverskaya 1', 'Kazan, Baumana 10', 15000.00, TO_DATE('2023-10-01', 'YYYY-MM-DD'));

INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price, OrderDate)
VALUES (2, 2, 3, 'Addr 1', 'Addr 2', 5000, TO_DATE('2023-11-01', 'YYYY-MM-DD'));
INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price, OrderDate) 
VALUES (2, 1, 3, 'Addr 3', 'Addr 4', 4000, TO_DATE('2023-11-05', 'YYYY-MM-DD'));    
INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price, OrderDate) 
VALUES (2, 2, 3, 'Addr 5', 'Addr 6', 6000, TO_DATE('2023-11-10', 'YYYY-MM-DD'));
INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price, OrderDate) 
VALUES (2, 1, 3, 'Addr 7', 'Addr 8', 3500, TO_DATE('2023-11-15', 'YYYY-MM-DD'));
INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price, OrderDate) 
VALUES (2, 2, 3, 'Addr 9', 'Addr 10', 8000, TO_DATE('2023-11-20', 'YYYY-MM-DD'));

COMMIT;