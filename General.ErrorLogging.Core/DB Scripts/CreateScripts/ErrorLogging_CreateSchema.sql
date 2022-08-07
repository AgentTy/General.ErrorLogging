-- =================================================
-- Create User as DBO template for Windows Azure SQL Database
-- =================================================
-- For login <login_name, sysname, login_name>, create a user in the database
/*
CREATE USER [ErrorLogger]
	FOR LOGIN [ErrorLogger]
	WITH DEFAULT_SCHEMA = dbo
GO

-- Add user to the database owner role
EXEC sp_addrolemember N'db_owner', N'ErrorLogger'
GO

*/


IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[dbo].[fn_MD5HashString]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [dbo].[fn_MD5HashString]
GO 

/*
    USE FOR SQL SERVER 2014 INSTANCE: This FUNCTION returns the MD5 Hash of a string of any length
*/
CREATE FUNCTION [dbo].[fn_MD5HashString](@INPUT NVARCHAR(MAX))
RETURNS [binary](16)
AS
BEGIN
RETURN ( 
  SELECT CASE
    WHEN DATALENGTH(@INPUT) > 8000
      THEN master.sys.fn_repl_hash_binary(CAST(@INPUT COLLATE Latin1_General_CS_AS AS VARBINARY(MAX)))
    ELSE
      HASHBYTES('MD5', CAST(@INPUT COLLATE Latin1_General_CS_AS AS VARBINARY(MAX)))
    END
)
END
GO


/*
    USE FOR AZURE: This FUNCTION returns the MD5 Hash of a string of any length, however lengths over 8000 are truncated for Azure databases
*/
CREATE FUNCTION [dbo].[fn_MD5HashString](@INPUT NVARCHAR(MAX))
RETURNS [binary](16)
AS
BEGIN
RETURN HASHBYTES('MD5', CAST(@INPUT COLLATE Latin1_General_CS_AS AS VARBINARY(MAX)))
END
GO


/*
	This FUNCTION returns the given date, modified to be 11:59:59 PM of the given day
*/
CREATE FUNCTION [dbo].[fn_PrepFutureDateByEndOfDay]
(
	@Date [DateTimeOffset]
)
RETURNS [DateTimeOffset]
AS
BEGIN
	DECLARE @DateTime DATETIMEOFFSET
	SET @DateTime = TODATETIMEOFFSET( DATEADD(second, -1, DATEADD(day,1,CONVERT(DATETIMEOFFSET,CONVERT(Date, @Date)))), DATEPART(TZ, @Date))
	RETURN @DateTime
END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_RemoveQueryStringFromURL]    Script Date: 1/14/2016 9:39:25 PM ******/
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

CREATE TYPE IDListType AS TABLE 
( ID INT );
GO

