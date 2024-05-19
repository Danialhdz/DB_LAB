----returns the account number of the last logged in user as the current user
--ALTER PROCEDURE get_current_user
--    @account_number CHAR(16) OUTPUT
--AS
--BEGIN
--    DECLARE @curr_username NVARCHAR(20);

--    -- get username of the latest login
--    SELECT TOP 1 @curr_username = l.username
--    FROM login_log AS l
--    ORDER BY l.login_time DESC;

--    -- get account number of the username
--    SELECT @account_number = a.account_number
--    FROM account AS a
--    WHERE a.username = @curr_username;
--END;

CREATE VIEW v_latest_login AS
SELECT 
    l.username,
    a.account_number,
    l.login_time
FROM 
    login_log AS l
JOIN 
    account AS a ON l.username = a.username
WHERE 
    l.login_time = (SELECT MAX(login_time) FROM login_log WHERE username = l.username);

CREATE PROCEDURE get_current_user
    @account_number CHAR(16) OUTPUT
AS
BEGIN
    DECLARE @curr_username NVARCHAR(20);

    -- get the latest login information using the view
    SELECT TOP 1 @curr_username = username, @account_number = account_number
    FROM v_latest_login
    ORDER BY login_time DESC;
END;
