# -*- coding: utf-8 -*-
"""
Created on Thu Aug  4 17:25:57 2016

@author: David A. Rynties
"""
from faker import Factory
import random
import numpy
from datetime import datetime 
 
year = random.randint(1950, 2000)
month = random.randint(1, 12)
day = random.randint(1, 28)
birth_date = datetime(year, month, day)
birth_date_final = birth_date.replace(second=0, microsecond=0)

birth_date_final = '{0}-{1}-{2}'.format(year, month, day)

randNum = random.SystemRandom()

fake = Factory.create()

researchType = ['Educational', 'Commercial', 'Advanced Educational']
email_suffix = ['@gmail.com', '@yahoo.com', '@outlook.com', ]

#%% Researcher

#CREATE TABLE Researcher ( 
#    userID INTEGER PRIMARY KEY, 
#    gradeCompleted INTEGER NOT NULL,
#    researchType CHAR(20) NOT NULL,
#    date_of_birth DATE NOT NULL, 
#    lastName CHAR(40) NOT NULL, 
#    firstName CHAR(40) NOT NULL,
#    email CHAR(100), 
#    groupID INTEGER,
#    CONSTRAINT ric1 FOREIGN KEY groupID 
#        REFERENCES Household_Institution(groupID),
#    CONSTRAINT ric2 CHECK (researchType IN ('Educational', 'Commercial', 'Advanced Educational'),
#    CONSTRAINT ric3 CHECK (NOT(gradeCompleted <= 12 AND researchType = 'Advanced Educational') 
#); 

for i in range(20):
    year = random.randint(1950, 2000)
    month = random.randint(1, 12)
    day = random.randint(1, 28)
    birth_date = datetime(year, month, day)
    birth_date_final = '{0}-{1}-{2}'.format(year, month, day)
    last_name = fake.last_name()
    first_name = fake.first_name()
    email_string = first_name + last_name+numpy.random.choice(email_suffix)
    print('INSERT INTO Researcher(userID, gradeCompleted, researchType, date_of_birth, lastName, firstName, email, groupID) VALUES ({0}, {1}, \'{2}\', \'{3}\', \'{4}\', \'{5}\', \'{6}\', {7});'.format(i, random.randint(12,20), numpy.random.choice(researchType), birth_date_final, first_name, last_name, email_string, random.randint(0,200)))

#%% Research Numbers

#CREATE TABLE ResearcherNumbers (
#  userID INTEGER PRIMARY KEY,
#  phoneNumber VARCHAR(22) PRIMARY KEY,
#  CONSTRAINT rnic1 FOREIGN KEY userID
#      REFERENCES Researcher(userID)
#);

for i in range(20):
    print('INSERT INTO ResearcherNumbers(userID, phoneNumber) VALUES ({0}, \'{1}\''.format(i, fake.phone_number()[:22]))

#%% Driver

#CREATE TABLE Driver (
#    userID INTEGER PRIMARY KEY,
#    licenseType CHAR(10) NOT NULL,
#    date_of_birth DATE NOT NULL,
#    lastName CHAR(40) NOT NULL,
#    firstName CHAR(40) NOT NULL,
#    email CHAR(100),
#    groupID INTEGER,
#    CONSTRAINT dic1 FOREIGN KEY groupID 
#        REFERENCES Household_Institution(groupID),
#    CONSTRAINT dic2 CHECK ( licenseType IN ('Commercial', 'Operator') )
#);

licenseType = ['Commercial', 'Operator']
email_suffix = ['@gmail.com', '@yahoo.com', '@outlook.com', ]


for i in range(20):
    year = random.randint(1950, 2000)
    month = random.randint(1, 12)
    day = random.randint(1, 28)
    birth_date = datetime(year, month, day)
    birth_date_final = '{0}-{1}-{2}'.format(year, month, day)
    last_name = fake.last_name()
    first_name = fake.first_name()
    email_string = first_name + last_name+numpy.random.choice(email_suffix)
    license_type = numpy.random.choice(licenseType)
    
    
    print('INSERT INTO Driver(userID, licenseType, date_of_birth, lastName, firstname, email, groupID) VALUES ({0}, \'{1}\', \'{2}\', \'{3}\', \'{4}\', \'{5}\', {6});'.format(i, license_type, birth_date_final, last_name, first_name, email_string, i))
    
    #%% Driver Numbers
    
#    CREATE TABLE DriverNumbers (
#    userID INTEGER PRIMARY KEY,
#    phoneNumber VARCHAR(22) PRIMARY KEY,
#    CONSTRAINT dnic1 FOREIGN KEY userID
#      REFERENCES Driver(userID)
#);
    
