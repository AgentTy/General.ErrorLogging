/****** Object:  UserDefinedFunction [dbo].[fn_GetEventTypeName]    Script Date: 1/5/2018 3:49:40 PM ******/
DROP FUNCTION [dbo].[fn_GetEventTypeName]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetEventTypeName]    Script Date: 1/5/2018 3:49:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
	This FUNCTION returns the friendly name for an EventTypeID
*/
CREATE FUNCTION [dbo].[fn_GetEventTypeName]
(
	@EventTypeID [SmallInt]
)
RETURNS [VarChar](100)
AS
BEGIN
	RETURN CASE
		WHEN @EventTypeID = 0 THEN 'Unknown'
		WHEN @EventTypeID = 1 THEN 'Server Side Error'
		WHEN @EventTypeID = 2 THEN 'SQL Error'
		WHEN @EventTypeID = 3 THEN 'SQL Connectivity'
		WHEN @EventTypeID = 4 THEN 'SQL Timeout'
		WHEN @EventTypeID = 6 THEN 'Javascript Error'
		WHEN @EventTypeID = 10 THEN 'Warning'
		WHEN @EventTypeID = 11 THEN 'Audit'
		WHEN @EventTypeID = 12 THEN 'Trace'
		WHEN @EventTypeID = 13 THEN 'Auth'
		ELSE CONVERT(VARCHAR, @EventTypeID)
	END
END


GO




/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_DatabaseSummaryReport]    Script Date: 5/23/2016 1:01:44 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_DatabaseSummaryReport]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_DatabaseSummaryReport]    Script Date: 5/23/2016 1:01:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_ErrorOther_DatabaseSummaryReport]
	@Label [VarChar](200) = 'Database Summary Report'
	, @AppID [Int] = NULL
	, @EnvironmentID [Int] = NULL 
AS

	--Events By Event Type
	SELECT @Label AS Label
	, app.Name + ' (' + CONVERT(VARCHAR, app.ID) + ')' AS App
	, [dbo].[fn_GetEventTypeName](ErrorType) + ' (' + CONVERT(VARCHAR, ErrorType) + ')' AS EventType
	, CONVERT(varchar, CAST(COUNT(*) AS money), 1) AS RecordCount
	, CONVERT(varchar, CAST(COUNT(DISTINCT ErrorOther.ID) AS money), 1) AS DistinctEvents
	, MIN([TimeStamp]) AS EarliestRecord
	, MAX([TimeStamp]) AS LatestRecord
	FROM [dbo].[ErrorOtherLog]
		JOIN [dbo].[ErrorOther]
			ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
		JOIN [dbo].[Application] app
			ON app.ID = ErrorOther.AppID
	WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
	AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
	GROUP BY ErrorType, app.Name, app.ID
	ORDER BY ErrorType, app.Name

GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_AutoDelete]    Script Date: 5/23/2016 1:01:44 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_AutoDelete]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_AutoDelete]    Script Date: 5/23/2016 1:01:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_ErrorOther_AutoDelete]
	@Preview [Bit] = 1
	, @AppID [Int] = NULL
	, @EnvironmentID [Int] = NULL 
	, @MaximumSeverityToDelete [INT] = 9
	, @MinimumAge_ProdEnv [Int] = 365
	, @MinimumAge_OtherEnv [Int] = 180
	, @MinimumAge_ErrorEvent [Int] = 730
	, @MinimumAge_AuditEvent [Int] = 180
	, @MinimumAge_OtherEvent [Int] = 180
