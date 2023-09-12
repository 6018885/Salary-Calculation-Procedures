# Salary-Calculation-Procedures
This repository contains five stored procedures for calculating employee salaries:  CalculateAbsenceDays: To calculate the number of days of absence. 
CalculateOvertime: To calculate overtime. CalculateSocialSecurity: To calculate social security contributions. CalculateTax: To calculate taxes. CalculateTotalSalary: To sum all values together.
##CalculateLeaveDiscount
This stored procedure calculates the number of days of absence for an employee based on the provided parameters.
You can call this procedure using the following SQL query:
EXEC CalculateLeaveDiscount @EmployeeID int, @Year int , @Month int, @LEAVE FLOAT OUTPUT
But, you must know that there is a function that must be present to calculate the number of days of absence before the current month in order
to know whether the employee has exceeded the number of days of absence calculated or not, to know whether the deduction will be achieved or not.
Function name: ##AllLeaves

##CalculateOvertime procedure calculates the overtime pay for employees.
To utilize this procedure, use the following SQL query:
EXEC CalculateOvertime @EMPID int, @Year int, @Month int,@AllOvertimeHoure DECIMAL(18, 2) output

##CalculateSocialSecurity value, use the following SQL query:
EXEC CalculateSocialSecurity  @EmployeeID INT, @Year INT,@SocialSecurityAmount float OUTPUT

##CalculateTaxForEmployee
To calculate taxes, use the following SQL query:
EXEC CalculateTaxForEmployee @EmpID int, @Year int , @TAXS FLOAT OUTPUT

##CalculatePayroll 
In this procedure all procedures are called
To calculate the total salary, use the following SQL query:
EXEC CalculatePayroll @Year int, @Month int

