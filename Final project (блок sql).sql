CREATE DATABASE customers_transactions;

update customers set Gender = NULL where Gender = '';

update customers set Age = NULL where Age = '';

Alter table customers modify Age INT NULL;

Select * from customers;

Show Variables like 'secure_file_priv';


DROP TABLE transactions;

CREATE TABLE transactions (
    Date_new DATE,
    Id_check INT,
    ID_client INT,
    Count_products DECIMAL(10,3),
    Sum_payment DECIMAL(10,2)
);

Show Variables like 'secure_file_priv';

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TRANSACTIONS_Kuralay3.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 rows;


# 1 task

SELECT ID_client, DATE_FORMAT(Date_new, '%Y-%m') AS month
FROM transactions;


WITH months AS (SELECT ID_client, DATE_FORMAT(Date_new, '%Y-%m') AS ym
FROM transactions
GROUP BY ID_client, ym),
full_year_clients AS (SELECT ID_client
FROM months
GROUP BY ID_client
HAVING COUNT(*) = 12)
SELECT t.ID_client, AVG(t.Sum_payment) AS avg_check,
SUM(t.Sum_payment) / 12 AS avg_monthly_spend,
COUNT(*) AS total_operations
FROM transactions t
JOIN full_year_clients f
    ON t.ID_client = f.ID_client
GROUP BY t.ID_client;


# 2 task
# a)
SELECT DATE_FORMAT(Date_new, '%Y-%m') AS month,
    AVG(Sum_payment) AS avg_check
FROM transactions
GROUP BY month
ORDER BY month;

# b)
SELECT DATE_FORMAT(Date_new, '%Y-%m') AS month,
    COUNT(*) AS operations
FROM transactions
GROUP BY month
ORDER BY month;

# c)
SELECT DATE_FORMAT(Date_new, '%Y-%m') AS month,
    COUNT(DISTINCT ID_client) AS active_clients
FROM transactions
GROUP BY month
ORDER BY month;

#d)
WITH monthly AS (SELECT DATE_FORMAT(Date_new, '%Y-%m') AS month,
        COUNT(*) AS ops,
        SUM(Sum_payment) AS sum_pay
FROM transactions
GROUP BY DATE_FORMAT(Date_new, '%Y-%m')
),
totals AS (SELECT SUM(ops) AS total_ops,
        SUM(sum_pay) AS total_sum
FROM monthly)
SELECT m.month, m.ops, m.sum_pay, m.ops / t.total_ops AS ops_share,
		m.sum_pay / t.total_sum AS sum_share
FROM monthly m
CROSS JOIN totals t
ORDER BY m.month;


# e)
SELECT DATE_FORMAT(t.Date_new, '%Y-%m') AS month,
    c.Gender,
    COUNT(*) AS ops,
    SUM(t.Sum_payment) AS spend,
    COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY DATE_FORMAT(t.Date_new, '%Y-%m')) AS gender_share_ops,
    SUM(t.Sum_payment) / SUM(SUM(t.Sum_payment)) OVER (PARTITION BY DATE_FORMAT(t.Date_new, '%Y-%m')) AS gender_share_spend
FROM transactions t
JOIN customers c ON t.ID_client = c.Id_client
GROUP BY month, c.Gender
ORDER BY month, c.Gender;


# 3 task
SELECT CASE WHEN Age IS NULL THEN 'Unknown'
	ELSE CONCAT(FLOOR(Age/10)*10, '-', FLOOR(Age/10)*10 + 9)
    END AS age_group,
    SUM(t.Sum_payment) AS total_spend,
    COUNT(*) AS total_ops
FROM transactions t
JOIN customers c ON t.ID_client = c.Id_client
GROUP BY age_group
ORDER BY age_group;

SELECT CONCAT(YEAR(Date_new), '-Q', QUARTER(Date_new)) AS quarter,
    CASE 
        WHEN Age IS NULL THEN 'Unknown'
        ELSE CONCAT(FLOOR(Age/10)*10, '-', FLOOR(Age/10)*10 + 9)
    END AS age_group,
    AVG(Sum_payment) AS avg_check,
    COUNT(*) AS ops,
    SUM(Sum_payment) AS spend
FROM transactions t
JOIN customers c ON t.ID_client = c.Id_client
GROUP BY quarter, age_group
ORDER BY quarter, age_group;