/****** Object:  Table [dbo].[Application]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Application](
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
/****** Object:  Table [dbo].[Error404]    Script Date: 1/14/2016 9:39:25 PM ******/
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
	[FirstTime] [DateTimeOffset] NOT NULL CONSTRAINT [DF_Error404_FirstTime]  DEFAULT (SYSDATETIMEOFFSET()),
	[LastTime] [DateTimeOffset] NOT NULL CONSTRAINT [DF_Error404_LastTime]  DEFAULT (SYSDATETIMEOFFSET()),
	[URL] [varchar](200) NOT NULL,
	[Count] [int] NOT NULL CONSTRAINT [DF_Error404_Count]  DEFAULT ((1)),
	[Hide] [bit] NOT NULL DEFAULT ((0)),
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
/****** Object:  Table [dbo].[Error404Redirect]    Script Date: 1/14/2016 9:39:25 PM ******/
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
	[CreateDate] [DateTimeOffset] NOT NULL CONSTRAINT [DF_Error404Redirect_CreateDate]  DEFAULT (SYSDATETIMEOFFSET()),
	[ModifyDate] [DateTimeOffset] NOT NULL CONSTRAINT [DF_Error404Redirect_ModifyDate]  DEFAULT (SYSDATETIMEOFFSET()),
	[RedirectType] [smallint] NOT NULL,
	[From] [varchar](300) NOT NULL,
	[To] [varchar](300) NOT NULL,
	[FirstTime] [DateTimeOffset] NULL,
	[LastTime] [DateTimeOffset] NULL,
	[Count] [int] NOT NULL CONSTRAINT [DF_Error404Redirect_Count]  DEFAULT ((0)),
 CONSTRAINT [PK_Error404Redirect] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ErrorOther]    Script Date: 1/14/2016 9:39:25 PM ******/
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
	[DetailID] [int] NULL,
	[ClientID] [varchar](50) NULL,
	[FirstTime] [DateTimeOffset] NOT NULL CONSTRAINT [DF_ErrorOther_FirstTime]  DEFAULT (SYSDATETIMEOFFSET()),
	[LastTime] [DateTimeOffset] NOT NULL CONSTRAINT [DF_ErrorOther_LastTime]  DEFAULT (SYSDATETIMEOFFSET()),
	[Count] [int] NOT NULL CONSTRAINT [DF_ErrorOther_Count]  DEFAULT ((1)),
	[ErrorType] [smallint] NOT NULL,
	[Severity] [smallint] NULL,
	[ErrorCode] [varchar](50) NULL,
	[CodeMethod] [varchar](200) NULL,
	[CodeFileName] [varchar](200) NULL,
	[CodeLineNumber] [int] NULL,
	[CodeColumnNumber] [int] NULL,
	[ExceptionType] [varchar](200) NULL,
	[ErrorName] [varchar](200) NULL,
	--[ErrorDetail] [varchar](max) NULL,
	[ErrorURL] [varchar](200) NULL,
	[UserAgent] [varchar](400) NULL,
	[UserType] [varchar](50) NULL,
	[UserID] [varchar](50) NULL,
	[CustomID] [int] NULL,
	[AppName] [varchar](100) NULL,
	[MachineName] [varchar](50) NULL,
	[Custom1] [varchar](200) NULL,
	[Custom2] [varchar](200) NULL,
	[Custom3] [varchar](200) NULL,
	[Duration] [int] NULL,
 CONSTRAINT [PK_ErrorOther] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] --TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ErrorOtherLog]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[ErrorOtherLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorOtherID] [int] NOT NULL,
	[DetailID] [int] NULL,
	[TimeStamp] [DateTimeOffset] NOT NULL,
	[ClientID] [varchar](50) NULL,
	[UserType] [varchar](50) NULL,
	[UserID] [varchar](50) NULL,
	[CustomID] [int] NULL,
	[MachineName] [varchar](50) NULL,
	[URL] [varchar](200) NULL,
	[UserAgent] [varchar](400) NULL,
	[Custom1] [varchar](200) NULL,
	[Custom2] [varchar](200) NULL,
	[Custom3] [varchar](200) NULL,
	[Duration] [int] NULL,
 CONSTRAINT [PK_ErrorOtherLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO



SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON

CREATE TABLE [dbo].[ErrorOtherDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DetailTypeID] [smallint] NOT NULL,
	[FirstTime] [datetimeoffset](7) NOT NULL,
	[MD5Hash] [binary](16) NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	CONSTRAINT [PK_ErrorOtherDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
ALTER TABLE [dbo].[ErrorOtherDetail] ADD  CONSTRAINT [DF_ErrorOtherDetail_DetailType]  DEFAULT ((1)) FOR [DetailTypeID]
ALTER TABLE [dbo].[ErrorOtherDetail] ADD  CONSTRAINT [DF_ErrorOtherDetail_FirstTime]  DEFAULT (sysdatetimeoffset()) FOR [FirstTime]
GO



/****** Object:  Table [dbo].[LoggingFilter]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoggingFilter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](200) NULL,
	[AppID] [int] NOT NULL,
	[ClientFilter] [varchar](600) NOT NULL,
	[UserFilter] [varchar](600) NOT NULL,
	[EnvironmentFilter] [varchar](50) NOT NULL,
	[EventFilter] [varchar](500) NOT NULL,
	[Enabled] [bit] NOT NULL DEFAULT ((1)),
	[StartDate] [DateTimeOffset] NULL,
	[EndDate] [DateTimeOffset] NULL,
	[PageEmail] [varchar](254) NULL,
	[PageSMS] [varchar](50) NULL,
	[CreatedBy] [int] NULL,
	[CreateDate] [DateTimeOffset] NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
	[ModifyDate] [DateTimeOffset] NOT NULL DEFAULT (SYSDATETIMEOFFSET()),
	[Custom1] [varchar](200) NULL,
	[Custom2] [varchar](200) NULL,
	[Custom3] [varchar](200) NULL,
 CONSTRAINT [PK_LoggingFilter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[ErrorOtherLogTrigger](
		[ID] [int] IDENTITY(1,1) NOT NULL,
		[ErrorOtherLogID] [int] NOT NULL,
		[LoggingFilterID] [int] NOT NULL,
		[Processed] [bit] NOT NULL DEFAULT(0),
		[ProcessedTimeStamp] [DATETIMEOFFSET] NULL,
		[ProcessingSuccessful] [bit] NOT NULL DEFAULT(0),
		[SMSSent] [bit] NOT NULL DEFAULT(0),
		[EmailSent] [bit] NOT NULL DEFAULT (0),
		[Details] [varchar](MAX) NULL
	 CONSTRAINT [PK_ErrorOtherLogTrigger] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY] 
GO

SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserProfile]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfile](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](56) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[webpages_Membership]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webpages_Membership](
	[UserId] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[ConfirmationToken] [nvarchar](128) NULL,
	[IsConfirmed] [bit] NULL DEFAULT ((0)),
	[LastPasswordFailureDate] [datetime] NULL,
	[PasswordFailuresSinceLastSuccess] [int] NOT NULL DEFAULT ((0)),
	[Password] [nvarchar](128) NOT NULL,
	[PasswordChangedDate] [datetime] NULL,
	[PasswordSalt] [nvarchar](128) NOT NULL,
	[PasswordVerificationToken] [nvarchar](128) NULL,
	[PasswordVerificationTokenExpirationDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[webpages_OAuthMembership]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webpages_OAuthMembership](
	[Provider] [nvarchar](30) NOT NULL,
	[ProviderUserId] [nvarchar](100) NOT NULL,
	[UserId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Provider] ASC,
	[ProviderUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[webpages_Roles]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webpages_Roles](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](256) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[webpages_UsersInRoles]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webpages_UsersInRoles](
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[webpages_UsersInRoles]  WITH CHECK ADD  CONSTRAINT [fk_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[webpages_Roles] ([RoleId])
GO
ALTER TABLE [dbo].[webpages_UsersInRoles] CHECK CONSTRAINT [fk_RoleId]
GO
ALTER TABLE [dbo].[webpages_UsersInRoles]  WITH CHECK ADD  CONSTRAINT [fk_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[webpages_UsersInRoles] CHECK CONSTRAINT [fk_UserId]
GO
/****** Object:  StoredProcedure [dbo].[pr_Application_Select]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  StoredProcedure [dbo].[pr_Application_SelectAll]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  StoredProcedure [dbo].[pr_Application_SelectClients]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Application_SelectUsers]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Error404_Delete]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Error404_Insert]    Script Date: 1/14/2016 9:39:25 PM ******/
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
		AND DATEDIFF(DAY, [Error404].[LastTime], SYSDATETIMEOFFSET()) < 31
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
		, [LastTime] = SYSDATETIMEOFFSET()
		, [UserAgent] = COALESCE(@UserAgent, [UserAgent])
		, [Detail] = COALESCE(@Detail, [Detail])
		WHERE [ID] = @Error404ID
	END

	EXEC [dbo].[pr_Error404_Select] @Error404ID



GO
/****** Object:  StoredProcedure [dbo].[pr_Error404_Select]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Error404_SelectAll]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_Error404_SelectAll]
	@AppID [Int]
	, @EnvironmentID [SmallInt] = NULL
	, @ClientID [varchar](50) = NULL 
	, @StartDate [DateTimeOffset] 
	, @EndDate [DateTimeOffset]
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
/****** Object:  StoredProcedure [dbo].[pr_Error404_Update]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_Error404_Update]
	@Error404ID [Int]
	,@URL [VarChar](200)
	,@Count [Int]
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
/****** Object:  StoredProcedure [dbo].[pr_Error404_UpdateVisibility]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_Delete]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_Insert]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_Select]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_SelectAll]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_SelectByFrom]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_Update]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_Error404Redirect_Update]
	@Error404RedirectID [Int]
	,@RedirectType [SmallInt]
	,@From [VarChar](300)
	,@To [VarChar](300)
	,@FirstTime [DateTimeOffset]
	,@LastTime [DateTimeOffset]
	,@Count [Int]
AS
	UPDATE [dbo].[Error404Redirect]
	SET [ModifyDate] = SYSDATETIMEOFFSET()
	,[RedirectType] = @RedirectType
	,[From] = @From
	,[To] = @To
	,[FirstTime] = @FirstTime
	,[LastTime] = @LastTime
	,[Count] = @Count
	WHERE [ID] = @Error404RedirectID

	EXEC [dbo].[pr_Error404Redirect_Select] @Error404RedirectID


GO
/****** Object:  StoredProcedure [dbo].[pr_Error404Redirect_UpdateLog]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_Error404Redirect_UpdateLog]
	@Error404RedirectID [Int]
	,@FirstTime [DateTimeOffset]
	,@LastTime [DateTimeOffset]
	,@Count [Int]
AS
	UPDATE [dbo].[Error404Redirect]
	SET [ModifyDate] = SYSDATETIMEOFFSET()
	,[FirstTime] = @FirstTime
	,[LastTime] = @LastTime
	,[Count] = @Count
	WHERE [ID] = @Error404RedirectID

	EXEC [dbo].[pr_Error404Redirect_Select] @Error404RedirectID


GO
/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Delete]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_ErrorOther_Delete]
	@ErrorOtherID [Int]
AS
	SET NOCOUNT ON

	--Delete the occurrences
	DELETE FROM [dbo].[ErrorOtherLog]
	WHERE [ErrorOtherLog].[ErrorOtherID] = @ErrorOtherID

	--Delete the summary row
	DELETE FROM [dbo].[ErrorOther]
	WHERE [ErrorOther].[ID] = @ErrorOtherID

	--Delete orphaned details
	DELETE detail 
	FROM [dbo].[ErrorOtherDetail] detail
	LEFT JOIN ErrorOtherLog logg
		ON logg.DetailID = detail.ID
	LEFT JOIN ErrorOther summary
		ON summary.DetailID = detail.ID
	WHERE logg.ID IS NULL AND summary.ID IS NULL

GO

CREATE PROCEDURE [dbo].[pr_ErrorOtherLog_Delete]
	@ErrorOtherLogID [Int]
AS
	SET NOCOUNT ON

	--Delete the occurrence
	DELETE FROM [dbo].[ErrorOtherLog]
	WHERE [ErrorOtherLog].[ID] = @ErrorOtherLogID

	--Delete orphaned details
	DELETE detail 
	FROM [dbo].[ErrorOtherDetail] detail
	LEFT JOIN ErrorOtherLog logg
		ON logg.DetailID = detail.ID
	LEFT JOIN ErrorOther summary
		ON summary.DetailID = detail.ID
	WHERE logg.ID IS NULL AND summary.ID IS NULL


GO


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Insert]    Script Date: 5/23/2016 1:01:45 PM ******/
CREATE PROCEDURE [dbo].[pr_ErrorOther_Insert]
    @AppID [Int]
    ,@EnvironmentID [SmallInt]
    ,@ClientID [varchar](50) = NULL
    ,@ErrorType [SmallInt]
    ,@Severity [SmallInt] = NULL
    ,@ExceptionType [VarChar](200) = NULL
    ,@ErrorCode [VarChar](50) = NULL
    ,@ErrorName [VarChar](200)
    ,@CodeMethod [VarChar](200) = NULL
    ,@CodeFileName [VarChar](200) = NULL
    ,@CodeLineNumber [Int] = NULL
    ,@CodeColumnNumber [Int] = NULL
    ,@ErrorDetail [NVarChar](MAX) = NULL
    ,@ErrorURL [VarChar](200) = NULL
    ,@UserAgent [VarChar](400) = NULL
    ,@UserType [varchar](50) = NULL
    ,@UserID [varchar](50) = NULL
    ,@CustomID [Int] = NULL
    ,@AppName [VarChar](100) = NULL
    ,@MachineName [VarChar](50) = NULL
    ,@Custom1 [VarChar](200) = NULL
    ,@Custom2 [VarChar](200) = NULL
    ,@Custom3 [VarChar](200) = NULL
    ,@TimeStamp [DateTimeOffset] = NULL
	,@Duration [Int] = NULL
	,@FiltersMatched IDListType READONLY
AS

    IF @TimeStamp IS NULL
    BEGIN
        SET @TimeStamp = SYSDATETIMEOFFSET()
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
    AND DATEDIFF(DAY, [ErrorOther].[LastTime], @TimeStamp) < 31

	DECLARE @DetailID [Int]
	IF @ErrorDetail IS NOT NULL
	BEGIN
		DECLARE @DetailMD5Hash [binary](16)
		SET @DetailMD5Hash = [dbo].[fn_MD5HashString](@ErrorDetail)
		SELECT TOP 1 @DetailID = [ID] FROM [dbo].[ErrorOtherDetail]
		WHERE [ErrorOtherDetail].MD5Hash = @DetailMD5Hash
		IF @DetailID IS NULL
		BEGIN
			INSERT INTO ErrorOtherDetail (FirstTime, MD5Hash, Content)
			SELECT @TimeStamp, @DetailMD5Hash, @ErrorDetail
			SET @DetailID = SCOPE_IDENTITY()
		END
	END

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
		,[Duration]
		,[DetailID]
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
		,@Duration
		,@DetailID
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
		, [Duration] = @Duration
		, [DetailID] = @DetailID
        WHERE [ID] = @ErrorID
    END

	INSERT INTO ErrorOtherLog
	(
		[ErrorOtherID]
		,[TimeStamp]
		,[ClientID]
		,[UserType]
		,[UserID]
		,[CustomID]
		,[UserAgent]
		,[Custom1]
		,[Custom2]
		,[Custom3]
		,[Duration]
		,[DetailID]
		,[URL]
		,[MachineName]
	)
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
	, @Duration
	, @DetailID
	, @ErrorURL
	, @MachineName

	DECLARE @ErrorOtherLogID [Int]
    SET @ErrorOtherLogID = SCOPE_IDENTITY()
	
	INSERT INTO ErrorOtherLogTrigger (ErrorOtherLogID, LoggingFilterID)
	SELECT DISTINCT @ErrorOtherLogID, filter.ID
	FROM @FiltersMatched filter

	SELECT @ErrorOtherLogID

GO




/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Update]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pr_ErrorOther_Update]
	@ErrorOtherID [Int]
	,@ErrorType [SmallInt]
	,@Severity [SmallInt] = NULL
	,@ExceptionType [VarChar](200) = NULL
	,@ErrorCode [VarChar](50)
	,@ErrorName [VarChar](200)
	,@CodeMethod [VarChar](200) = NULL
	,@CodeFileName [VarChar](200) = NULL
	,@CodeLineNumber [Int] = NULL
	,@CodeColumnNumber [Int] = NULL
	,@ErrorDetail [NVarChar](MAX) = NULL
	,@ErrorURL [VarChar](200) = NULL
	,@UserAgent [VarChar](400) = NULL
	,@UserType [varchar](50) = NULL
	,@UserID [varchar](50) = NULL
	,@CustomID [Int] = NULL
	,@AppName [VarChar](100) = NULL
	,@MachineName [VarChar](50) = NULL
	,@Custom1 [VarChar](200) = NULL
	,@Custom2 [VarChar](200) = NULL
	,@Custom3 [VarChar](200) = NULL
	,@Duration [Int] = NULL
