ALTER TABLE dbo.Users ADD OrgNode HIERARCHYID;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ShowSubordinates 
    @managerId INT
AS
BEGIN
    DECLARE @ManagerNode HIERARCHYID;
    SELECT @ManagerNode = OrgNode FROM dbo.Users WHERE UserID = @managerId;

    SELECT 
        UserID, 
        FullName, 
        OrgNode.ToString() AS [Node Path], 
        OrgNode.GetLevel() AS [Hierarchy Level]
    FROM dbo.Users
    WHERE OrgNode.IsDescendantOf(@ManagerNode) = 1
      AND UserID <> @managerId 
    ORDER BY OrgNode; 
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AddSubordinateNode
    @managerId INT,
    @newFullName NVARCHAR(150),
    @newEmail NVARCHAR(100),
    @roleId INT
AS
BEGIN
    DECLARE @ManagerNode HIERARCHYID = (SELECT OrgNode FROM dbo.Users WHERE UserID = @managerId);
    DECLARE @LastChildNode HIERARCHYID = (SELECT MAX(OrgNode) FROM dbo.Users WHERE OrgNode.GetAncestor(1) = @ManagerNode);
    DECLARE @NewNode HIERARCHYID = @ManagerNode.GetDescendant(@LastChildNode, NULL);

    INSERT INTO dbo.Users (RoleID, FullName, Email, PasswordHash, OrgNode)
    VALUES (@roleId, @newFullName, @newEmail, 'hash', @NewNode);
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_MoveSubordinates
    @oldManagerId INT,
    @newManagerId INT
AS
BEGIN
    
    DECLARE @OldParentNode HIERARCHYID = (SELECT OrgNode FROM dbo.Users WHERE UserID = @oldManagerId);
    DECLARE @NewParentNode HIERARCHYID = (SELECT OrgNode FROM dbo.Users WHERE UserID = @newManagerId);

    DECLARE @CurrentSubID INT;
    DECLARE @SubNode HIERARCHYID;
    DECLARE @NewSubNode HIERARCHYID;

    DECLARE sub_cursor CURSOR FOR 
    SELECT UserID, OrgNode FROM dbo.Users 
    WHERE OrgNode.GetAncestor(1) = @OldParentNode;

    OPEN sub_cursor;
    FETCH NEXT FROM sub_cursor INTO @CurrentSubID, @SubNode;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @LastChild HIERARCHYID = (SELECT MAX(OrgNode) FROM dbo.Users WHERE OrgNode.GetAncestor(1) = @NewParentNode);
        SET @NewSubNode = @NewParentNode.GetDescendant(@LastChild, NULL);

        UPDATE dbo.Users
        SET OrgNode = OrgNode.GetReparentedValue(@SubNode, @NewSubNode)
        WHERE OrgNode.IsDescendantOf(@SubNode) = 1;

        FETCH NEXT FROM sub_cursor INTO @CurrentSubID, @SubNode;
    END;

    CLOSE sub_cursor;
    DEALLOCATE sub_cursor;

    PRINT '¬се ветви успешно перемещены без дубликатов.';
END;
GO

DROP PROCEDURE sp_ShowSubordinates;
DROP PROCEDURE sp_AddSubordinateNode;
DROP PROCEDURE sp_MoveSubordinates;