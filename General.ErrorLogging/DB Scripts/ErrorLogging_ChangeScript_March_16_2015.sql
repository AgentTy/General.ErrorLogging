ALTER TABLE [dbo].[ErrorOther]
ADD [Severity] [smallint] NULL
GO




DROP PROCEDURE [dbo].[pr_ErrorOther_Insert]
/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Insert]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_ErrorOther_Insert]
	@AppID [Int]
	,@EnvironmentID [SmallInt]
	,@ClientID [varchar](50) = NULL
	,@ErrorType [SmallInt]
	,@Severity [SmallInt] = NULL
	,@ExceptionType [VarChar](200) = NULL
	,@ErrorCode [VarChar](20) = NULL
	,@ErrorName [VarChar](200)
	,@CodeMethod [VarChar](200) = NULL
	,@CodeFileName [VarChar](200) = NULL
	,@CodeLineNumber [SmallInt] = NULL
	,@CodeColumnNumber [SmallInt] = NULL
	,@ErrorDetail [VarChar](MAX) = NULL
	,@ErrorURL [VarChar](200) = NULL
	,@UserAgent [VarChar](400) = NULL
	,@UserType [varchar](50) = NULL
	,@UserID [varchar](50) = NULL
	,@CustomID [Int] = NULL
	,@AppName [VarChar](100) = NULL
	,@MachineName [VarChar](20) = NULL
	,@Custom1 [VarChar](200) = NULL
	,@Custom2 [VarChar](200) = NULL
	,@Custom3 [VarChar](200) = NULL
	,@TimeStamp [DateTime] = NULL
AS

	IF @TimeStamp IS NULL
	BEGIN
		SET @TimeStamp = GETDATE()
	END

	DECLARE @ErrorID [Int]
	SELECT TOP 1 @ErrorID = [ID] FROM [dbo].[ErrorOther] 
	WHERE [ErrorType] = @ErrorType
	AND ([ExceptionType] = @ExceptionType OR ([ExceptionType] IS NULL AND @ExceptionType IS NULL))
	AND ([ErrorName] = @ErrorName OR ([ErrorName] IS NULL AND @ErrorName IS NULL))
	AND ([ErrorCode] = @ErrorCode OR ([ErrorCode] IS NULL AND @ErrorCode IS NULL))
	AND ([CodeMethod] = @CodeMethod OR ([CodeMethod] IS NULL AND @CodeMethod IS NULL))
	AND ([CodeFileName] = @CodeFileName OR ([CodeFileName] IS NULL AND @CodeFileName IS NULL))
	AND ([CodeLineNumber] = @CodeLineNumber OR ([CodeLineNumber] IS NULL AND @CodeLineNumber IS NULL))
	AND ([CodeColumnNumber] = @CodeColumnNumber OR ([CodeColumnNumber] IS NULL AND @CodeColumnNumber IS NULL))
	AND ([dbo].[fn_RemoveQueryStringFromURL]([ErrorURL]) = [dbo].[fn_RemoveQueryStringFromURL](@ErrorURL) OR ([ErrorURL] IS NULL AND @ErrorURL IS NULL))
	AND ([AppID] = @AppID OR ([AppID] IS NULL AND @AppID IS NULL))
	AND ([EnvironmentID] = @EnvironmentID OR ([EnvironmentID] IS NULL AND @EnvironmentID IS NULL))
	AND ([ClientID] = @ClientID OR ([ClientID] IS NULL AND @ClientID IS NULL))
	AND ([AppName] = @AppName OR ([AppName] IS NULL AND @AppName IS NULL))
	AND DATEDIFF(MONTH, [ErrorOther].[LastTime], @TimeStamp) = 0 

	IF @ErrorID IS NULL
	BEGIN
		INSERT [dbo].[ErrorOther]
		( 
		[AppID]
		,[EnvironmentID]
		,[ClientID]
		,[ErrorType]
		,[Severity]
		,[ExceptionType]
		,[CodeMethod]
		,[CodeFileName]
		,[CodeLineNumber]
		,[CodeColumnNumber]
		,[ErrorCode]
		,[ErrorName]
		,[ErrorDetail]
		,[ErrorURL]
		,[UserAgent]
		,[UserType]
		,[UserID]
		,[CustomID]
		,[AppName]
		,[MachineName]
		,[Custom1]
		,[Custom2]
		,[Custom3]
		)
		VALUES
		(
		 @AppID
		,@EnvironmentID
		,@ClientID
		,@ErrorType
		,@Severity
		,@ExceptionType
		,@CodeMethod
		,@CodeFileName
		,@CodeLineNumber
		,@CodeColumnNumber
		,@ErrorCode
		,@ErrorName
		,@ErrorDetail
		,@ErrorURL
		,@UserAgent
		,@UserType
		,@UserID
		,@CustomID
		,@AppName
		,@MachineName
		,@Custom1
		,@Custom2
		,@Custom3
		)

		SET @ErrorID = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		UPDATE [dbo].[ErrorOther]
		SET [Count] = [Count] + 1
		, [LastTime] = @TimeStamp
		, [ClientID] = @ClientID
		, [ErrorType] = @ErrorType
		, [Severity] = @Severity
		, [ExceptionType] = @ExceptionType
		, [ErrorName] = @ErrorName
		, [ErrorCode] = COALESCE(@ErrorCode, [ErrorCode])
		, [CodeMethod] = COALESCE(@CodeMethod, [CodeMethod])
		, [CodeFileName] = COALESCE(@CodeFileName, [CodeFileName])
		, [CodeLineNumber] = COALESCE(@CodeLineNumber, [CodeLineNumber])
		, [CodeColumnNumber] = COALESCE(@CodeColumnNumber, [CodeColumnNumber])
		, [ErrorDetail] = COALESCE(@ErrorDetail, [ErrorDetail])
		, [ErrorURL] = COALESCE(@ErrorURL, [ErrorURL])
		, [UserAgent] = COALESCE(@UserAgent, [UserAgent])
		, [UserType] = COALESCE(@UserType, [UserType])
		, [UserID] = COALESCE(@UserID, [UserID])
		, [CustomID] = COALESCE(@CustomID, [CustomID])
		, [AppName] = COALESCE(@AppName, [AppName])
		, [MachineName] = COALESCE(@MachineName, [MachineName])
		, [Custom1] = COALESCE(@Custom1, [Custom1])
		, [Custom2] = COALESCE(@Custom2, [Custom2])
		, [Custom3] = COALESCE(@Custom3, [Custom3])
		WHERE [ID] = @ErrorID
	END

	INSERT INTO ErrorOtherLog
	SELECT @ErrorID
	, @TimeStamp
	, @ClientID
	, @UserType
	, @UserID
	, @CustomID
	, @UserAgent
	, @Custom1
	, @Custom2
	, @Custom3

	--EXEC [dbo].[pr_ErrorOther_Select] @ErrorID

