CREATE DATABASE StaffINfo


SELECT * FROM UserPerson

CREATE TABLE UserPerson
(
	UserPersonId INT,
	UserPersonName NVARCHAR(200)
);


SELECT * FROM Staff

CREATE TABLE Staff
(
	StaffId INT IDENTITY(1,1) PRIMARY KEY,
	StaffFirstName NVARCHAR(200),
	StaffMiddleName NVARCHAR(200),
	StaffLastName NVARCHAR(200),
	DateOfBirth DATE,
	Position NVARCHAR(200),
	HireDate DATE,
	UserPersonId INT,
	InsertDate DATE DEFAULT GETDATE()
);

SELECT * from Department
CREATE TABLE Department
(
	DepartmentId INT IDENTITY(101,1),
	DepartmentName NVARCHAR(200),
	UserPersonId INT,
	InsertDate DATE
);


SELECT * FROM Address

CREATE TABLE Address
(
	AddressId INT,  
    City NVARCHAR(100),  
    State NVARCHAR(100),  
    PostalCode NVARCHAR(100),  
    Country VARCHAR(100),  
    UserPersonId INT,  
    InsertDate DATE
);

SELECT * FROM Contact

CREATE TABLE Contact
(
	ContactId INT,  
    MobileNumber NVARCHAR(100),  
    Email NVARCHAR(100),  
    UserPersonId INT,  
    InsertDate DATE 
);

SELECT * FROM StaffAddress

CREATE TABLE StaffAddress
(
	StaffAddressId INT,  
    StaffId INT,  
    AddressId INT  
);

SELECT * FROM StaffContact

CREATE TABLE StaffContact
(
	StaffContactId INT,  
    StaffId INT,  
    ContactId INT
);

SELECT * FROM StaffDepartment

CREATE TABLE StaffDepartment
(
	StaffDepartmentId INT,  
    StaffId INT,  
    DepartmentId INT
);


