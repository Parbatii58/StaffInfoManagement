USE StaffInfo
GO

  
CREATE OR ALTER  PROCEDURE SpStaffContactIns  
@json NVARCHAR(MAX)  
AS  
BEGIN  
 BEGIN TRY  
  BEGIN TRANSACTION  
   CREATE TABLE #temp  
   (   
    ContactId INT,  
    StaffId INT,  
    DepartmentId INT  
   )  
   INSERT INTO #temp(ContactId, StaffId,  DepartmentId)  
   SELECT ContactId, StaffId, DepartmentId  
   FROM OPENJSON(@json)  
   WITH  
   (  
    ContactId INT,  
    StaffId INT,  
    DepartmentId INT  
   );  
   DECLARE @StaffContact TABLE  
   (  
    StaffContactId INT,  
    StaffId INT,  
    ContactId INT  
   );  
   INSERT INTO StaffContact (StaffId, ContactId)  
   OUTPUT INSERTED.* INTO @StaffContact  
   SELECT StaffId, ContactId  
   FROM #temp;  
  
   SELECT * FROM @StaffContact;  
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
  PRINT 'Error Procedure ' + ISNULL(@ErrorProcedure, 'UNKNOWN');  
  PRINT 'Error Message' + @ErrorMessage;  
  RAISERROR(@ErrorMessage, 16,1);  
 END CATCH  
END