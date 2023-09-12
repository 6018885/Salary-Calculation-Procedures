USE [payroll]
GO

/****** Object:  StoredProcedure [dbo].[CalculateSocialSecurityDeduction]    Script Date: 9/12/2023 5:28:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CalculateSocialSecurityDeduction]
    @EmployeeID INT,
    @Year INT,
    @SocialSecurityAmount float OUTPUT
AS

    DECLARE @salary FLOAT = (SELECT salary FROM Classifications WHERE @EmployeeID = EmployeeID AND EndDate IS NULL)
    DECLARE @Social_Security FLOAT = (SELECT ScocialSecurity FROM ROlLs WHERE Year = @Year)
	BEGIN
    SET @SocialSecurityAmount = @salary * @Social_Security
END
GO


