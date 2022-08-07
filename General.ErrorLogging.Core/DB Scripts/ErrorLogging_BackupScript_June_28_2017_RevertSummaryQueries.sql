/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries]    Script Date: 6/28/2017 11:17:46 AM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectSummaries]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries]    Script Date: 6/28/2017 11:17:46 AM ******/
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
			LEFT JOIN [dbo].[ErrorOtherDetail]
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


GO


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries_Multi]    Script Date: 6/28/2017 11:17:37 AM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectSummaries_Multi]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries_Multi]    Script Date: 6/28/2017 11:17:37 AM ******/
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

