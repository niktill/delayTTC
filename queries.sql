-- Project Question Number 1
DROP VIEW IF EXISTS monthdelays CASCADE;
DROP VIEW IF EXISTS months CASCADE;
DROP VIEW IF EXISTS revMonth CASCADE;
DROP VIEW IF EXISTS Q1 CASCADE;

-- total delays by month and year
Create view monthdelays as 
Select extract(month from date) as Month, extract(year from date) as year, count(delayId) as DelayCount from
Delay group by extract(month from date), extract(year from date);

-- intermediate step to connect delay and ridershiprevenue by month
CREATE VIEW months (month, id) AS
SELECT * FROM (
	VALUES ('Jan', 1), ('Feb', 2), ('Mar', 3), ('Apr', 4),
	       ('May', 5), ('Jun', 6), ('Jul', 7), ('Aug',8), ('Sep',9),
	       ('Oct',10),('Nov',11),('Dec',12)
) AS m(month, id);

-- intermediate step to show ridershiprevenue by month
Create view revMonth as
Select * from ridershiprevenue natural join months;

-- addresses first investigative question by showing the count of delays, ridership and
-- revenue by month and year
Create view Q1 as
Select m.month, m.year, m.delaycount, r.ridership, r.revenue
From revMonth r join monthdelays m on r.id = m.month and
r.year = m.year;

-- final query
select * from Q1;

-- Project Question Number 2
DROP TABLE IF EXISTS CodeTypeDelayTimes CASCADE;
DROP VIEW IF EXISTS trainCodeDelayTimes CASCADE;
DROP VIEW IF EXISTS streetcarCodeDelayTimes CASCADE;
DROP VIEW IF EXISTS busCodeDelayTimes CASCADE;

CREATE TABLE CodeTypeDelayTimes (
    vehicleType CHAR(9) NOT NULL,
    description TEXT,
    num_of_delays INT NOT NULL,
    sum_delay_time INT NOT NULL,
    avg_delay_time FLOAT NOT NULL
);

-- Shows delay statistics for each delay type
CREATE VIEW trainCodeDelayTimes AS SELECT 'train' AS vehicleType, description, 
count(delayId) AS num_of_delays, 
sum(delayTime) AS sum_delay_time, 
avg(delayTime) AS avg_delay_time 
from delay NATURAL JOIN traindelay 
GROUP BY delayTypeCode, description 
ORDER BY avg(delayTime) DESC;

CREATE VIEW streetcarCodeDelayTimes AS SELECT 'streetcar' AS vehicleType, streetCarDelayType AS description,
count(delayId) AS num_of_delays,
sum(delayTime) AS sum_delay_time,
avg(delayTime) AS avg_delay_time
from delay NATURAL JOIN streetcardelay
GROUP BY streetCarDelayType
ORDER BY avg(delayTime) DESC;

CREATE VIEW busCodeDelayTimes AS SELECT 'bus' AS vehicleType, busDelayType AS description,
count(delayId) AS num_of_delays,
sum(delayTime) AS sum_delay_time,
avg(delayTime) AS avg_delay_time
from delay NATURAL JOIN busdelay
GROUP BY busDelayType
ORDER BY avg(delayTime) DESC;

INSERT INTO CodeTypeDelayTimes
SELECT * FROM trainCodeDelayTimes UNION SELECT * FROM streetcarCodeDelayTimes UNION SELECT * FROM busCodeDelayTimes;

-- Query to find the most common delay type for each vehicle type
CREATE VIEW mostcommondelays AS SELECT * from CodeTypeDelayTimes AS t1 
WHERE num_of_delays >= ALL 
(SELECT DISTINCT num_of_delays 
from CodeTypeDelayTimes AS t2 
WHERE t2.vehicleType=t1.vehicleType AND t2.description<>t1.description);

SELECT * from mostcommondelays;

-- Query to find the longest avg of delay time for delay for each vehicle type
SELECT * from CodeTypeDelayTimes AS t1 
WHERE avg_delay_time >= ALL 
(SELECT DISTINCT avg_delay_time 
from CodeTypeDelayTimes AS t2 
WHERE t2.vehicleType=t1.vehicleType AND t2.description<>t1.description);

