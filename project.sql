/*
This is the file for creating the database tables, adding the integrity constraints
and inserting records into the table. This will also include the base queries that
select all from the created database tables
*/
SPOOL project.out
SET ECHO ON
--
/*
The next section is reserved for dropping tables to run script as clean test
*/
-- want to drop all tables to be able to debug this script
DROP TABLE Household_Institution CASCADE CONSTRAINTS;
DROP TABLE Researcher CASCADE CONSTRAINTS;
DROP TABLE ResearcherNumbers CASCADE CONSTRAINTS;
DROP TABLE ResearchProject CASCADE CONSTRAINTS;
DROP TABLE Conducts CASCADE CONSTRAINTS;
DROP TABLE Driver CASCADE CONSTRAINTS;
DROP TABLE DriverNumbers CASCADE CONSTRAINTS;
DROP TABLE Vehicle CASCADE CONSTRAINTS;
DROP TABLE Model CASCADE CONSTRAINTS;
DROP TABLE Incident CASCADE CONSTRAINTS;
DROP TABLE ProjectMilestone CASCADE CONSTRAINTS;
DROP TABLE Drives CASCADE CONSTRAINTS;
DROP TABLE IncidentRelation CASCADE CONSTRAINTS;
DROP TABLE Monitor CASCADE CONSTRAINTS;
--
/*
The next section is reserved for creating tables, integrity constraints, triggers, and functions
*/
CREATE TABLE Household_Institution (
    groupID INTEGER PRIMARY KEY,
    groupType CHAR(15) NOT NULL,
    groupName CHAR(40)
    --numMembers to be implemented by function 
); 
-- 
/*
Values Added
*/ 
CREATE TABLE Researcher ( 
    userID INTEGER PRIMARY KEY, 
    gradeCompleted INTEGER NOT NULL,
    researchType CHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL, 
    lastName CHAR(40) NOT NULL, 
    firstName CHAR(40) NOT NULL,
    email CHAR(100), 
    groupID INTEGER,
    CONSTRAINT resic1 FOREIGN KEY (groupID) 
        REFERENCES Household_Institution(groupID),
    CONSTRAINT resic2 CHECK (researchType IN ('Educational', 'Commercial', 'Advanced Educational') ),
    CONSTRAINT resic3 CHECK (NOT (gradeCompleted <= 12 AND researchType = 'Advanced Educational') ) ); 
--
/*
Values Added
*/ 
CREATE TABLE ResearcherNumbers (
  userID INTEGER,
  phoneNumber VARCHAR(22),
  PRIMARY KEY (userID, phoneNumber),
  CONSTRAINT rnic1 FOREIGN KEY (userID)
      REFERENCES Researcher(userID) );
-- 
CREATE TABLE ResearchProject (
    projectID INTEGER PRIMARY KEY,
    projectStartDate DATE NOT NULL,
    projectEndDate DATE );
--
CREATE TABLE Conducts (
    userID INTEGER,
    projectID INTEGER,
    beginDate DATE NOT NULL,
    endDate DATE,
    PRIMARY KEY (userID, projectID),
    CONSTRAINT cic1 FOREIGN KEY (userID)
        REFERENCES Researcher(userID),
    CONSTRAINT cic2 FOREIGN KEY (projectID)
        REFERENCES ResearchProject(projectID) );
/*
Values Added
*/ 
--
CREATE TABLE Driver (
    userID INTEGER PRIMARY KEY,
    licenseType CHAR(10) NOT NULL,
    date_of_birth DATE NOT NULL,
    lastName CHAR(40) NOT NULL,
    firstName CHAR(40) NOT NULL,
    email CHAR(100),
    groupID INTEGER,
    CONSTRAINT dic1 FOREIGN KEY (groupID) 
        REFERENCES Household_Institution(groupID),
    CONSTRAINT dic2 CHECK ( licenseType IN ('Commercial', 'Operator') ) );
--
/*
Values Added
*/ 
CREATE TABLE DriverNumbers (
  userID INTEGER,
  phoneNumber VARCHAR(22),
  PRIMARY KEY (userID, phoneNumber),
  CONSTRAINT dnic1 FOREIGN KEY (userID)
      REFERENCES Driver(userID) );
--
/*
Values Added
*/ 
CREATE TABLE Model (
    vehicleMake CHAR(30),
    vehicleModel CHAR(30),
    isAutonomous CHAR(1),
    PRIMARY KEY (vehicleMake, vehicleModel),
    --numIncidents to be implemented by function
    CONSTRAINT mic1 CHECK ( isAutonomous = 'Y' OR isAutonomous = 'N' ) );
