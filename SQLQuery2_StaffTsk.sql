USE StaffInfo
GO

  
CREATE OR ALTER  PROCEDURE SpStaffTsk  
@json NVARCHAR(MAX)  OUTPUT
AS  
 BEGIN  
 BEGIN TRY  
 BEGIN TRANSACTION  
  
  --Validate userperson 
 DECLARE @UserPersonId INT = JSON_VALUE(@JSON, '$.UserPersonId');  
 IF NOT EXISTS (SELECT 1 FROM UserPerson WHERE UserPersonId = @UserPersonId)  
 BEGIN  
 RAISERROR('Invalid Userperson. ALert!!!!! UserPersonId must be between range 1 to 5..',16,1)  
 END  
  
  --Validate departmentid
  IF EXISTS
		(
			SELECT 1 
			FROM OPENJSON(@json,'$.data')
			WITH
			(
				DepartmentId INT
			)
			WHERE DepartmentId  NOT BETWEEN 101 AND 110
		)
		BEGIN
			RAISERROR('INVALID Department Id!! It must be in range between 101 and 110',16,1);
			RETURN;
		END

-- Check middlename---
/**
IF EXISTS
(
	SELECT 1 FROM OPENJSON(@json,'$.data')
	WITH
	(
		StaffMiddleName NVARCHAR(200)
	)
	WHERE StaffMiddleName IS NULL
)
BEGIN
	RAISERROR('Middle name cannot be NULL. Therefore, provide a blank space  " " if not applicable.',16,1);
	RETURN;
END
*/


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
			 "StaffFirstName": "Fatima",
			 "StaffMiddleName": "Zehra",
			 "StaffLastName": "Syed",
			 "DateOfBirth": "1990-07-15",
			 "Position": "Database Administrator",
			 "HireDate": "2022-08-10",
			 "DepartmentId": 104,
			 "MobileNumber": "03009876543",
			 "Email": "fatima.syed@example.com",
			 "City": "Karachi",
			 "State": "Sindh",
			 "PostCode": "74000",
			 "Country": "Pakistan",
			 "InsertDate": "2025-05-26"
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
