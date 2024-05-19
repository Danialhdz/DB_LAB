
--this function sets employees interest rate to zero
--and creates balance for account in latest balance table
-- Procedure to set interest rate and insert initial balance
CREATE PROCEDURE complete_fields
    @username VARCHAR(20),
    @account_number CHAR(16)
AS
BEGIN
    -- Set interest rate of employees to zero
    UPDATE account
    SET interest_rate = 0
    WHERE username = @username AND [type] = 'employee';

    -- Insert balance for account
    INSERT INTO latest_balance (account_number, amount) VALUES (@account_number, 0.00);
END;
GO



-- Procedure to generate username
CREATE PROCEDURE get_username
    @last_name VARCHAR(15),
    @account_number CHAR(16),
    @username VARCHAR(20) OUTPUT
AS
BEGIN
    SET @username = @last_name + SUBSTRING(@account_number,6,5);
END;
GO

-- Procedure to generate account number based on current timestamp
CREATE PROCEDURE get_account_number
    @account_number CHAR(16) OUTPUT
AS
BEGIN
    DECLARE @seconds BIGINT;
    SET @seconds = CAST(CAST(DATEDIFF(SECOND, '1970-01-01', SYSDATETIME()) AS BIGINT) * 1000000 AS BIGINT);
    SET @account_number = CAST(@seconds AS CHAR(16));
END;
GO

-- Trigger to call complete_fields procedure after insert
CREATE TRIGGER account_insertion
ON account
AFTER INSERT
AS
BEGIN
    DECLARE @username VARCHAR(20);
    DECLARE @account_number CHAR(16);

    SELECT @username = inserted.username, @account_number = inserted.account_number
    FROM inserted;

    EXEC complete_fields @username, @account_number;
END;
GO
