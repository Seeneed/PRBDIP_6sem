SET SERVEROUTPUT ON;

INSERT INTO Roles (RoleID, RoleName) VALUES (1, 'Administrator');
INSERT INTO Roles (RoleID, RoleName) VALUES (2, 'Manager');
INSERT INTO Roles (RoleID, RoleName) VALUES (3, 'Driver');
COMMIT;

--добавление директора
INSERT INTO Users (RoleID, FullName, Email, PasswordHash, ManagerID) 
VALUES (1, 'Director General', 'ceo@mail.com', 'hash', NULL);
COMMIT;

--добавление подчиненных
EXEC sp_add_subordinate_node(1, 'Head of Logistics', 'logistics@mail.com', 2);
COMMIT;

EXEC sp_add_subordinate_node(1, 'Head of Sales', 'sales@mail.com', 2);   
COMMIT;

EXEC sp_add_subordinate_node(2, 'Fleet Manager', 'fleet@mail.com', 2);
COMMIT;

EXEC sp_add_subordinate_node(3, 'Sales Team Lead', 'teamlead@mail.com', 2);   
COMMIT;

EXEC sp_add_subordinate_node(4, 'Driver Alex', 'alex@mail.com', 3); 
COMMIT;

EXEC sp_add_subordinate_node(4, 'Driver Bob', 'bob@mail.com', 3);              
COMMIT;

EXEC sp_show_subordinates(1);

EXEC sp_add_subordinate_node(1, 'Head of HR', 'hr@mail.com', 2);
COMMIT;

EXEC sp_add_subordinate_node(3, 'Regional Manager', 'region@mail.com', 2);
COMMIT;

EXEC sp_add_subordinate_node(5, 'Junior Sales', 'junior@mail.com', 2);
COMMIT;

EXEC sp_show_subordinates(1);

--перемещение подчиненных
EXEC sp_move_subordinates(4, 1);

EXEC sp_show_subordinates(1);

EXEC sp_move_subordinates(3, 2);

EXEC sp_show_subordinates(1);