GO
/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Select]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE [dbo].[pr_ErrorOther_Select]
GO

CREATE PROCEDURE [dbo].[pr_ErrorOther_Select]
	@ErrorOtherID [Int]
AS
	SET NOCOUNT ON

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
	, [ErrorOther].[ErrorDetail] AS ErrorOtherErrorDetail
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
	FROM [dbo].[ErrorOther]
	WHERE [ErrorOther].[ID] = @ErrorOtherID



GO
/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectAll]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE [dbo].[pr_ErrorOther_SelectAll]
GO

CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectAll]
	@AppID [Int] = NULL
	, @EnvironmentID [Int] = NULL 
	, @ClientID [varchar](50) = NULL
	, @ErrorType [SmallInt] = NULL 
	, @MinimumSeverity [SmallInt] = NULL
	, @StartDate [DateTime] 
	, @EndDate [DateTime]
AS
	SET NOCOUNT ON

	SET @EndDate = [dbo].[fn_PrepFutureDateByEndOfDay](@EndDate)

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
	, [ErrorOther].[ErrorDetail] AS ErrorOtherErrorDetail
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


GO



/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Update]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE [dbo].[pr_ErrorOther_Update]
GO

CREATE PROCEDURE [dbo].[pr_ErrorOther_Update]
	@ErrorOtherID [Int]
	,@ErrorType [SmallInt]
	,@Severity [SmallInt] = NULL
	,@ExceptionType [VarChar](200) = NULL
	,@ErrorCode [VarChar](20)
	,@ErrorName [VarChar](200)
	,@CodeMethod [VarChar](200) = NULL
	,@CodeFileName [VarChar](200) = NULL
	,@CodeLineNumber [SmallInt] = NULL
	,@CodeColumnNumber [SmallInt] = NULL
	,@ErrorDetail [VarChar](5000) = NULL
	,@ErrorURL [VarChar](200) = NULL
	,@UserAgent [VarChar](400) = NULL
	,@UserType [varchar](50) = NULL
	,@UserID [varchar](50) = NULL
	,@CustomID [Int] = NULL
	,@AppName [VarChar](100) = NULL
	,@MachineName [VarChar](20) = NULL
	,@Custom1 [VarChar](200) = NULL
	,@Custom2 [VarChar](200) = NULL
	,@Custom3 [VarChar](200) = NULL
AS
	UPDATE [dbo].[ErrorOther]
	SET [ErrorType] = @ErrorType
	,[Severity] = @Severity
	,[ExceptionType] = @ExceptionType
	,[ErrorCode] = @ErrorCode
	,[ErrorName] = @ErrorName
	,[CodeMethod] = @CodeMethod
	,[CodeFileName] = @CodeFileName
	,[CodeLineNumber] = @CodeLineNumber
	,[CodeColumnNumber] = @CodeColumnNumber
	,[ErrorDetail] = @ErrorDetail
	,[ErrorURL] = @ErrorURL
	,[UserAgent] = @UserAgent
	,[UserType] = @UserType
	,[UserID] = @UserID
	,[CustomID] = @CustomID
	,[AppName] = @AppName
	,[MachineName] = @MachineName
	,[Custom1] = @Custom1
	,[Custom2] = @Custom2
	,[Custom3] = @Custom3
	WHERE [ID] = @ErrorOtherID

	EXEC [dbo].[pr_ErrorOther_Select] @ErrorOtherID


GO