AS

	DECLARE @DetailID [Int]
	DECLARE @DetailMD5Hash [binary](16)
	SET @DetailMD5Hash = [dbo].[fn_MD5HashString](@ErrorDetail)
	SELECT TOP 1 @DetailID = [ID] FROM [dbo].[ErrorOtherDetail]
	WHERE [ErrorOtherDetail].MD5Hash = @DetailMD5Hash
	IF @DetailID IS NULL
	BEGIN
		INSERT INTO ErrorOtherDetail (MD5Hash, Content)
		SELECT @DetailMD5Hash, @ErrorDetail
		SET @DetailID = SCOPE_IDENTITY()
	END

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
	--,[ErrorDetail] = @ErrorDetail
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
	,[Duration] = @Duration
	,[DetailID] = @DetailID
	WHERE [ID] = @ErrorOtherID

	EXEC [dbo].[pr_ErrorOther_Select] @ErrorOtherID


GO


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Select]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pr_ErrorOther_Select]
	@ErrorOtherID [Int]
AS
	SET NOCOUNT ON

	DECLARE @ErrorOtherLastLogID INT
	SELECT TOP 1 @ErrorOtherLastLogID = [ID] FROM [dbo].[ErrorOtherLog] WHERE [ErrorOtherID] = @ErrorOtherID ORDER BY [TimeStamp] DESC

	SELECT [ErrorOther].[ID] AS ErrorOtherID
	, [ErrorOther].[AppID] AS ErrorOtherAppID
	, [ErrorOther].[EnvironmentID] AS ErrorOtherEnvironmentID
	, [ErrorOther].[ClientID] AS ErrorOtherClientID
	, [ErrorOther].[FirstTime] AS ErrorOtherFirstTime
	, [ErrorOther].[LastTime] AS ErrorOtherLastTime
	, @ErrorOtherLastLogID AS ErrorOtherLastLogID
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
	WHERE [ErrorOther].[ID] = @ErrorOtherID