--
CREATE TABLE Vehicle (
    numLicensePlate CHAR(12),
    plateState CHAR(2),
    --dateLastIncident implemented by function
    purchaseDate DATE,
    purchasePrice NUMBER(15,2),
    groupID INTEGER,
    vehicleMake CHAR(30),
    vehicleModel CHAR(30),
    PRIMARY KEY (numLicensePlate, plateState),
    CONSTRAINT vic1 FOREIGN KEY (groupID) 
        REFERENCES Household_Institution(groupID),
    CONSTRAINT vic2 FOREIGN KEY (vehicleMake, vehicleModel)
        REFERENCES Model(vehicleMake, vehicleModel),
    CONSTRAINT vic4 CHECK ( plateState IN ('AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY') ) );
--
/*
Values Added
*/ 
CREATE TABLE Incident (
    incidentID INTEGER PRIMARY KEY,
    incidentSeverity CHAR(10) NOT NULL,
    reportedDate DATE NOT NULL,
    numLicensePlate CHAR(12),
    plateState CHAR(2),
    userID integer,
    CONSTRAINT iic1 FOREIGN KEY (numLicensePlate, plateState) 
        REFERENCES Vehicle(numLicensePlate, plateState),    
    CONSTRAINT iic3 FOREIGN KEY (userID)
       REFERENCES Driver(userID),
    CONSTRAINT iic2 CHECK ( incidentSeverity IN ('Low', 'Medium', 'High', 'Critical')));
--
CREATE TABLE IncidentRelation (
    incidentID1 INTEGER,
    incidentID2 INTEGER,
    comments CHAR(80),
    PRIMARY KEY (incidentID1, incidentID2),
    CONSTRAINT iric1 FOREIGN KEY (incidentID1)
        REFERENCES Incident(incidentID),
    CONSTRAINT iric2 FOREIGN KEY (incidentID2)
        REFERENCES Incident(incidentID));    
--
CREATE TABLE ProjectMilestone (
    projectID INTEGER,
    milestoneDate DATE,
    objective CHAR(100) NOT NULL,
    PRIMARY KEY (projectID, milestoneDate),
    CONSTRAINT pic1 FOREIGN KEY (projectID) 
        REFERENCES ResearchProject(projectID) );
--
CREATE TABLE Drives (
    userID INTEGER,
    numLicensePlate CHAR(12),
    plateState CHAR(2),
    PRIMARY KEY (userID, numLicensePlate, plateState),
    CONSTRAINT dric1 FOREIGN KEY (numLicensePlate, plateState) 
        REFERENCES Vehicle(numLicensePlate, plateState),
    CONSTRAINT dric3 FOREIGN KEY (userID)
        REFERENCES Driver(userID)
    -- constraint to check Drivers are all part of same Household_Institution to be added by trigger 
);
CREATE TABLE Monitor (
    incidentID INTEGER,
    projectID INTEGER,
    PRIMARY KEY (incidentID, projectID),
    CONSTRAINT moic1 FOREIGN KEY (incidentID)
        REFERENCES incident(incidentID),
    CONSTRAINT moic2 FOREIGN KEY (projectID)
        REFERENCES ResearchProject(projectID)
);
--
CREATE OR REPLACE TRIGGER dric4
    BEFORE INSERT OR UPDATE ON Drives
    FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    numNotMatch INTEGER;
    IDS INTEGER;
BEGIN
    SELECT groupID INTO IDS
        FROM Driver
        WHERE userID = :NEW.userID;
        
    SELECT COUNT(*) INTO numNotMatch
        FROM Driver d, Drives dr
        WHERE d.userID = dr.userID AND
              dr.numLicensePlate = :NEW.numLicensePlate AND
              dr.plateState = :NEW.plateState AND
              dr.userID <> :NEW.userID AND
              d.groupID <> IDS;
              
    IF numNotMatch > 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, '++++Insert or Update rejected. '||'User ID ' ||:NEW.userID|| ' part of different Group ID.');
    END IF;
END;
--
/
SHOW ERROR
-- Function for getting the number of members in a Household_Institution
CREATE OR REPLACE FUNCTION numMembers(gID IN Household_Institution.GroupID%TYPE)
    RETURN INTEGER IS
--
    num INTEGER;
    num2 INTEGER;
BEGIN
    SELECT COUNT(*) INTO num
      FROM driver d
      WHERE d.groupID = gID;
--      
    SELECT COUNT(*) INTO num2
      FROM researcher r
      WHERE r.groupID = gID;
--      
    num := num + num2;
    RETURN num;
END numMembers;
-- 
/
SHOW ERROR
--
-- Function for finding the date of last incident for a vehicle
CREATE OR REPLACE FUNCTION dateLastIncident(nLicensePlate IN Vehicle.numLicensePlate%TYPE, pState IN Vehicle.plateState%TYPE)
    RETURN DATE IS
    lastdate DATE;
