CREATE OR ALTER PROCEDURE USPGetUserPrivileges
 (
     @UserID INT
 )
 AS
 /***********************************************
 Purpose:       Get the privileges for a user based on their role

 Input Params: @UserID - ID of the user
 
 History:
 -----------------------------------------------
 Date         Author      Description   
 26-12-2025   Chandan     Created procedure

 ************************************************/
 BEGIN
    DECLARE @RoleID INT

    SELECT @RoleID = URM.RoleID
    FROM UsertoRoleMapping URM
    WHERE IsDeletedBit = 0 AND IsActiveBit = 1 AND URM.UserID = @UserID

    SELECT R.RoleCode, R.RoleName, P.PrivilegeCode, P.PrivilegeName, P.PrivilegeOrder, P.ParentPrivilegeID
    FROM RoletoPrivilegeMapping RTP
        INNER JOIN Roles R on R.RoleID = RTP.RoleID
        INNER JOIN Privileges P ON P.PrivilegeID = RTP.PrivilegeID
    WHERE RTP.RoleID = @RoleID
    ORDER BY P.ParentPrivilegeID, P.PrivilegeOrder

 END