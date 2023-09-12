USE [payroll]
GO

/****** Object:  StoredProcedure [dbo].[CalculateOverTime]    Script Date: 9/12/2023 5:28:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CalculateOverTime] (@EMPID int, @Year int, @Month int,@AllOvertimeHoure DECIMAL(18, 2) output)
AS
BEGIN
    DECLARE @EMPName BIT = (SELECT OverTime FROM Classifications WHERE EmployeeID = @EMPID and endDate is null)

    IF @EMPName = 'false'
    BEGIN
        SELECT 'This employee does not take overtime'
        RETURN
    END

    DECLARE @OverTimeHour FLOAT;
    DECLARE @OverTimeDate DATE;
    DECLARE @OverTimeRate FLOAT;
    DECLARE @AllHours FLOAT = 0;

    --Modification required by the engineer
	DECLARE @OverTimeRateWeekend FLOAT = (SELECT OverTimeRateWeekend  FROM Rolls WHERE  YEAR = @Year) 

	--Modification required by the engineer
	DECLARE @Rate FLOAT =  (SELECT OverTimeRate FROM Rolls WHERE YEAR = @Year)



    DECLARE OverTimeCalc CURSOR FOR
        SELECT OverTimeHour, OverTimeDate
        FROM OverTime
        WHERE EmployeeID = @EMPID AND YEAR(OverTimeDate) = @Year AND MONTH(OverTimeDate) = @Month;

    OPEN OverTimeCalc;
    FETCH NEXT FROM OverTimeCalc INTO @OverTimeHour, @OverTimeDate;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF DATENAME(WEEKDAY, @OverTimeDate) IN ('Friday', 'Saturday')
            SET @OverTimeRate = @OverTimeHour * @OverTimeRateWeekend
        ELSE
            SET @OverTimeRate = @OverTimeHour * @Rate

        SET @AllHours = @AllHours + @OverTimeRate;

        FETCH NEXT FROM OverTimeCalc INTO @OverTimeHour, @OverTimeDate;
    END;

    CLOSE OverTimeCalc;
    DEALLOCATE OverTimeCalc;

	DECLARE @workHour FLOAT = (SELECT Workinghours FROM Rolls WHERE YEAR = @Year)
    SET @AllOvertimeHoure = (
        SELECT (Salary / 30 / @workHour) * @AllHours
        FROM Classifications
        WHERE EmployeeID = @EMPID AND endDate IS NULL
    );
END;
GO


