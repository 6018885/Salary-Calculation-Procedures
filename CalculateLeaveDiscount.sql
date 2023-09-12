USE [payroll]
GO

/****** Object:  StoredProcedure [dbo].[CalculateLeaveDiscount]    Script Date: 9/12/2023 5:27:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CalculateLeaveDiscount] (@EmployeeID INT, @Year INT, @Month INT , @LEAVE FLOAT OUTPUT)
AS
BEGIN
    DECLARE @StartDate DATE;
    DECLARE @EndDate DATE;
    DECLARE @MonthlyLeaveCount INT = 0;

    DECLARE @AnnualLeaves INT = (
        SELECT annual
        FROM Classifications
        WHERE EmployeeID = @EmployeeID
            AND endDate IS NULL
    );

    -- ALLLeaves
    DECLARE @OverallLeaveDuration INT;
    SET @OverallLeaveDuration = dbo.AllLeaves(@EmployeeID, @Year, @Month);
    SELECT @OverallLeaveDuration;

    DECLARE LeaveDiscountCursor CURSOR FOR
        SELECT StartDate, EndDate
        FROM Leaves
        WHERE EmployeeID = @EmployeeID
            AND YEAR(StartDate) = @Year
            AND MONTH(StartDate) = @Month;

    OPEN LeaveDiscountCursor;
    FETCH NEXT FROM LeaveDiscountCursor INTO @StartDate, @EndDate;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @LeaveDuration INT = 0;

        --ANOTHER LOOP
        WHILE @StartDate <= @EndDate
        BEGIN
            IF DATENAME(DW, @StartDate) NOT IN ('FRIDAY', 'SATURDAY')
            BEGIN
                SET @LeaveDuration = @LeaveDuration + 1;
                
                --annual
                IF @OverallLeaveDuration < @AnnualLeaves
                BEGIN
                    SET @LeaveDuration = @LeaveDuration - 1;
                    SET @OverallLeaveDuration = @OverallLeaveDuration + 1;
                END
            END;

            SET @StartDate = DATEADD(DAY, 1, @StartDate);
        END;

        SET @MonthlyLeaveCount = @MonthlyLeaveCount + @LeaveDuration;
        FETCH NEXT FROM LeaveDiscountCursor INTO @StartDate, @EndDate;
    END;

    CLOSE LeaveDiscountCursor;
    DEALLOCATE LeaveDiscountCursor;

    DECLARE @SalaryPerDay FLOAT = (
        SELECT Salary / 30
        FROM Classifications
        WHERE EmployeeID = @EmployeeID
            AND endDate IS NULL
    );

    SET @LEAVE = @MonthlyLeaveCount * @SalaryPerDay;
END;
GO


