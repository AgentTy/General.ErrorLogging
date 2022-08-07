DROP TABLE [dbo].[ErrorOtherLog]
/****** Object:  Table [dbo].[ErrorOtherLog]    Script Date: 1/23/2015 10:25:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorOtherLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorOtherID] [int] NOT NULL,
	[TimeStamp] [datetime] NOT NULL,
	[ClientID] [int] NULL,
	[UserType] [int] NULL,
	[UserID] [int] NULL,
	[CustomID] [int] NULL,
	[UserAgent] [varchar](400) NULL,
	[Custom1] [varchar](200) NULL,
	[Custom2] [varchar](200) NULL,
	[Custom3] [varchar](200) NULL,
 CONSTRAINT [PK_ErrorOtherLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Error404] ALTER COLUMN [UserAgent] varchar(400)
GO

ALTER TABLE [dbo].[ErrorOther]
ADD [CodeColumnNumber] [smallint] NULL
GO

ALTER TABLE [dbo].[ErrorOther]
ADD [UserAgent] [varchar](400) NULL
GO

/****** Object:  StoredProcedure [dbo].[pr_Error404_Delete]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_Error404_Delete]
	@Error404ID [Int]
AS
	SET NOCOUNT ON

	DELETE FROM [dbo].[Error404]
	WHERE [Error404].[ID] = @Error404ID


GO
/****** Object:  StoredProcedure [dbo].[pr_Error404_Insert]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[pr_Error404_Insert]
	@AppID [Int]
	,@EnvironmentID [SmallInt]
	,@ClientID [Int] = NULL
	,@URL [VarChar](200)
	,@UserAgent [VarChar](400) = NULL
	,@Detail [VarChar](5000) = NULL
AS

	DECLARE @Error404ID [Int]
	SELECT TOP 1 @Error404ID = [ID] 
	FROM [dbo].[Error404] 
	WHERE [URL] = @URL 
		AND DATEDIFF(MONTH, [Error404].[LastTime], GETDATE()) = 0 
		AND [AppID] = @AppID 
		AND [EnvironmentID] = @EnvironmentID 
		AND ([ClientID] = @ClientID OR ([ClientID] IS NULL AND @ClientID IS NULL))

	IF @Error404ID IS NULL
	BEGIN
		INSERT [dbo].[Error404]
		( 
		[AppID]
		,[EnvironmentID]
		,[ClientID]
		,[URL]
		,[UserAgent]
		,[Detail]
		)
		VALUES
		(
		 @AppID
		,@EnvironmentID
		,@ClientID
		,@URL
		,@UserAgent
		,@Detail
		)

		SET @Error404ID = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		UPDATE [dbo].[Error404]
		SET [Count] = [Count] + 1
		, [LastTime] = GETDATE()
		, [UserAgent] = COALESCE(@UserAgent, [UserAgent])
		, [Detail] = COALESCE(@Detail, [Detail])
		WHERE [ID] = @Error404ID
	END

	EXEC [dbo].[pr_Error404_Select] @Error404ID


GO
/****** Object:  StoredProcedure [dbo].[pr_Error404_Select]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--DROP PROCEDURE [dbo].[pr_Error404_Select]
--GO
ALTER PROCEDURE [dbo].[pr_Error404_Select]
	@Error404ID [Int]
AS
	SET NOCOUNT ON

	SELECT [Error404].[ID] AS Error404ID
	, [Error404].[AppID] AS Error404AppID
	, [Error404].[EnvironmentID] AS Error404EnvironmentID
	, [Error404].[ClientID] AS Error404ClientID
	, [Error404].[FirstTime] AS Error404FirstTime
	, [Error404].[LastTime] AS Error404LastTime
	, [Error404].[URL] AS Error404URL
	, [Error404].[Count] AS Error404Count
	, [Error404].[Hide] AS Error404Hide
	, [Error404].[UserAgent] AS Error404UserAgent
	, [Error404].[Detail] AS Error404Detail
	, [Application].[Name] AS AppName
	, [Application].[URL] AS AppURL
	FROM [dbo].[Error404]
		LEFT JOIN [dbo].[Application]
			ON [Application].[ID] = [AppID]
	WHERE [Error404].[ID] = @Error404ID


GO
/****** Object:  StoredProcedure [dbo].[pr_Error404_SelectAll]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_Error404_SelectAll]
	@AppID [Int]
	, @EnvironmentID [SmallInt] = NULL
	, @ClientID [Int] = NULL 
	, @StartDate [DateTime] 
	, @EndDate [DateTime]
	, @ReturnHidden [Bit] = 0
	, @ReturnCommonOnly [Bit] = 0
AS
	SET NOCOUNT ON

	SET @EndDate = [dbo].[fn_PrepFutureDateByEndOfDay](@EndDate)

	SELECT TOP 500 [Error404].[ID] AS Error404ID
	, [Error404].[AppID] AS Error404AppID
	, [Error404].[EnvironmentID] AS Error404EnvironmentID
	, [Error404].[ClientID] AS Error404ClientID
	, [Error404].[FirstTime] AS Error404FirstTime
	, [Error404].[LastTime] AS Error404LastTime
	, [Error404].[URL] AS Error404URL
	, [Error404].[Count] AS Error404Count
	, [Error404].[Hide] AS Error404Hide
	, [Error404].[UserAgent] AS Error404UserAgent
	, [Error404].[Detail] AS Error404Detail
	FROM [dbo].[Error404]
	WHERE [Error404].[AppID] = @AppID
	AND [Error404].[EnvironmentID] = COALESCE(@EnvironmentID, [Error404].[EnvironmentID])
	AND ([Error404].[ClientID] = @ClientID OR @ClientID IS NULL)
	AND ([Error404].[Hide] = 0 OR @ReturnHidden = 1)
	AND ([Error404].[Count] > 5 OR @ReturnCommonOnly = 0)
	AND (
		([Error404].[FirstTime] BETWEEN @StartDate AND @EndDate)
		OR
		([Error404].[LastTime] BETWEEN @StartDate AND @EndDate)
	)
	ORDER BY CONVERT(DATE, [Error404].[LastTime]) DESC, [Error404].[Count] DESC


GO
/****** Object:  StoredProcedure [dbo].[pr_Error404_Update]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_Error404_Update]
	@Error404ID [Int]
	,@URL [VarChar](200)
	,@Count [SmallInt]
	,@Hide [Bit]
	,@UserAgent [VarChar](400) = NULL
	,@Detail [VarChar](5000) = NULL
AS
	UPDATE [dbo].[Error404]
	SET [URL] = @URL
	,[Count] = @Count
	,[Hide] = @Hide
	,[UserAgent] = @UserAgent
	,[Detail] = @Detail
	WHERE [ID] = @Error404ID

	EXEC [dbo].[pr_Error404_Select] @Error404ID

GO
/****** Object:  StoredProcedure [dbo].[pr_Error404_UpdateVisibility]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_Error404_UpdateVisibility]
	@Error404ID [Int]
	, @Hide [Bit]
AS
	SET NOCOUNT ON

	UPDATE [dbo].[Error404]
	SET [Hide] = @Hide
	WHERE [Error404].[ID] = @Error404ID


GO
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_Delete]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_Error404Redirect_Delete]
	@Error404RedirectID [Int]
AS
	SET NOCOUNT ON

	DELETE FROM [dbo].[Error404Redirect]
	WHERE [Error404Redirect].[ID] = @Error404RedirectID


GO
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_Insert]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_Error404Redirect_Insert]
	@AppID [Int]
	,@ClientID [Int] = NULL
	,@RedirectType [SmallInt]
	,@From [VarChar](300)
	,@To [VarChar](300)
AS
	INSERT [dbo].[Error404Redirect]
	( 
	[AppID]
	,[ClientID]
	,[RedirectType]
	,[From]
	,[To]
	)
	VALUES
	(
	 @AppID
	,@ClientID
	,@RedirectType
	,@From
	,@To
	)

	DECLARE @Error404RedirectID [Int]
	SET @Error404RedirectID = SCOPE_IDENTITY()

	EXEC [dbo].[pr_Error404Redirect_Select] @Error404RedirectID

GO
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_Select]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[pr_Error404Redirect_Select]
--GO
ALTER PROCEDURE [dbo].[pr_Error404Redirect_Select]
	@Error404RedirectID [Int]
AS
	SET NOCOUNT ON

	SELECT [Error404Redirect].[ID] AS Error404RedirectID
	, [Error404Redirect].[AppID] AS Error404RedirectAppID
	, [Error404Redirect].[ClientID] AS Error404RedirectClientID
	, [Error404Redirect].[CreateDate] AS Error404RedirectCreateDate
	, [Error404Redirect].[ModifyDate] AS Error404RedirectModifyDate
	, [Error404Redirect].[RedirectType] AS Error404RedirectRedirectType
	, [Error404Redirect].[From] AS Error404RedirectFrom
	, [Error404Redirect].[To] AS Error404RedirectTo
	, [Error404Redirect].[FirstTime] AS Error404RedirectFirstTime
	, [Error404Redirect].[LastTime] AS Error404RedirectLastTime
	, [Error404Redirect].[Count] AS Error404RedirectCount
	, [Application].[Name] AS AppName
	, [Application].[URL] AS AppURL
	FROM [dbo].[Error404Redirect]
		LEFT JOIN [dbo].[Application]
			ON [Application].[ID] = [AppID]
	WHERE [Error404Redirect].[ID] = @Error404RedirectID


GO
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_SelectAll]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[pr_Error404Redirect_SelectAll] 
--GO
ALTER PROCEDURE [dbo].[pr_Error404Redirect_SelectAll]
	@AppID [Int]
	, @ClientID [Int] = NULL 
AS
	SET NOCOUNT ON

	SELECT [Error404Redirect].[ID] AS Error404RedirectID
	, [Error404Redirect].[AppID] AS Error404RedirectAppID
	, [Error404Redirect].[ClientID] AS Error404RedirectClientID
	, [Error404Redirect].[CreateDate] AS Error404RedirectCreateDate
	, [Error404Redirect].[ModifyDate] AS Error404RedirectModifyDate
	, [Error404Redirect].[RedirectType] AS Error404RedirectRedirectType
	, [Error404Redirect].[From] AS Error404RedirectFrom
	, [Error404Redirect].[To] AS Error404RedirectTo
	, [Error404Redirect].[FirstTime] AS Error404RedirectFirstTime
	, [Error404Redirect].[LastTime] AS Error404RedirectLastTime
	, [Error404Redirect].[Count] AS Error404RedirectCount
	, [Application].[Name] AS AppName
	, [Application].[URL] AS AppURL
	FROM [dbo].[Error404Redirect]
		LEFT JOIN [dbo].[Application]
			ON [Application].[ID] = [AppID]
	WHERE [Error404Redirect].[AppID] = @AppID
	AND ([Error404Redirect].[ClientID] = @ClientID OR @ClientID IS NULL)
	ORDER BY [Error404Redirect].[LastTime] DESC

GO
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_SelectByFrom]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_Error404Redirect_SelectByFrom]
	@AppID [Int],
	@ClientID [Int] = NULL,
	@From [VarChar](300)
AS
	SET NOCOUNT ON

	SELECT [Error404Redirect].[ID] AS Error404RedirectID
	, [Error404Redirect].[AppID] AS Error404RedirectAppID
	, [Error404Redirect].[ClientID] AS Error404RedirectClientID
	, [Error404Redirect].[CreateDate] AS Error404RedirectCreateDate
	, [Error404Redirect].[ModifyDate] AS Error404RedirectModifyDate
	, [Error404Redirect].[RedirectType] AS Error404RedirectRedirectType
	, [Error404Redirect].[From] AS Error404RedirectFrom
	, [Error404Redirect].[To] AS Error404RedirectTo
	, [Error404Redirect].[FirstTime] AS Error404RedirectFirstTime
	, [Error404Redirect].[LastTime] AS Error404RedirectLastTime
	, [Error404Redirect].[Count] AS Error404RedirectCount
	FROM [dbo].[Error404Redirect]
	WHERE [Error404Redirect].[AppID] = @AppID
		AND ([Error404Redirect].[ClientID] = @ClientID OR [Error404Redirect].[ClientID] IS NULL)
		AND [Error404Redirect].[From] = @From


GO
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_Update]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_Error404Redirect_Update]
	@Error404RedirectID [Int]
	,@RedirectType [SmallInt]
	,@From [VarChar](300)
	,@To [VarChar](300)
	,@FirstTime [DateTime]
	,@LastTime [DateTime]
	,@Count [Int]
AS
	UPDATE [dbo].[Error404Redirect]
	SET [ModifyDate] = GETDATE()
	,[RedirectType] = @RedirectType
	,[From] = @From
	,[To] = @To
	,[FirstTime] = @FirstTime
	,[LastTime] = @LastTime
	,[Count] = @Count
	WHERE [ID] = @Error404RedirectID

	EXEC [dbo].[pr_Error404Redirect_Select] @Error404RedirectID

GO
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_UpdateLog]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_Error404Redirect_UpdateLog]
	@Error404RedirectID [Int]
	,@FirstTime [DateTime]
	,@LastTime [DateTime]
	,@Count [Int]
AS
	UPDATE [dbo].[Error404Redirect]
	SET [ModifyDate] = GETDATE()
	,[FirstTime] = @FirstTime
	,[LastTime] = @LastTime
	,[Count] = @Count
	WHERE [ID] = @Error404RedirectID

	EXEC [dbo].[pr_Error404Redirect_Select] @Error404RedirectID

GO
/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Delete]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_ErrorOther_Delete]
	@ErrorOtherID [Int]
AS
	SET NOCOUNT ON

	DELETE FROM [dbo].[ErrorOther]
	WHERE [ErrorOther].[ID] = @ErrorOtherID


GO

--DROP PROCEDURE [dbo].[pr_ErrorOther_Insert]
/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Insert]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pr_ErrorOther_Insert]
	@AppID [Int]
	,@EnvironmentID [SmallInt]
	,@ClientID [Int] = NULL
	,@ErrorType [SmallInt]
	,@ExceptionType [VarChar](200)
	,@ErrorCode [VarChar](20)
	,@ErrorName [VarChar](200)
	,@CodeFileName [VarChar](200) = NULL
	,@CodeLineNumber [SmallInt] = NULL
	,@CodeColumnNumber [SmallInt] = NULL
	,@ErrorDetail [VarChar](MAX) = NULL
	,@ErrorURL [VarChar](200) = NULL
	,@UserAgent [VarChar](400) = NULL
	,@UserType [Int] = NULL
	,@UserID [Int] = NULL
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
	WHERE [ExceptionType] = @ExceptionType 
	AND [ErrorType] = @ErrorType
	AND [ErrorName] = @ErrorName 
	AND ([ErrorCode] = @ErrorCode OR ([ErrorCode] IS NULL AND @ErrorCode IS NULL))
	AND ([CodeFileName] = @CodeFileName OR ([CodeFileName] IS NULL AND @CodeFileName IS NULL))
	AND ([CodeLineNumber] = @CodeLineNumber OR ([CodeLineNumber] IS NULL AND @CodeLineNumber IS NULL))
	AND ([CodeColumnNumber] = @CodeColumnNumber OR ([CodeColumnNumber] IS NULL AND @CodeColumnNumber IS NULL))
	AND ([ErrorURL] = @ErrorURL OR ([ErrorURL] IS NULL AND @ErrorURL IS NULL))
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
		,[ExceptionType]
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
		,@ExceptionType
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
		, [ExceptionType] = @ExceptionType
		, [ErrorName] = @ErrorName
		, [ErrorCode] = COALESCE(@ErrorCode, [ErrorCode])
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


ALTER PROCEDURE [dbo].[pr_ErrorOther_Select]
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
	, [ErrorOther].[ExceptionType] AS ErrorOtherExceptionType
	, [ErrorOther].[ErrorCode] AS ErrorOtherErrorCode
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


ALTER PROCEDURE [dbo].[pr_ErrorOther_SelectAll]
	@AppID [Int] = NULL
	, @EnvironmentID [Int] = NULL 
	, @ClientID [Int] = NULL 
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
	, [ErrorOther].[ExceptionType] AS ErrorOtherExceptionType
	, [ErrorOther].[ErrorCode] AS ErrorOtherErrorCode
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


ALTER PROCEDURE [dbo].[pr_ErrorOther_Update]
	@ErrorOtherID [Int]
	,@ErrorType [SmallInt]
	,@ExceptionType [VarChar](200)
	,@ErrorCode [VarChar](20)
	,@ErrorName [VarChar](200)
	,@CodeFileName [VarChar](200) = NULL
	,@CodeLineNumber [SmallInt] = NULL
	,@CodeColumnNumber [SmallInt] = NULL
	,@ErrorDetail [VarChar](5000) = NULL
	,@ErrorURL [VarChar](200) = NULL
	,@UserAgent [VarChar](400) = NULL
	,@UserType [Int] = NULL
	,@UserID [Int] = NULL
	,@CustomID [Int] = NULL
	,@AppName [VarChar](100) = NULL
	,@MachineName [VarChar](20) = NULL
	,@Custom1 [VarChar](200) = NULL
	,@Custom2 [VarChar](200) = NULL
	,@Custom3 [VarChar](200) = NULL
AS
	UPDATE [dbo].[ErrorOther]
	SET [ErrorType] = @ErrorType
	,[ExceptionType] = @ExceptionType
	,[ErrorCode] = @ErrorCode
	,[ErrorName] = @ErrorName
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