GO




/****** [dbo].[pr_ErrorOther_SelectAll] IS DEPRECATED ******/

/*
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
	, @StartDate [DateTimeOffset] 
	, @EndDate [DateTimeOffset]
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




GO
*/


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectOccurrence]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectOccurrence]
	@ErrorOtherLogID [Int]
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
		LEFT JOIN [dbo].[ErrorOtherDetail]
			ON [ErrorOtherDetail].[ID] = [ErrorOtherLog].[DetailID]
	WHERE [ErrorOtherLog].[ID] = @ErrorOtherLogID




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



CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectLog]
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
			LEFT JOIN [dbo].[ErrorOtherDetail]
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
		WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
		AND ([ErrorOther].[EnvironmentID] = @EnvironmentID OR @EnvironmentID IS NULL)
		AND ([ErrorOther].[ClientID] = @ClientID OR @ClientID IS NULL)
		AND ([ErrorOther].[ErrorType] = @ErrorType OR @ErrorType IS NULL)
		AND (COALESCE([ErrorOther].[Severity], 1) >= @MinimumSeverity OR @MinimumSeverity IS NULL)
		AND ([ErrorOtherLog].[TimeStamp] BETWEEN @StartDate AND @EndDate)
		ORDER BY [ErrorOtherLog].[TimeStamp] DESC
	END

