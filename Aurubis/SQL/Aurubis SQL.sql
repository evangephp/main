DROP DATABASE IF EXISTS Aurubis;
CREATE DATABASE Aurubis;

use Aurubis;

drop table `ch_order`;
create table `ch_order` (
  `INVID` VARCHAR(128),
  `INDENS` VARCHAR(128),
  `INHEAT` VARCHAR(128),
  `INPAS` VARCHAR(128),
  `INALLY` int(11),
  `INMINL` VARCHAR(128),
  `INVCLK` text,
  `INSENT` CHAR(20),
  `INSRSQ` int(11),
  `INSNXU` VARCHAR(128),
  `INSACT` CHAR(20),
  `INSSTA` text,
  `INSWID` float,
  `INSGAG` float,
  `INSGWT` int(11),
  `INFENT` CHAR(20),
  `INFGAG` VARCHAR(128),
  `INFGWT` int(11),
  `month` VARCHAR(128),
  `coil` VARCHAR(128)
);

LOAD DATA INFILE 'ch_order.csv' INTO TABLE ch_order
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

/* QUERY CHECK */
select * from ch_order;

SELECT * from ch_order where INSACT = 'I';

select * from ch_order where (INSENT = 10019 or INSENT = 10022 or INSENT = 10024);

select * from ch_order where (INSENT = 10175);

select distinct INSENT from ch_order order by INSENT desc limit 5;

SELECT * from ch_order where `coil` = 695140;

/* count coil number in each order */
select INSENT, count(distinct coil) as coil_number, count(distinct INALLY) as alloy_number from ch_order group by INSENT;

/* STARTING WEIGHT */
SELECT INSENT, `coil`, max(INSGWT) as SW from ch_order group by `coil`;

/* ENDING WEIGHT */
SELECT INSENT, `coil`, sum(INSGWT) as EW from ch_order 
where INFGWT = 0 and (INSACT = 'A' or INSACT = 'B') group by `coil`;

/* calculate yield for each main coil */
SELECT a.`coil`, ifnull(EW/SW, NULL) as yield 
from (SELECT INSENT, `coil`, max(INSGWT) as SW from ch_order group by `coil`) a left join (SELECT INSENT, `coil`, sum(INSGWT) as EW from ch_order where INFGWT = 0 and (INSACT = 'A' or INSACT = 'B') group by `coil`) b
on a.`coil` = b.`coil`;

/* calculate total ending weight per order */
SELECT INSENT, sum(EW) as total_weight from 
(SELECT a.INSENT, a.`coil`, ifnull(EW/SW, NULL) as yield, EW 
from (SELECT INSENT, `coil`, max(INSGWT) as SW from ch_order group by `coil`) a left join (SELECT INSENT, `coil`, sum(INSGWT) as EW from ch_order where INFGWT = 0 and (INSACT = 'A' or INSACT = 'B') group by `coil`) b
on a.`coil` = b.`coil`) temp
group by INSENT;

/* aggregate into order yield (not avg based on weight yet) */
SELECT temp1.INSENT, (temp1.yield * sum(temp1.EW) / temp2.total_weight) as order_yield from
(SELECT a.INSENT, a.`coil`, ifnull(EW/SW, NULL) as yield, EW 
from (SELECT INSENT, `coil`, max(INSGWT) as SW from ch_order group by `coil`) a left join (SELECT INSENT, `coil`, sum(INSGWT) as EW from ch_order where INFGWT = 0 and (INSACT = 'A' or INSACT = 'B') group by `coil`) b
on a.`coil` = b.`coil`) temp1
left join (SELECT INSENT, sum(EW) as total_weight from 
(SELECT a.INSENT, a.`coil`, ifnull(EW/SW, NULL) as yield, EW 
from (SELECT INSENT, `coil`, max(INSGWT) as SW from ch_order group by `coil`) a left join (SELECT INSENT, `coil`, sum(INSGWT) as EW from ch_order where INFGWT = 0 and (INSACT = 'A' or INSACT = 'B') group by `coil`) b
on a.`coil` = b.`coil`) temp
group by INSENT) temp2
on temp1.INSENT = temp2.INSENT
group by temp1.INSENT
order by temp1.INSENT;

/* calculate avg yield across all orders */
select avg(order_yield) from
(SELECT temp1.INSENT, (temp1.yield * sum(temp1.EW) / temp2.total_weight) as order_yield from
(SELECT a.INSENT, a.`coil`, ifnull(EW/SW, NULL) as yield, EW 
from (SELECT INSENT, `coil`, max(INSGWT) as SW from ch_order group by `coil`) a left join (SELECT INSENT, `coil`, sum(INSGWT) as EW from ch_order where INFGWT = 0 and (INSACT = 'A' or INSACT = 'B') group by `coil`) b
on a.`coil` = b.`coil`) temp1
left join (SELECT INSENT, sum(EW) as total_weight from 
(SELECT a.INSENT, a.`coil`, ifnull(EW/SW, NULL) as yield, EW 
from (SELECT INSENT, `coil`, max(INSGWT) as SW from ch_order group by `coil`) a left join (SELECT INSENT, `coil`, sum(INSGWT) as EW from ch_order where INFGWT = 0 and (INSACT = 'A' or INSACT = 'B') group by `coil`) b
on a.`coil` = b.`coil`) temp
group by INSENT) temp2
on temp1.INSENT = temp2.INSENT
group by temp1.INSENT
order by temp1.INSENT) temp3;



/* aggregate process bianry variables */
SELECT distinct coil from ch_order;

SELECT coil, ifnull(INSNXU,INVCLK) as machine, count(*) as counts from ch_order group by coil, ifnull(INSNXU,INVCLK);

SELECT ifnull((420000, 143) in (SELECT distinct coil, INMINL from ch_order),0);

SELECT distinct c.coil, ifnull((c.coil, 134) in (SELECT distinct coil, INMINL from ch_order), 0) as `134`
from ch_order c join (SELECT distinct coil, INMINL from ch_order) temp
on temp.coil = c.coil
;

SELECT *
from ch_order c join (SELECT distinct coil, INMINL from ch_order) temp
on c.coil = temp.coil and c.INMINL = temp.INMINL;

select distinct INMINL from ch_order where INSNXU = 143;

SELECT * from ch_order where coil = 691117;