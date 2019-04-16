
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
/*
CREATE FUNCTION [dbo].[fn_MD5HashString](@INPUT NVARCHAR(MAX))
RETURNS [binary](16)
AS
BEGIN
RETURN HASHBYTES('MD5', CAST(@INPUT COLLATE Latin1_General_CS_AS AS VARBINARY(MAX)))
END
GO
*/



IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[ErrorOtherLog]') 
         AND name = 'MachineName'
)
BEGIN
	ALTER TABLE [dbo].[ErrorOtherLog]
	ADD [URL] [varchar](200) NULL

	ALTER TABLE [dbo].[ErrorOtherLog]
	ADD [MachineName] [varchar](50) NULL

END

ALTER TABLE [dbo].[ErrorOther]
ALTER COLUMN [MachineName] VARCHAR(50) NULL
GO

ALTER TABLE [dbo].[ErrorOther]
ALTER COLUMN [ErrorCode] VARCHAR(50) NULL
GO

IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'[dbo].[ErrorOtherLog]') 
         AND name = 'DetailID'
)
BEGIN
	ALTER TABLE [dbo].[ErrorOther]
	ADD [DetailID] [int] NULL

	ALTER TABLE [dbo].[ErrorOtherLog]
	ADD [DetailID] [int] NULL
END

GO

/*
ALTER TABLE [dbo].[ErrorOtherDetail] DROP CONSTRAINT [DF_ErrorOtherDetail_FirstTime]
GO

ALTER TABLE [dbo].[ErrorOtherDetail] DROP CONSTRAINT [DF_ErrorOtherDetail_DetailType]
GO

DROP TABLE [dbo].[ErrorOtherDetail]
GO

*/


IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND  TABLE_NAME = 'ErrorOtherDetail'))
BEGIN
    PRINT 'Creating Table'

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



	SET ANSI_PADDING OFF
	ALTER TABLE [dbo].[ErrorOtherDetail] ADD  CONSTRAINT [DF_ErrorOtherDetail_DetailType]  DEFAULT ((1)) FOR [DetailTypeID]
	ALTER TABLE [dbo].[ErrorOtherDetail] ADD  CONSTRAINT [DF_ErrorOtherDetail_FirstTime]  DEFAULT (sysdatetimeoffset()) FOR [FirstTime]

	
	TRUNCATE TABLE ErrorOtherDetail

	INSERT INTO ErrorOtherDetail (FirstTime, MD5Hash, Content)
	SELECT MIN(ErrorOther.FirstTime )
		, [dbo].[fn_MD5HashString](ErrorDetail COLLATE Latin1_General_CS_AS) AS MD5Hash
		, ErrorDetail COLLATE Latin1_General_CS_AS
	FROM ErrorOther
	WHERE ErrorDetail IS NOT NULL
	GROUP BY ErrorDetail COLLATE Latin1_General_CS_AS

	SELECT COUNT(*) FROM ErrorOtherDetail
	SELECT TOP 100 * FROM ErrorOtherDetail ORDER BY FirstTime DESC

	UPDATE ErrorOther SET ErrorOther.DetailID = ErrorOtherDetail.ID
	FROM ErrorOtherDetail 
	WHERE ErrorOther.ErrorDetail IS NOT NULL
		AND ErrorOther.DetailID IS NULL
		AND ErrorOtherDetail.Content COLLATE Latin1_General_CS_AS  = ErrorOther.ErrorDetail COLLATE Latin1_General_CS_AS 


	UPDATE ErrorOtherLog SET ErrorOtherLog.DetailID = ErrorOtherDetail.ID
	FROM ErrorOtherLog
		JOIN ErrorOther
			ON ErrorOther.ID = ErrorOtherLog.ErrorOtherID
		JOIN ErrorOtherDetail
			ON ErrorOtherDetail.ID = ErrorOther.DetailID
	WHERE ErrorOther.DetailID IS NOT NULL
		AND ErrorOtherLog.DetailID IS NULL



END

GO


/*

SELECT TOP 100 * FROM ErrorOther WHERE ErrorDetail IS NOT NULL AND DetailID IS NULL

SELECT TOP 100 * FROM ErrorOther 
	JOIN ErrorOtherDetail detail
		ON detail.ID = ErrorOther.DetailID
WHERE ErrorDetail COLLATE Latin1_General_CS_AS <> detail.Content COLLATE Latin1_General_CS_AS

*/



/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Insert]    Script Date: 4/7/2016 1:31:59 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_Insert]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Insert]    Script Date: 4/7/2016 1:31:59 PM ******/
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
        --,[ErrorDetail]
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
        --,@ErrorDetail
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
        --, [ErrorDetail] = COALESCE(@ErrorDetail, [ErrorDetail])
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

    SELECT SCOPE_IDENTITY()


GO



/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Update]    Script Date: 4/7/2016 1:37:35 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_Update]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Update]    Script Date: 4/7/2016 1:37:35 PM ******/
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


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Select]    Script Date: 4/8/2016 1:19:35 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_Select]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Select]    Script Date: 4/8/2016 1:19:35 PM ******/
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


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectAll]    Script Date: 4/8/2016 1:19:54 PM ******/
IF EXISTS(SELECT 1 FROM SYSOBJECTS WHERE NAME = 'pr_ErrorOther_SelectAll')
BEGIN
	DROP PROCEDURE [dbo].[pr_ErrorOther_SelectAll]
END
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSummaries]    Script Date: 4/8/2016 1:19:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT 1 FROM SYSOBJECTS WHERE NAME = 'pr_ErrorOther_SelectSummaries')
BEGIN
	DROP PROCEDURE [dbo].[pr_ErrorOther_SelectSummaries]
END
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


IF EXISTS(SELECT 1 FROM SYSOBJECTS WHERE NAME = 'pr_ErrorOther_SelectLog')
BEGIN
	DROP PROCEDURE [dbo].[pr_ErrorOther_SelectLog]
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

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSeries]    Script Date: 4/8/2016 1:20:01 PM ******/
IF EXISTS(SELECT 1 FROM SYSOBJECTS WHERE NAME = 'pr_ErrorOther_SelectSeries')
BEGIN
	DROP PROCEDURE [dbo].[pr_ErrorOther_SelectSeries]
END
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectSeries]    Script Date: 4/8/2016 1:20:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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



/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectOccurrence]    Script Date: 4/8/2016 1:20:01 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_SelectOccurrence]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_SelectOccurrence]    Script Date: 4/8/2016 1:20:01 PM ******/
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


/****** Object:  StoredProcedure [dbo].[pr_Error404_Insert]    Script Date: 5/4/2016 10:42:17 AM ******/
DROP PROCEDURE [dbo].[pr_Error404_Insert]
GO

/****** Object:  StoredProcedure [dbo].[pr_Error404_Insert]    Script Date: 5/4/2016 10:42:17 AM ******/
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


/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Delete]    Script Date: 4/8/2016 1:12:38 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_Delete]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Delete]    Script Date: 4/8/2016 1:12:38 PM ******/
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


IF EXISTS(SELECT 1 FROM SYSOBJECTS WHERE NAME = 'pr_ErrorOtherLog_Delete')
BEGIN
	DROP PROCEDURE [dbo].[pr_ErrorOtherLog_Delete]
END
GO


/****** Object:  StoredProcedure [dbo].[pr_ErrorOtherLog_Delete]    Script Date: 5/4/2016 3:57:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

