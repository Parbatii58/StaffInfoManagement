/** To backup  **/

BACKUP DATABASE StaffInfo
TO DISK = 'C:\BACKUP_SSMS\StaffInfo.bak'
WITH FORMAT,
     MEDIANAME = 'StaffManagement_BackupDrive',
     NAME = 'Full Backup of Staff Management Database - May 22, 2025';

/** To recover  **/

RESTORE DATABASE StaffInfo
FROM DISK = 'C:\BACKUP_SSMS\StaffInfo.bak';