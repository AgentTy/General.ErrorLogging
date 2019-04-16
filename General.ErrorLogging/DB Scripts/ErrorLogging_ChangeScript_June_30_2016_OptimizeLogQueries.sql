/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectLog_Multi]    Script Date: 6/30/2016 10:55:17 AM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectLog_Multi]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectLog_Multi]    Script Date: 6/30/2016 10:55:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectLog_Multi]
	@Apps IDListType READONLY
	, @EnvironmentID [Int] = NULL 
	, @ClientID [varchar](50) = NULL
	, @EventTypes IDListType READONLY
	, @MinimumSeverity [SmallInt] = NULL
	, @StartDate [DateTimeOffset] 
	, @EndDate [DateTimeOffset]
	, @IncludeDetail [Bit] = 1
AS
	SET NOCOUNT ON

	SET @EndDate = [dbo].[fn_PrepFutureDateByEndOfDay](@EndDate)

	IF @IncludeDetail = 1
	BEGIN
		SELECT [ErrorOtherLog].[ID] AS ErrorOtherLogID
		, [ErrorOtherLog].[TimeStamp] AS ErrorOtherLogTimeStamp
		, [ErrorOther].[ID] AS ErrorOtherID
		, [ErrorOther].[AppID] AS ErrorOtherAppID
		, [ErrorOther].[EnvironmentID] AS ErrorOtherEnvironmentID
		, [ErrorOtherLog].[ClientID] AS ErrorOtherClientID
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
		, [ErrorOtherDetail].[Content] AS ErrorOtherErrorDetail
		, [ErrorOtherDetail].[ID] AS ErrorOtherErrorDetailID
		, [ErrorOtherLog].[URL] AS ErrorOtherErrorURL
		, [ErrorOtherLog].[UserAgent] AS ErrorOtherUserAgent
		, [ErrorOtherLog].[UserType] AS ErrorOtherUserType
		, [ErrorOtherLog].[UserID] AS ErrorOtherUserID
		, [ErrorOtherLog].[CustomID] AS ErrorOtherCustomID
		, [ErrorOther].[AppName] AS ErrorOtherAppName
		, [ErrorOtherLog].[MachineName] AS ErrorOtherMachineName
		, [ErrorOtherLog].[Custom1] AS ErrorOtherCustom1
		, [ErrorOtherLog].[Custom2] AS ErrorOtherCustom2
		, [ErrorOtherLog].[Custom3] AS ErrorOtherCustom3
		, [ErrorOtherLog].[Duration] AS ErrorOtherDuration
		FROM [dbo].[ErrorOtherLog]
			JOIN [dbo].[ErrorOther]
				ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
			JOIN @EventTypes eventMatch
				ON eventMatch.ID = [ErrorOther].[ErrorType]
			LEFT JOIN @Apps appMatch
				ON appMatch.ID = [ErrorOther].[AppID]
			LEFT JOIN [dbo].[ErrorOtherDetail]
				ON [ErrorOtherDetail].[ID] = [ErrorOtherLog].[DetailID]
		WHERE (appMatch.ID IS NOT NULL OR (SELECT COUNT(1) FROM @Apps) = 0)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
		AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
		AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
		AND ([ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate)
		ORDER BY [ErrorOtherLog].[TimeStamp] DESC
	END
	ELSE
	BEGIN
		SELECT [ErrorOtherLog].[ID] AS ErrorOtherLogID
		, [ErrorOtherLog].[TimeStamp] AS ErrorOtherLogTimeStamp
		, [ErrorOther].[ID] AS ErrorOtherID
		, [ErrorOther].[AppID] AS ErrorOtherAppID
		, [ErrorOther].[EnvironmentID] AS ErrorOtherEnvironmentID
		, [ErrorOtherLog].[ClientID] AS ErrorOtherClientID
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
		, [ErrorOtherLog].[URL] AS ErrorOtherErrorURL
		, [ErrorOtherLog].[UserAgent] AS ErrorOtherUserAgent
		, [ErrorOtherLog].[UserType] AS ErrorOtherUserType
		, [ErrorOtherLog].[UserID] AS ErrorOtherUserID
		, [ErrorOtherLog].[CustomID] AS ErrorOtherCustomID
		, [ErrorOther].[AppName] AS ErrorOtherAppName
		, [ErrorOtherLog].[MachineName] AS ErrorOtherMachineName
		, [ErrorOtherLog].[Custom1] AS ErrorOtherCustom1
		, [ErrorOtherLog].[Custom2] AS ErrorOtherCustom2
		, [ErrorOtherLog].[Custom3] AS ErrorOtherCustom3
		, [ErrorOtherLog].[Duration] AS ErrorOtherDuration
		FROM [dbo].[ErrorOtherLog]
			JOIN [dbo].[ErrorOther]
				ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
			JOIN @EventTypes eventMatch
				ON eventMatch.ID = [ErrorOther].[ErrorType]
			LEFT JOIN @Apps appMatch
				ON appMatch.ID = [ErrorOther].[AppID]
		WHERE (appMatch.ID IS NOT NULL OR (SELECT COUNT(1) FROM @Apps) = 0)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
		AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
		AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
		AND ([ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate)
		ORDER BY [ErrorOtherLog].[TimeStamp] DESC
	END


GO



/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries_Multi]    Script Date: 6/30/2016 10:55:29 AM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectSummaries_Multi]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries_Multi]    Script Date: 6/30/2016 10:55:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectSummaries_Multi]
	@Apps IDListType READONLY
	, @EnvironmentID [Int] = NULL 
	, @ClientID [varchar](50) = NULL
	, @EventTypes IDListType READONLY
	, @MinimumSeverity [SmallInt] = NULL
	, @StartDate [DateTimeOffset] 
	, @EndDate [DateTimeOffset]
	, @IncludeDetail [Bit] = 1
AS
	SET NOCOUNT ON

	SET @EndDate = [dbo].[fn_PrepFutureDateByEndOfDay](@EndDate)

	IF @IncludeDetail = 1
	BEGIN
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
		, [ErrorOtherDetail].[Content] AS ErrorOtherErrorDetail
		, [ErrorOtherDetail].[ID] AS ErrorOtherErrorDetailID
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
			JOIN @EventTypes eventMatch
				ON eventMatch.ID = [ErrorOther].[ErrorType]
			LEFT JOIN @Apps appMatch
				ON appMatch.ID = [ErrorOther].[AppID]
			LEFT JOIN [dbo].[ErrorOtherDetail]
				ON [ErrorOtherDetail].[ID] = [ErrorOther].[DetailID]
		WHERE (appMatch.ID IS NOT NULL OR (SELECT COUNT(1) FROM @Apps) = 0)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
		AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
		AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
		AND (
			([ErrorOther].[FirstTime] BETWEEN @StartDate AND @EndDate)
			OR
			([ErrorOther].[LastTime] BETWEEN @StartDate AND @EndDate)
		)
		ORDER BY [ErrorOther].[LastTime] DESC
	END
	ELSE
	BEGIN
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
			JOIN @EventTypes eventMatch
				ON eventMatch.ID = [ErrorOther].[ErrorType]
			LEFT JOIN @Apps appMatch
				ON appMatch.ID = [ErrorOther].[AppID]
		WHERE (appMatch.ID IS NOT NULL OR (SELECT COUNT(1) FROM @Apps) = 0)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
		AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
		AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
		AND (
			([ErrorOther].[FirstTime] BETWEEN @StartDate AND @EndDate)
			OR
			([ErrorOther].[LastTime] BETWEEN @StartDate AND @EndDate)
		)
		ORDER BY [ErrorOther].[LastTime] DESC
	END


GO
