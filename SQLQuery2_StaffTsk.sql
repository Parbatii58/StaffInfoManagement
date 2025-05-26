USE StaffInfo
GO

  
CREATE OR ALTER  PROCEDURE SpStaffTsk  
@json NVARCHAR(MAX)  OUTPUT
AS  
 BEGIN  
 BEGIN TRY  
 BEGIN TRANSACTION  
  
 DECLARE @UserPersonId INT = JSON_VALUE(@JSON, '$.UserPersonId');  
 IF NOT EXISTS (SELECT 1 FROM UserPerson WHERE UserPersonId = @UserPersonId)  
 BEGIN  
 RAISERROR('Invalid Userperson. ALert!!!!!',16,1)  
 END  
  
 EXEC SpStaffIns @json = @json OUTPUT;  
 EXEC SpAddressIns @json = @json OUTPUT;  
 EXEC SpContactIns @json = @json OUTPUT;  
 EXEC SpStaffAddressIns @json;  
 EXEC SpStaffContactIns @json;  
 EXEC SpStaffDepartmentIns @json;  
  
 COMMIT TRANSACTION  
 END TRY  
  
 BEGIN CATCH  
  
 IF @@TRANCOUNT > 0  
 BEGIN  
 ROLLBACK;  
 END  
 DECLARE @ErrorLine INT;  
 DECLARE @ErrorProcedure NVARCHAR(200);  
 DECLARE @ErrorMessage NVARCHAR(200);  
   
 SELECT @ErrorLine = ERROR_LINE();  
 SELECT @ErrorMessage = ERROR_PROCEDURE();  
 SELECT @ErrorMessage = ERROR_MESSAGE();  
  
 PRINT 'Line with error:' + CAST(@ErrorLine AS NVARCHAR);  
 PRINT 'Procedure with error:' + ISNULL(@ErrorMessage, 'UNKNOWN');  
 PRINT 'Error message:' + @ErrorMessage;  
 RAISERROR (@ErrorMessage,16,1);  
  
 END CATCH  
END  


/***
Make sure departmentId MUST BE FROM :  101 to 110
AND		  UserPersonId MUST BE FROM :  1   to 5
***/
DECLARE @json NVARCHAR(MAX) = N'
{
  "UserPersonId": 1,
  "data": [
    {
      "StaffFirstName": "Ahmed",
      "StaffMiddleName": "Raza",
      "StaffLastName": "Khan",
      "DateOfBirth": "1992-03-10",
      "Position": "Data Analyst",
      "HireDate": "2023-03-01",
      "DepartmentId": 106,
      "MobileNumber": "03001234567",
      "Email": "ahmed.khan@example.com",
      "City": "Lahore",
      "State": "Punjab",
      "PostCode": "54000",
      "Country": "Pakistan",
      "InsertDate": "2025-05-22"
    },
    {
      "StaffFirstName": "Fatima",
      "StaffMiddleName": "",
      "StaffLastName": "Siddiqui",
      "DateOfBirth": "1995-08-25",
      "Position": "System Administrator",
      "HireDate": "2022-09-12",
      "DepartmentId": 108,
      "MobileNumber": "03111234567",
      "Email": "fatima.siddiqui@example.com",
      "City": "Karachi",
      "State": "Sindh",
      "PostCode": "74000",
      "Country": "Pakistan",
      "InsertDate": "2025-05-22"
    }
  ]
}
'
EXEC SpStaffTsk @json;




SELECT * FROM Staff
SELECT * FROM Address
SELECT * FROM Contact
SELECT * FROM StaffAddress
SELECT * FROM StaffContact
SELECT * FROM StaffDepartment

SELECT * FROM UserPerson
