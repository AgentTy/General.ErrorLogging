--DROP TABLE  [dbo].[Application]

/****** Object:  Table [dbo].[Application]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Application] (
	[ID] [int] NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[URL] [varchar](200) NULL,
	[SortOrder] [smallint] NULL,
	[CustomID] [int] NULL,
	[Custom1] [varchar](200) NULL,
	[Custom2] [varchar](200) NULL,
	[Custom3] [varchar](200) NULL,
 CONSTRAINT [PK_Application] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

/*
INSERT INTO [dbo].[Application] ([ID], [Name], [URL]) VALUES (1, 'PAC-Metrix Assessment Tool', 'http://login.pac-metrix.com/kiosk')
INSERT INTO [dbo].[Application] ([ID], [Name], [URL]) VALUES (2, 'PAC-Metrix Admin', 'http://login.pac-metrix.com')
INSERT INTO [dbo].[Application] ([ID], [Name], [URL]) VALUES (3, 'PAC-Metrix API', 'http://login.pac-metrix.com/api')
INSERT INTO [dbo].[Application] ([ID], [Name], [URL], [SortOrder]) VALUES (0, 'General Library', '' ,9999)
*/
GO


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

--DROP TABLE [dbo].[Error404]

/****** Object:  Table [dbo].[Error404]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Error404](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AppID] [int] NOT NULL,
	[EnvironmentID] [smallint] NOT NULL,
	[ClientID] [varchar](50) NULL,
	[FirstTime] [datetime] NOT NULL,
	[LastTime] [datetime] NOT NULL,
	[URL] [varchar](200) NOT NULL,
	[Count] [smallint] NOT NULL,
	[Hide] [bit] NOT NULL,
	[UserAgent] [varchar](400) NULL,
	[Detail] [varchar](5000) NULL,
 CONSTRAINT [PK_Error404] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Error404Redirect]    Script Date: 1/23/2015 10:25:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Error404Redirect](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AppID] [int] NOT NULL,
	[ClientID] [varchar](50) NULL,
	[CreateDate] [datetime] NOT NULL,
	[ModifyDate] [datetime] NOT NULL,
	[RedirectType] [smallint] NOT NULL,
	[From] [varchar](300) NOT NULL,
	[To] [varchar](300) NOT NULL,
	[FirstTime] [datetime] NULL,
	[LastTime] [datetime] NULL,
	[Count] [int] NOT NULL,
 CONSTRAINT [PK_Error404Redirect] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

--DROP TABLE [dbo].[ErrorOther]
/****** Object:  Table [dbo].[ErrorOther]    Script Date: 1/23/2015 10:25:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ErrorOther](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AppID] [int] NOT NULL,
	[EnvironmentID] [smallint] NOT NULL,
	[ClientID] [varchar](50) NULL,
	[FirstTime] [datetime] NOT NULL,
	[LastTime] [datetime] NOT NULL,
	[Count] [smallint] NOT NULL,
	[ErrorType] [smallint] NOT NULL,
	[Severity] [smallint] NULL,
	[ErrorCode] [varchar](20) NULL,
	[CodeMethod] [varchar](200) NULL,
	[CodeFileName] [varchar](200) NULL,
	[CodeLineNumber] [smallint] NULL,
	[CodeColumnNumber] [smallint] NULL,
	[ExceptionType] [varchar](200) NULL,
	[ErrorName] [varchar](200) NULL,
	[ErrorDetail] [varchar](max) NULL,
	[ErrorURL] [varchar](200) NULL,
	[UserAgent] [varchar](400) NULL,
	[UserType] [varchar](50) NULL,
	[UserID] [varchar](50)   NULL,
	[CustomID] [int] NULL,
	[AppName] [varchar](100) NULL,
	[MachineName] [varchar](20) NULL,
	[Custom1] [varchar](200) NULL,
	[Custom2] [varchar](200) NULL,
	[Custom3] [varchar](200) NULL,
 CONSTRAINT [PK_ErrorOther] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

--DROP TABLE [dbo].[ErrorOtherLog]
/****** Object:  Table [dbo].[ErrorOtherLog]    Script Date: 1/23/2015 10:25:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorOtherLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorOtherID] [int] NOT NULL,
	[TimeStamp] [datetime] NOT NULL,
	[ClientID] [varchar](50) NULL,
	[UserType] [varchar](50) NULL,
	[UserID] [varchar](50)   NULL,
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
ALTER TABLE [dbo].[Error404] ADD  CONSTRAINT [DF_Error404_FirstTime]  DEFAULT (getdate()) FOR [FirstTime]
GO
ALTER TABLE [dbo].[Error404] ADD  CONSTRAINT [DF_Error404_LastTime]  DEFAULT (getdate()) FOR [LastTime]
GO
ALTER TABLE [dbo].[Error404] ADD  CONSTRAINT [DF_Error404_Count]  DEFAULT ((1)) FOR [Count]
GO
ALTER TABLE [dbo].[Error404] ADD  DEFAULT ((0)) FOR [Hide]
GO
ALTER TABLE [dbo].[Error404Redirect] ADD  CONSTRAINT [DF_Error404Redirect_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Error404Redirect] ADD  CONSTRAINT [DF_Error404Redirect_ModifyDate]  DEFAULT (getdate()) FOR [ModifyDate]
GO
ALTER TABLE [dbo].[Error404Redirect] ADD  CONSTRAINT [DF_Error404Redirect_Count]  DEFAULT ((0)) FOR [Count]
GO
ALTER TABLE [dbo].[ErrorOther] ADD  CONSTRAINT [DF_ErrorOther_FirstTime]  DEFAULT (getdate()) FOR [FirstTime]
GO
ALTER TABLE [dbo].[ErrorOther] ADD  CONSTRAINT [DF_ErrorOther_LastTime]  DEFAULT (getdate()) FOR [LastTime]
GO
ALTER TABLE [dbo].[ErrorOther] ADD  CONSTRAINT [DF_ErrorOther_Count]  DEFAULT ((1)) FOR [Count]
GO




CREATE PROCEDURE [dbo].[pr_Application_SelectAll] 
AS
	SET NOCOUNT ON

	INSERT INTO [dbo].[Application] ([ID], [Name])
	SELECT [ErrorOther].[AppID] AS ID
		, MAX([ErrorOther].[AppName]) AS Name
	FROM [dbo].[ErrorOther]
		LEFT JOIN [dbo].[Application]
			ON [Application].[ID] = [ErrorOther].[AppID]
	WHERE [ErrorOther].[AppName] IS NOT NULL
		AND [Application].[ID] IS NULL
	GROUP BY [ErrorOther].[AppID]

	SELECT [Application].[ID] AS AppID
	, [Application].[Name] AS AppName
	, [Application].[URL] AS AppURL
	, [Application].[SortOrder] AS AppSortOrder
	, [Application].[CustomID] AS AppCustomID
	, [Application].[Custom1] AS AppCustom1
	, [Application].[Custom2] AS AppCustom2
	, [Application].[Custom3] AS AppCustom3
	FROM [dbo].[Application]
	ORDER BY COALESCE([Application].[SortOrder],1000), [Application].[Name]

GO

CREATE PROCEDURE [dbo].[pr_Application_Select] 
	@AppID [Int]
AS
	SET NOCOUNT ON

	INSERT INTO [dbo].[Application] ([ID], [Name])
	SELECT [ErrorOther].[AppID] AS ID
		, MAX([ErrorOther].[AppName]) AS Name
	FROM [dbo].[ErrorOther]
		LEFT JOIN [dbo].[Application]
			ON [Application].[ID] = [ErrorOther].[AppID]
	WHERE [ErrorOther].[AppName] IS NOT NULL
		AND [Application].[ID] IS NULL
	GROUP BY [ErrorOther].[AppID]

	SELECT [Application].[ID] AS AppID
	, [Application].[Name] AS AppName
	, [Application].[URL] AS AppURL
	, [Application].[SortOrder] AS AppSortOrder
	, [Application].[CustomID] AS AppCustomID
	, [Application].[Custom1] AS AppCustom1
	, [Application].[Custom2] AS AppCustom2
	, [Application].[Custom3] AS AppCustom3
	FROM [dbo].[Application]
	WHERE [ID] = @AppID

GO


/****** Object:  UserDefinedFunction [dbo].[fn_PrepFutureDateByEndOfDay]    Script Date: 2/16/2015 11:46:57 AM ******/
--DROP FUNCTION [dbo].[fn_PrepFutureDateByEndOfDay]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_PrepFutureDateByEndOfDay]    Script Date: 2/16/2015 11:46:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    This FUNCTION returns the given date, modified to be 11:59:59 PM of the given day
*/
CREATE FUNCTION [dbo].[fn_PrepFutureDateByEndOfDay]
(
    @Date [DateTime]
)
RETURNS [DateTime]
AS
BEGIN
    DECLARE @DateTime DATETIME
    SET @DateTime = DATEADD(second, -1, DATEADD(day,1,CONVERT(DateTime,CONVERT(Date, @Date))))
    RETURN @DateTime
