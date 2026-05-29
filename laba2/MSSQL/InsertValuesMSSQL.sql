INSERT INTO Roles (RoleName) VALUES ('Administrator');
INSERT INTO Roles (RoleName) VALUES ('Client');
INSERT INTO Roles (RoleName) VALUES ('Driver');

INSERT INTO OrderStatus (StatusName) VALUES ('New');         
INSERT INTO OrderStatus (StatusName) VALUES ('In Progress'); 
INSERT INTO OrderStatus (StatusName) VALUES ('Delivered');   
INSERT INTO OrderStatus (StatusName) VALUES ('Cancelled');   

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (1, N'Ivanov Ivan', N'admin@logistics.com', N'+79001112233', N'pass1');

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (2, N'Petrov Petr', N'client_p@mail.ru', N'+79995554433', N'pass2');

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (3, N'Sidorov Alex', N'driver_alex@logistics.com', N'+78887776655', N'pass3');

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (3, N'Dmitriev Oleg', N'dmitr_o@logistics.com', N'+71112223344 [VERIFIED]', N'pass4');

INSERT INTO Vehicles (DriverID, Brand, LicensePlate, CapacityKG, VolumeM3)
VALUES (3, N'Mercedes Sprinter', N'A777AA77', 1500.0, 10.5);

INSERT INTO Vehicles (DriverID, Brand, LicensePlate, CapacityKG, VolumeM3)
VALUES (4, N'Volvo FH16', N'B999BB99', 20000.0, 80.0);

INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price, OrderDate)
VALUES (2, 1, 3, N'Moscow, Tverskaya 1', N'Kazan, Baumana 10', 15000.00, '20231001');

INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price, OrderDate)
VALUES (2, 2, 3, N'Addr 1', N'Addr 2', 5000.00, '20231101'),
       (2, 1, 3, N'Addr 3', N'Addr 4', 4000.00, '20231105'),
       (2, 2, 3, N'Addr 5', N'Addr 6', 6000.00, '20231110'),
       (2, 1, 3, N'Addr 7', N'Addr 8', 3500.00, '20231115'),
       (2, 2, 3, N'Addr 9', N'Addr 10', 8000.00, '20231120');