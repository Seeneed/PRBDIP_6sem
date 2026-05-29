CREATE DATABASE GIS_DB;
GO

use GIS_DB;

SELECT TOP 1 geom.STGeometryType() FROM countries;

select * from countries;

SELECT TOP 1 geom.STSrid FROM countries;

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'countries' 
  AND DATA_TYPE NOT IN ('geometry', 'geography');


SELECT TOP 5 geom.STAsText() FROM countries;


DECLARE @g1 geometry = (SELECT geom FROM countries WHERE qgs_fid = 14);
DECLARE @g2 geometry = (SELECT geom FROM countries WHERE qgs_fid = 15);

SELECT @g1.STIntersection(@g2).STAsText() AS IntersectionWKT;


SELECT TOP 10 
    ADMIN AS CountryName,
    geom.STPointN(1).STX AS Lon, 
    geom.STPointN(1).STY AS Lat
FROM countries;


SELECT TOP 10 ADMIN, geom.STArea() as Area FROM countries;



--DECLARE @myPoint geometry = geometry::STGeomFromText('POINT(37.6173 55.7558)', 4326);

SELECT ADMIN as CountryName 
FROM countries 
WHERE geom.STIntersects(@myPoint) = 1;


DECLARE @myLine geometry = geometry::STGeomFromText('LINESTRING(-0.1278 51.5074, 2.3522 48.8566)', 4326);

SELECT  ADMIN as CountryName 
FROM countries 
WHERE geom.STIntersects(@myLine) = 1;


DECLARE @myPoly geometry = geometry::STGeomFromText('POLYGON((13.4050 52.5200, 14.4378 50.0755, 21.0122 52.2297, 13.4050 52.5200))', 4326);

SELECT  ADMIN as CountryName 
FROM countries 
WHERE geom.STIntersects(@myPoly) = 1;


CREATE SPATIAL INDEX IX_Spatial_Countries 
ON countries(geom)
USING GEOMETRY_GRID
WITH (
  BOUNDING_BOX = (xmin=-180, ymin=-90, xmax=180, ymax=90),
  GRIDS = (LEVEL_1 = MEDIUM, LEVEL_2 = MEDIUM, LEVEL_3 = MEDIUM, LEVEL_4 = MEDIUM),
  CELLS_PER_OBJECT = 16
);

DECLARE @myPoint geometry = geometry::STGeomFromText('POINT(37.6173 55.7558)', 4326);

SELECT ADMIN 
FROM countries WITH (INDEX(IX_Spatial_Countries))
WHERE geom.STIntersects(@myPoint) = 1;

DROP INDEX IX_Spatial_Countries ON countries;
GO


CREATE OR ALTER PROCEDURE GetCountryByPoint
    @lat float, @lon float
AS
BEGIN
    DECLARE @p geometry = geometry::STGeomFromText('POINT(' + CAST(@lon AS varchar) + ' ' + CAST(@lat AS varchar) + ')', 4326);
    SELECT ADMIN FROM countries WHERE geom.STIntersects(@p) = 1;
END;


EXEC GetCountryByPoint @lon = 37.61, @lat = 55.75;