USE StaffInfo
GO

CREATE  OR ALTER  PROCEDURE SpStaffIns  
@json NVARCHAR(MAX) OUTPUT  
AS  
BEGIN  
BEGIN TRY  
BEGIN TRANSACTION  
CREATE TABLE #TempStaff  
(  
 StaffFirstName NVARCHAR(100),  
 StaffMiddleName NVARCHAR(100) NULL,  
 StaffLastName NVARCHAR(100),  
 DateOfBirth DATE,  
 Position NVARCHAR(100),  
 HireDate DATE,  
 DepartmentId INT,  
 MobileNumber VARCHAR(200),  
 Email VARCHAR(200),  
 City VARCHAR(200),  
 State VARCHAR(200),  
 PostCode VARCHAR(200),  
 Country VARCHAR(200),  
 UserPersonId INT,  
 InsertDate DATE  
);  
  
INSERT INTO #TempStaff( StaffFirstName, StaffMiddleName, StaffLastName, DateOfBirth, Position, HireDate, DepartmentId, MobileNumber, Email, City, State, PostCode, Country, UserPersonId, InsertDate)  
SELECT DISTINCT  StaffFirstName, StaffMiddleName, StaffLastName, DateOfBirth, Position, HireDate,DepartmentId, MobileNumber, Email, City, State, PostCode, Country, JSON_VALUE(@json, '$.UserPersonId') AS UserPersonId, GETDATE() AS InsertDate  
FROM  OPENJSON(@json, '$.data')  
WITH  
(  
 StaffFirstName NVARCHAR(100),  
 StaffMiddleName NVARCHAR(100),  
 StaffLastName NVARCHAR(100),  
 DateOfBirth DATE,  
 Position NVARCHAR(100),  
 HireDate DATE,  
 DepartmentId INT,  
 MobileNumber VARCHAR(200),  
 Email VARCHAR(200),  
 City VARCHAR(200),  
 State VARCHAR(200),  
 PostCode VARCHAR(200),  
 Country VARCHAR(200)  
);  
  
DECLARE @Staff TABLE  
(   
 StaffId INT,  
 StaffFirstName NVARCHAR(100),  
 StaffMiddleName NVARCHAR(100) NULL,  
 StaffLastName NVARCHAR(100),  
 DateOfBirth DATE,  
 Position NVARCHAR(100),  
 HireDate DATE,  
 UserPersonId INT,  
 InsertDate DATE  
);  
---------------if there is null in any of the column on both the table of same staff there might occur problem  
----------------that duplicate data get inserted  
INSERT INTO Staff(StaffFirstName, StaffMiddleName, StaffLastName, DateOfBirth, Position, HireDate, UserPersonId, InsertDate)  
OUTPUT INSERTED.* INTO @Staff  
SELECT t.StaffFirstName, t.StaffMiddleName, t.StaffLastName, t.DateOfBirth, t.Position, t.HireDate, t.UserPersonId, t.InsertDate  
FROM #TempStaff t  
LEFT JOIN Staff s  
ON t.StaffFirstName =s.StaffFirstName   
AND t.StaffMiddleName= s.StaffMiddleName  
AND t.StaffLastName = s.StaffLastName  
AND t.DateOfBirth = s.DateOfBirth  
AND t.Position = s.Position  
AND t.HireDate = s.HireDate  
WHERE s.StaffFirstName IS NULL  
  
SET @json = (SELECT t.*, s.StaffId  
    FROM @Staff s  
    INNER JOIN #TempStaff t  
    ON s.StaffFirstName = t.StaffFirstName  
    AND s.StaffMiddleName = t.StaffMiddleName  
    AND s.StaffLastName = t.StaffLastName  
    AND s.DateOfBirth = t.DateOfBirth  
    AND s.Position = t.Position  
    AND s.HireDate = t.HireDate  
    FOR JSON PATH);  
  
SELECT * FROM @Staff;  
--PRINT @json;  
DROP TABLE #TempStaff;  
COMMIT TRANSACTION  
END TRY  
BEGIN CATCH  
IF @@TRANCOUNT>0  
ROLLBACK;  
DECLARE @ErrorLine INT;  
DECLARE @ErrorProcedure NVARCHAR(200);  
DECLARE @ErrorMessage NVARCHAR(200);  
SET @ErrorLine = ERROR_LINE();  
SET @ErrorProcedure = ERROR_PROCEDURE();  
SET @ErrorMessage = ERROR_MESSAGE();  
PRINT 'Error line: ' + CAST (@ErrorLine AS NVARCHAR(200));  
PRINT 'Error procedure: ' + ISNULL(@ErrorProcedure, 'UNKNOWN PROCEDURE!!!');  
PRINT 'Error message: ' + @ErrorMessage;  
RAISERROR(@ErrorMessage,16,1);  
END CATCH  
END  
  
  
  