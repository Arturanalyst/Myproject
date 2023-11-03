-- Create a new table with numerical_sequence.
CREATE TABLE GTA (
	id INT AUTO_INCREMENT PRIMARY KEY,
    price TEXT,
    region TEXT,
    address TEXT,
    bedrooms TEXT,
    bathrooms DOUBLE
);

-- Copy data from the old table to the new table
INSERT INTO GTA (price, region, address, bedrooms, bathrooms)
SELECT price, region, address, bedrooms, bathrooms
FROM toronto;

-- Drop the old table 
DROP TABLE toronto;

-- Changing bedrooms column datatype to avoid such text as 3+2
UPDATE GTA 
SET bedrooms = 
CASE
    WHEN bedrooms LIKE '%+%' THEN 
        CAST(SUBSTRING_INDEX(bedrooms, '+', 1) AS SIGNED) + 
        CAST(SUBSTRING_INDEX(bedrooms, '+', -1) AS SIGNED)
    ELSE
        CAST(bedrooms AS SIGNED)
END;

SELECT *
FROM GTA;

UPDATE GTA
SET bedrooms = 0
WHERE bedrooms IS NULL;

UPDATE GTA
SET bathrooms = 0
WHERE bathrooms IS NULL;

SELECT bedrooms, bathrooms
FROM GTA
WHERE bedrooms = 0 OR bathrooms = 0;

-- To clean data where bedrooms equals 0
DELETE FROM GTA
WHERE bedrooms = 0;

-- To clean data where bathrooms equals 0
DELETE FROM GTA
WHERE bathrooms = 0;


SELECT *
FROM GTA;

-- To have exporeted excel list of areas in GTA included in database.
SELECT DISTINCT region
FROM GTA;


-- To change currency data type
UPDATE GTA
SET price = REPLACE(REPLACE(price, '$', ''), ',', '')
WHERE price IS NOT NULL;

SELECT price FROM GTA LIMIT 10;

-- Altering price to Decimal data type.
ALTER TABLE GTA
MODIFY price DECIMAL(10,2);

-- Removing ON from region.
UPDATE GTA 
SET region = TRIM(TRAILING ' ON' FROM REPLACE(region, ',', ''))
WHERE region LIKE '%, ON';

--  To clean region name to avoid mistakes with formatting
UPDATE GTA
SET region = CASE
	WHEN region = 'East Gwillimbury' THEN 'East_Gwillimbury'
    WHEN region = 'Halton Hills' THEN 'Halton_Hills'
    WHEN region = 'Richmond Hill' THEN 'Richmond_Hill'
    WHEN region = 'Scarborough Toronto' THEN 'Scarborough'
    WHEN region = 'Old Toronto Toronto' THEN 'Toronto'
    ELSE region
END
WHERE region IN ('Old Toronto Toronto', 'Scarborough Toronto', 'East Gwillimbury', 'Richmond Hill', 'Halton Hills');

-- Cleaning data which is not applicable
DELETE FROM GTA
WHERE region = "Toronto";

DELETE FROM GTA
WHERE price= 1.00;

ALTER TABLE GTA ADD Average_price DECIMAL(10, 2);

UPDATE GTA a
JOIN (
    SELECT 
        region, 
        bedrooms, 
        bathrooms,
        AVG(price) as average_price
    FROM 
        GTA
    GROUP BY 
        region, 
        bedrooms,
        bathrooms
) b ON a.region = b.region AND a.bedrooms = b.bedrooms AND a.bathrooms = b.bathrooms
SET a.average_price = b.average_price;



ALTER TABLE GTA ADD Average_distance FLOAT(10,2);

