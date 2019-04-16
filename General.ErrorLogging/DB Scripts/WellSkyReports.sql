/*SELECT TOP 1000 ErrorOtherLog.Duration, ErrorOther.ErrorName, * 
FROM ErrorOtherLog 
	JOIN ErrorOther 
		ON ErrorOther.ID = Errorotherlog.ErrorOtherID
WHERE ErrorOtherLog.Duration IS NOT NULL 
AND AppID = 4
ORDER BY ErrorOtherLog.TimeStamp DESC
*/


--SELECT * FROM Application

--COUNT TIMEOUTS FOR REHAB
SELECT TOP 1000 'Rehab Servers' AS AppName, 'SQL Timeouts' AS ErrorName, COUNT(*) AS TimeoutCount, CONVERT(date, (DATEADD(DAY, 1-DATEPART(WEEKDAY,  MAX(ErrorOtherLog.TimeStamp)),  MAX(ErrorOtherLog.TimeStamp)))) AS WeekOf
 -- CONVERT(date, MIN(ErrorOtherLog.TimeStamp)), CONVERT(date, MAX(ErrorOtherLog.TimeStamp)),
FROM ErrorOtherLog 
	JOIN ErrorOther 
		ON ErrorOther.ID = Errorotherlog.ErrorOtherID
WHERE ErrorOther.ErrorType IN (3,4)
AND AppID IN (4,5,6,7,8,10)
--AND ErrorOther.ErrorName = 'The wait operation timed out'
--AND ErrorOtherLog.TimeStamp <= '9/23/2018'
GROUP BY DATEPART(wk, ErrorOtherLog.TimeStamp)
ORDER BY DATEPART(wk, ErrorOtherLog.TimeStamp)  DESC


--COUNT TIMEOUTS FOR SCHEDULING
SELECT TOP 1000 'Scheduling Servers' AS AppName, 'SQL Timeouts' AS ErrorName, COUNT(*) AS TimeoutCount, CONVERT(date, (DATEADD(DAY, 1-DATEPART(WEEKDAY,  MAX(ErrorOtherLog.TimeStamp)),  MAX(ErrorOtherLog.TimeStamp)))) AS WeekOf
 -- CONVERT(date, MIN(ErrorOtherLog.TimeStamp)), CONVERT(date, MAX(ErrorOtherLog.TimeStamp)),
FROM ErrorOtherLog 
	JOIN ErrorOther 
		ON ErrorOther.ID = Errorotherlog.ErrorOtherID
WHERE ErrorOther.ErrorType IN (3,4)
AND AppID IN (11)
--AND ErrorOther.ErrorName = 'The wait operation timed out'
--AND ErrorOtherLog.TimeStamp <= '9/23/2018'
GROUP BY DATEPART(wk, ErrorOtherLog.TimeStamp)
ORDER BY DATEPART(wk, ErrorOtherLog.TimeStamp)  DESC


--COUNT ERRORS FOR REHAB
SELECT TOP 1000 'Rehab Servers' AS AppName
--, ErrorOther.ErrorName
, 'Server Errors' AS ErrorName
, COUNT(*) AS ErrCount
, CONVERT(date, (DATEADD(DAY, 1-DATEPART(WEEKDAY,  MAX(ErrorOtherLog.TimeStamp)),  MAX(ErrorOtherLog.TimeStamp)))) AS WeekOf
 -- CONVERT(date, MIN(ErrorOtherLog.TimeStamp)), CONVERT(date, MAX(ErrorOtherLog.TimeStamp)),
FROM ErrorOtherLog 
	JOIN ErrorOther 
		ON ErrorOther.ID = Errorotherlog.ErrorOtherID
WHERE AppID IN (4,5,6,7,8,10)
AND ErrorOther.ErrorType = 1
--AND ErrorOther.ErrorName = 'The wait operation timed out'
--AND ErrorOtherLog.TimeStamp <= '9/23/2018'
GROUP BY DATEPART(wk, ErrorOtherLog.TimeStamp)--, ErrorOther.ErrorName
ORDER BY DATEPART(wk, ErrorOtherLog.TimeStamp)  DESC


--COUNT ERRORS FOR SCHEDULING
SELECT TOP 1000 'Scheduling Servers' AS AppName
, 'Server Errors' AS ErrorName
--, ErrorOther.ErrorName
, COUNT(*) AS ErrCount
, CONVERT(date, (DATEADD(DAY, 1-DATEPART(WEEKDAY,  MAX(ErrorOtherLog.TimeStamp)),  MAX(ErrorOtherLog.TimeStamp)))) AS WeekOf
 -- CONVERT(date, MIN(ErrorOtherLog.TimeStamp)), CONVERT(date, MAX(ErrorOtherLog.TimeStamp)),
FROM ErrorOtherLog 
	JOIN ErrorOther 
		ON ErrorOther.ID = Errorotherlog.ErrorOtherID
WHERE AppID IN (11)
AND ErrorOther.ErrorType = 1
--AND ErrorOther.ErrorName = 'The wait operation timed out'
--AND ErrorOtherLog.TimeStamp <= '9/23/2018'
GROUP BY DATEPART(wk, ErrorOtherLog.TimeStamp)--, ErrorOther.ErrorName
ORDER BY DATEPART(wk, ErrorOtherLog.TimeStamp)  DESC