END
GO



/****** Object:  StoredProcedure [dbo].[pr_Error404_Delete]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_Error404_Delete]
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


CREATE PROCEDURE [dbo].[pr_Error404_Insert]
	@AppID [Int]
	,@EnvironmentID [SmallInt]
	,@ClientID [VarChar](50) = NULL
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
CREATE PROCEDURE [dbo].[pr_Error404_Select]
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

CREATE PROCEDURE [dbo].[pr_Error404_SelectAll]
	@AppID [Int]
	, @EnvironmentID [SmallInt] = NULL
	, @ClientID [varchar](50) = NULL 
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

CREATE PROCEDURE [dbo].[pr_Error404_Update]
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

CREATE PROCEDURE [dbo].[pr_Error404_UpdateVisibility]
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

CREATE PROCEDURE [dbo].[pr_Error404Redirect_Delete]
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

CREATE PROCEDURE [dbo].[pr_Error404Redirect_Insert]
	@AppID [Int]
	,@ClientID [varchar](50) = NULL
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
CREATE PROCEDURE [dbo].[pr_Error404Redirect_Select]
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
CREATE PROCEDURE [dbo].[pr_Error404Redirect_SelectAll]
	@AppID [Int]
	, @ClientID [varchar](50) = NULL 
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

CREATE PROCEDURE [dbo].[pr_Error404Redirect_SelectByFrom]
	@AppID [Int],
	@ClientID [varchar](50) = NULL,
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

CREATE PROCEDURE [dbo].[pr_Error404Redirect_Update]
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

CREATE PROCEDURE [dbo].[pr_Error404Redirect_UpdateLog]
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

CREATE PROCEDURE [dbo].[pr_ErrorOther_Delete]
	@ErrorOtherID [Int]
AS
	SET NOCOUNT ON

	DELETE FROM [dbo].[ErrorOther]
	WHERE [ErrorOther].[ID] = @ErrorOtherID


GO


/****** Object:  UserDefinedFunction [dbo].[fn_RemoveQueryStringFromURL]    Script Date: 2/16/2015 11:46:57 AM ******/
--DROP FUNCTION [dbo].[fn_RemoveQueryStringFromURL]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_RemoveQueryStringFromURL]    Script Date: 2/16/2015 11:46:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    This FUNCTION returns the given date, modified to be 11:59:59 PM of the given day
*/
CREATE FUNCTION [dbo].[fn_RemoveQueryStringFromURL]
(
    @URL [VarChar](500)
)
RETURNS [VarChar](500)
AS
BEGIN
    RETURN CASE
        WHEN CHARINDEX('?', @URL) > 0 THEN SUBSTRING(@URL, 1, CHARINDEX('?', @URL) - 1)
        ELSE @URL
    End
END
GO



--DROP PROCEDURE [dbo].[pr_ErrorOther_Insert]
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

	SELECT SCOPE_IDENTITY()

GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Select]    Script Date: 1/23/2015 10:25:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