UPDATE GTA 
SET Average_distance = 
    CASE 
        WHEN region = 'Ajax' THEN 47.8
        WHEN region = 'Aurora' THEN 49.6
        WHEN region = 'Brampton' THEN 44.9
        WHEN region = 'Brantford' THEN 105  
        WHEN region = 'Brock' THEN 104 
        WHEN region = 'Burlington' THEN 56.9
        WHEN region = 'Caledon' THEN 60
        WHEN region = 'Cambridge' THEN 96.9
        WHEN region = 'Clarington' THEN 82.7
        WHEN region = 'East_Gwillimbury' THEN 56.4
        WHEN region = 'Georgina' THEN 79.1
        WHEN region = 'Guelph' THEN 94.9
        WHEN region = 'Halton_Hills' THEN 68.9
        WHEN region = 'Hamilton' THEN 68
        WHEN region = 'King' THEN 62.6
        WHEN region = 'Kitchener' THEN 108
        WHEN region = 'Markham' THEN 29.8
        WHEN region = 'Milton' THEN 53.1
        WHEN region = 'Mississauga' THEN 28.0
        WHEN region = 'Newmarket' THEN 54.7
        WHEN region = 'Oakville' THEN 38.4
        WHEN region = 'Oshawa' THEN 61
        WHEN region = 'Pickering' THEN 40.2
        WHEN region = 'Richmond_Hill' THEN 36.2
        WHEN region = 'Scarborough' THEN 27.1
		WHEN region = 'Scugog' THEN 90.6
        WHEN region = 'Uxbridge' THEN 80.3
        WHEN region = 'Vaughan' THEN 41.9
        WHEN region = 'Whitby' THEN 55.6
        WHEN region = 'Whitchurch-Stouffville' THEN 49.5
        ELSE 0
    END;

-- Choosing location with best average_price in GTA according to Dataset
SELECT region, average_price, average_distance, bathrooms, bedrooms
FROM GTA
WHERE 
    average_price = (SELECT MIN(average_price) FROM GTA);

-- Choosing list of locations which are 50 Km distances from Toronto
SELECT region, 
       average_price, 
       average_distance,
       bedrooms,
       bathrooms
FROM gta
GROUP BY region
HAVING average_distance <= 50
ORDER BY average_price ASC;


SELECT region,average_price, average_distance, bedrooms, bathrooms
FROM GTA;

select distinct city
FROM GTA;

ALTER TABLE gta
ADD COLUMN province VARCHAR(255);

UPDATE gta
SET province = 'Ontario';

ALTER TABLE gta 
CHANGE COLUMN region city VARCHAR(255);

SELECT *
FROM GTA;


-- Identifying average amount of bedrooms and bathrooms among cities
SELECT 
    (SELECT bedrooms FROM GTA 
     WHERE city IN (
        'Ajax', 'Clarington', 'Brock', 'Oshawa', 'Pickering', 'Scugog', 'Uxbridge', 'Whitby',
        'Burlington', 'Halton_Hills', 'Milton', 'Oakville', 'Brampton', 'Caledon', 'Mississauga',
        'Aurora', 'East_Gwillimbury', 'Georgina', 'King', 'Markham', 'Newmarket', 'Richmond_Hill',
        'Vaughan', 'Whitchurch-Stouffville', 'Hamilton', 'Guelph', 'Kitchener', 'Cambridge', 'Brantford', 
        'Scarborough'
    ) 
    GROUP BY bedrooms 
    ORDER BY COUNT(*) DESC 
    LIMIT 1) AS most_popular_bedrooms,
    
    (SELECT bathrooms FROM GTA 
     WHERE city IN (
        'Ajax', 'Clarington', 'Brock', 'Oshawa', 'Pickering', 'Scugog', 'Uxbridge', 'Whitby',
        'Burlington', 'Halton_Hills', 'Milton', 'Oakville', 'Brampton', 'Caledon', 'Mississauga',
        'Aurora', 'East_Gwillimbury', 'Georgina', 'King', 'Markham', 'Newmarket', 'Richmond_Hill',
        'Vaughan', 'Whitchurch-Stouffville', 'Hamilton', 'Guelph', 'Kitchener', 'Cambridge', 'Brantford', 
        'Scarborough'
    ) 
    GROUP BY bathrooms 
    ORDER BY COUNT(*) DESC 
    LIMIT 1) AS most_popular_bathrooms;
    
    -- identifying city with min price
    SELECT id,address,city, bathrooms, bedrooms, average_price, average_distance,MIN(price)
    FROM GTA;
    
    -- Identifying city with max price
    SELECT MAX(price), city
    FROM GTA;
    
   
    
