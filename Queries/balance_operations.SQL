CREATE TYPE TRANS AS TABLE (
    type NVARCHAR(8),
    amount DECIMAL(16, 2),
    from_account CHAR(16)
);


CREATE PROCEDURE update_balance
AS
BEGIN
    DECLARE @latest_update DATETIME;
    DECLARE @curr_account_number CHAR(16);

    -- get latest updates date
    SELECT @latest_update = snapshot_time
    FROM snapshot_log
    WHERE snapshot_id = (
        SELECT MAX(snapshot_id)
        FROM snapshot_log
    );

    DECLARE account_cursor CURSOR FOR
    SELECT account_number
    FROM latest_balance;

    OPEN account_cursor;
    FETCH NEXT FROM account_cursor INTO @curr_account_number;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- call the update balance procedure to update balance of each account
        EXEC update_balance1 @curr_account_number, @latest_update;

        FETCH NEXT FROM account_cursor INTO @curr_account_number;
    END;

    CLOSE account_cursor;
    DEALLOCATE account_cursor;

    -- save time of current update
    EXEC make_snapshot;
END;
GO

CREATE PROCEDURE update_balance1
    @curr_account_number VARCHAR(20),
    @latest_update DATETIME
AS
BEGIN
    DECLARE @new_balance NUMERIC(16, 2);

    DECLARE @trans_type VARCHAR(50);
    DECLARE @trans_amount NUMERIC(16, 2);
    DECLARE @trans_from_account VARCHAR(20);
    DECLARE trans_cursor CURSOR FOR
    SELECT type, amount, from_account
    FROM transactions
    WHERE transaction_time > @latest_update AND
          (from_account = @curr_account_number OR to_account = @curr_account_number)
    ORDER BY transaction_time DESC;

    SELECT @new_balance = amount
    FROM latest_balance
    WHERE account_number = @curr_account_number;

    OPEN trans_cursor;
    FETCH NEXT FROM trans_cursor INTO @trans_type, @trans_amount, @trans_from_account;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @trans_type = 'deposit'
        BEGIN
            SET @new_balance = @new_balance + @trans_amount;
            -- Insert into recent_events table
            INSERT INTO recent_events (event_type, event_time, account_number, amount)
            VALUES ('deposit', GETDATE(), @curr_account_number, @trans_amount);
        END
        ELSE IF @trans_type = 'withdraw'
        BEGIN
            SET @new_balance = @new_balance - @trans_amount;
            -- Insert into recent_events table
            INSERT INTO recent_events (event_type, event_time, account_number, amount)
            VALUES ('withdraw', GETDATE(), @curr_account_number, @trans_amount);
        END
        ELSE IF @trans_type = 'transfer'
        BEGIN
            IF @trans_from_account = @curr_account_number
            BEGIN
                SET @new_balance = @new_balance - @trans_amount;
                -- Insert into recent_events table
                INSERT INTO recent_events (event_type, event_time, account_number, amount)
                VALUES ('transfer_out', GETDATE(), @curr_account_number, @trans_amount);
            END
            ELSE
            BEGIN
                SET @new_balance = @new_balance + @trans_amount;
                -- Insert into recent_events table
                INSERT INTO recent_events (event_type, event_time, account_number, amount)
                VALUES ('transfer_in', GETDATE(), @curr_account_number, @trans_amount);
            END
        END
        ELSE -- assume type is 'interest'
        BEGIN
            SET @new_balance = @new_balance * (1 + @trans_amount);
            -- Insert into recent_events table
            INSERT INTO recent_events (event_type, event_time, account_number)
            VALUES ('interest', GETDATE(), @curr_account_number);
        END;

        FETCH NEXT FROM trans_cursor INTO @trans_type, @trans_amount, @trans_from_account;
    END;

    CLOSE trans_cursor;
    DEALLOCATE trans_cursor;

    -- update balance of current user
    UPDATE latest_balance
    SET amount = @new_balance
    WHERE account_number = @curr_account_number;
END;
GO

--makes snapshot of the latest update
CREATE PROCEDURE make_snapshot
AS
BEGIN
    INSERT INTO snapshot_log (snapshot_time)
    VALUES (GETDATE());
END;


--CREATE PROCEDURE check_balance
--    @curr_balance DECIMAL(16, 2) OUTPUT
--AS
--BEGIN
--    DECLARE @curr_account_number CHAR(16);

--    -- Get the current user's account number
--    EXEC get_current_user @curr_account_number OUTPUT;

--    -- Get the current balance for the current account number
--    SELECT @curr_balance = amount
--    FROM latest_balance
--    WHERE account_number = @curr_account_number;
--END;

CREATE VIEW v_latest_balance AS
SELECT 
    account_number, 
    amount
FROM 
    latest_balance;

CREATE PROCEDURE check_balance
    @curr_balance DECIMAL(16, 2) OUTPUT
AS
BEGIN
    DECLARE @curr_account_number CHAR(16);

    -- Get the current user's account number
    EXEC get_current_user @curr_account_number OUTPUT;

    -- Get the current balance for the current account number using the view
    SELECT @curr_balance = amount
    FROM v_latest_balance
    WHERE account_number = @curr_account_number;
END;
GO