GO



CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectSeries]
	@ErrorOtherID [Int],
	@IncludeDetail [Bit] = 1
AS
	SET NOCOUNT ON

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
			LEFT JOIN [dbo].[ErrorOtherDetail]
				ON [ErrorOtherDetail].[ID] = [ErrorOtherLog].[DetailID]
		WHERE [ErrorOtherLog].[ErrorOtherID] = @ErrorOtherID
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
		WHERE [ErrorOtherLog].[ErrorOtherID] = @ErrorOtherID
		ORDER BY [ErrorOtherLog].[TimeStamp] DESC
	END

GO


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectPendingTriggers]    Script Date: 5/23/2016 2:52:23 PM ******/
CREATE PROCEDURE [dbo].[pr_ErrorOther_SelectPendingTriggers]
	@AppID [Int] = NULL
AS
	SET NOCOUNT ON

	--First, bypass the ones that don't need work anyways. If you aren't sending an email or an sms, there is nothing for the trigger to trigger!
	UPDATE [ErrorOtherLogTrigger] 
	SET Processed = 1
	 , ProcessingSuccessful = 1
	 , ProcessedTimeStamp = SYSDATETIMEOFFSET()
	FROM [dbo].[ErrorOtherLogTrigger]
		JOIN [dbo].[LoggingFilter]
			ON [LoggingFilter].[ID] = [ErrorOtherLogTrigger].[LoggingFilterID]
	WHERE [ErrorOtherLogTrigger].[Processed] = 0
		AND [LoggingFilter].[Enabled] = 1
		AND [LoggingFilter].[PageSMS] IS NULL
		AND [LoggingFilter].[PageEmail] IS NULL

	--Finally, get all the events that haven't been processed, with their details and the filters details
	SELECT [ErrorOtherLogTrigger].[ID] AS ErrorOtherLogTriggerID
	, [ErrorOtherLog].[ID] AS ErrorOtherLogID
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
	, [LoggingFilter].[ID] AS FilterID
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
	FROM [dbo].[ErrorOtherLogTrigger]
		JOIN [dbo].[LoggingFilter]
			ON [LoggingFilter].[ID] = [ErrorOtherLogTrigger].[LoggingFilterID]
		JOIN [dbo].[ErrorOtherLog]
			ON [ErrorOtherLog].[ID] = [ErrorOtherLogTrigger].[ErrorOtherLogID]
		JOIN [dbo].[ErrorOther]
			ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
		LEFT JOIN [dbo].[ErrorOtherDetail]
			ON [ErrorOtherDetail].[ID] = [ErrorOtherLog].[DetailID]
	WHERE ([ErrorOther].[AppID] = @AppID OR @AppID IS NULL)
		AND [ErrorOtherLogTrigger].[Processed] = 0
		AND [LoggingFilter].[Enabled] = 1
	ORDER BY [ErrorOtherLog].[TimeStamp] ASC

