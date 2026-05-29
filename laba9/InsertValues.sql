BEGIN
    INSERT INTO Roles (RoleName) VALUES ('HR Manager');
    INSERT INTO Roles (RoleName) VALUES ('Candidate');
    
    INSERT INTO AppStatuses (StatusName) VALUES ('В работе');
    INSERT INTO AppStatuses (StatusName) VALUES ('Принят');
    INSERT INTO AppStatuses (StatusName) VALUES ('Отвергнут');

    INSERT INTO LegalEntities (EntityName) VALUES ('ООО "Ромашка"');
    INSERT INTO LegalEntities (EntityName) VALUES ('ЗАО "Вектор"');

    INSERT INTO Departments (EntityID, DeptName) VALUES (1, 'IT Отдел');
    INSERT INTO Departments (EntityID, DeptName) VALUES (1, 'Отдел продаж');
    INSERT INTO Departments (EntityID, DeptName) VALUES (2, 'Бухгалтерия');
    INSERT INTO Departments (EntityID, DeptName) VALUES (2, 'Служба безопасности');

    INSERT INTO Vacancies (DeptID, Title) VALUES (1, 'C# Developer');
    INSERT INTO Vacancies (DeptID, Title) VALUES (1, 'QA Engineer');
    INSERT INTO Vacancies (DeptID, Title) VALUES (2, 'Менеджер по продажам');
    INSERT INTO Vacancies (DeptID, Title) VALUES (3, 'Главный бухгалтер');
    INSERT INTO Vacancies (DeptID, Title) VALUES (4, 'Охранник');

    INSERT INTO Users (RoleID, FullName, Email) VALUES (1, 'Иванова Анна (HR)', 'anna.hr@mail.com');
    INSERT INTO Users (RoleID, FullName, Email) VALUES (1, 'Петров Иван (HR)', 'ivan.hr@mail.com');

    FOR i IN 1..10 LOOP
        INSERT INTO Users (RoleID, FullName, Email) 
        VALUES (2, 'Кандидат ' || i, 'cand' || i || '@mail.com');
    END LOOP;

    FOR app IN 1..42 LOOP
        INSERT INTO Applications (CandidateID, VacancyID, HR_ID, StatusID, ApplyDate, ResolutionDate)
        VALUES (
            TRUNC(DBMS_RANDOM.VALUE(3, 13)), 
            TRUNC(DBMS_RANDOM.VALUE(1, 6)),  
            TRUNC(DBMS_RANDOM.VALUE(1, 3)),  
            TRUNC(DBMS_RANDOM.VALUE(2, 4)), 
            SYSDATE - (app * 8), 
            SYSDATE - (app * 8) + 2 
        );
    END LOOP;
    COMMIT;
END;
/

BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO Applications (CandidateID, VacancyID, HR_ID, StatusID, ApplyDate, ResolutionDate)
        VALUES (3, 1, 1, 2, TO_DATE('2025-01-10','YYYY-MM-DD'), TO_DATE('2025-01-10','YYYY-MM-DD'));
    END LOOP;
    
    FOR i IN 1..3 LOOP
        INSERT INTO Applications (CandidateID, VacancyID, HR_ID, StatusID, ApplyDate, ResolutionDate)
        VALUES (3, 1, 1, 2, TO_DATE('2025-02-10','YYYY-MM-DD'), TO_DATE('2025-02-10','YYYY-MM-DD'));
    END LOOP;

    FOR i IN 1..15 LOOP
        INSERT INTO Applications (CandidateID, VacancyID, HR_ID, StatusID, ApplyDate, ResolutionDate)
        VALUES (3, 1, 1, 2, TO_DATE('2025-03-10','YYYY-MM-DD'), TO_DATE('2025-03-10','YYYY-MM-DD'));
    END LOOP;

    FOR i IN 1..2 LOOP
        INSERT INTO Applications (CandidateID, VacancyID, HR_ID, StatusID, ApplyDate, ResolutionDate)
        VALUES (3, 1, 1, 2, TO_DATE('2025-04-10','YYYY-MM-DD'), TO_DATE('2025-04-10','YYYY-MM-DD'));
    END LOOP;
    COMMIT;
END;
/