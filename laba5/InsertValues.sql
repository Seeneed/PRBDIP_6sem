INSERT INTO Roles (RoleName) VALUES ('HR Manager'), ('Candidate');
INSERT INTO AppStatuses (StatusName) VALUES ('В работе'), ('Принят'), ('Отвергнут');

INSERT INTO LegalEntities (EntityName) VALUES ('ООО "Ромашка"'), ('ЗАО "Вектор"');

INSERT INTO Departments (EntityID, DeptName) VALUES 
(1, 'IT Отдел'), (1, 'Отдел продаж'), (2, 'Бухгалтерия'), (2, 'Служба безопасности');

INSERT INTO Vacancies (DeptID, Title) VALUES 
(1, 'C# Developer'), (1, 'QA Engineer'), (2, 'Менеджер по продажам'), (3, 'Главный бухгалтер'), (4, 'Охранник');

INSERT INTO Users (RoleID, FullName, Email) VALUES 
(1, 'Иванова Анна (HR)', 'anna.hr@mail.com'),
(1, 'Петров Иван (HR)', 'ivan.hr@mail.com');

DECLARE @i INT = 1;
WHILE @i <= 10 BEGIN
    INSERT INTO Users (RoleID, FullName, Email) VALUES (2, 'Кандидат ' + CAST(@i AS NVARCHAR), 'cand'+CAST(@i AS NVARCHAR)+'@mail.com');
    SET @i = @i + 1;
END;

DECLARE @app INT = 1;
WHILE @app <= 42 BEGIN
    INSERT INTO Applications (CandidateID, VacancyID, HR_ID, StatusID, ApplyDate, ResolutionDate)
    VALUES (
        (ABS(CHECKSUM(NEWID())) % 10) + 3, 
        (ABS(CHECKSUM(NEWID())) % 5) + 1,  
        (ABS(CHECKSUM(NEWID())) % 2) + 1,  
        (ABS(CHECKSUM(NEWID())) % 2) + 2,  
        DATEADD(day, -(@app * 9), GETDATE()), 
        DATEADD(day, -(@app * 9) + 2, GETDATE()) 
    );
    SET @app = @app + 1;
END;

INSERT INTO Applications (CandidateID, VacancyID, HR_ID, StatusID, ApplyDate, ResolutionDate)
SELECT TOP 3 CandidateID, VacancyID, HR_ID, StatusID, ApplyDate, ResolutionDate FROM Applications;