select * from customerinfo;
select * from bank;
ALTER TABLE customerinfo
RENAME COLUMN ï»¿CustomerId TO CustomerId;

#1.Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
	Select 
		CustomerID,Surname,EstimatedSalary ,Date_of_joining from
	(
	select 
		CustomerID,Surname,EstimatedSalary ,Date_of_joining,
		rank() over(partition by year(Date_of_joining) order by EstimatedSalary desc) ranking
		from customerinfo
		where month(Date_of_joining) BETWEEN 10 AND 12)x
	where ranking <6 order by Date_of_joining;

#2.Calculate the average number of products used by customers who have a credit card. (SQL)
	select avg(NumOfProducts) 
    from bank 
    where HasCrCard="credit card holder";
    
#3.Compare the average credit score of customers who have exited and those who remain. (SQL)  
	SELECT
		CASE
        WHEN Exited = 'Exit' THEN 'Exited'
        ELSE 'Retain'
		END AS customer_status,
    AVG(CreditScore) AS average_credit_score 
    FROM bank 
    GROUP BY customer_status;

#4.Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
	SELECT c.Gender, ROUND(avg(c.EstimatedSalary),4) as avg_sal 
    from customerinfo c join bank b on c.CustomerId=b.CustomerId 
	where b.IsActiveMember = "Active Member" 
    group by Gender 
    order by avg_sal desc limit 1;

