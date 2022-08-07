
/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectLog_Multi]    Script Date: 4/16/2019 11:39:28 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectLog_Multi]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectLog_Multi]    Script Date: 4/16/2019 11:39:28 PM ******/
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
WITH RECOMPILE
AS
	SET NOCOUNT ON

	SET @EndDate = [dbo].[fn_PrepFutureDateByEndOfDay](@EndDate)

	IF @IncludeDetail = 1
	BEGIN
		SELECT TOP 5000 [ErrorOtherLog].[ID] AS ErrorOtherLogID
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
		FROM [dbo].[ErrorOtherLog] WITH (nolock)
			JOIN [dbo].[ErrorOther] WITH (nolock)
				ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
			JOIN @EventTypes eventMatch
				ON eventMatch.ID = [ErrorOther].[ErrorType]
			LEFT JOIN @Apps appMatch
				ON appMatch.ID = [ErrorOther].[AppID]
			LEFT JOIN [dbo].[ErrorOtherDetail] WITH (nolock)
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
		SELECT TOP 5000 [ErrorOtherLog].[ID] AS ErrorOtherLogID
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
		FROM [dbo].[ErrorOtherLog] WITH (nolock)
			JOIN [dbo].[ErrorOther] WITH (nolock)
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


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectLog]    Script Date: 4/16/2019 11:47:24 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectLog]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectLog]    Script Date: 4/16/2019 11:47:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectLog]
	@AppID [Int] = NULL
	, @EnvironmentID [Int] = NULL 
	, @ClientID [varchar](50) = NULL
	, @ErrorType [SmallInt] = NULL 
	, @MinimumSeverity [SmallInt] = NULL
	, @StartDate [DateTimeOffset] 
	, @EndDate [DateTimeOffset]
	, @IncludeDetail [Bit] = 1
WITH RECOMPILE
AS
	SET NOCOUNT ON

	SET @EndDate = [dbo].[fn_PrepFutureDateByEndOfDay](@EndDate)

	IF @IncludeDetail = 1
	BEGIN
		SELECT TOP 5000 [ErrorOtherLog].[ID] AS ErrorOtherLogID
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
		FROM [dbo].[ErrorOtherLog] WITH (nolock)
			JOIN [dbo].[ErrorOther] WITH (nolock)
				ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
			LEFT JOIN [dbo].[ErrorOtherDetail] WITH (nolock)
				ON [ErrorOtherDetail].[ID] = [ErrorOtherLog].[DetailID]
		WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
		AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
		AND ([ErrorOther].[ErrorType] = @ErrorType OR @ErrorType IS NULL)
		AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
		AND ([ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate)
		ORDER BY [ErrorOtherLog].[TimeStamp] DESC
	END
	ELSE
	BEGIN
		SELECT TOP 5000 [ErrorOtherLog].[ID] AS ErrorOtherLogID
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
		FROM [dbo].[ErrorOtherLog] WITH (nolock)
			JOIN [dbo].[ErrorOther] WITH (nolock)
				ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
		WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
		AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
		AND ([ErrorOther].[ErrorType] = @ErrorType OR @ErrorType IS NULL)
		AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
		AND ([ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate)
		ORDER BY [ErrorOtherLog].[TimeStamp] DESC
	END


GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries]    Script Date: 4/16/2019 11:47:38 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectSummaries]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries]    Script Date: 4/16/2019 11:47:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectSummaries]
	@AppID [Int] = NULL
	, @EnvironmentID [Int] = NULL 
	, @ClientID [varchar](50) = NULL
	, @ErrorType [SmallInt] = NULL 
	, @MinimumSeverity [SmallInt] = NULL
	, @StartDate [DateTimeOffset] 
	, @EndDate [DateTimeOffset]
	, @IncludeDetail [Bit] = 1