GO


/****** Object:  StoredProcedure [dbo].[pr_ErrorOtherLogTrigger_MarkAsProcessed]    Script Date: 5/23/2016 2:52:23 PM ******/
CREATE PROCEDURE [dbo].[pr_ErrorOtherLogTrigger_MarkAsProcessed]
	@ErrorOtherLogTriggerID [Int]
	, @ProcessingSuccessful [Bit]
	, @SMSSent [Bit]
	, @EmailSent [Bit]
	, @Details [VarChar](MAX) = NULL
AS
	UPDATE [ErrorOtherLogTrigger] 
	SET Processed = 1
	 , ProcessedTimeStamp = SYSDATETIMEOFFSET()
	 , ProcessingSuccessful = @ProcessingSuccessful
	 , SMSSent = @SMSSent
	 , EmailSent = @EmailSent
	 , Details = @Details
	 WHERE ID = @ErrorOtherLogTriggerID
GO


/****** Object:  StoredProcedure [dbo].[pr_LoggingFilter_Delete]    Script Date: 1/14/2016 9:39:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[pr_LoggingFilter_Insert]    Script Date: 1/14/2016 9:39:25 PM ******/
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
	,@StartDate [DateTimeOffset] = NULL
	,@EndDate [DateTimeOffset] = NULL
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
/****** Object:  StoredProcedure [dbo].[pr_LoggingFilter_Select]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  StoredProcedure [dbo].[pr_LoggingFilter_SelectAll]    Script Date: 1/14/2016 9:39:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_LoggingFilter_SelectAll] 
	@AppID [int] = NULL,
	@ActiveOnly [bit] = 1,
	@CurrentDate [DateTimeOffset] = NULL
AS
	SET NOCOUNT ON

	IF @CurrentDate IS NULL
	BEGIN
		SET @CurrentDate = SYSDATETIMEOFFSET()
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
/****** Object:  StoredProcedure [dbo].[pr_LoggingFilter_Update]    Script Date: 1/14/2016 9:39:25 PM ******/
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
	,@StartDate [DateTimeOffset] = NULL
	,@EndDate [DateTimeOffset] = NULL
	,@PageEmail [VarChar](254) = NULL
	,@PageSMS [VarChar](50) = NULL
	,@Custom1 [VarChar](200) = NULL
	,@Custom2 [VarChar](200) = NULL
	,@Custom3 [VarChar](200) = NULL
