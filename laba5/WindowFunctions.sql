--3
SELECT 
    u.FullName AS HR_Name,
    YEAR(a.ResolutionDate) AS [Год],
    CASE 
        WHEN MONTH(a.ResolutionDate) <= 6 THEN 1 
        ELSE 2 
    END AS [Полугодие],
    DATEPART(QUARTER, a.ResolutionDate) AS [Квартал],
    MONTH(a.ResolutionDate) AS [Месяц],
    COUNT(a.AppID) AS [Обработано_резюме],
    SUM(CASE WHEN a.StatusID = 2 THEN 1 ELSE 0 END) AS [Нанято_сотрудников]
FROM Applications a
JOIN Users u ON a.HR_ID = u.UserID
WHERE a.ResolutionDate IS NOT NULL
GROUP BY GROUPING SETS (
    (u.FullName, YEAR(a.ResolutionDate), MONTH(a.ResolutionDate)), 
    (u.FullName, YEAR(a.ResolutionDate), DATEPART(QUARTER, a.ResolutionDate)), 
    (u.FullName, YEAR(a.ResolutionDate), CASE WHEN MONTH(a.ResolutionDate) <= 6 THEN 1 ELSE 2 END), 
    (u.FullName, YEAR(a.ResolutionDate)), 
    (u.FullName), 
    () 
)
ORDER BY HR_Name, [Год], [Полугодие], [Квартал], [Месяц];

--4
WITH HR_Stats AS (
    SELECT 
        u.FullName AS HR_Name,
        SUM(CASE WHEN a.StatusID = 2 THEN 1 ELSE 0 END) AS HiredCount,
        SUM(CASE WHEN a.StatusID = 3 THEN 1 ELSE 0 END) AS RejectedCount
    FROM Applications a
    JOIN Users u ON a.HR_ID = u.UserID
    WHERE a.ResolutionDate >= DATEADD(year, -1, GETDATE())
    GROUP BY u.FullName
)
SELECT 
    HR_Name,
    HiredCount AS [Кол-во нанятых],
    CAST((HiredCount * 100.0 / NULLIF(SUM(HiredCount) OVER (), 0)) AS DECIMAL(5,2)) AS [% от всех нанятых],
    RejectedCount AS [Кол-во отвергнутых],
    CAST((HiredCount * 100.0 / NULLIF(HiredCount + RejectedCount, 0)) AS DECIMAL(5,2)) AS [% нанятых от обработанных (к отвергнутым)]
FROM HR_Stats;

--5
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 20;   

WITH PagedData AS (
    SELECT 
        AppID, 
        CandidateID, 
        VacancyID, 
        ApplyDate,
        ROW_NUMBER() OVER (ORDER BY ApplyDate DESC) AS RowNum
    FROM Applications
)
SELECT * 
FROM PagedData
WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize);

--6
WITH CTE_Duplicates AS (
    SELECT 
        AppID,
        ROW_NUMBER() OVER (
            PARTITION BY CandidateID, VacancyID, HR_ID, StatusID, ApplyDate 
            ORDER BY AppID
        ) AS RowNum
    FROM Applications
)
DELETE FROM CTE_Duplicates 
WHERE RowNum > 1;

--7
SELECT 
    le.EntityName AS [Юридическое Лицо],
    YEAR(a.ResolutionDate) AS [Год],
    MONTH(a.ResolutionDate) AS [Месяц],
    COUNT(a.AppID) AS [Количество принятых]
FROM Applications a
JOIN Vacancies v ON a.VacancyID = v.VacancyID
JOIN Departments d ON v.DeptID = d.DeptID
JOIN LegalEntities le ON d.EntityID = le.EntityID
WHERE a.StatusID = 2 
  AND a.ResolutionDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 5, 0)
GROUP BY 
    le.EntityName, 
    YEAR(a.ResolutionDate), 
    MONTH(a.ResolutionDate)
ORDER BY 
    [Юридическое Лицо], [Год], [Месяц];

--8
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
        Title AS [Самая популярная должность],
        TotalResumesPerVacancy AS [Макс. количество резюме],
        ROW_NUMBER() OVER (PARTITION BY DeptName ORDER BY TotalResumesPerVacancy DESC) AS rn
    FROM ResumeCounts
)
SELECT 
    DeptName AS [Отдел],
    [Самая популярная должность],
    [Макс. количество резюме]
FROM RankedResumes
WHERE rn = 1
ORDER BY [Макс. количество резюме] DESC;

