/*
TRUNCATE TABLE [Error404]
TRUNCATE TABLE [Error404Redirect]
TRUNCATE TABLE [ErrorOther]
TRUNCATE TABLE [ErrorOtherLog]
TRUNCATE TABLE [LoggingFilter]
GO
*/

DECLARE @OffsetTimeOfExistingDateTimes INT
SET @OffsetTimeOfExistingDateTimes = -420 -- (in minutes)  -360 for AZMISSQL02, -420 for PROD

IF((SELECT COUNT(*) FROM dbo.[Application]) = 0)
BEGIN
	INSERT INTO dbo.[Application] SELECT * FROM ApplicationErrorLogging.dbo.[Application]
	SELECT * FROM dbo.[Application]
END


IF((SELECT COUNT(*) FROM dbo.[Error404]) = 0)
BEGIN
	SET IDENTITY_INSERT dbo.[Error404] ON
	INSERT INTO [Error404] (ID, AppID, EnvironmentID, ClientID, FirstTime, LastTime, URL, Count, Hide, UserAgent, Detail)
	SELECT *
	FROM ApplicationErrorLogging.dbo.[Error404]
	SET IDENTITY_INSERT dbo.[Error404] OFF

	UPDATE [Error404] SET [FirstTime] = TODATETIMEOFFSET([FirstTime], @OffsetTimeOfExistingDateTimes)
	UPDATE [Error404] SET [LastTime] = TODATETIMEOFFSET([LastTime], @OffsetTimeOfExistingDateTimes)

	SELECT TOP 1000 * FROM dbo.[Error404] ORDER BY LastTime DESC
END


IF((SELECT COUNT(*) FROM dbo.[Error404Redirect]) = 0)
BEGIN
	SET IDENTITY_INSERT dbo.[Error404Redirect] ON
	INSERT INTO [Error404Redirect] (ID, AppID, ClientID, CreateDate, ModifyDate, RedirectType, [From], [To], FirstTime, LastTime, [Count])
	SELECT *
	FROM ApplicationErrorLogging.dbo.[Error404Redirect]
	SET IDENTITY_INSERT dbo.[Error404Redirect] OFF

	UPDATE [Error404Redirect] SET [FirstTime] = TODATETIMEOFFSET([FirstTime], @OffsetTimeOfExistingDateTimes)
	UPDATE [Error404Redirect] SET [LastTime] = TODATETIMEOFFSET([LastTime], @OffsetTimeOfExistingDateTimes)
	UPDATE [Error404Redirect] SET [CreateDate] = TODATETIMEOFFSET([CreateDate], @OffsetTimeOfExistingDateTimes)
	UPDATE [Error404Redirect] SET [ModifyDate] = TODATETIMEOFFSET([ModifyDate], @OffsetTimeOfExistingDateTimes)

	SELECT TOP 1000 * FROM dbo.[Error404Redirect] ORDER BY LastTime DESC
END




IF((SELECT COUNT(*) FROM dbo.[ErrorOther]) = 0)
BEGIN
	SET IDENTITY_INSERT dbo.[ErrorOther] ON
	INSERT INTO [ErrorOther] (ID, AppID, EnvironmentID, ClientID, FirstTime, LastTime, Count, ErrorType, Severity, ErrorCode, CodeMethod, CodeFileName, CodeLineNumber, CodeColumnNumber, ExceptionType, ErrorName, ErrorDetail, ErrorURL, UserAgent, UserType, UserID, CustomID, AppName, MachineName, Custom1, Custom2, Custom3)
	SELECT ID, AppID, EnvironmentID, ClientID, FirstTime, LastTime, Count, ErrorType, Severity, ErrorCode, CodeMethod, CodeFileName, CodeLineNumber, CodeColumnNumber, ExceptionType, ErrorName, ErrorDetail, ErrorURL, UserAgent, UserType, UserID, CustomID, AppName, MachineName, Custom1, Custom2, Custom3
	FROM ApplicationErrorLogging.dbo.[ErrorOther]
	SET IDENTITY_INSERT dbo.[ErrorOther] OFF

	UPDATE [ErrorOther] SET [FirstTime] = TODATETIMEOFFSET([FirstTime], @OffsetTimeOfExistingDateTimes)
	UPDATE [ErrorOther] SET [LastTime] = TODATETIMEOFFSET([LastTime], @OffsetTimeOfExistingDateTimes)

	SELECT TOP 1000 * FROM dbo.[ErrorOther] ORDER BY LastTime DESC
END




