--DROP TABLE  [dbo].[LoggingFilter]

/****** Object:  Table [dbo].[LoggingFilter]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[LoggingFilter] (
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](200) NULL,
	[AppID] [int] NOT NULL,
	[ClientFilter] [varchar](600) NOT NULL,
	[UserFilter] [varchar](600) NOT NULL,
	[EnvironmentFilter] [varchar](50) NOT NULL,
	[EventFilter] [varchar](500) NOT NULL,
	[Enabled] [bit] NOT NULL DEFAULT(1),
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[PageEmail] [varchar](254) NULL,
	[PageSMS] [varchar](50) NULL,
	[CreatedBy] [int] NULL,
	[CreateDate] [datetime] NOT NULL DEFAULT(getdate()),
	[ModifyDate] [datetime] NOT NULL DEFAULT(getdate()),
	[Custom1] [varchar](200) NULL,
	[Custom2] [varchar](200) NULL,
	[Custom3] [varchar](200) NULL,
 CONSTRAINT [PK_LoggingFilter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

/*
INSERT INTO [dbo].[LoggingFilter] 
([Name], [AppID], [ClientFilter], [UserFilter], [EnvironmentFilter], [EventFilter], [StartDate], [EndDate], [PageEmail], [PageSMS]) 
VALUES ('Test Filter', 0, '{"all":false,"clients":["LAS","PHX"]}', '{"all":false,"users":["thansen","garrisong"]}', '{"all":false,"environments":[DEV]}', '{"all":false,"events":[6,1]}', '2015-01-01', '2015-04-01', 'hansenty@mac.com', '7022398057')
*/

/*
INSERT INTO [dbo].[LoggingFilter] 
([Name], [AppFilter], [ClientFilter], [UserFilter], [EnvironmentFilter], [EventFilter], [StartDate], [EndDate], [PageEmail], [PageSMS]) 
VALUES ('Test Filter', '   ', '   ', '   ', '   ', '   ', '2015-01-01', '2015-04-01', 'hansenty@mac.com', '7022398057')


*/
GO


IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_LoggingFilter_SelectAll]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_LoggingFilter_SelectAll]
GO

CREATE PROCEDURE [dbo].[pr_LoggingFilter_SelectAll] 
	@AppID [int] = NULL,
	@ActiveOnly [bit] = 1,
	@CurrentDate [datetime] = NULL
AS
	SET NOCOUNT ON

	IF @CurrentDate IS NULL
	BEGIN
		SET @CurrentDate = GETDATE()
	END

	SELECT [LoggingFilter].[ID] AS FilterID
	, [LoggingFilter].[Name] AS FilterName
	, [LoggingFilter].[AppID] AS FilterAppID
	, [LoggingFilter].[ClientFilter]
	, [LoggingFilter].[UserFilter]
	, [LoggingFilter].[EnvironmentFilter]
	, [LoggingFilter].[EventFilter]
	, [LoggingFilter].[Enabled] AS FilterEnabled
	, [LoggingFilter].[StartDate] AS FilterStartDate
	, [LoggingFilter].[EndDate] AS FilterEndDate
	, [LoggingFilter].[PageEmail] AS FilterPageEmail
	, [LoggingFilter].[PageSMS] AS FilterPageSMS
	, [LoggingFilter].[CreatedBy] AS FilterCreatedBy
	, [LoggingFilter].[CreateDate] AS FilterCreateDate
	, [LoggingFilter].[ModifyDate] AS FilterModifyDate
	, [LoggingFilter].[Custom1] AS FilterCustom1
	, [LoggingFilter].[Custom2] AS FilterCustom2
	, [LoggingFilter].[Custom3] AS FilterCustom3
	FROM [dbo].[LoggingFilter]
	WHERE (@AppID IS NULL OR [LoggingFilter].[AppID] = @AppID)
	AND (@ActiveOnly = 0 OR 
	([Enabled] = 1
		AND ([StartDate] IS NULL OR [StartDate] <= @CurrentDate)
		AND ([EndDate] IS NULL OR [EndDate] >= @CurrentDate)
	))
	ORDER BY [LoggingFilter].[Name]

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_LoggingFilter_Select]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_LoggingFilter_Select]
GO

CREATE PROCEDURE [dbo].[pr_LoggingFilter_Select] 
	@FilterID [Int]
