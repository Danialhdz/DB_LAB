--DECLARE @password VARCHAR(500) = '1234',
--        @first_name VARCHAR(20) = 'danesh',
--        @last_name VARCHAR(20) = 'danesh',
--        @national_id CHAR(10) = '1234567891',
--        @date_of_birth DATE = '2002-05-15',
--        @account_type VARCHAR(8) = 'client',
--        @interest_rate DECIMAL(4,2) = 0.2,
--        @message VARCHAR(100),
--        @username VARCHAR(20);

--DECLARE @password VARCHAR(500) = '123456',
--        @first_name VARCHAR(20) = 'asghar',
--        @last_name VARCHAR(20) = 'akbar',
--        @national_id CHAR(10) = '9896543210',
--        @date_of_birth DATE = '1991-11-25',
--        @account_type VARCHAR(8) = 'client',
--        @interest_rate DECIMAL(4,2) = 0.1,
--        @message VARCHAR(100),
--        @username VARCHAR(20);

--DECLARE @password VARCHAR(500) = '12345',
--        @first_name VARCHAR(20) = 'danial',
--        @last_name VARCHAR(20) = 'hadi',
--        @national_id CHAR(10) = '9876543210',
--        @date_of_birth DATE = '2003-05-25',
--        @account_type VARCHAR(8) = 'client',
--        @interest_rate DECIMAL(4,2) = 0.7,
--        @message VARCHAR(100),
--        @username VARCHAR(20);

DECLARE @password VARCHAR(500) = '1111',
        @first_name VARCHAR(20) = 'Amireza',
        @last_name VARCHAR(20) = 'Gholi',
        @national_id CHAR(10) = '9986543210',
        @date_of_birth DATE = '2003-05-25',
        @account_type VARCHAR(8) = 'employee',
        @interest_rate DECIMAL(4,2) = 0.3,
        @message VARCHAR(100),
        @username VARCHAR(20);

-- Declare output parameters
DECLARE @output_message VARCHAR(100),
        @output_username VARCHAR(20);

-- Call the stored procedure
EXEC register 
    @password = @password,
    @first_name = @first_name,
    @last_name = @last_name,
    @national_id = @national_id,
    @date_of_birth = @date_of_birth,
    @account_type = @account_type,
    @interest_rate = @interest_rate,
    @message = @output_message OUTPUT,
    @username = @output_username OUTPUT;

-- Assign output parameter values to variables
SET @message = @output_message;
SET @username = @output_username;

-- Display output
SELECT @message AS [Message],
       @username AS [Username];



DECLARE @message VARCHAR(100);
-- Execute the login stored procedure with valid credentials
EXEC login @input_username = 'danesh61692', @password = '1234', @message = @message OUTPUT;
PRINT @message;


DECLARE @message VARCHAR(100);
-- Execute the login stored procedure with valid credentials
EXEC login @input_username = 'hadi61633', @password = '12345', @message = @message OUTPUT;
PRINT @message;



-- Declare output variable for account number
DECLARE @account_number CHAR(16);
-- Execute the get_current_user stored procedure
EXEC get_current_user @account_number OUTPUT;
-- Print the account number of the last logged in user
PRINT 'Current user account number: ' + @account_number;


select * from account
select * from login_log



DECLARE @amount DECIMAL(16, 2) = 100.00;
DECLARE @message VARCHAR(100);
EXEC deposit @amount, @message OUTPUT;
SELECT @message AS [Transaction Message];



DECLARE @amount DECIMAL(16, 2) = 50.00;
DECLARE @to_username NVARCHAR(20) = 'danesh61692';
DECLARE @message NVARCHAR(100);
EXEC transfer 
    @amount = @amount,
    @to_username = @to_username,
    @message = @message OUTPUT;
SELECT @message AS [Message];



DECLARE @message NVARCHAR(100);
EXEC interest_payment 
    @message = @message OUTPUT;
SELECT @message AS [Message];



-- Call the make_snapshot procedure
EXEC make_snapshot;
-- Verify the insertion
SELECT * FROM snapshot_log;



DECLARE @currentBalance DECIMAL(16, 2);
EXEC check_balance @currentBalance OUTPUT;
SELECT @currentBalance AS CurrentBalance;

select * from latest_balance
select * from recent_events


DROP table latest_balance
DROP table login_log
DROP table transactions
DROP table snapshot_log
DROP table branches
DROP table recent_events
DROP table account


INSERT INTO branches (branch_name, address, city, state, postal_code, country)
VALUES
('Downtown Branch', '123 Main St', 'New York', 'NY', '10001', 'USA'),
('Uptown Branch', '456 Elm St', 'New York', 'NY', '10011', 'USA'),
('Central Branch', '789 Maple Ave', 'Los Angeles', 'CA', '90001', 'USA'),
('Westside Branch', '101 Pine St', 'Los Angeles', 'CA', '90011', 'USA'),
('Eastside Branch', '202 Oak St', 'Chicago', 'IL', '60601', 'USA'),
('Southside Branch', '303 Birch St', 'Chicago', 'IL', '60611', 'USA'),
('Northside Branch', '404 Cedar St', 'Houston', 'TX', '77001', 'USA'),
('Midtown Branch', '505 Spruce St', 'Houston', 'TX', '77011', 'USA'),
('City Center Branch', '606 Ash St', 'Miami', 'FL', '33101', 'USA'),
('Beachside Branch', '707 Palm St', 'Miami', 'FL', '33111', 'USA');

EXEC FindNearestBranch @City = 'New York';


