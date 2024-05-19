--CREATE PROCEDURE FindNearestBranch
--    @City VARCHAR(50)
--AS
--BEGIN
--    SET NOCOUNT ON;

--    IF EXISTS (SELECT 1 FROM branches WHERE city = @City)
--    BEGIN
--        SELECT branch_id, branch_name, address, city, state, postal_code, country
--        FROM branches
--        WHERE city = @City;
--    END
--    ELSE
--    BEGIN
--        PRINT 'No branches found in the specified city.';
--    END
--END;
--GO

CREATE VIEW v_branches AS
SELECT 
    branch_id, 
    branch_name, 
    address, 
    city, 
    state, 
    postal_code, 
    country
FROM 
    branches;

CREATE PROCEDURE FindNearestBranch
    @City VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM v_branches WHERE city = @City)
    BEGIN
        SELECT branch_id, branch_name, address, city, state, postal_code, country
        FROM v_branches
        WHERE city = @City;
    END
    ELSE
    BEGIN
        PRINT 'No branches found in the specified city.';
    END
END;
GO

