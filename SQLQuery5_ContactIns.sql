USE StaffInfo
GO

CREATE OR ALTER PROCEDURE SpContactIns  
@json NVARCHAR(MAX) OUTPUT  
AS  
BEGIN  
 BEGIN TRY  
  BEGIN TRANSACTION  
   CREATE TABLE #temp  
   (  
    StaffId INT,  
    AddressId INT,  
    DepartmentId INT,  
    MobileNumber NVARCHAR(100),  
    Email NVARCHAR(100),  
    UserPersonId INT,  
    InsertDate DATE  
   );  
   INSERT INTO #temp(StaffId, AddressId, DepartmentId, MobileNumber, Email, UserPersonId, InsertDate)  
   SELECT StaffId, AddressId, DepartmentId, MobileNumber, Email, UserPersonId, InsertDate  
   FROM OPENJSON(@json)  
   WITH  
   (  
    StaffId INT,  
    AddressId INT,  
    DepartmentId INT,  
    MobileNumber NVARCHAR(100),  
    Email NVARCHAR(100),  
    UserPersonId INT,  
    InsertDate DATE  
   );  
  
   DECLARE @Contact TABLE  
   (  
    ContactId INT,  
    MobileNumber NVARCHAR(100),  
    Email NVARCHAR(100),  
    UserPersonId INT,  
    InsertDate DATE  
   );  
   INSERT INTO Contact(MobileNumber, Email, UserPersonId, InsertDate)  
   OUTPUT INSERTED.* INTO @Contact  
   SELECT MobileNumber, Email, UserPersonId, InsertDate  
   FROM #temp;  
  
   SET @json = (SELECT c.ContactId, t.*  
       FROM #temp t  
       INNER JOIN @Contact c  
       ON t.MobileNumber = c.MobileNumber  
       AND t.Email = c.Email  
       FOR JSON PATH);  
   --SELECT @json;  
   SELECT * FROM @Contact;  
   DROP TABLE #temp;  
  COMMIT TRANSACTION  
 END TRY  
 BEGIN CATCH  
  IF @@TRANCOUNT>0  
  ROLLBACK;  
  
  DECLARE @ErrorLine INT;  
  DECLARE @ErrorProcedure NVARCHAR(200);  
  DECLARE @ErrorMessage NVARCHAR(200);  
  SET @ErrorLine = ERROR_LINE();  
  SET @ErrorMessage = ERROR_MESSAGE();  
  SET @ErrorProcedure = ERROR_PROCEDURE();  
  
  PRINT 'Error line: ' + CAST(@ErrorLine AS NVARCHAR(200));  
  PRINT 'Error Procedure: ' + ISNULL(@ErrorProcedure, 'UNKNOWN');  
  PRINT 'Error Message: ' + @ErrorMessage;  
  RAISERROR(@ErrorMessage, 16,1);  
 END CATCH  
END  
  
  