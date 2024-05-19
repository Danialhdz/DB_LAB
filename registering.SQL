    -- Register new users

CREATE PROCEDURE register
    @password VARCHAR(500),
    @first_name VARCHAR(20),
    @last_name VARCHAR(20),
    @national_id CHAR(10),
    @date_of_birth DATE,
    @account_type VARCHAR(8),
    @interest_rate DECIMAL(4,2),
    @message VARCHAR(100) OUTPUT,
    @username VARCHAR(20) OUTPUT
AS
BEGIN
    DECLARE @age INT;
    DECLARE @account_number CHAR(16);

    SET @age = DATEDIFF(YEAR, @date_of_birth, GETDATE());

    EXEC get_account_number @account_number OUTPUT;
    EXEC get_username @last_name, @account_number, @username OUTPUT;

    IF @age < 13
    BEGIN
        SET @message = 'You are under age! (users age must be at least 13)';
    END
    ELSE
    BEGIN
        INSERT INTO account(
            username, account_number, password, first_name, last_name, national_id,
            date_of_birth, type, interest_rate)
        VALUES (
            @username, 
            @account_number, 
            CONVERT(VARCHAR(500), HASHBYTES('SHA2_256', @password), 2), 
            @first_name, 
            @last_name, 
            @national_id, 
            @date_of_birth, 
            @account_type, 
            @interest_rate
        );
        SET @message = 'account created successfully.';
    END
END;
GO


--login to account
--gets username and password
--and adds log to the login loges in successful logging in
CREATE PROCEDURE login
    @input_username VARCHAR(20),
    @password VARCHAR(50),
    @message VARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @correct_pass VARCHAR(500);
    DECLARE @input_pass VARCHAR(500);

    SELECT @correct_pass = [password]
    FROM account
    WHERE username = @input_username;

    SET @input_pass = CONVERT(VARCHAR(500), HASHBYTES('SHA2_256', @password), 2);

    IF @correct_pass IS NULL
    BEGIN
        SET @message = 'Invalid username. Account with username ' + @input_username + ' not found!';
    END
    ELSE IF @correct_pass <> @input_pass
    BEGIN
        SET @message = 'Incorrect password!';
    END
    ELSE
    BEGIN
        INSERT INTO login_log (username, login_time)
        VALUES (@input_username, GETDATE());
        SET @message = 'Logged in successfully.';
    END;
END;
