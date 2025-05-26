USE StaffInfo
GO

  
CREATE OR ALTER PROCEDURE SpStaffDepartmentIns  
@json NVARCHAR(MAX)  
AS  
BEGIN  
 BEGIN TRY  
  BEGIN TRANSACTION  
   CREATE TABLE #temp  
   (   
    StaffId INT,  
    DepartmentId INT  
   )  
   INSERT INTO #temp( StaffId,  DepartmentId)  
   SELECT  StaffId, DepartmentId  
   FROM OPENJSON(@json)  
   WITH  
   (  
    StaffId INT,  
    DepartmentId INT  
   );  
   DECLARE @StaffDepartment TABLE  
   (  
    StaffDepartmentId INT,  
    StaffId INT,  
    DepartmentId INT  
   );  
   INSERT INTO StaffDepartment (StaffId, DepartmentId)  
   OUTPUT INSERTED.* INTO @StaffDepartment  
   SELECT StaffId, DepartmentId  
   FROM #temp;  
  
   SELECT * FROM @StaffDepartment;  
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
  
  