USE [payroll]
GO

/****** Object:  UserDefinedFunction [dbo].[AllLeaves]    Script Date: 9/12/2023 6:11:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[AllLeaves] (@EmployeeID INT, @Year INT , @MONTH INT)
RETURNS INT
AS
BEGIN
    DECLARE @OverallLeaveDuration INT;
    DECLARE @StartDate DATE;
    DECLARE @EndDate DATE;

    DECLARE @AllLeaves TABLE (LeaveDate DATE);

    DECLARE AllLeavesPerYear CURSOR FOR
    SELECT StartDate, EndDate FROM Leaves
    WHERE EmployeeID = @EmployeeID AND YEAR(StartDate) = @Year AND MONTH(StartDate) < @MONTH;

    OPEN AllLeavesPerYear;
    FETCH NEXT FROM AllLeavesPerYear INTO @StartDate, @EndDate;

    WHILE @@FETCH_STATUS = 0 
    BEGIN
        WHILE @StartDate <= @EndDate 
        BEGIN
            IF DATENAME(DW, @StartDate) NOT IN ('FRIDAY', 'SATURDAY')
            BEGIN 
                INSERT INTO @AllLeaves (LeaveDate) VALUES (@StartDate);
            END;

            SET @StartDate = DATEADD(DAY, 1, @StartDate);
        END;

        FETCH NEXT FROM AllLeavesPerYear INTO @StartDate, @EndDate;
    END;

    CLOSE AllLeavesPerYear;
    DEALLOCATE AllLeavesPerYear;

    SELECT @OverallLeaveDuration = COUNT(*) FROM @AllLeaves;

    RETURN @OverallLeaveDuration;
END;


GO


