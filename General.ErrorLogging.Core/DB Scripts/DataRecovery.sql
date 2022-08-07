BEGIN TRAN

--SELECT * INTO ErrorOtherBackup FROM ErrorOther

/****** Object:  Table [dbo].[ErrorOther]    Script Date: 4/7/2016 1:52:38 PM ******/
DROP TABLE [dbo].[ErrorOther]
GO

/****** Object:  Table [dbo].[ErrorOther]    Script Date: 4/7/2016 1:52:38 PM ******/
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
    [FirstTime] [datetimeoffset](7) NOT NULL CONSTRAINT [DF_ErrorOther_FirstTime]  DEFAULT (sysdatetimeoffset()),
    [LastTime] [datetimeoffset](7) NOT NULL CONSTRAINT [DF_ErrorOther_LastTime]  DEFAULT (sysdatetimeoffset()),
    [Count] [smallint] NOT NULL CONSTRAINT [DF_ErrorOther_Count]  DEFAULT ((1)),
    [ErrorType] [smallint] NOT NULL,
    [Severity] [smallint] NULL,
    [ErrorCode] [varchar](20) NULL,
    [CodeMethod] [varchar](200) NULL,
    [CodeFileName] [varchar](200) NULL,
    [CodeLineNumber] [int] NULL,
    [CodeColumnNumber] [int] NULL,
    [ExceptionType] [varchar](200) NULL,
    [ErrorName] [varchar](200) NULL,
    [ErrorDetail] [varchar](max) NULL,
    [ErrorURL] [varchar](200) NULL,
    [UserAgent] [varchar](400) NULL,
    [UserType] [varchar](50) NULL,
    [UserID] [varchar](50) NULL,
    [CustomID] [int] NULL,
    [AppName] [varchar](100) NULL,
    [MachineName] [varchar](20) NULL,
    [Custom1] [varchar](200) NULL,
    [Custom2] [varchar](200) NULL,
    [Custom3] [varchar](200) NULL,
    [Duration] [int] NULL,
 CONSTRAINT [PK_ErrorOther] PRIMARY KEY CLUSTERED 
(
    [ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


SET IDENTITY_INSERT ErrorOther ON
INSERT INTO ErrorOther 
(ID, AppID, EnvironmentID, ClientID, FirstTime, LastTime, Count, ErrorType, Severity, ErrorCode, CodeMethod, CodeFileName, CodeLineNumber, CodeColumnNumber, ExceptionType, ErrorName, ErrorDetail, ErrorURL, UserAgent, UserType, UserID, CustomID, AppName, MachineName, Custom1, Custom2, Custom3, Duration)
SELECT ID, AppID, EnvironmentID, ClientID, FirstTime, LastTime, Count, ErrorType, Severity, ErrorCode, CodeMethod, CodeFileName, CodeLineNumber, CodeColumnNumber, ExceptionType, ErrorName, ErrorDetail, ErrorURL, UserAgent, UserType, UserID, CustomID, AppName, MachineName, Custom1, Custom2, Custom3, Duration
FROM ErrorOtherBackup 
SET IDENTITY_INSERT ErrorOther OFF

SELECT COUNT(*) FROM ErrorOther

SELECT TOP 100 * FROM ErrorOther

COMMIT TRAN