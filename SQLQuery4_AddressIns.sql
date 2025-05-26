/*
USE StaffInfo
GO
*/


CREATE OR ALTER PROCEDURE SpAddressIns  
@json NVARCHAR(MAX) OUTPUT  
AS  
BEGIN  
 BEGIN TRY  
  BEGIN TRANSACTION  
   CREATE TABLE #Temp  
   (  
    StaffId INT,  
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
   INSERT INTO #Temp(StaffId, StaffFirstName, StaffMiddleName, StaffLastName, DateOfBirth, Position, HireDate,DepartmentId, MobileNumber, Email, City, State, PostCode,Country, UserPersonId, InsertDate)  
   SELECT StaffId, StaffFirstName, StaffMiddleName, StaffLastName, DateOfBirth, Position, HireDate,DepartmentId, MobileNumber, Email, City, State, PostCode,Country, UserPersonId, InsertDate  
   FROM OPENJSON(@json)  
   WITH  
   (  
    StaffId INT,  
    StaffFirstName NVARCHAR(100),  
    StaffMiddleName NVARCHAR(100) ,  
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
   )  
  
   DECLARE @Address TABLE  
   (  
    AddressId INT,  
    City NVARCHAR(100),  
    State NVARCHAR(100),  
    PostalCode NVARCHAR(100),  
    Country VARCHAR(100),  
    UserPersonId INT,  
    InsertDate DATE  
   );  
  
   INSERT INTO Address(City, State, PostalCode, Country, UserPersonId, InsertDate)  
   OUTPUT INSERTED.* INTO @Address  
   SELECT City, State, PostCode, Country, UserPersonId, InsertDate  
   FROM #Temp;  
  
   SET @json = (SELECT a.AddressId, t.*  
       FROM #Temp t  
       INNER JOIN @Address a  
       ON t.City = a.City AND  
       t.State = a.State AND  
       t.PostCode = a.PostalCode AND  
       t.Country = a.Country  
       FOR JSON PATH);  
   SELECT * FROM @Address;  
   DROP TABLE #Temp;  
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
  PRINT 'Error line: ' + CAST(@ErrorLine AS VARCHAR(200));  
  PRINT 'Error Procedure: ' + ISNULL(@ErrorProcedure, 'UNKNOWN');  
  PRINT 'Error Message: ' + @ErrorMessage;  
  RAISERROR(@ErrorMessage, 16,1);  
 END CATCH  
END