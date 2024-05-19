Alter PROCEDURE deposit
    @amount DECIMAL(16,2),
    @message VARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @account_number CHAR(16);

    -- Get account number of current user
    EXEC get_current_user @account_number OUTPUT;

    INSERT INTO transactions (
        type,
        transaction_time,
        from_account,
        to_account,
        amount
    )
    VALUES (
        'deposit',
        GETDATE(),
        NULL,
        @account_number,
        @amount
    );
	EXEC update_balance;
    SET @message = 'Deposit transaction done | amount: ' + CONVERT(VARCHAR(16), @amount) + ' | to ' + @account_number;
END;



ALTER PROCEDURE withdraw
    @amount DECIMAL(16, 2),
    @message NVARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @username NVARCHAR(20);
    DECLARE @account_number CHAR(16);

    -- get account number of current user
    EXEC get_current_user @account_number OUTPUT;

    INSERT INTO transactions (
        type,
        transaction_time,
        from_account,
        to_account,
        amount
    ) VALUES (
        'withdraw',
        GETDATE(),
        @account_number,
        NULL,
        @amount
    );
	EXEC update_balance;
    SET @message = 'Withdraw transaction done | amount: ' + CAST(@amount AS NVARCHAR(16)) + ' | from ' + @account_number;
END;


ALTER PROCEDURE transfer
    @amount DECIMAL(16, 2),
    @to_username NVARCHAR(20),
    @message NVARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @username NVARCHAR(20);
    DECLARE @account_number CHAR(16);
    DECLARE @to_account CHAR(16);

    -- get account number of current user
    EXEC get_current_user @account_number OUTPUT;

    -- get account number of destination account
    SELECT @to_account = a.account_number
    FROM account AS a
    WHERE a.username = @to_username;

    IF @to_account IS NOT NULL
    BEGIN
        INSERT INTO transactions (
            type,
            transaction_time,
            from_account,
            to_account,
            amount
        ) VALUES (
            'transfer',
            GETDATE(),
            @account_number,
            @to_account,
            @amount
        );

		EXEC update_balance;
        SET @message = 'Transfer transaction done | amount: ' + CAST(@amount AS NVARCHAR(16)) + ' | from ' + @account_number + ' | to ' + @to_account;
    END
    ELSE
    BEGIN
        SET @message = 'Transaction failed! There is no account with username: ' + @to_username;
    END
END;


ALTER PROCEDURE interest_payment
    @message NVARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @username NVARCHAR(20);
    DECLARE @curr_account_number CHAR(16);
    DECLARE @curr_interest_rate DECIMAL(4, 2);

    -- get account number of current user
    EXEC get_current_user @curr_account_number OUTPUT;

    SELECT @curr_interest_rate = interest_rate
    FROM account
    WHERE account_number = @curr_account_number;

    INSERT INTO transactions (
        type,
        transaction_time,
        from_account,
        to_account,
        amount
    ) VALUES (
        'interest',
        GETDATE(),
        NULL,
        @curr_account_number,
        @curr_interest_rate
    );

	EXEC update_balance;
    SET @message = 'Interest payment done | rate: ' + CAST(@curr_interest_rate AS NVARCHAR(4)) + ' | to ' + @curr_account_number;
END;

