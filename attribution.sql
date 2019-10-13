select 1 as question;
/*How many campaigns and sources does CoolTShirts use?
 Which source is used for each campaign?*/
--
select * from page_visits limit 20;
select count(distinct utm_campaign),
count(distinct utm_source)
from page_visits;
select utm_campaign, utm_source
from page_visits
group by 1;
-- eight campaigns feuled by six sources
-- interwoven relationships, except for 
-- newsletter( and retargeting?), which
-- which is(/are) primarily sourced by email
-- also, paid search is likely google only
---------------------------------------------
select 2 as question;
/*What pages are on the CoolTShirts website?*/
--
select count(distinct page_name) from page_visits;
-- four pages on the website
---------------------------------------------
select 3 as question;
/*How many first touches is each campaign responsible for?*/
--
WITH first_touch AS (
    SELECT user_id,
    MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id )
SELECT pv.utm_campaign,
       count(ft.first_touch_at) as first_touch_count
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
    group by 1
    order by 2 desc;
-- campaign and corresp. # of first touches;
--__________________________________________.
--cool-tshirts-search	                | 169 |
--getting-to-know-cool-tshirts        |	612 |
--interview-with-cool-tshirts-founder | 622 |
--ten-crazy-cool-tshirts-facts	            | 576 |
---------------------------------------------
select 4 as question;
/* How many last touches is each campaign responsible for? */
--
with last_touch as(
     select user_id,
     	    max(timestamp) as last_touch_at
  from page_visits
  group by user_id )
select pv.utm_campaign,  
count(lt.last_touch_at) as last_touch_count
from last_touch lt
join page_visits pv
     on lt.user_id = pv.user_id
  and lt.last_touch_at = pv.timestamp
  group by 1
  order by 2 desc;  
--____________________________________________.
--| cool-tshirts-search	                |  60 |
--| getting-to-know-cool-tshirts	      | 232 |
--| interview-with-cool-tshirts-founder |     184 |
--| paid-search				                        | 178 |
--| retargetting-ad						                    | 443 |
--| retargetting-campaign							                  | 245 | 
--| ten-crazy-cool-tshirts-facts								        | 190 | 
--| weekly-newsletter											                  | 447 |
---------------------------------------------
select 5 as question;
/*How many visitors make a purchase?*/
--
select count(distinct user_id)
from page_visits
where page_name like '4%';
-- 361 distinct user_id's who've visited the 
-- purchase webpage
---------------------------------------------
select 6 as question;
/*How many last touches on the purchase page is 
      each campaign responsible for?*/
--
with last_touch as(
     select user_id,
     	    max(timestamp) as last_touch_at
  from page_visits
  group by user_id )
select pv.utm_campaign,  
count(lt.last_touch_at) as last_touch_on_purchase_page_count
from last_touch lt
join page_visits pv
     on lt.user_id = pv.user_id
  and lt.last_touch_at = pv.timestamp
  where page_name like '4%'
  group by 1
  order by 2 desc;  
--____________________________________________.
--| cool-tshirts-search	                |   2 |
--| getting-to-know-cool-tshirts	      |   9 |
--| interview-with-cool-tshirts-founder |       7 |
--| paid-search				                        |  52 |
--| retargetting-ad						                    | 112 |
--| retargetting-campaign							                  |  53 | 
--| ten-crazy-cool-tshirts-facts								        |   9 | 
--| weekly-newsletter											                  | 114 |
---------------------------------------------
select 7 as question;
/* CoolTShirts can re-invest in 5 campaigns. Given your findings in the project, which should they pick and why? */
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

-- the following queries create tables showing percentage
-- of distinct user UTM timestamps leaving each page,
-- respectively, both by campaign and by source
with last_touch as(
     select user_id,
     	    max(timestamp) as last_touch_at
  from page_visits
  group by user_id ),
  last_touch_percentage as (
select pv.utm_campaign as campaign,  
count(lt.last_touch_at) as total_last_touch,
count(case when page_name like '1%' then 1
     else null end) as page1,
count(case
     when page_name like '2%' then 1
     else null end) as page2,
count(case
     when page_name like '3%' then 1
     else null end) as page3,
count(case
     when page_name like '4%' then 1
     else null end) as page4
from last_touch lt
join page_visits pv
     on lt.user_id = pv.user_id
  and lt.last_touch_at = pv.timestamp
  group by 1
  order by 2 desc)
  select 
  campaign,
  round(100.0*page1 / total_last_touch,3) as '% users left on page 1',
  round(100.0*page2 / total_last_touch,3) as '--- 2',
  round(100.0*page3 / total_last_touch,3) as '--- 3',
  round(100.0*page4 / total_last_touch,3) as '--- 4'
  from last_touch_percentage;
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
with last_touch as(
     select user_id,
     	    max(timestamp) as last_touch_at
  from page_visits
  group by user_id ),
  last_touch_percentage as (
select pv.utm_source as source,  
count(lt.last_touch_at) as total_last_touch,
count(case when page_name like '1%' then 1
     else null end) as page1,
count(case
     when page_name like '2%' then 1
     else null end) as page2,
count(case
     when page_name like '3%' then 1
     else null end) as page3,
count(case
     when page_name like '4%' then 1
     else null end) as page4
from last_touch lt
join page_visits pv
     on lt.user_id = pv.user_id
  and lt.last_touch_at = pv.timestamp
  group by 1
  order by 2 desc)
  select 
  source,
  round(100.0*page1 / total_last_touch,3) as '% users left on page 1',
  round(100.0*page2 / total_last_touch,3) as '--- 2',
  round(100.0*page3 / total_last_touch,3) as '--- 3',
  round(100.0*page4 / total_last_touch,3) as '--- 4'
  from last_touch_percentage;
--
-- THE TOP THREE AD CAMPAIGNS BY PERCENTAGE OF 
-- USERS WITH LAST TIMESTAMP ON PURCHASE PAGE:
--     * weekly newletter
--     * retargetting ad
--     * retargetting campaign
--
-- THE FOLLOWING QUERY SHOWS SOURCING OF EACH CAMPAIGN:
  with campbysource as (
       select utm_campaign,
    round(sum(case when utm_source like 'buzzfeed'
         then 1 else 0 end), 3) as 'buzzfeed',
    round(sum(case when utm_source like 'facebook'
          then 1 else 0 end) , 3) as 'facebook',
    round(sum(case when utm_source like 'email'
          then 1 else 0 end)  , 3) as 'email',
    round(sum(case when utm_source like 'google'
          then 1 else 0 end) , 3) as 'google',
    round(sum(case when utm_source like 'medium'
          then 1 else 0 end) , 3) as 'medium',
    round(sum(case when utm_source like 'nytimes'
          then 1 else 0 end), 3) as 'nytimes'
    from page_visits
  group by 1)
    select * from campbysource limit 100;
--
-- SINCE email and facebook are the sole sources to the top three
-- campaigns, which account for ~75% of user purchases, they should
-- be the focal points of future investments;
--
/*#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#----$$--------$-----$------------------#
#---$----------$-----$------------------#
#----$$----$$--$$$---$---$$-----$$-$$---#
#------$--$----$--$--$--$--$---$--$--$--#
#----$$----$$--$--$--$---$$-$--$-----$--#
 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/