AS
	SET NOCOUNT ON

	SELECT [LoggingFilter].[ID] AS FilterID
	, [LoggingFilter].[Name] AS FilterName
	, [LoggingFilter].[AppID] AS FilterAppID
	, [LoggingFilter].[ClientFilter]
	, [LoggingFilter].[UserFilter]
	, [LoggingFilter].[EnvironmentFilter]
	, [LoggingFilter].[EventFilter]
	, [LoggingFilter].[Enabled] AS FilterEnabled
	, [LoggingFilter].[StartDate] AS FilterStartDate
	, [LoggingFilter].[EndDate] AS FilterEndDate
	, [LoggingFilter].[PageEmail] AS FilterPageEmail
	, [LoggingFilter].[PageSMS] AS FilterPageSMS
	, [LoggingFilter].[CreatedBy] AS FilterCreatedBy
	, [LoggingFilter].[CreateDate] AS FilterCreateDate
	, [LoggingFilter].[ModifyDate] AS FilterModifyDate
	, [LoggingFilter].[Custom1] AS FilterCustom1
	, [LoggingFilter].[Custom2] AS FilterCustom2
	, [LoggingFilter].[Custom3] AS FilterCustom3
	FROM [dbo].[LoggingFilter]
	WHERE [ID] = @FilterID

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_LoggingFilter_Delete]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_LoggingFilter_Delete]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_LoggingFilter_Delete]
	@LoggingFilterID [Int]
AS
	SET NOCOUNT ON

	DELETE FROM [dbo].[LoggingFilter]
	WHERE [LoggingFilter].[ID] = @LoggingFilterID

GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/****** Object:  StoredProcedure [dbo].[pr_LoggingFilter_UpdateStatus]    Script Date: 3/20/2015 2:33:02 PM ******/
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_LoggingFilter_UpdateStatus]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_LoggingFilter_UpdateStatus]
GO



/****** Object:  StoredProcedure [dbo].[pr_LoggingFilter_UpdateStatus]    Script Date: 3/20/2015 2:33:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_LoggingFilter_UpdateStatus]
	@LoggingFilterID [Int]
	, @Enabled [bit]
AS
	SET NOCOUNT ON

	UPDATE [dbo].[LoggingFilter]
	SET [Enabled] = @Enabled
	WHERE [LoggingFilter].[ID] = @LoggingFilterID

GO



IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_LoggingFilter_Insert]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_LoggingFilter_Insert]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_LoggingFilter_Insert]
	@Name [VarChar](200) = NULL
	,@AppID [Int]
	,@ClientFilter [VarChar](600)
	,@UserFilter [VarChar](600)
	,@EnvironmentFilter [VarChar](50)
	,@EventFilter [VarChar](500)
	,@Enabled [Bit] = 1
	,@StartDate [DateTime] = NULL
	,@EndDate [DateTime] = NULL
	,@PageEmail [VarChar](254) = NULL
	,@PageSMS [VarChar](50) = NULL
	,@CreatedBy [Int] = NULL
	,@Custom1 [VarChar](200) = NULL
	,@Custom2 [VarChar](200) = NULL
	,@Custom3 [VarChar](200) = NULL
AS
	INSERT [dbo].[LoggingFilter]
	( 
	[Name]
	,[AppID]
	,[ClientFilter]
	,[UserFilter]
	,[EnvironmentFilter]
	,[EventFilter]
	,[Enabled]
	,[StartDate]
	,[EndDate]
	,[PageEmail]
	,[PageSMS]
	,[CreatedBy]
	,[Custom1]
	,[Custom2]
	,[Custom3]
	)
	VALUES
	(
	 @Name
	,@AppID
	,@ClientFilter
	,@UserFilter
	,@EnvironmentFilter
	,@EventFilter
	,@Enabled
	,@StartDate
	,@EndDate
	,@PageEmail
	,@PageSMS
	,@CreatedBy
	,@Custom1
	,@Custom2
	,@Custom3
	)

	DECLARE @LoggingFilterID [Int]
	SET @LoggingFilterID = SCOPE_IDENTITY()

	EXEC [dbo].[pr_LoggingFilter_Select] @LoggingFilterID
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_LoggingFilter_Update]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_LoggingFilter_Update]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_LoggingFilter_Update]
	@LoggingFilterID [Int]
	,@Name [VarChar](200) = NULL
	,@AppID [Int]
	,@ClientFilter [VarChar](600)
	,@UserFilter [VarChar](600)
	,@EnvironmentFilter [VarChar](50)
	,@EventFilter [VarChar](500)
	,@Enabled [Bit]
	,@StartDate [DateTime] = NULL
	,@EndDate [DateTime] = NULL
	,@PageEmail [VarChar](254) = NULL
	,@PageSMS [VarChar](50) = NULL
	,@Custom1 [VarChar](200) = NULL
	,@Custom2 [VarChar](200) = NULL
	,@Custom3 [VarChar](200) = NULL
AS
	UPDATE [dbo].[LoggingFilter]
	SET [ModifyDate] = GETDATE()
	,[Name] = @Name
	,[AppID] = @AppID
	,[ClientFilter] = @ClientFilter
	,[UserFilter] = @UserFilter
	,[EnvironmentFilter] = @EnvironmentFilter
	,[EventFilter] = @EventFilter
	,[Enabled] = @Enabled
	,[StartDate] = @StartDate
	,[EndDate] = @EndDate
	,[PageEmail] = @PageEmail
	,[PageSMS] = @PageSMS
	,[Custom1] = @Custom1
	,[Custom2] = @Custom2
	,[Custom3] = @Custom3
	WHERE [ID] = @LoggingFilterID

	EXEC [dbo].[pr_LoggingFilter_Select] @LoggingFilterID
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_ErrorOther_Insert]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_ErrorOther_Insert]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Insert]    Script Date: 3/26/2015 10:19:52 AM ******/
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

	SELECT SCOPE_IDENTITY()