#5.Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
	SELECT
    credit_score_segment,
    SUM(CASE WHEN Exited = 'Exit' THEN 1 ELSE 0 END) AS exited_count,
    COUNT(*) AS total_count,
    round(CAST(SUM(CASE WHEN Exited = 'Exit' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*),4) AS exit_rate
	FROM (
    SELECT
        CASE
            WHEN CreditScore < 600 THEN 'Poor'
            WHEN CreditScore >= 600 AND CreditScore < 700 THEN 'Fair'
            WHEN CreditScore >= 700 AND CreditScore < 800 THEN 'Good'
            ELSE 'Excellent'
        END AS credit_score_segment, Exited FROM bank) AS segmented_data
	GROUP BY credit_score_segment 
    ORDER BY exit_rate DESC LIMIT 1;

#6.Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
	select c.Geography ,count(b.IsActiveMember) as ActiveMember 
	from bank b join customerinfo c ON b.CustomerId=c.CustomerId 
	where b.Tenure>5 and b.IsActiveMember='Active Member' 
	group by c.Geography 
	order by ActiveMember desc limit 1;

#7.Examine the trend of customer joining over time and identify any seasonal patterns (yearly or monthly).
# Prepare the data through SQL and then visualize it.
	#YEARLY trend of customer joining
	SELECT
		YEAR(Date_of_joining) 'Year', COUNT(CustomerId) 'Customer_Joining'
	FROM customerinfo 
    GROUP BY YEAR(Date_of_joining) 
    ORDER BY COUNT(CustomerId) DESC;
	#MONTHLY trend of customer joining
	SELECT
		YEAR(Date_of_joining) 'YEAR',
		MONTH(Date_of_joining) 'MONTH',
		COUNT(CustomerId) 'Customer_Joining'
	FROM customerinfo
	GROUP BY YEAR(Date_of_joining) , MONTH(Date_of_joining) 
    ORDER BY YEAR ASC , MONTH ASC;

#8.Using SQL, write a query to find out the gender wise average income of male and female in each geography id. 
#  Also rank the gender according to the average value. (SQL)
	select 
		Geography,Gender,avg(EstimatedSalary) as avg_salary,
		rank()over(partition by Geography order by avg(EstimatedSalary) desc) as Gender_Rank 
    from customerinfo 
    group by 1,2;

#9.Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
	select 
		case 
		when c.Age between 18 and 30 then '18-30'
		when c.Age between 30 and 50 then '30-50'
		else '50+' end as Age_Bracket, avg(b.Tenure) as Avg_Tenure 
	from bank b join customerinfo c on b.CustomerId=c.CustomerId 
    where b.Exited='Exit' 
    group by 
	case 
		when c.Age between 18 and 30 then '18-30' 
		when c.Age between 30 and 50 then '30-50'
		else '50+' end order by Age_Bracket;
    
#10.Rank each bucket of credit score as per the number of customers who have churned the bank.
	SELECT CreditScoreBucket, COUNT(CustomerID) AS Customers,
    RANK() OVER (ORDER BY COUNT(CustomerID) DESC) AS CreditScoreRank
	FROM ( SELECT
        CASE
            WHEN CreditScore BETWEEN 300 AND 500 THEN 'Poor'
            WHEN CreditScore BETWEEN 501 AND 600 THEN 'Fair'
            WHEN CreditScore BETWEEN 601 AND 700 THEN 'Good'
            WHEN CreditScore BETWEEN 701 AND 800 THEN 'Very Good'
            WHEN CreditScore BETWEEN 801 AND 850 THEN 'Excellent'
            ELSE 'Unknown' END AS CreditScoreBucket,CustomerID
	FROM bank WHERE Exited = 'Exit') AS ChurnedCustomersByCreditScore 
    GROUP BY CreditScoreBucket;

#11.According to the age buckets find the number of customers who have a credit card. 
#   Also retrieve those buckets who have lesser than average number of credit cards per bucket.
	WITH AgeBucketCounts AS (
    SELECT
        CASE
            WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN c.Age BETWEEN 31 AND 50 THEN '31-50'
            ELSE '50+'
        END AS Age_Bracket,
        COUNT(DISTINCT b.CustomerId) AS Number_Customers,
        AVG(COUNT(DISTINCT b.CustomerId)) OVER () AS Average_Customers
    FROM bank b 
    JOIN customerinfo c ON b.CustomerId = c.CustomerId
    WHERE b.HasCrCard = 'credit card holder'
    GROUP BY Age_Bracket
	)
	SELECT Age_Bracket,Number_Customers 
    FROM AgeBucketCounts
	WHERE Number_Customers < Average_Customers;
    
#12.Rank the Locations as per the number of people who have churned the bank and average balance of the learners.
	select Geography,CUST_CHURNED ,
	rank() over(order by CUST_CHURNED desc ) as  "RANK_CUST_CHURN"
	from (
		select c.Geography,count(b.Exited) CUST_CHURNED
	from bank b
	join customerinfo c on b.CustomerId = c.CustomerId
	where b.Exited = "Exit"
	group by c.Geography)x;
#Rank the Locations as per the  average balance of the learners.
	select Geography,CUST_AVG_BAL ,
	rank() over(order by CUST_AVG_BAL desc ) as  "RANK_CUST_AVG_BAL"
	from (
		select c.Geography,avg(b.Balance) CUST_AVG_BAL
	from bank b join customerinfo c on b.CustomerId = c.CustomerId
	group by c.Geography)x;
    
#13. As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the 
#    primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.
	 select concat(b.CustomerId,"_", c.Surname) as CustomerID_Surname 
     from bank b join Customerinfo c on b.CustomerId=c.customerId
    
#14. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
	
    #For solving this question we import the question23_bank and question23_exitcustomer file in csv format and run the query on that table.
	#First method using Case
		select 
			case when Exited=0 then 'Exit'
			else 'Retain' end as Exited
		from question23_bank;
    #Second Method using Update
		UPDATE question23_bank
          set Exited = "Exit"
          where Exited = "1";
          UPDATE question23_bank
          set Exited = "Retain"
          where Exited = "0";

#15.Write the query to get the customer ids, their last name and whether they are active or not for the customers 
#   whose surname  ends with “on”.
	select 
		CustomerId, Surname 
	from customerinfo 
    where Surname like '%on';
    
 # 9th question from subjective.
 -- Segment customers based on age groups and calculate the average account balance for each group
SELECT
    CASE
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN Age BETWEEN 41 AND 50 THEN '41-50'
        ELSE '51+'
    END AS Age_Group,
    COUNT(*) AS Total_Customers,
    round(AVG(Balance),2) AS Avg_Balance
FROM bank b join customerinfo c on b.CustomerId=c.CustomerId
GROUP BY Age_Group
ORDER BY Age_Group;
-- Segment customers based on gender and calculate the number of accounts for each gender
SELECT
    Gender,
    COUNT(DISTINCT customerId) AS Total_Accounts
FROM customerinfo
GROUP BY Gender;
-- Segment customers based on geographic location.
SELECT
    Geography,
    COUNT(*) AS Total_Customers
FROM customerinfo
GROUP BY Geography
ORDER BY Geography;

# 14th question from subjective
ALTER TABLE Bank
RENAME COLUMN HasCrCard TO Has_creditcard;
 