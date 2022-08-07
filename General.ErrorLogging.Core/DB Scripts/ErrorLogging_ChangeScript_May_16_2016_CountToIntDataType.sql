SELECT TOP 10 * FROM ErrorOther ORDER BY [COUNT] DESC


ALTER TABLE [dbo].[Error404] DROP CONSTRAINT [DF_Error404_Count]
GO

ALTER TABLE [dbo].[Error404]
ALTER COLUMN [Count] [int]
GO

ALTER TABLE [dbo].[Error404] ADD  CONSTRAINT [DF_Error404_Count]  DEFAULT ((1)) FOR [Count]
GO

ALTER TABLE [dbo].[ErrorOther] DROP CONSTRAINT [DF_ErrorOther_Count]
GO

ALTER TABLE [dbo].[ErrorOther]
ALTER COLUMN [Count] [int]
GO

ALTER TABLE [dbo].[ErrorOther] ADD  CONSTRAINT [DF_ErrorOther_Count]  DEFAULT ((1)) FOR [Count]
GO

SELECT TOP 10 * FROM ErrorOther ORDER BY [COUNT] DESC

GO


ALTER PROCEDURE [dbo].[pr_Error404_Update]
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

ALTER PROCEDURE [dbo].[pr_Error404Redirect_Update]
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

ALTER PROCEDURE [dbo].[pr_Error404Redirect_UpdateLog]
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