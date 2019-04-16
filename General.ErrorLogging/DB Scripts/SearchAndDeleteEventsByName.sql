/*
SELECT TOP 100 * FROM ErrorOther 
WHERE AppID = 5
	AND ErrorType = 6
ORDER BY Count DESC
*/



SELECT COUNT(*) AS Found
FROM [dbo].[ErrorOtherLog] logg
			JOIN [dbo].[ErrorOther]
				ON [ErrorOther].[ID] = logg.[ErrorOtherID]
		WHERE  logg.URL LIKE '%ajax-loader.gif%'

--EXEC [dbo].[pr_ErrorOther_AutoDelete] @Preview = 0

BEGIN TRAN

DROP TABLE #TempRowsToDelete

SELECT logg.ID AS ErrorOtherLogID
INTO #TempRowsToDelete
FROM [dbo].[ErrorOtherLog] logg
			JOIN [dbo].[ErrorOther]
				ON [ErrorOther].[ID] = logg.[ErrorOtherID]
		WHERE ErrorName = 'Completed request for new document.'
		--AND [ErrorOther].[AppID] = 5
		--AND [ErrorOther].[EnvironmentID] = 5
		--AND [TimeStamp] < GETDATE() - 7

PRINT 'Deleting Trigger Records'
DELETE ErrorOtherLogTrigger
FROM ErrorOtherLogTrigger
	JOIN #TempRowsToDelete temp
		ON ErrorOtherLogTrigger.ErrorOtherLogID = temp.ErrorOtherLogID 

PRINT 'Deleting Event Records'
DELETE ErrorOtherLog
FROM ErrorOtherLog
	JOIN #TempRowsToDelete temp
		ON ErrorOtherLog.ID = temp.ErrorOtherLogID 

PRINT 'Deleting Header Records'
DELETE ErrorOther
FROM ErrorOther
	LEFT JOIN ErrorOtherLog
		ON ErrorOther.ID = ErrorOtherLog.ErrorOtherID
WHERE ErrorOtherLog.ID IS NULL

PRINT 'Deleting Detail Records'
DELETE ErrorOtherDetail 
FROM ErrorOtherDetail
	LEFT JOIN ErrorOther
		ON ErrorOther.DetailID = ErrorOtherDetail.ID
	LEFT JOIN ErrorOtherLog
		ON ErrorOtherLog.DetailID = ErrorOtherDetail.ID
WHERE ErrorOtherLog.ID IS NULL AND ErrorOther.ID IS NULL

COMMIT TRAN