AS

	DECLARE @ProdEnvironmentID SMALLINT
	SET @ProdEnvironmentID = 5

	DECLARE @ErrorEventMaxTypeID SMALLINT, @AuditEventTypeID SMALLINT
	SET @ErrorEventMaxTypeID = 9 --1-9 are all error codes
	SET @AuditEventTypeID = 11 --11 is Audit

	DECLARE @TotalRowsToScan INT
	SELECT @TotalRowsToScan = COUNT(*) 
	FROM [dbo].[ErrorOtherLog]
			JOIN [dbo].[ErrorOther]
				ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
		WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)

	PRINT CONVERT(varchar, CAST(@TotalRowsToScan AS money), 1) + ' events found'

	
	;WITH possibles AS (SELECT logg.[ErrorOtherID] 
	, logg.[ID] AS ErrorOtherLogID
	, logg.[TimeStamp]
	, DATEDIFF(DAY, logg.[TimeStamp], GETDATE()) AS Age
	, ErrorOther.ErrorType AS EventType
	, ErrorOther.EnvironmentID
	FROM [dbo].[ErrorOtherLog] logg
			JOIN [dbo].[ErrorOther]
				ON [ErrorOther].[ID] = logg.[ErrorOtherID]
		WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
		AND (COALESCE([ErrorOther].[Severity], 1) < @MaximumSeverityToDelete OR @MaximumSeverityToDelete IS NULL)
	)
	SELECT * 
	INTO #TempRowsToDelete
	FROM possibles
	WHERE 
	(
		(
			EnvironmentID = @ProdEnvironmentID 
			AND Age >= @MinimumAge_ProdEnv
		)
		OR 
		(
			EnvironmentID <> @ProdEnvironmentID
			AND Age >= @MinimumAge_OtherEnv
		)
	)
	AND
	(
		(
			EventType = @AuditEventTypeID 
			AND Age >= @MinimumAge_AuditEvent
		)
		OR 
		(
			EventType <= @ErrorEventMaxTypeID
			AND Age >= @MinimumAge_ErrorEvent
		)
		OR 
		(
			EventType > @ErrorEventMaxTypeID
			AND EventType <> @AuditEventTypeID
			AND Age >= @MinimumAge_OtherEvent
		)
	)

	DECLARE @TotalRowsToDelete INT
	SELECT @TotalRowsToDelete = COUNT(*) FROM #TempRowsToDelete
	PRINT CONVERT(varchar, CAST(@TotalRowsToDelete AS money), 1) + ' events elligible for deletion'

	IF @Preview = 0
	BEGIN
		PRINT 'DO DELETE!'

		BEGIN TRANSACTION

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

		DECLARE @TotalRowsAfterDeletion INT
		SELECT @TotalRowsAfterDeletion = COUNT(*) 
		FROM [dbo].[ErrorOtherLog]
			JOIN [dbo].[ErrorOther]
				ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
		WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)


		SELECT CONVERT(varchar, CAST(@TotalRowsToScan AS money), 1)  AS TotalEventsScanned
			, CONVERT(varchar, CAST(@TotalRowsToDelete AS money), 1) AS TotalEventsToDelete
			, CONVERT(varchar, CONVERT(DECIMAL(18,2), (CONVERT(DECIMAL(18,4), @TotalRowsToDelete) / CONVERT(DECIMAL(18,4), @TotalRowsToScan)) * 100)) + '%' AS PercentToDelete
			, CONVERT(varchar, CAST(@TotalRowsToScan - @TotalRowsAfterDeletion AS money), 1) AS AuditActualEventsDeleted

		EXEC [dbo].[pr_ErrorOther_DatabaseSummaryReport] 'After'

		IF @@TRANCOUNT > 0
		BEGIN
			COMMIT TRANSACTION;
		END

	END
	ELSE
	BEGIN

		SELECT CONVERT(varchar, CAST(@TotalRowsToScan AS money), 1)  AS TotalEventsScanned
			, CONVERT(varchar, CAST(@TotalRowsToDelete AS money), 1) AS TotalEventsToDelete
			, CONVERT(varchar, CONVERT(DECIMAL(18,2), (CONVERT(DECIMAL(18,4), @TotalRowsToDelete) / CONVERT(DECIMAL(18,4), @TotalRowsToScan)) * 100)) + '%' AS PercentToDelete
		PRINT 'Preview Mode Only'

		EXEC [dbo].[pr_ErrorOther_DatabaseSummaryReport] 'BEFORE'

		SELECT 'TO DELETE' AS Label
		, app.Name + ' (' + CONVERT(VARCHAR, app.ID) + ')' AS App
		, [dbo].[fn_GetEventTypeName](ErrorType) + ' (' + CONVERT(VARCHAR, ErrorType) + ')' AS EventType
		, CONVERT(varchar, CAST(COUNT(*) AS money), 1) AS RecordCount
		, CONVERT(varchar, CAST(COUNT(DISTINCT ErrorOther.ID) AS money), 1) AS DistinctEvents
		, MIN([ErrorOtherLog].[TimeStamp]) AS EarliestRecord
		, MAX([ErrorOtherLog].[TimeStamp]) AS LatestRecord
		FROM [dbo].[ErrorOtherLog]
			JOIN #TempRowsToDelete
				ON #TempRowsToDelete.ErrorOtherLogID = [ErrorOtherLog].ID
			JOIN [dbo].[ErrorOther]
				ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
			JOIN [dbo].[Application] app
				ON app.ID = ErrorOther.AppID
		GROUP BY ErrorType, app.Name, app.ID
		ORDER BY ErrorType, app.Name

	END

GO


EXEC [dbo].[pr_ErrorOther_AutoDelete] @Preview = 1