--COUNT DROPPED CONNECTIONS FOR REHAB
SELECT TOP 1000 'Rehab Servers' AS AppName
, 'Connection Drops' AS ErrorName
--, ErrorOther.ErrorName
, COUNT(*) AS TimeoutCount
, CONVERT(date, (DATEADD(DAY, 1-DATEPART(WEEKDAY,  MAX(ErrorOtherLog.TimeStamp))
,  MAX(ErrorOtherLog.TimeStamp)))) AS WeekOf
 -- CONVERT(date, MIN(ErrorOtherLog.TimeStamp)), CONVERT(date, MAX(ErrorOtherLog.TimeStamp)),
FROM ErrorOtherLog 
	JOIN ErrorOther 
		ON ErrorOther.ID = Errorotherlog.ErrorOtherID
WHERE AppID IN (4,5,6,7,8,10)
AND (ErrorOther.ErrorName IN ('An existing connection was forcibly closed by the remote host','A task was canceled.','The remote host closed the connection. The error code is 0x80070057.')
	OR ErrorOther.ErrorName LIKE '%connection was forcibly closed%'
	OR ErrorOther.ErrorName LIKE '%task was cancel%' 
	OR ErrorOther.ErrorName LIKE '%closed the connection%' 
	OR ErrorOther.ErrorName LIKE '%network name is no longer available%' 
	)
--AND ErrorOtherLog.TimeStamp <= '9/23/2018'
GROUP BY DATEPART(wk, ErrorOtherLog.TimeStamp)
ORDER BY DATEPART(wk, ErrorOtherLog.TimeStamp)  DESC


--COUNT DROPPED CONNECTIONS FOR SCHEDULING
SELECT TOP 1000 'Scheduling Servers' AS AppName
, 'Connection Drops' AS ErrorName
--, ErrorOther.ErrorName
, COUNT(*) AS TimeoutCount
, CONVERT(date, (DATEADD(DAY, 1-DATEPART(WEEKDAY,  MAX(ErrorOtherLog.TimeStamp))
,  MAX(ErrorOtherLog.TimeStamp)))) AS WeekOf
 -- CONVERT(date, MIN(ErrorOtherLog.TimeStamp)), CONVERT(date, MAX(ErrorOtherLog.TimeStamp)),
FROM ErrorOtherLog 
	JOIN ErrorOther 
		ON ErrorOther.ID = Errorotherlog.ErrorOtherID
WHERE AppID IN (11)
AND (ErrorOther.ErrorName IN ('An existing connection was forcibly closed by the remote host','A task was canceled.','The remote host closed the connection. The error code is 0x80070057.')
	OR ErrorOther.ErrorName LIKE '%connection was forcibly closed%'
	OR ErrorOther.ErrorName LIKE '%task was cancel%' 
	OR ErrorOther.ErrorName LIKE '%closed the connection%' 
	OR ErrorOther.ErrorName LIKE '%network name is no longer available%' 
	)
--AND ErrorOtherLog.TimeStamp <= '9/23/2018'
GROUP BY DATEPART(wk, ErrorOtherLog.TimeStamp)
ORDER BY DATEPART(wk, ErrorOtherLog.TimeStamp)  DESC










--COUNT TIMEOUTS FOR REHAB
SELECT TOP 1000 'Rehab Servers' AS AppName, ErrorOther.ErrorName AS ErrorName, ErrorOtherLog.TimeStamp
 -- CONVERT(date, MIN(ErrorOtherLog.TimeStamp)), CONVERT(date, MAX(ErrorOtherLog.TimeStamp)),
FROM ErrorOtherLog 
	JOIN ErrorOther 
		ON ErrorOther.ID = Errorotherlog.ErrorOtherID
WHERE ErrorOther.ErrorType IN (3,4)
AND AppID IN (4,5,6,7,8,10)
AND ErrorOther.ErrorName = 'The wait operation timed out'
AND ErrorOtherLog.TimeStamp <= '9/23/2018'
AND ErrorOtherlog.TimeStamp >= '9/16/2018'
ORDER BY ErrorOtherLog.TimeStamp DESC
--GROUP BY DATEPART(wk, ErrorOtherLog.TimeStamp), ErrorOther.ErrorName
--ORDER BY DATEPART(wk, ErrorOtherLog.TimeStamp)  DESC









SELECT TOP 1000 'Rehab Servers' AS AppName, 'SQL Timeouts' AS ErrorName, COUNT(*) AS TimeoutCount, CONVERT(date, (DATEADD(DAY, 1-DATEPART(WEEKDAY,  MAX(ErrorOtherLog.TimeStamp)),  MAX(ErrorOtherLog.TimeStamp)))) AS WeekOf
 -- CONVERT(date, MIN(ErrorOtherLog.TimeStamp)), CONVERT(date, MAX(ErrorOtherLog.TimeStamp)),
FROM ErrorOtherLog 
	JOIN ErrorOther 
		ON ErrorOther.ID = Errorotherlog.ErrorOtherID
WHERE AppID IN (4,5,6,7,8,10)
AND ErrorOther.ErrorName = 'Cannot read property ''value'' of undefined'
--AND ErrorOtherLog.TimeStamp <= '9/23/2018'
GROUP BY DATEPART(wk, ErrorOtherLog.TimeStamp)
ORDER BY DATEPART(wk, ErrorOtherLog.TimeStamp)  DESC
