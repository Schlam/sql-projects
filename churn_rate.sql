/*
 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#----$$--------$-----$------------------#
#---$----------$-----$------------------#
#----$$----$$--$$$---$---$$-----$$-$$---#
#------$--$----$--$--$--$--$---$--$--$--#
#----$$----$$--$--$--$---$$-$--$-----$--#
 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


Churn rate calculations from the dqtabase corresponding to subscriptions.csv

month		churn rate
2017-01-01	0.126811594202899
2017-02-01	0.124505928853755
2017-03-01	0.23688155922039

It looks like our sample company did something in March that doubled the churn rate. They might want to look into that…

In this lesson you learned:

The churn rate is a percent of subscribers at the beginning of a period that cancel within that period. “Monthly churn” is a typical metric and what was used in the examples.
How to calculate this metric using SQL for a single month. This used COUNT() and conditions to determine the number of subscribers that were active and how many canceled.
A more complex method to track the subscriber churn rate over many months.

*/


WITH months AS (
  SELECT 
    '2017-01-01' AS first_day, 
    '2017-01-31' AS last_day 
  UNION 
  SELECT 
    '2017-02-01' AS first_day, 
    '2017-02-28' AS last_day 
  UNION 
  SELECT 
    '2017-03-01' AS first_day, 
    '2017-03-31' AS last_day
), 
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
), 
status AS (
  SELECT 
    id, 
    first_day AS month, 
    CASE
      WHEN (subscription_start < first_day) 
        AND (
          subscription_end > first_day 
          OR subscription_end IS NULL
        ) THEN 1
      ELSE 0
    END AS is_active, 
    CASE
      WHEN subscription_end BETWEEN first_day AND last_day THEN 1
      ELSE 0
    END AS is_canceled 
  FROM cross_join
), 
status_aggregate AS (
  SELECT 
    month, 
    SUM(is_active) AS active, 
    SUM(is_canceled) AS canceled 
  FROM status 
  GROUP BY month
) 
SELECT
  month, 
  1.0 * canceled / active AS churn_rate 
FROM status_aggregate;