AS
	UPDATE [dbo].[LoggingFilter]
	SET [ModifyDate] = SYSDATETIMEOFFSET()
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
/****** Object:  StoredProcedure [dbo].[pr_LoggingFilter_UpdateStatus]    Script Date: 1/14/2016 9:39:25 PM ******/
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



/*
SAMPLE QUERIES



DECLARE @RC int
DECLARE @AppID int
DECLARE @EnvironmentID smallint
DECLARE @ClientID varchar(50)
DECLARE @ErrorType smallint
DECLARE @Severity smallint
DECLARE @ExceptionType varchar(200)
DECLARE @ErrorCode varchar(50)
DECLARE @ErrorName varchar(200)
DECLARE @CodeMethod varchar(200)
DECLARE @CodeFileName varchar(200)
DECLARE @CodeLineNumber int
DECLARE @CodeColumnNumber int
DECLARE @ErrorDetail nvarchar(max)
DECLARE @ErrorURL varchar(200)
DECLARE @UserAgent varchar(400)
DECLARE @UserType varchar(50)
DECLARE @UserID varchar(50)
DECLARE @CustomID int
DECLARE @AppName varchar(100)
DECLARE @MachineName varchar(50)
DECLARE @Custom1 varchar(200)
DECLARE @Custom2 varchar(200)
DECLARE @Custom3 varchar(200)
DECLARE @TimeStamp datetimeoffset(7)
DECLARE @Duration int

SET @AppID = 1
SET @EnvironmentID = 1
SET @ErrorType = 1
SET @AppName = 'MyApp'
SET @ClientID = 'C1'
SET @ErrorName = 'Test Event With Content'
SET @ErrorDetail = 'A BUNCH OF DETAILS NEW'
SET @ErrorURL = 'https://www.web.com/test?342424342434'

EXECUTE @RC = [dbo].[pr_ErrorOther_Insert] 
   @AppID
  ,@EnvironmentID
  ,@ClientID
  ,@ErrorType
  ,@Severity
  ,@ExceptionType
  ,@ErrorCode
  ,@ErrorName
  ,@CodeMethod
  ,@CodeFileName
  ,@CodeLineNumber
  ,@CodeColumnNumber
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
  ,@TimeStamp
  ,@Duration
GO


EXEC [dbo].[pr_ErrorOther_SelectSummaries]
	@AppID = NULL
	, @EnvironmentID = NULL 
	, @ClientID = NULL
	, @ErrorType= NULL 
	, @MinimumSeverity = NULL
	, @StartDate ='1/1/2016'
	, @EndDate  = '1/1/2020'
	, @IncludeDetail = 1

EXEC [dbo].[pr_ErrorOther_SelectLog]
	@AppID = NULL
	, @EnvironmentID = NULL 
	, @ClientID = NULL
	, @ErrorType= NULL 
	, @MinimumSeverity = NULL
	, @StartDate ='1/1/2016'
	, @EndDate  = '1/1/2020'
	, @IncludeDetail = 1

EXEC [dbo].[pr_ErrorOther_SelectSeries]
	@ErrorOtherID = 1,
	@IncludeDetail = 1

EXEC [dbo].[pr_ErrorOther_Select]
	@ErrorOtherID = 1

EXEC [dbo].[pr_ErrorOther_SelectOccurrence]
	@ErrorOtherLogID = 1

*/