for i in range(20):
    print('INSERT INTO DriverNumbers(userID, phoneNumber) VALUES ({0}, \'{1}\');'.format(i, fake.phone_number()[:22]))
        
#%%
#        CREATE TABLE Vehicle (
#    numLicensePlate CHAR(12) PRIMARY KEY,
#    plateState CHAR(2) PRIMARY KEY,
#    --dateLastIncident implemented by function
#    purchaseDate DATE,
#    purchasePrice NUMBER(15,2),
#    groupID INTEGER,
#    vehicleMake CHAR(30),
#    vehicleModel CHAR(30),
#    CONSTRAINT vic1 FOREIGN KEY groupID 
#        REFERENCES Household_Institution(groupID),
#    CONSTRAINT vic2 FOREIGN KEY vehicleMake
#        REFERENCES Model(vehicleMake),
#    CONSTRAINT vic3 FOREIGN KEY vehicleModel
#        REFERENCES Model(vehicleModel),
#    CONSTRAINT vic4 CHECK ( plateState IN ('AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY') )
#);
        
import uuid
from random_words import RandomWords
rw = RandomWords()

def my_random_string(string_length=20):
    """Returns a random string of length string_length."""
    random = str(uuid.uuid4()) # Convert UUID format to a Python string.
    random = random.upper() # Make all characters uppercase.
    random = random.replace("-","") # Remove the UUID '-'.
    return random[0:string_length] # Return the random string.

print(my_random_string(6)) # For example, D9E50C

vehicleMake = ['Tesla', 'Audi', 'Mercedes-Benz', 'Ford', 'Jeep', 'Fiat']
states = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY']


for i in range(20):
    year = random.randint(1990, 2016)
    month = random.randint(1, 12)
    day = random.randint(1,28)
    licenseNum = my_random_string(6)
    plate_state = numpy.random.choice(states)
    purchase_date = datetime(year, month, day)
    purchase_date_final = '{0}-{1}-{2}'.format(year, month, day)
    purchase_price = random.randint(2500, 120000 )
    vehicle_make = numpy.random.choice(vehicleMake)
    plate_state = numpy.random.choice(states)
    vehicle_model = rw.random_word()
    decimal = '.00'
    purchase_price_final = '{0}{1}'.format(purchase_price, decimal)
    print('INSERT INTO Vehicle(numLicensePlate, plateState, purchaseDate, purchasePrice, groupID, vehicleMake, vehicleModel) VALUES (\'{0}\', \'{1}\', \'{2}\', \'{3}\', {4}, \'{5}\', \'{6}\');'.format(licenseNum, plate_state, purchase_date_final,birth_date_final, purchase_price_final,vehicle_make, vehicle_model.title()))

#%%

#CREATE TABLE Model (
#    vehicleMake CHAR(30) PRIMARY KEY,
#    vehicleModel CHAR(30) PRIMARY KEY,
#    isAutonomous CHAR(1),
#    --numIncidents to be implemented by function
#    CONSTRAINT mic1 CHECK ( isAutonomous = 'Y' OR isAutonomous = 'N' ),
#);

from random_words import RandomWords
rw = RandomWords()

vehicleMake = ['Tesla', 'Audi', 'Mercedes-Benz', 'Ford', 'Jeep', 'Fiat', 'GM', 'Honda', 'Toyota']
is_autonomous = ['Y','N']

for i in range(20):
    vehicle_model = rw.random_word()
    vehicle_make = numpy.random.choice(vehicleMake)
    #is_autonomous = numpy.random.choice(is_autonomous)
    print('INSERT INTO Model(vehicleMake, vehicleModel, isAutonomous) VALUES (\'{0}\', \'{1}\');'.format(vehicle_make, vehicle_model.title()))
    
    

#%%

#CREATE TABLE Conducts (
#    userID INTEGER,
#    projectID INTEGER,
#    beginDate DATE NOT NULL,
#    endDate DATE,
#    PRIMARY KEY (userID, projectID),
#    CONSTRAINT cic1 FOREIGN KEY (userID)
#        REFERENCES Researcher(userID),
#    CONSTRAINT cic2 FOREIGN KEY (projectID)
#        REFERENCES ResearchProject(projectID) );
import random

x = random.sample(range(20), 20)

for i in range(20):
    year = random.randint(1990, 2016)
    month = random.randint(1, 12)
    day = random.randint(1,28)
    project_start_date = '{0}-{1}-{2}'.format(year, month, day)
    #is_autonomous = numpy.random.choice(is_autonomous)
    print('INSERT INTO Conducts(userID, projectID, beginDate, endDate,) VALUES ({0}, {1}, \'{2}\', \'{3}\');'.format(i, x[i], project_start_date, project_start_date))






#%%