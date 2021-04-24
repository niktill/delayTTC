-- Schema for storing a subset of the Toronto Public transit data, with some
-- modifications.  The data sets can be found at the following links:
--   https://open.toronto.ca/dataset/ttc-bus-delay-data/
--   https://open.toronto.ca/dataset/ttc-subway-delay-data/
--   https://open.toronto.ca/dataset/ttc-streetcar-delay-data/
--   https://open.toronto.ca/dataset/ttc-average-weekday-ridership/
--   https://open.toronto.ca/dataset/ttc-ridership-revenues/
-- and is provided license free and free of charge. 


drop schema if exists projectschema cascade; 
create schema projectschema;
set search_path to projectschema;

create domain VehicleNumber as int
    not null 
    check (value>=1);

create domain VehicleType as text
    not null 
    check (value in ('bus','streetcar','train'));

create domain DelayTime as smallint
    not null 
    check (value>=0);

create domain SubwayLine as varchar(7)
    not null
    check (value in ('YU','BD','SHP','SRT','YU/BD'));

create domain Route as int
    not null 
    check (value>=1);

create domain Month as varchar(3)
    not null 
    check (value in ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'));

create domain Ridership as int
    not null 
    check (value>=0);

create domain Revenue as int
    not null 
    check (value>=0);

-- A Toronto public transit vehicle.
create table Vehicle(
    number VehicleNumber primary key,
    -- vehicle identification number.
    type VehicleType);
    -- the type of vehicle.

-- An instance of a delay of a Toronto public transit vehicle. 
create table Delay(
    delayId integer primary key,
    -- unique delay identification number.
    vehicleNumber VehicleNumber,
    -- vehicle number associated with the delay.
    date date not null,
    -- date of the delay.
    time time not null,
    -- time of the delay.
    delayTime DelayTime,
    -- length of time of the delay in minutes.
    foreign key (vehicleNumber) references Vehicle);

-- A delay associated with Toronto public transit subway trains.
create table TrainDelay(
    delayId integer primary key,
    -- unique delay identification number.
    station text not null,
    -- TTC subway station.
    line SubwayLine,
    -- TTC subway line.
    delayTypeCode varchar(5) not null,
    -- delay code that summarizes common types of train delays.
    description text not null,
    -- text description of the cause of the delay.
    foreign key (delayId) references Delay);

-- A delay associated with Toronto public transit streetcars.
create table StreetcarDelay(
    delayId integer primary key,
    -- unique delay identification number.
    location text not null,
    -- major intersection or station where the delay occured.
    route Route,
    -- the street car route on which the delay occured.
    streetcarDelayType text not null,
    -- delay code that summarizes common types of streetcar delays.
    foreign key (delayId) references Delay);

-- A delay associated with Toronto public transit buses.
create table BusDelay(
    delayId integer primary key,
    -- unique delay identification number.
    location text not null,
    -- major intersection or station where the delay occured.
    route Route,
    -- the bus route on which the delay occured.
    busDelayType text not null,
    -- delay code that summarizes common types of bus delays.
    foreign key (delayId) references Delay);

-- Weekly average ridership and revenue information of riders of Toronto
-- public transit services.
create table RidershipRevenue(
    month Month,
    year smallint not null,
    ridership Ridership,
    -- average number of riders on Toronto public transit services per week.
    revenue Revenue,
    -- average revenue collected on Toronto public transit services per week. 
    primary key (month, year));