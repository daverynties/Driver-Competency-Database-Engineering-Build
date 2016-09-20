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
select D.userID, D.lastName, D.FirstName, DN.PhoneNumber, I.IncidentID, I.IncidentSeverity, v.numlicenseplate, v.platestate, (v.numLicensePlate, v.plateState)
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
FROM ResearchProject RP LEFT OUTER JOIN ProjectMilestone PM ON RP.ProjectID = PM.ProjectID
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