WITH RECOMPILE
AS
	SET NOCOUNT ON

	SET @EndDate = [dbo].[fn_PrepFutureDateByEndOfDay](@EndDate)

	--When I'm checking today's logs, the fastest possible query is based on the LastDate column on ErrorOther (the header table)
	IF @EndDate >= SYSDATETIMEOFFSET()
	BEGIN
		IF @IncludeDetail = 1
		BEGIN
			SELECT TOP 5000 [ErrorOther].[ID] AS ErrorOtherID
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
			FROM [dbo].[ErrorOther] WITH (nolock)
				LEFT JOIN [dbo].[ErrorOtherDetail] WITH (nolock)
					ON [ErrorOtherDetail].[ID] = [ErrorOther].[DetailID]
			WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
			AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
			AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
			AND ([ErrorOther].[ErrorType] = @ErrorType OR @ErrorType IS NULL)
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
			SELECT TOP 5000 [ErrorOther].[ID] AS ErrorOtherID
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
			FROM [dbo].[ErrorOther] WITH (nolock)
			WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
			AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
			AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
			AND ([ErrorOther].[ErrorType] = @ErrorType OR @ErrorType IS NULL)
			AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
			AND (
				([ErrorOther].[FirstTime] BETWEEN @StartDate AND @EndDate)
				OR
				([ErrorOther].[LastTime] BETWEEN @StartDate AND @EndDate)
			)
			ORDER BY [ErrorOther].[LastTime] DESC
		END
	END 
	ELSE
	--When I'm checking older logs, the fastest query is to get a list of ther ErrorOther (header) rows that occurred in my date range, and use that as a join on the ErrorOther table.
	BEGIN

		IF @IncludeDetail = 1
		BEGIN
			;WITH Occurences AS (
					SELECT ErrorOther.ID AS ErrorOtherID
						, MAX([ErrorOtherLog].[TimeStamp]) AS LastTime
					FROM [dbo].[ErrorOtherLog] WITH (nolock)
						JOIN [dbo].[ErrorOther] WITH (nolock)
							ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
					WHERE [ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate
					GROUP BY ErrorOther.ID
			)
			SELECT TOP 5000 [ErrorOther].[ID] AS ErrorOtherID
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
			FROM [dbo].[ErrorOther] WITH (nolock)
				JOIN Occurences
					ON Occurences.[ErrorOtherID] = [ErrorOther].[ID]
				LEFT JOIN [dbo].[ErrorOtherDetail] WITH (nolock)
					ON [ErrorOtherDetail].[ID] = [ErrorOther].[DetailID]
			WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
			AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
			AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
			AND ([ErrorOther].[ErrorType] = @ErrorType OR @ErrorType IS NULL)
			AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
			ORDER BY Occurences.[LastTime] DESC
		END
		ELSE
		BEGIN
			;WITH Occurences AS (
					SELECT ErrorOther.ID AS ErrorOtherID
						, MAX([ErrorOtherLog].[TimeStamp]) AS LastTime
					FROM [dbo].[ErrorOtherLog] WITH (nolock)
						JOIN [dbo].[ErrorOther] WITH (nolock)
							ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
					WHERE [ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate
					GROUP BY ErrorOther.ID
				)
			SELECT TOP 5000 [ErrorOther].[ID] AS ErrorOtherID
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
			FROM [dbo].[ErrorOther] WITH (nolock)
				JOIN Occurences
					ON Occurences.[ErrorOtherID] = [ErrorOther].[ID]
			WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
			AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
			AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
			AND ([ErrorOther].[ErrorType] = @ErrorType OR @ErrorType IS NULL)
			AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
			ORDER BY Occurences.[LastTime] DESC
		END
	END


GO


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries_Multi]    Script Date: 4/16/2019 11:47:46 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectSummaries_Multi]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries_Multi]    Script Date: 4/16/2019 11:47:46 PM ******/
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
WITH RECOMPILE
AS
	SET NOCOUNT ON

	SET @EndDate = [dbo].[fn_PrepFutureDateByEndOfDay](@EndDate)

	--When I'm checking today's logs, the fastest possible query is based on the LastDate column on ErrorOther (the header table)
	IF @EndDate >= SYSDATETIMEOFFSET()
	BEGIN
		IF @IncludeDetail = 1
		BEGIN
			SELECT TOP 5000 [ErrorOther].[ID] AS ErrorOtherID
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
			FROM [dbo].[ErrorOther] WITH (nolock)
				JOIN @EventTypes eventMatch
					ON eventMatch.ID = [ErrorOther].[ErrorType]
				LEFT JOIN @Apps appMatch
					ON appMatch.ID = [ErrorOther].[AppID]
				LEFT JOIN [dbo].[ErrorOtherDetail] WITH (nolock)
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
			SELECT TOP 5000 [ErrorOther].[ID] AS ErrorOtherID
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
			FROM [dbo].[ErrorOther] WITH (nolock)
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
	END
	ELSE
	--When I'm checking older logs, the fastest query is to get a list of ther ErrorOther (header) rows that occurred in my date range, and use that as a join on the ErrorOther table.
	BEGIN
		IF @IncludeDetail = 1
		BEGIN
			;WITH Occurences AS (
					SELECT ErrorOther.ID AS ErrorOtherID
						, MAX([ErrorOtherLog].[TimeStamp]) AS LastTime
					FROM [dbo].[ErrorOtherLog] WITH (nolock)
						JOIN [dbo].[ErrorOther] WITH (nolock)
							ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
					WHERE [ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate
					GROUP BY ErrorOther.ID
			)
			SELECT TOP 5000 [ErrorOther].[ID] AS ErrorOtherID
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
			FROM [dbo].[ErrorOther] WITH (nolock)
				JOIN Occurences
					ON Occurences.[ErrorOtherID] = [ErrorOther].[ID]
				JOIN @EventTypes eventMatch
					ON eventMatch.ID = [ErrorOther].[ErrorType]
				LEFT JOIN @Apps appMatch
					ON appMatch.ID = [ErrorOther].[AppID]
				LEFT JOIN [dbo].[ErrorOtherDetail] WITH (nolock)
					ON [ErrorOtherDetail].[ID] = [ErrorOther].[DetailID]
			WHERE (appMatch.ID IS NOT NULL OR (SELECT COUNT(1) FROM @Apps) = 0)
			AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
			AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
			AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
			ORDER BY Occurences.[LastTime] DESC
		END
		ELSE
		BEGIN
			;WITH Occurences AS (
				SELECT ErrorOther.ID AS ErrorOtherID
					, MAX([ErrorOtherLog].[TimeStamp]) AS LastTime
				FROM [dbo].[ErrorOtherLog] WITH (nolock)
					JOIN [dbo].[ErrorOther] WITH (nolock)
						ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
				WHERE [ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate
				GROUP BY ErrorOther.ID
			)
			SELECT TOP 5000 [ErrorOther].[ID] AS ErrorOtherID
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
			FROM [dbo].[ErrorOther] WITH (nolock)
				JOIN Occurences
					ON Occurences.[ErrorOtherID] = [ErrorOther].[ID]
				JOIN @EventTypes eventMatch
					ON eventMatch.ID = [ErrorOther].[ErrorType]
				LEFT JOIN @Apps appMatch
					ON appMatch.ID = [ErrorOther].[AppID]
			WHERE (appMatch.ID IS NOT NULL OR (SELECT COUNT(1) FROM @Apps) = 0)
			AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
			AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
			AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
			ORDER BY Occurences.[LastTime] DESC
		END
	END


GO

