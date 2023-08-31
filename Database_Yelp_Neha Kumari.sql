--D1 Create Database for yelp project
CREATE DATABASE yelp_project;
\c yelp_project

--T1 Create Table Businesses
CREATE TABLE businesses (
BusinessID varchar(22) PRIMARY KEY,
BusinessName varchar(100),
StreetAddress varchar(120),	
City varchar(100),
State varchar(3),
PostalCode varchar(9),
Latitude double precision,
Longitude double precision,
AverageReviews numeric(6,2),
NumberOfReviews integer,
IsBusinessOpen integer
 ) ;
 

--T2 Create Table Business_attributes
CREATE TABLE business_attributes (
BusinessId varchar(22) REFERENCES businesses (BusinessId),
AttributeName varchar(100),
AttributeValue varchar(30)
);


--T3 Create Table Business_categories
CREATE TABLE business_categories (
BusinessId varchar(22) REFERENCES businesses (BusinessId),
CategoryName varchar(80)
);


--T4 Create Table Business_hours
CREATE TABLE business_hours (
BusinessId varchar(22) REFERENCES businesses (BusinessId),
DayOfTheWeek varchar(10),
OpeningTime time,
ClosingTime time
);


--T5 Create Table Users
CREATE TABLE users (
UserId varchar(22) PRIMARY KEY,				   
Name varchar(40),				   
NumberOfReviews smallint,
DateAndTime timestamp,
UsefulVotes integer,				   
FunnyVotes integer,				   
CoolVotes integer,				   
NumberOfFans smallint,				   
AverageRating numeric(6,2),				   
HotCompliments smallint,
MoreCompliments smallint,
ProfileCompliments smallint,
CuteCompliments integer,
ListCompliments integer,
NoteCompliments integer,
PlainCompliments integer,
CoolCompliments integer,
FunnyCompliments integer,	
WriterCompliments integer,	
PhotoCompliments integer	
) ;


--T6 Create Table Reviews
CREATE TABLE reviews (
ReviewId varchar(22) PRIMARY KEY,
UserId varchar(22),
BusinessID varchar(22) REFERENCES businesses(BusinessId),
UserRating numeric (6,2),
UsersMarkingReviewUseful integer,
UsersMarkingReviewFunny integer,
UsersMarkingReviewCool integer,
ReviewText varchar (6000),
ReviewDateAndTime timestamp
);


--T7 Create Table Tips
CREATE TABLE tips (
UserId varchar(22) REFERENCES users(UserId),
BusinessId varchar(22) REFERENCES businesses(BusinessId),
Text varchar(1000),
DateAndTimeOfTip timestamp,
NumberOfCompliments smallint
);

--T8 Create Table User_Friends
CREATE TABLE userfriends (
UserId varchar(22) REFERENCES users(UserId),
FriendId varchar(22) 
);

--T9 Create Table User_Elite_Years
CREATE TABLE usereliteyears (
UserId varchar(22) REFERENCES users(UserId),
Year smallint 
);


