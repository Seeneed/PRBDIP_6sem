INSERT INTO Roles (RoleName) VALUES ('Client');
INSERT INTO Roles (RoleName) VALUES ('Driver');

INSERT INTO OrderStatus (StatusName) VALUES ('Created');
INSERT INTO OrderStatus (StatusName) VALUES ('In Transit');
INSERT INTO OrderStatus (StatusName) VALUES ('Delivered');

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (1, 'ООО Ромашка', 'rom@mail.com', '123', 'hash1');

INSERT INTO Users (RoleID, FullName, Email, Phone, PasswordHash) 
VALUES (2, 'Иван Водитель', 'ivan@mail.com', '456', 'hash2');

INSERT INTO Vehicles (DriverID, Brand, LicensePlate, CapacityKG, VolumeM3)
VALUES (2, 'Volvo FH', 'A123AA', 20000, 82);

INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price)
VALUES (1, 1, 3, 'Склад А', 'Магазин Б', 15000.50);

INSERT INTO Orders (ClientID, VehicleID, StatusID, PickupAddress, DropAddress, Price)
VALUES (1, 1, 2, 'Завод В', 'Склад А', 8500.00);

COMMIT;