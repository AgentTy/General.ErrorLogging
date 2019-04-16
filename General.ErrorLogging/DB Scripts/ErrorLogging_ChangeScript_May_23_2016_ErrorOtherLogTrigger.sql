IF(TYPE_ID(N'[dbo].[IDListType]') IS NULL) 
CREATE TYPE IDListType AS TABLE 
( ID INT );
GO

IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'ErrorOtherLogTrigger'))
BEGIN
    PRINT 'Creating Table'

	SET ANSI_NULLS ON
	SET QUOTED_IDENTIFIER ON
	SET ANSI_PADDING ON

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


END




/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Insert]    Script Date: 5/23/2016 1:01:44 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_Insert]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Insert]    Script Date: 5/23/2016 1:01:45 PM ******/
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


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectPendingTriggers]    Script Date: 5/23/2016 2:52:22 PM ******/
--DROP PROCEDURE [dbo].[pr_ErrorOther_SelectPendingTriggers]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectPendingTriggers]    Script Date: 5/23/2016 2:52:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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



/****** Object:  StoredProcedure [dbo].[pr_ErrorOtherLogTrigger_MarkAsProcessed]    Script Date: 5/23/2016 2:52:22 PM ******/
--DROP PROCEDURE [dbo].[pr_ErrorOtherLogTrigger_MarkAsProcessed]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOtherLogTrigger_MarkAsProcessed]    Script Date: 5/23/2016 2:52:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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


--EXEC [dbo].[pr_ErrorOther_SelectPendingTriggers]


/*
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

DECLARE @FiltersMatched IDListType
INSERT INTO @FiltersMatched SELECT 1
INSERT INTO @FiltersMatched SELECT 1
INSERT INTO @FiltersMatched SELECT 2

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
  ,@FiltersMatched
GO


EXEC [dbo].[pr_ErrorOther_SelectLog]
	@AppID = NULL
	, @EnvironmentID = NULL 
	, @ClientID = NULL
	, @ErrorType= NULL 
	, @MinimumSeverity = NULL
	, @StartDate ='5/23/2016'
	, @EndDate  = '5/23/2016'
	, @IncludeDetail = 1

TRUNCATE TABLE ErrorOtherLogTrigger

*/

/*
DECLARE @TriggerIDs IDListType
INSERT INTO @TriggerIDs SELECT 1
INSERT INTO @TriggerIDs SELECT 1
INSERT INTO @TriggerIDs SELECT 2

EXEC [dbo].[pr_ErrorOtherLogTrigger_BatchProcessed]
@TriggerIDs

SELECT * FROM ErrorOtherLogTrigger
*/