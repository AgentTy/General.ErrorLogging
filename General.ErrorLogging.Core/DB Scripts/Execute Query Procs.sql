DECLARE @RC int
DECLARE @AppID int
DECLARE @EnvironmentID int
DECLARE @ClientID varchar(50)
DECLARE @ErrorType smallint
DECLARE @MinimumSeverity smallint
DECLARE @StartDate datetimeoffset(7)
DECLARE @EndDate datetimeoffset(7)
DECLARE @IncludeDetail bit

SET @AppID = NULL
SET @EnvironmentID = NULL
SET @ClientID = NULL
SET @ErrorType = NULL
SET @StartDate = '2018-01-11 00:00:00.0000000 -07:00'
SET @EndDate = '2018-01-11 23:59:59.0000000 -07:00'
SET @IncludeDetail = 0


--Events By Event Type
SELECT app.Name + ' (' + CONVERT(VARCHAR, app.ID) + ')' AS App
, [dbo].[fn_GetEventTypeName](ErrorType) + ' (' + CONVERT(VARCHAR, ErrorType) + ')' AS EventType
, CONVERT(varchar, CAST(COUNT(*) AS money), 1) AS RecordCount
, CONVERT(varchar, CAST(COUNT(DISTINCT ErrorOther.ID) AS money), 1) AS DistinctEvents
, MIN([TimeStamp]) AS EarliestRecord
, MAX([TimeStamp]) AS LatestRecord
FROM [dbo].[ErrorOtherLog]
	JOIN [dbo].[ErrorOther]
		ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
	LEFT JOIN [dbo].[Application] app
		ON app.ID = ErrorOther.AppID
WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
AND ([ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate)
GROUP BY ErrorType, app.Name, app.ID
ORDER BY ErrorType, app.Name


SELECT CONVERT(varchar, CAST(COUNT(*) AS money), 1) AS RecordCount
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
AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
AND ([ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate)



EXECUTE @RC = [dbo].[pr_ErrorOther_SelectLog] 
   @AppID
  ,@EnvironmentID
  ,@ClientID
  ,@ErrorType
  ,@MinimumSeverity
  ,@StartDate
  ,@EndDate
  ,@IncludeDetail






/*

EXECUTE @RC = [dbo].[pr_ErrorOther_SelectSummaries] 
   @AppID
  ,@EnvironmentID
  ,@ClientID
  ,@ErrorType
  ,@MinimumSeverity
  ,@StartDate
  ,@EndDate
  ,@IncludeDetail



  */



--Expect to see ErrorOtherID: 7134

/*
;WITH Occurences AS (
				SELECT ErrorOther.ID AS ErrorOtherID
					, MAX([ErrorOtherLog].[TimeStamp]) AS LastTime
				FROM [dbo].[ErrorOtherLog]
					JOIN [dbo].[ErrorOther]
						ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
				WHERE [ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate
				GROUP BY ErrorOther.ID
		)
SELECT [ErrorOther].[ID] AS ErrorOtherID
		, [ErrorOther].[AppID] AS ErrorOtherAppID
		, [ErrorOther].[EnvironmentID] AS ErrorOtherEnvironmentID
		, [ErrorOther].[ClientID] AS ErrorOtherClientID
		, [ErrorOther].[FirstTime] AS ErrorOtherFirstTime
		, [ErrorOther].[LastTime] AS ErrorOtherLastTime
		, [ErrorOther].[Count] AS ErrorOtherCount
		, [ErrorOther].[ErrorType] AS ErrorOtherErrorType
		, [ErrorOther].[Severity] AS ErrorOtherSeverity
		, [ErrorOther].[ExceptionType] AS ErrorOtherExceptionType
		, [ErrorOther].[ErrorCode] AS ErrorOtherErrorCode
		, [ErrorOther].[CodeMethod] AS ErrorOtherCodeMethod
		, [ErrorOther].[CodeFileName] AS ErrorOtherCodeFileName
		, [ErrorOther].[CodeLineNumber] AS ErrorOtherCodeLineNumber
		, [ErrorOther].[CodeColumnNumber] AS ErrorOtherCodeColumnNumber
		, [ErrorOther].[ErrorName] AS ErrorOtherErrorName
		, [ErrorOther].[ErrorURL] AS ErrorOtherErrorURL
		, [ErrorOther].[UserAgent] AS ErrorOtherUserAgent
		, [ErrorOther].[UserType] AS ErrorOtherUserType
		, [ErrorOther].[UserID] AS ErrorOtherUserID
		, [ErrorOther].[CustomID] AS ErrorOtherCustomID
		, [ErrorOther].[AppName] AS ErrorOtherAppName
		, [ErrorOther].[MachineName] AS ErrorOtherMachineName
		, [ErrorOther].[Custom1] AS ErrorOtherCustom1
		, [ErrorOther].[Custom2] AS ErrorOtherCustom2
		, [ErrorOther].[Custom3] AS ErrorOtherCustom3
		, [ErrorOther].[Duration] AS ErrorOtherDuration
		FROM [dbo].[ErrorOther]
			JOIN Occurences
				ON Occurences.[ErrorOtherID] = [ErrorOther].[ID]
		WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
		AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
		AND ([ErrorOther].[ErrorType] = @ErrorType OR @ErrorType IS NULL)
		AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
		ORDER BY Occurences.[LastTime] DESC

		*/


