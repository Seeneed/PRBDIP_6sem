INSERT INTO Roles (RoleName) VALUES ('Administrator');
INSERT INTO Roles (RoleName) VALUES ('Client');
INSERT INTO Roles (RoleName) VALUES ('Driver');

--добавление директора
INSERT INTO dbo.Users (RoleID, FullName, Email, PasswordHash, OrgNode) 
VALUES (1, 'Director General', 'ceo@mail.com', 'hash', hierarchyid::GetRoot());
GO

--добавление подчиненных
EXEC dbo.sp_AddSubordinateNode 1, 'Head of Logistics', 'logistics@mail.com', 2;
GO

EXEC dbo.sp_AddSubordinateNode 1, 'Head of Sales', 'sales@mail.com', 2;
GO

EXEC dbo.sp_AddSubordinateNode 2, 'Fleet Manager', 'fleet@mail.com', 2;
GO

EXEC dbo.sp_AddSubordinateNode 3, 'Sales Team Lead', 'teamlead@mail.com', 2;
GO

EXEC dbo.sp_AddSubordinateNode 4, 'Driver Alex', 'alex@mail.com', 3;
GO

EXEC dbo.sp_AddSubordinateNode 4, 'Driver Bob', 'bob@mail.com', 3;
GO

EXEC dbo.sp_ShowSubordinates 1;
GO

EXEC dbo.sp_AddSubordinateNode 1, 'Head of HR', 'hr@mail.com', 2;
GO

EXEC dbo.sp_AddSubordinateNode 3, 'Regional Manager', 'region@mail.com', 2;
GO

EXEC dbo.sp_AddSubordinateNode 5, 'Driver Charl1', 'charl1@mail.com', 3;
GO

EXEC dbo.sp_ShowSubordinates 1;
GO

--перемещение подчиненных
EXEC dbo.sp_MoveSubordinates @oldManagerId = 4, @newManagerId = 2;
GO

EXEC dbo.sp_ShowSubordinates 1;
GO

EXEC dbo.sp_MoveSubordinates @oldManagerId = 5, @newManagerId = 2;
GO

EXEC dbo.sp_ShowSubordinates 1;
GO

EXEC dbo.sp_MoveSubordinates @oldManagerId = 1, @newManagerId = 3;
GO

EXEC dbo.sp_ShowSubordinates 1;
GO