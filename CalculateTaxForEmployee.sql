USE [payroll]
GO

/****** Object:  StoredProcedure [dbo].[CalculateTaxForEmployee]    Script Date: 9/12/2023 5:29:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CalculateTaxForEmployee] (@EmpID int, @Year int , @TAXS FLOAT OUTPUT)
AS
BEGIN
    DECLARE @Salary float = 12 * (SELECT Salary FROM Classifications WHERE EmployeeID = @EmpID AND endDate IS NULL);
    DECLARE @Housing float = 12 * (SELECT Housing FROM Classifications WHERE EmployeeID = @EmpID AND endDate IS NULL);
    DECLARE @Transportation float = 12 * (SELECT Transportation FROM Classifications WHERE EmployeeID = @EmpID AND endDate IS NULL);
    DECLARE @TotalSalaryPerYear float = @Salary + @Housing + @Transportation;
    
    IF @TotalSalaryPerYear <= 9000
    BEGIN
        SELECT 'This employee does not apply to the tax' AS Message;
        RETURN;
    END

    DECLARE @Income DECIMAL(18,2) = @TotalSalaryPerYear;
    DECLARE @TaxAmount DECIMAL(18,2) = 0;

    IF @Income <= 14000
        SET @TaxAmount = (@Income - 9000) * 0.05;
    ELSE IF @Income <= 19000
        SET @TaxAmount = 5000 * 0.05 + (@Income - 14000) * 0.1;
    ELSE IF @Income <= 24000
        SET @TaxAmount = 5000 * 0.05 + 5000 * 0.1 + (@Income - 19000) * 0.15;
    ELSE IF @Income <= 29000
        SET @TaxAmount = 5000 * 0.05 + 5000 * 0.1 + 5000 * 0.15 + (@Income - 24000) * 0.2;
    ELSE IF @Income <= 34000
        SET @TaxAmount = 5000 * 0.05 + 5000 * 0.1 + 5000 * 0.15 + 5000 * 0.2 + (@Income - 29000) * 0.25;

    SET  @TAXS = @TaxAmount / 12  ;
END
GO


