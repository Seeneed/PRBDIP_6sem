ALTER TABLE Users ADD ManagerID NUMBER REFERENCES Users(UserID);
/

CREATE OR REPLACE PROCEDURE sp_show_subordinates(p_manager_id IN NUMBER) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Структура подчинения ---');
    FOR r IN (
        SELECT 
            UserID,
            FullName, 
            LEVEL AS HierarchyLevel,
            LPAD(' ', (LEVEL - 1) * 4) || FullName AS TreeView 
        FROM Users
        START WITH ManagerID = p_manager_id 
        CONNECT BY PRIOR UserID = ManagerID 
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Уровень ' || r.HierarchyLevel || ' | ' || r.TreeView);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE sp_add_subordinate_node(
    p_manager_id IN NUMBER,
    p_full_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_role_id IN NUMBER
) IS
BEGIN
    INSERT INTO Users (RoleID, FullName, Email, PasswordHash, ManagerID)
    VALUES (p_role_id, p_full_name, p_email, 'ora_hash', p_manager_id);
    
    DBMS_OUTPUT.PUT_LINE('Подчиненный ' || p_full_name || ' успешно добавлен.');
END;
/

CREATE OR REPLACE PROCEDURE sp_move_subordinates(
    p_old_manager_id IN NUMBER,
    p_new_manager_id IN NUMBER
) IS
BEGIN
    UPDATE Users
    SET ManagerID = p_new_manager_id
    WHERE ManagerID = p_old_manager_id;
    
    DBMS_OUTPUT.PUT_LINE('Все прямые подчиненные и их ветки успешно переведены новому руководителю.');
END;
/

DROP PROCEDURE sp_show_subordinates;
DROP PROCEDURE sp_add_subordinate_node;
DROP PROCEDURE sp_move_subordinates;