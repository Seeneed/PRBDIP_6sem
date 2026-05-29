--1
SELECT DeptName, Year, EmpCount, RequiredSpaceM2
FROM (
    SELECT 
        d.DeptName,
        EXTRACT(YEAR FROM a.ResolutionDate) as Year,
        COUNT(a.AppID) as EmpCount
    FROM Applications a
    JOIN Vacancies v ON a.VacancyID = v.VacancyID
    JOIN Departments d ON v.DeptID = d.DeptID
    WHERE a.StatusID = 2 AND EXTRACT(YEAR FROM a.ResolutionDate) = 2025
    GROUP BY d.DeptName, EXTRACT(YEAR FROM a.ResolutionDate)
)
MODEL 
    PARTITION BY (DeptName)
    DIMENSION BY (Year)
    MEASURES (EmpCount, 0 AS RequiredSpaceM2)
    RULES UPSERT (
        EmpCount[2026] = TRUNC(EmpCount[2025] * 1.2),
        RequiredSpaceM2[2026] = EmpCount[CV()] * 6
    )
ORDER BY DeptName, Year;

--2
SELECT *
FROM (
    SELECT 
        le.EntityName as V_NAME,
        TRUNC(a.ResolutionDate, 'MM') as V_MONTH,
        COUNT(a.AppID) as V_COUNT
    FROM Applications a
    JOIN Vacancies v ON a.VacancyID = v.VacancyID
    JOIN Departments d ON v.DeptID = d.DeptID
    JOIN LegalEntities le ON d.EntityID = le.EntityID
    WHERE a.StatusID = 2
    GROUP BY le.EntityName, TRUNC(a.ResolutionDate, 'MM')
)
MATCH_RECOGNIZE (
    PARTITION BY V_NAME
    ORDER BY V_MONTH
    MEASURES 
        FIRST(STRT.V_MONTH) AS START_P,
        LAST(DOWN2.V_MONTH) AS END_P,
        FIRST(STRT.V_COUNT) AS VAL_INIT,
        LAST(DOWN1.V_COUNT) AS VAL_DIP,
        LAST(UP.V_COUNT)    AS VAL_PEAK,
        LAST(DOWN2.V_COUNT) AS VAL_FINAL
    ONE ROW PER MATCH
    PATTERN (STRT DOWN1+ UP+ DOWN2+)
    DEFINE 
        STRT  AS V_MONTH IS NOT NULL, 
        DOWN1 AS V_COUNT < PREV(V_COUNT),
        UP    AS V_COUNT > PREV(V_COUNT),
        DOWN2 AS V_COUNT < PREV(V_COUNT)
)
ORDER BY V_NAME, START_P;