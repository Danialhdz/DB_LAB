--creating tables of db
IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'account'
)
BEGIN
    CREATE TABLE account (
        username VARCHAR(20) PRIMARY KEY,
        account_number CHAR(16) UNIQUE,
        password VARCHAR(500) NOT NULL,
        first_name VARCHAR(20) NOT NULL,
        last_name VARCHAR(20) NOT NULL,
        national_id CHAR(10) NOT NULL,
        date_of_birth DATE NOT NULL,
        type VARCHAR(8) CHECK (type IN ('client', 'employee')),
        interest_rate DECIMAL(4,2) -- SQL Server uses DECIMAL instead of NUMERIC
    );
END;

IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'login_log'
)
BEGIN
    CREATE TABLE login_log (
        username VARCHAR(20) NOT NULL,
        login_time DATETIME NOT NULL,
        FOREIGN KEY (username) REFERENCES account(username)
    );
END;


IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'transactions'
)
BEGIN
    CREATE TABLE transactions (
        type VARCHAR(8) NOT NULL,
        transaction_time DATETIME NOT NULL,
        from_account CHAR(16) NULL,
        to_account CHAR(16) NULL,
        amount DECIMAL(16,2) NOT NULL,
        CONSTRAINT type_check CHECK (
            (type IN ('deposit', 'withdraw', 'transfer', 'interest'))
            AND (
                ((type = 'deposit' OR type = 'interest') AND from_account IS NULL AND to_account IS NOT NULL)
                OR
                (type = 'withdraw' AND from_account IS NOT NULL AND to_account IS NULL)
                OR
                (type = 'transfer' AND from_account IS NOT NULL AND to_account IS NOT NULL)
            )
        )
    );
END;


-- Create the latest_balance table
IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'latest_balance'
)
BEGIN
    CREATE TABLE latest_balance (
        account_number CHAR(16) NOT NULL,
        amount DECIMAL(16,2) NOT NULL,
        FOREIGN KEY (account_number) REFERENCES account(account_number)
    );
END;

-- Create the snapshot_log table
IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'snapshot_log'
)
BEGIN
    CREATE TABLE snapshot_log (
        snapshot_id INT IDENTITY(1,1) PRIMARY KEY,
        snapshot_time DATETIME NOT NULL
    );
END;

IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'recent_events'
)
BEGIN
    CREATE TABLE recent_events (
        event_id INT IDENTITY(1,1) PRIMARY KEY,
        event_type VARCHAR(20) NOT NULL,
        event_time DATETIME NOT NULL,
        account_number CHAR(16) NOT NULL,
        amount DECIMAL(16,2),
        FOREIGN KEY (account_number) REFERENCES account(account_number)
    );
END;

IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'branches'
)
BEGIN
    CREATE TABLE branches (
		branch_id INT IDENTITY(1,1) PRIMARY KEY,
		branch_name VARCHAR(100) NOT NULL,
		address VARCHAR(255) NOT NULL,
		city VARCHAR(50) NOT NULL,
		state VARCHAR(50) NOT NULL,
		postal_code VARCHAR(20) NOT NULL,
		country VARCHAR(50) NOT NULL
    );
END;