GO



IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_ErrorOther_SelectOccurrence]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectOccurrence]
GO


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectOccurrence]    Script Date: 3/26/2015 10:51:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectOccurrence]
	@ErrorOtherLogID [BigInt]
AS
	SET NOCOUNT ON

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
	, [ErrorOther].[ErrorDetail] AS ErrorOtherErrorDetail
	, [ErrorOther].[ErrorURL] AS ErrorOtherErrorURL
	, [ErrorOtherLog].[UserAgent] AS ErrorOtherUserAgent
	, [ErrorOtherLog].[UserType] AS ErrorOtherUserType
	, [ErrorOtherLog].[UserID] AS ErrorOtherUserID
	, [ErrorOtherLog].[CustomID] AS ErrorOtherCustomID
	, [ErrorOther].[AppName] AS ErrorOtherAppName
	, [ErrorOther].[MachineName] AS ErrorOtherMachineName
	, [ErrorOtherLog].[Custom1] AS ErrorOtherCustom1
	, [ErrorOtherLog].[Custom2] AS ErrorOtherCustom2
	, [ErrorOtherLog].[Custom3] AS ErrorOtherCustom3
	FROM [dbo].[ErrorOtherLog]
		JOIN [dbo].[ErrorOther]
			ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
	WHERE [ErrorOtherLog].[ID] = @ErrorOtherLogID

GO




IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_Application_SelectClients]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_Application_SelectClients]
GO

/****** Object:  StoredProcedure [dbo].[pr_Application_SelectClients]    Script Date: 3/26/2015 10:51:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_Application_SelectClients]
	@AppID [Int]
AS
	SET NOCOUNT ON

	SELECT DISTINCT [ErrorOtherLog].[ClientID] AS ClientID
	FROM [dbo].[ErrorOtherLog]
		JOIN [dbo].[ErrorOther]
			ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
	WHERE [AppID] = @AppID
		AND [ErrorOtherLog].[ClientID] IS NOT NULL
	ORDER BY [ErrorOtherLog].[ClientID]

GO


IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[pr_Application_SelectUsers]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[pr_Application_SelectUsers]
GO

/****** Object:  StoredProcedure [dbo].[pr_Application_SelectUsers]    Script Date: 3/26/2015 10:51:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_Application_SelectUsers]
	@AppID [Int]
	, @ClientID [VarChar](50) = NULL
AS
	SET NOCOUNT ON

	SELECT DISTINCT [ErrorOtherLog].[UserID] AS UserID
	FROM [dbo].[ErrorOtherLog]
		JOIN [dbo].[ErrorOther]
			ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
	WHERE [AppID] = @AppID
		AND [ErrorOtherLog].[UserID] IS NOT NULL
		AND (@ClientID IS NULL OR [ErrorOtherLog].[ClientID] = @ClientID)
	ORDER BY [ErrorOtherLog].[UserID]

GO