BEGIN
    SELECT DISTINCT i.reportedDate INTO lastDate
      FROM incident i
      WHERE i.numLicensePlate = nLicensePlate AND
            i.plateState = pState
      ORDER BY i.reportedDate DESC
      FETCH FIRST ROW ONLY;
--
    RETURN lastDate;
END dateLastIncident;
--
/
SHOW ERROR
--
-- Function for find the amount of incidents for a Model
CREATE OR REPLACE FUNCTION modelIncidentNums(model IN Model.vehicleModel%TYPE, make IN Model.vehicleMake%TYPE)
    RETURN INTEGER IS
    num INTEGER;
BEGIN
    SELECT COUNT(*) INTO num
      FROM vehicle v, incident i
      WHERE v.numLicensePlate = i.numLicensePlate AND
            v.plateState = i.plateState AND
            v.vehicleModel = model AND
            v.vehicleMake = make;
    RETURN num;
END modelIncidentNums;
--
/
SHOW ERROR
--
SET FEEDBACK OFF 
--
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (0, 'Business', 'JP Morgan Chase');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (1, 'University', 'GVSU');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (2, 'Business', 'Priority Health');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (3, 'University', 'Calvin College');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (4, 'University', 'Aquinas College');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (5, 'Family', 'Devos');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (6, 'Family', 'Van Andel');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (7, 'Business', 'Honda');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (8, 'Business', 'Volkswagen');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (9, 'Family', 'Flikkema');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (10, 'Business', 'Steelcase');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (11, 'Business', 'Herman Miller');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (12, 'Business', 'Haworth');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (13, 'Business', 'Toyota');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (14, 'Business', 'Nissan');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (15, 'Family', 'Trump');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (16, 'Family', 'Clinton');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (17, 'Family', 'Obama');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (18, 'University', 'Ferris State');
INSERT INTO Household_Institution(groupID, groupType, groupName) VALUES (19, 'Business', 'Spectrum Health');
COMMIT;
--
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (0, 13, 'Educational', '15-APR-68', 'Adrian', 'Mclean', 'AdrianMclean@yahoo.com', 1);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (1, 16, 'Educational', '20-FEB-69', 'John', 'Harris', 'JohnHarris@gmail.com', 2);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (2, 13, 'Educational', '9-OCT-52', 'Elizabeth', 'Cortez', 'ElizabethCortez@yahoo.com', 4);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (3, 14, 'Advanced Educational', '9-JAN-50', 'Savannah', 'Sanchez', 'SavannahSanchez@gmail.com', 5);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (4, 18, 'Commercial', '11-MAY-55', 'Timothy', 'Freeman', 'TimothyFreeman@gmail.com', 7);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (5, 16, 'Advanced Educational', '26-DEC-92', 'Jennifer', 'Kemp', 'JenniferKemp@yahoo.com', 8);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (6, 14, 'Advanced Educational', '4-APR-71', 'Glenn', 'Shepherd', 'GlennShepherd@yahoo.com', 11);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (7, 15, 'Educational', '17-APR-97', 'Craig', 'Pope', 'CraigPope@yahoo.com', 12);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (8, 18, 'Advanced Educational', '10-MAR-77', 'David', 'Kirby', 'DavidKirby@gmail.com', 14);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (9, 14, 'Educational', '02-OCT-68', 'Kelsey', 'Peterson', 'KelseyPeterson@yahoo.com', 15);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (10, 20, 'Advanced Educational', '20-MAR-52', 'Gary', 'Moore', 'GaryMoore@gmail.com', 17);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (11, 17, 'Advanced Educational', '7-JAN-61', 'Craig', 'Stevens', 'CraigStevens@yahoo.com', 18);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (12, 16, 'Educational', '25-OCT-96', 'Allison', 'Austin', 'AllisonAustin@yahoo.com', 19);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (13, 14, 'Commercial', '3-MAY-62', 'Mary', 'Richards', 'MaryRichards@yahoo.com', 3);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (14, 16, 'Advanced Educational', '15-SEP-97', 'Sean', 'Vincent', 'SeanVincent@yahoo.com', 4);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (15, 14, 'Commercial', '18-SEP-86', 'Stacy', 'Patterson', 'StacyPatterson@outlook.com', 16);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (16, 16, 'Educational', '7-JUL-86', 'Lisa', 'Fuller', 'LisaFuller@gmail.com', 5);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (17, 14, 'Advanced Educational', '13-NOV-84', 'Maureen', 'Joyce', 'MaureenJoyce@gmail.com', 6);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (18, 18, 'Educational', '6-NOV-62', 'Monica', 'Collins', 'MonicaCollins@outlook.com', 7);
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (19, 16, 'Commercial', '4-OCT-63', 'Susan', 'Casey', 'SusanCasey@yahoo.com', 12);
COMMIT;
--
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (0, '03783635799');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (1, '219.045.7328x3692');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (2, '02747123249');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (3, '(052)817-8351x0509');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (4, '710.010.0468');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (5, '101.291.9749x8744');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (6, '958-564-6897x520');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (7, '1-074-803-8244');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (8, '988.849.2540x1259');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (9, '1-380-529-2514x7357');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (10, '(782)151-7678');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (11, '05965541016');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (12, '(301)676-2236x7558');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (13, '(527)446-7378');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (14, '(231)810-0297x997');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (15, '219.484.1444x3983');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (16, '092-367-0366x908');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (17, '(371)910-9353x79240');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (18, '(308)220-1792');
INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES (19, '358.638.7133');
COMMIT;
--
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (0, 'Commercial', '8-MAY-72', 'Miller', 'Eddie', 'EddieMiller@gmail.com', 0);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (1, 'Operator', '26-JUN-79', 'Haas', 'Jessica', 'JessicaHaas@gmail.com', 1);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (2, 'Operator', '12-NOV-88', 'Harris', 'Diane', 'DianeHarris@gmail.com', 2);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (3, 'Commercial', '1-MAR-94', 'Wilcox', 'Lindsey', 'LindseyWilcox@outlook.com', 1);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (4, 'Commercial', '2-MAY-73', 'Richardson', 'Angela', 'AngelaRichardson@gmail.com', 4);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (5, 'Commercial', '11-APR-86', 'Hernandez', 'Gregory', 'GregoryHernandez@yahoo.com', 1);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (6, 'Operator', '8-OCT-96', 'Gonzales', 'Jenna', 'JennaGonzales@yahoo.com', 6);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (7, 'Commercial', '24-JUL-58', 'Smith', 'Michael', 'MichaelSmith@gmail.com', 1);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (8, 'Operator', '24-JUL-88', 'Flores', 'Brian', 'BrianFlores@gmail.com', 8);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (9, 'Operator', '2-NOV-99', 'Wilson', 'Connor', 'ConnorWilson@gmail.com', 1);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (10, 'Commercial', '2-MAY-52', 'Horton', 'Michele', 'MicheleHorton@gmail.com', 10);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (11, 'Commercial', '5-FEB-63', 'Brown', 'David', 'DavidBrown@gmail.com', 1);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (12, 'Commercial', '8-AUG-78', 'Chase', 'Joshua', 'JoshuaChase@outlook.com', 1);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (13, 'Operator', '20-AUG-88', 'Mclean', 'Derrick', 'DerrickMclean@yahoo.com', 13);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (14, 'Commercial', '8-SEP-64', 'Sanford', 'Tracy', 'TracySanford@gmail.com', 14);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (15, 'Commercial', '7-MAY-71', 'Green', 'Jason', 'JasonGreen@gmail.com', 15);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (16, 'Operator', '2-JAN-69', 'Thomas', 'Sherry', 'SherryThomas@yahoo.com', 16);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (17, 'Commercial', '5-APR-78', 'Murray', 'Linda', 'LindaMurray@yahoo.com', 1);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (18, 'Operator', '1-DEC-77', 'Perez', 'Jill', 'JillPerez@gmail.com', 18);
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (19, 'Commercial', '8-AUG-67', 'Bean', 'Edward', 'EdwardBean@gmail.com', 19);
COMMIT;
--
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (1, '03128946891');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (1, '1-788-710-4747x9265');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (3, '(357)152-2929');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (3, '(148)612-1851');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (5, '245-115-2868x415');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (5, '(743)555-6772x7580');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (7, '1-052-329-6373x62871');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (7, '(818)472-1666x1195');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (9, '814-690-2110x5937');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (9, '+33(9)9316360642');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (11, '1-674-448-1455');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (11, '(614)435-1817x968');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (13, '674-215-3740');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (13, '+70(2)6060221805');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (15, '(613)282-2713x814');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (15, '(096)693-0398x36788');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (17, '1-140-930-4379x69845');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (17, '08906143790');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (19, '1-209-787-9285x652');
INSERT INTO DriverNumbers(userID, phoneNumber) VALUES (19, '418.995.8696x7500');
COMMIT;
--
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Audi', 'Tars', 'Y');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Ford', 'Wrap', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Mercedes-Benz', 'Note', 'Y');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Honda', 'Ax', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('GM', 'Failures', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Toyota', 'Ounces', 'Y');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Honda', 'Henrys', 'Y');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Ford', 'Hydrometer', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Audi', 'Beans', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Mercedes-Benz', 'Tools', 'Y');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Mercedes-Benz', 'Audit', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('GM', 'Match', 'Y');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Tesla', 'Ribbons', 'Y');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Jeep', 'Launch', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Tesla', 'Fact', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Ford', 'Hitch', 'Y');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Mercedes-Benz', 'Helmsmen', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Toyota', 'Commission', 'Y');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Audi', 'Verbs', 'N');
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Ford', 'Art', 'Y');
COMMIT;
--
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('CA7447', 'MD', '10-FEB-99', 7991.00, 0, 'Ford', 'Hitch');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('E94190', 'NH', '3-SEP-91', 20619.00, 1, 'Tesla', 'Ribbons');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('419D59', 'FL', '24-MAY-13', 70171.00, 2, 'Audi', 'Beans');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('337F42', 'WI', '6-JUN-11', 7572.00, 3, 'Mercedes-Benz', 'Tools');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('0F9A99', 'MT', '9-SEP-07', 15870.00, 4, 'GM', 'Match');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('4A9043', 'TX', '8-DEC-09', 38506.00, 5, 'Ford', 'Hydrometer');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('9AE932', 'AR', '20-MAR-08', 117602.00, 6, 'Honda', 'Ax');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('59A0CB', 'LA', '13-AUG-02', 22287.00, 7, 'Ford', 'Art');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('E4B0E6', 'NY', '21-NOV-12', 31580.00, 8, 'Audi', 'Verbs');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('2DE400', 'IA', '26-JAN-01', 107449.00, 9, 'Mercedes-Benz', 'Audit');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('B83246', 'IN', '12-FEB-00', 78029.00, 10, 'Mercedes-Benz', 'Helmsmen');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('F12316', 'IN', '23-JUN-11', 27686.00, 11, 'GM', 'Failures');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('C245EC', 'NC', '10-AUG-90', 102229.00, 12, 'GM', 'Failures');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('CF533D', 'MT', '18-JUL-98', 58976.00, 13, 'Jeep', 'Launch');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('60D1B3', 'MS', '4-JUL-11', 26284.00, 14, 'Jeep', 'Launch');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('BDDCD3', 'VT', '13-FEB-90', 4417.00, 15, 'Tesla', 'Fact');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('FBC5CA', 'TX', '7-OCT-14', 97223.00, 16, 'Tesla', 'Fact');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('4B3EFE', 'GA', '19-APR-11', 67539.00, 17, 'Honda', 'Henrys');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('9F68C8', 'CT', '18-JUN-02', 102060.00, 18, 'Honda', 'Henrys');
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('A8F1CF', 'RI', '21-FEB-11', 78248.00, 19, 'Audi', 'Tars');
COMMIT;
--
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('0', '4-AUG-16', NULL);
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('1', '7-MAY-13', '31-DEC-16');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('2', '8-MAY-14', NULL);
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('3', '5-APR-15', '30-MAR-17');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('4', '9-JUL-15', '30-MAR-18');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('5', '8-SEP-00', '30-JUN-19');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('6', '5-MAR-06', '30-JUL-24');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('7', '5-OCT-11', '30-MAR-17');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('8', '1-JAN-04', '30-APR-16');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('9', '3-JUN-14', '30-APR-16');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('10', '10-OCT-02', '30-MAR-17');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('11', '10-JAN-90', '30-APR-16');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('12', '14-FEB-93', '30-APR-16');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('13', '16-MAR-92', '30-MAR-17');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('14', '18-APR-12', '30-NOV-16');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('15', '20-MAR-90', '30-MAR-17');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('16', '23-JUN-16', '30-APR-16');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('17', '31-OCT-15', NULL);
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('18', '31-AUG-15', '30-APR-16');
INSERT INTO ResearchProject(projectID, projectStartDate, projectEndDate) VALUES ('19', '5-APR-07', '30-APR-16');
COMMIT;
--
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (1, '19-JUL-19', 'Determine most common causes of autonomous vehicle accidents');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (1, '1-DEC-18', 'What could improve driver attentiveness is semi-autonomous vehicles');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (2, '23-AUG-17', 'What autonomous vehicle technology should be phased out?');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (3, '18-APR-22', 'What technologies need to be introduced to improve overall autonomous vehicle safety');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (5, '2-OCT-27', 'What demographic of drivers are the slowest at adopting autonomous vehicles');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (6, '12-SEP-25', 'What demographic of drivers are purchasing autonomous vehicles the fastest');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (9, '30-MAY-19', 'What demographic of drivers are experiencing increasing numbers of driver accidents');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (9, '14-FEB-21', 'What demographic of drivers are improving the quickest in incident rates');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (11, '6-JAN-35', 'What technologies perform the worst for autonomous vehicles');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (13, '24-MAR-31', 'What technologies perform the best in autonomous vehicles');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (12, '15-APR-35', 'Determine the worst performing brands of autonomous vehicles');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (15, '3-JUN-17', 'Determine what would best help to reduce drunk driving accidents in U.S.');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (15, '14-JUL-25', 'Determine best performing brands of autonomous vehicles');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (15, '29-NOV-28', 'At fault analyst of human v. autonomous incidents');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (16, '7-AUG-19', 'Determine most common causes of human driver accidents');
INSERT INTO ProjectMilestone(projectID, milestoneDate, objective) VALUES (17, '10-DEC-16', 'Determine impediments to autonomous vehicle adoption');
COMMIT;
--
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (0, 'Low', '20-JUN-13', 'E94190', 'NH', 8); 
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (1, 'Medium', '15-FEB-16',  'CA7447', 'MD', 15);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (2, 'Low', '6-JAN-15',  '4A9043', 'TX', 6);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (3, 'High', '4-NOV-09',  'CA7447', 'MD', 2);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (4, 'Low', '11-DEC-05',  'B83246', 'IN', 11);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (5, 'High', '4-JUL-07',  'CA7447', 'MD', 4);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (6, 'Low', '14-MAY-90',  '2DE400', 'IA', 14);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (7, 'High', '16-APR-97',  'CA7447', 'MD', 16);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (8, 'Medium', '3-JAN-98',  '59A0CB', 'LA', 3);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (9, 'Medium', '17-FEB-01',  'CA7447', 'MD', 17);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (10, 'Low', '10-SEP-02',  '60D1B3', 'MS', 10);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (12, 'Critical', '28-OCT-86',  'CA7447', 'MD', 0);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (13, 'Low', '13-JAN-04',  '60D1B3', 'MS', 13);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (14, 'Critical', '18-JUN-89',  '9F68C8', 'CT', 18);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (15, 'Low', '9-JUN-96',  '9AE932', 'AR', 9);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (16, 'Low', '19-AUG-11',  'E4B0E6', 'NY', 19);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (17, 'High', '1-MAY-90',  'CA7447', 'MD', 5);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (18, 'Low', '9-DEC-16',  'F12316', 'IN', 12);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (19, 'Medium', '1-JUL-98',  '4B3EFE', 'GA', 7);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (20, 'Low', '1-JAN-15',  'CA7447', 'MD', 1);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (21, 'High', '1-JAN-14',  'CA7447', 'MD', 1);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (22, 'Medium', '9-JAN-15',  'F12316', 'IN', 12);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (23, 'Low', '1-JUL-15',  '4B3EFE', 'GA', 7);
INSERT INTO Incident(incidentID, incidentSeverity, reportedDate, numLicensePlate, plateState, userID) VALUES (24, 'Low', '1-AUG-15',  '4B3EFE', 'GA', 7);
COMMIT;
--
INSERT INTO Monitor(incidentID, projectID) VALUES (19, 10);
INSERT INTO Monitor(incidentID, projectID) VALUES (19, 11);
INSERT INTO Monitor(incidentID, projectID) VALUES (19, 14);
INSERT INTO Monitor(incidentID, projectID) VALUES (3, 2);
INSERT INTO Monitor(incidentID, projectID) VALUES (3, 7);
INSERT INTO Monitor(incidentID, projectID) VALUES (3, 9);
INSERT INTO Monitor(incidentID, projectID) VALUES (5, 1);
INSERT INTO Monitor(incidentID, projectID) VALUES (5, 3);
INSERT INTO Monitor(incidentID, projectID) VALUES (5, 15);
INSERT INTO Monitor(incidentID, projectID) VALUES (8, 4);
INSERT INTO Monitor(incidentID, projectID) VALUES (8, 5);
INSERT INTO Monitor(incidentID, projectID) VALUES (8, 6);
INSERT INTO Monitor(incidentID, projectID) VALUES (12, 8);
INSERT INTO Monitor(incidentID, projectID) VALUES (12, 12);
INSERT INTO Monitor(incidentID, projectID) VALUES (12, 13);
INSERT INTO Monitor(incidentID, projectID) VALUES (15, 16);
INSERT INTO Monitor(incidentID, projectID) VALUES (15, 17);
INSERT INTO Monitor(incidentID, projectID) VALUES (15, 18);
INSERT INTO Monitor(incidentID, projectID) VALUES (2, 19);
INSERT INTO Monitor(incidentID, projectID) VALUES (2, 0);
COMMIT;
--
INSERT INTO IncidentRelation(incidentID1, incidentID2, comments) VALUES (0, 1, NULL);
INSERT INTO IncidentRelation(incidentID1, incidentID2, comments) VALUES (2, 8, 'That driver is a madman!');
INSERT INTO IncidentRelation(incidentID1, incidentID2, comments) VALUES (1, 19, 'He cut me off, totally his fault.');
INSERT INTO IncidentRelation(incidentID1, incidentID2, comments) VALUES (17, 12, NULL);
INSERT INTO IncidentRelation(incidentID1, incidentID2, comments) VALUES (8, 13, 'Those autnomous vehicles are out of control, get them off the road');
INSERT INTO IncidentRelation(incidentID1, incidentID2, comments) VALUES (16, 15, NULL);
COMMIT;
--
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (0, 9, '5-MAR-01', '5-MAR-02');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (1, 5, '27-NOV-90', '27-NOV-95');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (2, 1, '22-SEP-12', '22-SEP-14');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (3, 3, '11-JUN-90', NULL);
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (4, 12, '25-AUG-09', '25-AUG-11');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (5, 18, '13-MAY-14', NULL);
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (18, 15, '4-OCT-94', '25-APR-95');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (7, 6, '27-FEB-96', '27-JUN-96');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (18, 17, '15-DEC-12', NULL);
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (18, 7, '27-NOV-03', '27-NOV-05');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (10, 19, '8-MAR-94', '3-AUG-94');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (18, 10, '3-MAR-06', NULL);
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (12, 16, '16-APR-98', '16-JUN-98');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (18, 13, '25-MAY-03', '25-OCT-03');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (14, 11, '21-JAN-05', NULL);
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (15, 4, '6-MAY-15', '10-JUN-15');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (16, 14, '9-SEP-05', '30-SEP-05');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (18, 2, '8-SEP-94', '9-DEC-94');
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (18, 0, '6-JUL-12', NULL);
INSERT INTO Conducts(userID, projectID, beginDate, endDate) VALUES (19, 8, '6-JUL-15', '6-DEC-15');
COMMIT;
--    
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (0, 'E94190', 'NH');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (1, 'CA7447', 'MD');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (2, '4A9043', 'TX');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (3, 'CA7447', 'MD');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (4, 'B83246', 'IN');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (5, 'CA7447', 'MD');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (6, '2DE400', 'IA');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (7, 'CA7447', 'MD');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (8, '59A0CB', 'LA');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (9, 'CA7447', 'MD');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (10,'60D1B3', 'MS');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (11, 'CA7447', 'MD');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (12, 'CA7447', 'MD');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (13, 'C245EC', 'NC');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (14, '9F68C8', 'CT');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (15, '9AE932', 'AR');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (16, 'E4B0E6', 'NY');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (17, 'CA7447', 'MD');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (18, 'F12316', 'IN');
COMMIT;
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (19, '4B3EFE', 'GA');
COMMIT;
--
SET FEEDBACK ON
--
/*
Queries below should return everything inserted into the tables
*/
SELECT * FROM Household_Institution;
--
SELECT * FROM Researcher;
--
SELECT * FROM  ResearcherNumbers;
--
SELECT * FROM  ResearchProject;
--
SELECT * FROM  Conducts;
--
SELECT * FROM  Driver;
--
SELECT * FROM  DriverNumbers;
--
SELECT * FROM  Vehicle;
--
SELECT * FROM Model;
--
SELECT * FROM Incident;
--
SELECT * FROM IncidentRelation;
--
SELECT * FROM  ProjectMilestone;
--
SELECT * FROM  Drives;
--
SELECT * FROM Monitor;
--
/*
This will include the all select statements that test different query types.
It will also include the INSERT, UPDATE, and DELETE statements that are needed
to test the integrity constraints
*/
--
--Join using 4 Relations :
/*
find driver, incident, and vehicle information for all incidents
*/
select D.userID, D.lastName, D.FirstName, DN.PhoneNumber, I.IncidentID, I.IncidentSeverity, v.numlicenseplate, v.platestate, dateLastIncident(v.numLicensePlate, v.plateState)
from Driver D , DriverNumbers DN , Incident I, Vehicle V
where D.userID = DN.userID AND D.userID = I.userID AND i.numlicenseplate = V.numlicenseplate and i.platestate = v.platestate;
--Groupby, having , count function :
/*
Find the number of incidents that drivers have been in, if they've been in more than 1
*/
select D.userID , Count (*)  
from Driver D , Incident I  
where D.userID = I.userID 
Group by D.userid 
Having count(incidentID) > 1
ORDER BY Count(*);
--Avg Fucntion:
/*
find the average grade completed for a research type
*/
select ResearchType, Avg(Gradecompleted) as AvgGrade from Researcher
Group by ResearchType;
/*
find max grade completed for a research type
*/
--Max Function
select ResearchType, MAX(Gradecompleted) as MaxGrade from Researcher
Group by ResearchType;
/*
find the minimum grade completed for a research type
*/
--Min Function
select ResearchType, Min(Gradecompleted) as MinGrade from Researcher
Group by ResearchType;
---Self Join
/*
Find pairs of researchers where the first researcher (in the pair) has a gradecompleted above 16 and the second researcher (in the pair)
has a similar grade completed. List each pair once only.
*/
select R1.FirstName, R2.FirstName 
from Researcher R1 , Researcher R2
where R1.Gradecompleted > 16 AND
R1.Gradecompleted = R2.Gradecompleted
AND R1.userID < R2.userID;
--
--- union
/*
find drivers who were born after 1990 or who have been in an incident since since 2015
*/
select userID, firstName, lastName from driver
where DATE_of_BIRTH > '01-JAN-90'
union
select D.userID, D.FIRSTNAME,D.LASTNAME from driver D, Incident I
where D.userID = i.userid and
      i.reporteddate > '01-JAN-15';