IF((SELECT COUNT(*) FROM dbo.[ErrorOtherLog]) = 0)
BEGIN
	SET IDENTITY_INSERT dbo.[ErrorOtherLog] ON
	INSERT INTO [ErrorOtherLog] (ID, ErrorOtherID, [TimeStamp], ClientID, UserType, UserID, CustomID, UserAgent, Custom1, Custom2, Custom3)
	SELECT *
	FROM ApplicationErrorLogging.dbo.[ErrorOtherLog]
	SET IDENTITY_INSERT dbo.[ErrorOtherLog] OFF

	UPDATE [ErrorOtherLog] SET [TimeStamp] = TODATETIMEOFFSET([TimeStamp], @OffsetTimeOfExistingDateTimes)

	SELECT TOP 1000 * FROM dbo.[ErrorOtherLog] ORDER BY [TimeStamp] DESC
END



IF((SELECT COUNT(*) FROM dbo.[LoggingFilter]) = 0)
BEGIN
	SET IDENTITY_INSERT dbo.[LoggingFilter] ON
	INSERT INTO [LoggingFilter] (ID, Name, AppID, ClientFilter, UserFilter, EnvironmentFilter, EventFilter, Enabled, StartDate, EndDate, PageEmail, PageSMS, CreatedBy, CreateDate, ModifyDate, Custom1, Custom2, Custom3)
	SELECT *
	FROM ApplicationErrorLogging.dbo.[LoggingFilter]
	SET IDENTITY_INSERT dbo.[LoggingFilter] OFF

	UPDATE [LoggingFilter] SET [StartDate] = TODATETIMEOFFSET([StartDate], @OffsetTimeOfExistingDateTimes)
	UPDATE [LoggingFilter] SET [EndDate] = TODATETIMEOFFSET([EndDate], @OffsetTimeOfExistingDateTimes)
	UPDATE [LoggingFilter] SET [CreateDate] = TODATETIMEOFFSET([CreateDate], @OffsetTimeOfExistingDateTimes)
	UPDATE [LoggingFilter] SET [ModifyDate] = TODATETIMEOFFSET([ModifyDate], @OffsetTimeOfExistingDateTimes)

	SELECT TOP 1000 * FROM dbo.[LoggingFilter] ORDER BY [ModifyDate] DESC
END


IF((SELECT COUNT(*) FROM dbo.[UserProfile]) = 0)
BEGIN
	SET IDENTITY_INSERT dbo.[UserProfile] ON
	INSERT INTO [UserProfile] (UserId, UserName)
	SELECT *
	FROM ApplicationErrorLogging.dbo.[UserProfile]
	SET IDENTITY_INSERT dbo.[UserProfile] OFF

	SELECT TOP 1000 * FROM dbo.[UserProfile] 
END


IF((SELECT COUNT(*) FROM [dbo].[webpages_Membership]) = 0)
BEGIN
	INSERT INTO [dbo].[webpages_Membership] (UserId, CreateDate, ConfirmationToken, IsConfirmed, LastPasswordFailureDate, PasswordFailuresSinceLastSuccess, Password, PasswordChangedDate, PasswordSalt, PasswordVerificationToken, PasswordVerificationTokenExpirationDate)
	SELECT *
	FROM ApplicationErrorLogging.[dbo].[webpages_Membership]

	SELECT TOP 1000 * FROM [dbo].[webpages_Membership] 
END


IF((SELECT COUNT(*) FROM [dbo].[webpages_OAuthMembership]) = 0)
BEGIN
	INSERT INTO [dbo].[webpages_OAuthMembership] (Provider, ProviderUserId, UserId)
	SELECT *
	FROM ApplicationErrorLogging.[dbo].[webpages_OAuthMembership]

	SELECT TOP 1000 * FROM [dbo].[webpages_OAuthMembership] 
END




IF((SELECT COUNT(*) FROM [dbo].[webpages_Roles]) = 0)
BEGIN
	SET IDENTITY_INSERT dbo.[webpages_Roles] ON
	INSERT INTO [dbo].[webpages_Roles] (RoleId, RoleName)
	SELECT *
	FROM ApplicationErrorLogging.[dbo].[webpages_Roles]
	SET IDENTITY_INSERT dbo.[webpages_Roles] OFF

	SELECT TOP 1000 * FROM [dbo].[webpages_Roles] 
END



IF((SELECT COUNT(*) FROM [dbo].[webpages_UsersInRoles]) = 0)
BEGIN
	INSERT INTO [dbo].[webpages_UsersInRoles] (UserId, RoleId)
	SELECT *
	FROM ApplicationErrorLogging.[dbo].[webpages_UsersInRoles]

	SELECT TOP 1000 * FROM [dbo].[webpages_UsersInRoles] 
END


GO
