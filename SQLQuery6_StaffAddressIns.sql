USE StaffInfo
GO

CREATE OR ALTER PROCEDURE SpStaffAddressIns  
@json NVARCHAR(MAX)  
AS  
BEGIN  
 BEGIN TRY  
  BEGIN TRANSACTION  
   CREATE TABLE #temp  
   (   
    ContactId INT,  
    StaffId INT,  
    AddressId INT,  
    DepartmentId INT  
   )  
   INSERT INTO #temp(ContactId, StaffId, AddressId, DepartmentId)  
   SELECT ContactId, StaffId, AddressId, DepartmentId  
   FROM OPENJSON(@json)  
   WITH  
   (  
    ContactId INT,  
    StaffId INT,  
    AddressId INT,  
    DepartmentId INT  
   );  
   DECLARE @StaffAddress TABLE  
   (  
    StaffAddressId INT,  
    StaffId INT,  
    AddressId INT  
   );  
   INSERT INTO StaffAddress (StaffId, AddressId)  
   OUTPUT INSERTED.* INTO @StaffAddress  
   SELECT StaffId, AddressId  
   FROM #temp;  
  
   SELECT * FROM @StaffAddress;  
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