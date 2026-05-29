--3
SELECT 
    u.FullName AS "Имя HR",
    EXTRACT(YEAR FROM a.ResolutionDate) AS "Год",
    CASE WHEN EXTRACT(MONTH FROM a.ResolutionDate) <= 6 THEN 1 ELSE 2 END AS "Полугодие",
    TO_NUMBER(TO_CHAR(a.ResolutionDate, 'Q')) AS "Квартал",
    EXTRACT(MONTH FROM a.ResolutionDate) AS "Месяц",
    COUNT(a.AppID) AS "Обработано резюме",
    SUM(CASE WHEN a.StatusID = 2 THEN 1 ELSE 0 END) AS "Нанято сотрудников"
FROM Applications a
JOIN Users u ON a.HR_ID = u.UserID
WHERE a.ResolutionDate IS NOT NULL
GROUP BY GROUPING SETS (
    (u.FullName, EXTRACT(YEAR FROM a.ResolutionDate), EXTRACT(MONTH FROM a.ResolutionDate)), 
    (u.FullName, EXTRACT(YEAR FROM a.ResolutionDate), TO_NUMBER(TO_CHAR(a.ResolutionDate, 'Q'))), 
    (u.FullName, EXTRACT(YEAR FROM a.ResolutionDate), CASE WHEN EXTRACT(MONTH FROM a.ResolutionDate) <= 6 THEN 1 ELSE 2 END), 
    (u.FullName, EXTRACT(YEAR FROM a.ResolutionDate)), 
    (u.FullName), 
    () 
)
ORDER BY "Имя HR", "Год", "Полугодие", "Квартал", "Месяц";

--4
WITH HR_Stats AS (
    SELECT 
        u.FullName AS HR_Name,
        SUM(CASE WHEN a.StatusID = 2 THEN 1 ELSE 0 END) AS HiredCount,
        SUM(CASE WHEN a.StatusID = 3 THEN 1 ELSE 0 END) AS RejectedCount
    FROM Applications a
    JOIN Users u ON a.HR_ID = u.UserID
    WHERE a.ResolutionDate >= ADD_MONTHS(SYSDATE, -12)
    GROUP BY u.FullName
)
SELECT 
    HR_Name AS "HR Менеджер",
    HiredCount AS "Кол-во нанятых",
    ROUND(HiredCount * 100 / NULLIF(SUM(HiredCount) OVER (), 0), 2) AS "% от всех нанятых в КЭ",
    RejectedCount AS "Кол-во отвергнутых",
    ROUND(HiredCount * 100 / NULLIF(HiredCount + RejectedCount, 0), 2) AS "% нанятых (отработанных)"
FROM HR_Stats;

--5
SELECT 
    le.EntityName AS "Юридическое Лицо",
    EXTRACT(YEAR FROM a.ResolutionDate) AS "Год",
    EXTRACT(MONTH FROM a.ResolutionDate) AS "Месяц",
    COUNT(a.AppID) AS "Количество принятых"
FROM Applications a
JOIN Vacancies v ON a.VacancyID = v.VacancyID
JOIN Departments d ON v.DeptID = d.DeptID
JOIN LegalEntities le ON d.EntityID = le.EntityID
WHERE a.StatusID = 2
  AND a.ResolutionDate >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -5)
GROUP BY 
    le.EntityName, 
    EXTRACT(YEAR FROM a.ResolutionDate), 
    EXTRACT(MONTH FROM a.ResolutionDate)
ORDER BY 
    "Юридическое Лицо", "Год", "Месяц";

--6
WITH ResumeCounts AS (
    SELECT 
        d.DeptName,
        v.Title,
        COUNT(a.AppID) AS TotalResumesPerVacancy
    FROM Departments d
    JOIN Vacancies v ON d.DeptID = v.DeptID
    LEFT JOIN Applications a ON v.VacancyID = a.VacancyID
    GROUP BY d.DeptName, v.Title
),
RankedResumes AS (
    SELECT 
        DeptName,
        Title AS PopularVacancy,
        TotalResumesPerVacancy,
        ROW_NUMBER() OVER (PARTITION BY DeptName ORDER BY TotalResumesPerVacancy DESC) AS rn
    FROM ResumeCounts
)
SELECT 
    DeptName AS "Отдел",
    PopularVacancy AS "Самая востребованная должность",
    TotalResumesPerVacancy AS "Макс. количество резюме"
FROM RankedResumes
WHERE rn = 1
ORDER BY "Макс. количество резюме" DESC;