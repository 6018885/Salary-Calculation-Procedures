USE [payroll]
GO

/****** Object:  StoredProcedure [dbo].[CalculatePayroll]    Script Date: 9/12/2023 5:29:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[CalculatePayroll] (@Year INT, @Month INT)
AS
BEGIN
    DECLARE @SALARY FLOAT;
    DECLARE @HOUSING FLOAT;
    DECLARE @Transportation FLOAT;
    DECLARE @EMPID INT;

	-- CURSOR
    DECLARE CalculateAllPayroll CURSOR FOR
        SELECT EmployeeID, Salary, Housing, Transportation FROM AllEmployee;

    OPEN CalculateAllPayroll;
    FETCH NEXT FROM CalculateAllPayroll INTO @EMPID, @SALARY, @HOUSING, @Transportation;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO Payroll VALUES (@EMPID, @Year, @Month);

               DECLARE @EMPPayrollId INT;

        -- Get PayrollId
        SELECT @EMPPayrollId = PayrollId
        FROM Payroll
        WHERE EmployeeId = @EMPID AND Year = @Year AND Month = @Month;
       
		-- SALARY 
        INSERT INTO PayrollDetails VALUES (@EMPPayrollId, 1, 1, @SALARY);

		-- HOUSING
        IF @HOUSING > 0
        BEGIN
            INSERT INTO PayrollDetails VALUES (@EMPPayrollId, 1, 2, @HOUSING);
        END;
		--Transportation
        IF @Transportation > 0
        BEGIN
            INSERT INTO PayrollDetails VALUES (@EMPPayrollId, 1, 3, @Transportation);
        END;

        -- LEAVES
        DECLARE @LEAVES FLOAT = 0;
        EXEC CalculateLeaveDiscount @EMPID, @Year, @Month, @LEAVES OUTPUT;

        IF @LEAVES > 0
        BEGIN
            INSERT INTO PayrollDetails VALUES (@EMPPayrollId, 2, 4, @LEAVES);
        END;

        -- TAXS
        DECLARE @TAXS FLOAT = 0;
        EXEC CalculateTaxForEmployee @EMPID, @Year, @TAXS OUTPUT;

        IF @TAXS > 0
        BEGIN
            INSERT INTO PayrollDetails VALUES (@EMPPayrollId, 2, 5, @TAXS);
        END;

        -- SocialSecurityAmount
        DECLARE @SocialSecurityAmount DECIMAL(18, 2) = 0;
        EXEC CalculateSocialSecurityDeduction @EMPID, @Year, @SocialSecurityAmount OUTPUT;

        INSERT INTO PayrollDetails VALUES (@EMPPayrollId, 2, 6, @SocialSecurityAmount);
       

        -- AllovertimeHour
        DECLARE @AllovertimeHour FLOAT = 0;
        EXEC  CalculateOverTime @EMPID, @Year, @Month, @AllovertimeHour OUTPUT;

        IF @AllovertimeHour > 0
        BEGIN
            INSERT INTO PayrollDetails VALUES (@EMPPayrollId, 2, 7, @AllovertimeHour);
        END;

        FETCH NEXT FROM CalculateAllPayroll INTO @EMPID, @SALARY, @HOUSING, @Transportation;
    END;

    CLOSE CalculateAllPayroll;
    DEALLOCATE CalculateAllPayroll;
END;
GO


