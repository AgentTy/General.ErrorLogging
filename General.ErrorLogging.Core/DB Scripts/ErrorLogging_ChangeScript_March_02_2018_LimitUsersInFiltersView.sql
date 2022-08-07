/****** Object:  StoredProcedure [dbo].[pr_Application_SelectUsers]    Script Date: 3/2/18 1:26:30 PM ******/
DROP PROCEDURE [dbo].[pr_Application_SelectUsers]
GO

/****** Object:  StoredProcedure [dbo].[pr_Application_SelectUsers]    Script Date: 3/2/18 1:26:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pr_Application_SelectUsers]
	@AppID [Int]
	, @ClientID [VarChar](50) = NULL
AS
	SET NOCOUNT ON

	SELECT TOP 2000 [ErrorOtherLog].[UserID] AS UserID
		, COUNT(*) AS Frequency
		, (CASE WHEN COUNT(*)  > 1 THEN 1 ELSE 0 END) AS Frequent
	FROM [dbo].[ErrorOtherLog]
		JOIN [dbo].[ErrorOther]
			ON [ErrorOther].[ID] = [ErrorOtherLog].[ErrorOtherID]
	WHERE [AppID] = @AppID
		AND [ErrorOtherLog].[UserID] IS NOT NULL
		AND (@ClientID IS NULL OR [ErrorOtherLog].[ClientID] = @ClientID)
		AND ErrorOtherLog.[TimeStamp] > GETDATE() - 365
	GROUP BY [ErrorOtherLog].[UserID]
	ORDER BY Frequent DESC, [ErrorOtherLog].[UserID]



GO


