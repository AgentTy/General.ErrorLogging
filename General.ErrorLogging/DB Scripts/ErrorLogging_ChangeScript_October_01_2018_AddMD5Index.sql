/*
Missing Index Details from SQLQuery13.sql - MLDBSQA2K1201 (KCSQA).ApplicationEventLogging (denali (113))
The Query Processor estimates that implementing the following index could improve the query cost by 99.9763%.
*/

/*
USE [ApplicationEventLogging]
GO

GO
*/
CREATE NONCLUSTERED INDEX [ix_ErrorOtherDetail_MD5Hash]
ON [dbo].[ErrorOtherDetail] ([MD5Hash])