--     
--- correlated subquery
/*
Find vehicles that have not been in a reported incident
*/
select v.numlicenseplate, v.platestate from vehicle v
where not exists (select i.numlicenseplate, i.platestate from incident i
                  where i.numlicenseplate = v.numlicenseplate and
                        i.platestate = v.platestate);
--
-- non correlated subquery
/*
select driver who do not have any phone-numbers
*/
select d.userid, d.firstname, d.lastname from driver d
where d.userid not in(select dn.userid from drivernumbers dn);
--
-- outer-join query
/*
Find the projectId, projectStartDate, projectEndDate, projectMilestone, projectObjective for every project. Also show the projectMilestones for those that have them.
*/
--
SELECT RP.ProjectID , RP.ProjectstartDate ,RP.ProjectEndDate , PM.milestonedate, PM.objective 
FROM ResearchProject RP LEFT OUTER JOIN ProjectMilestone PM ON RP.ProjectID = PM.ProjectID;
-- Rank Query
/*
Find the userId, ResearchType, gradeCompleted and rank for each researcher for researchtypes Advanced- Educational and Educational
*/
SELECT R.userID, R.ResearchType, R.Gradecompleted, RANK() OVER (PARTITION BY R.researchtype ORDER BY R.Gradecompleted DESC) AS Rank  
FROM Researcher R
WHERE R. Researchtype in ('Advanced Educational','Educational')
order by researchtype;
--
-- Top-N query
/*
Find the top 5 userId, ResearchType, gradeCompleted and rank for each researcher for gradeCompleted range between 13 and 20.
*/
SELECT R.userID, R.ResearchType, R.Gradecompleted, RANK() OVER (PARTITION BY R.researchtype ORDER BY R.Gradecompleted DESC) AS Rank  
FROM Researcher R
WHERE R.Gradecompleted BETWEEN 13 AND 20  
and rownum <= 5;
--
-- Division Query
/*
Find the users that are on all projects without an end date
*/
SELECT r.userID, r.firstname, r.lastname
FROM researcher R
WHERE NOT EXISTS((SELECT rp.projectID
 FROM researchProject rp
 WHERE rp.projectendDate IS NULL)
 MINUS
 (SELECT c.projectID
 FROM conducts C, researchProject Rp
 WHERE c.userID = r.userID AND
 c.projectID = rp.projectID AND
 rp.projectendDate IS NULL));
--
-- query to demonstrate functioning numMembers function
select groupID, groupType, numMembers(groupID)
FROM household_institution;
--
-- query to demonstrate functioning modelIncidentNums function
select vehicleModel, vehicleMake, modelIncidentNums(vehicleModel, vehicleMake)
FROM model;
/*
Let tests some of the integrity constraints here
*/
--
INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES ('Audi', 'Adjective', 'X');
--
INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES (20, 'CrazyTown', '22-MAY-89', 'Jean', 'Claude', 'jeanclaude@gmail.com', 18);
--
INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES ('BHY7477', 'KO', '10-FEB-99', 7991.00, 0, 'Ford', 'Hitch');
--
INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES (35, 10, 'Advanced Educational', '17-APR-99', 'JD', 'Edwards', 'JDEdwards@yahoo.com', 12);
--
INSERT INTO Drives(UserID, numLicensePlate, plateState) VALUES (4, 'CA7447', 'MD');
--
--
SET ECHO OFF
SPOOL OFF
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        







