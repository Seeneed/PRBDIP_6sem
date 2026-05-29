INSERT INTO Clients (ClientName) VALUES ('ООО Стройтех');
INSERT INTO Clients (ClientName) VALUES ('ИП Иванов');

INSERT INTO ServiceTypes (ServiceName) VALUES ('Стандартная перевозка');
INSERT INTO ServiceTypes (ServiceName) VALUES ('Экспресс-доставка');

INSERT INTO Orders (ClientID, ServiceID, OrderDate, Distance) VALUES (1, 1, SYSDATE - 10, 450);
INSERT INTO Orders (ClientID, ServiceID, OrderDate, Distance) VALUES (1, 2, SYSDATE - 5, 120);
INSERT INTO Orders (ClientID, ServiceID, OrderDate, Distance) VALUES (2, 1, SYSDATE - 2, 800);
COMMIT;