--returns the account number of the last logged in user as the current user
ALTER PROCEDURE get_current_user
    @account_number CHAR(16) OUTPUT
AS
BEGIN
    DECLARE @curr_username NVARCHAR(20);

    -- get username of the latest login
    SELECT TOP 1 @curr_username = l.username
    FROM login_log AS l
    ORDER BY l.login_time DESC;

    -- get account number of the username
    SELECT @account_number = a.account_number
    FROM account AS a
    WHERE a.username = @curr_username;
END;