-- EXPANDED QUERY:
-- We found that Disorderly Patron is the worst case of delays on trains, which station has the most frequent disordly patrons?
-- This can answer which stations need more security measures 
SELECT station, count(delayID) FROM traindelay 
WHERE description IN (SELECT description FROM mostcommondelays WHERE vehicleType='train')
GROUP BY station ORDER BY count(delayID) DESC;

-- Project Question Number 3
-- Shows vehicles mechanical delay statistics 
DROP TABLE IF EXISTS VehicleMechanicalDelays CASCADE;
DROP VIEW IF EXISTS streetcarMechanicalDelays CASCADE;
DROP VIEW IF EXISTS trainMechanicalDelays CASCADE;
DROP VIEW IF EXISTS busMechanicalDelays CASCADE;
DROP VIEW IF EXISTS mechanicalDelays CASCADE;

CREATE TABLE VehicleMechanicalDelays (
    vehicleNumber INT,
    num_of_mdelays INT NOT NULL,
    avg_days_bt_delays FLOAT
);

CREATE VIEW busMechanicalDelays AS
SELECT vehicleNumber, delayId, date, LEAD(date,1) OVER (PARTITION BY vehiclenumber ORDER BY date) next_delay
FROM busdelay NATURAL JOIN delay WHERE busDelayType='Mechanical' ORDER BY date;

CREATE VIEW streetcarMechanicalDelays AS
SELECT vehicleNumber, delayId, date, LEAD(date,1) OVER (PARTITION BY vehiclenumber ORDER BY date) next_delay
FROM streetcardelay NATURAL JOIN delay WHERE streetcarDelayType='Mechanical';

CREATE VIEW trainMechanicalDelays AS
SELECT vehicleNumber, delayId, date, LEAD(date,1) OVER (PARTITION BY vehiclenumber ORDER BY date) next_delay
FROM traindelay NATURAL JOIN delay 
WHERE delaytypecode IN ('EUDO', 'EUBK', 'PUSCR', 'ERDB', 'PUSRA', 'EUPI', 'EUCO', 'PUSI', 'ERCO');

CREATE VIEW mechanicalDelays AS
SELECT * FROM busMechanicalDelays UNION SELECT * FROM streetcarMechanicalDelays UNION SELECT * FROM trainMechanicalDelays;

INSERT INTO VehicleMechanicalDelays
SELECT vehicleNumber, 
count(delayId) AS num_of_mdelays, 
avg(DATE_PART('day', next_delay::timestamp - date::timestamp)) AS avg_days_bt_delays
FROM mechanicalDelays JOIN vehicle ON vehicleNumber=number
GROUP BY vehicleNumber;

-- Query to find vehicles from each type that have most frequent mechanical issues
-- answers what vehicles maybe need to be decommissioned
SELECT * from (VehicleMechanicalDelays JOIN vehicle ON vehiclenumber=number) AS t1 
WHERE num_of_mdelays >= ALL 
(SELECT DISTINCT num_of_mdelays 
from (VehicleMechanicalDelays JOIN vehicle ON vehiclenumber=number) AS t2 
WHERE t2.type=t1.type AND t2.vehiclenumber<>t1.vehiclenumber);

-- Query to find vehicle type that has the least time between delays for same vehicles
-- answers what type of vehicle should focus into making more sustainable
SELECT type, avg(avg_days_bt_delays) from (VehicleMechanicalDelays NATURAL JOIN vehicle) GROUP BY type;

-- EXPANDED QUERY: 
-- 70 O'Connor is rated the worst route last year https://www.cbc.ca/news/canada/toronto/70-oconnor-bus-issues-1.5366918.
-- is this still true? No it is not, route 80 is 86th worst bus relative to delays.
-- I thought my 12 bus was worse than my girlfriend's 29 bus. Who has the worse bus? I was wrong by a landslide!
CREATE VIEW busroutedelays AS 
SELECT ROW_NUMBER() OVER (ORDER BY count(delayId) DESC) AS worst_rating, 
route, count(delayId) AS num_delays, 
avg(delayTime) AS avg_delay
FROM delay NATURAL JOIN busdelay GROUP BY ROUTE;

SELECT * from busroutedelays WHERE route=12 OR route=29 OR route=80;