/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Select]    Script Date: 3/4/2016 2:43:07 PM ******/
DROP PROCEDURE [dbo].[pr_ErrorOther_Select]
GO

/****** Object:  StoredProcedure [dbo].[pr_ErrorOther_Select]    Script Date: 3/4/2016 2:43:07 PM ******/
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


