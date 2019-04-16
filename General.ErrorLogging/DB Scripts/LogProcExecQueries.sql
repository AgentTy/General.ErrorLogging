DECLARE @AppList IDListType
DECLARE @EventTypeList IDListType

INSERT INTO @AppList SELECT 0
INSERT INTO @AppList SELECT 1
INSERT INTO @AppList SELECT 2
INSERT INTO @AppList SELECT 3
INSERT INTO @AppList SELECT 4
INSERT INTO @AppList SELECT 5
INSERT INTO @AppList SELECT 6
INSERT INTO @AppList SELECT 7
INSERT INTO @AppList SELECT 8
INSERT INTO @AppList SELECT 9
INSERT INTO @AppList SELECT 10
INSERT INTO @AppList SELECT 11

INSERT INTO @EventTypeList SELECT 0
INSERT INTO @EventTypeList SELECT 1
INSERT INTO @EventTypeList SELECT 2
INSERT INTO @EventTypeList SELECT 3
INSERT INTO @EventTypeList SELECT 4
INSERT INTO @EventTypeList SELECT 6
INSERT INTO @EventTypeList SELECT 10
INSERT INTO @EventTypeList SELECT 11
INSERT INTO @EventTypeList SELECT 12
INSERT INTO @EventTypeList SELECT 13

SET ARITHABORT OFF

EXEC [dbo].[pr_ErrorOther_SelectLog_Multi] 
@Apps=@AppList,
@EventTypes=@EventTypeList,
@StartDate='2/21/2019 12:00:00 AM -07:00',
@EndDate='2/21/2019 11:59:59 PM -07:00',
@IncludeDetail=False

/*
select o.object_id, s.plan_handle, h.query_plan 
from sys.objects o 
inner join sys.dm_exec_procedure_stats s on o.object_id = s.object_id
cross apply sys.dm_exec_query_plan(s.plan_handle) h
where o.object_id = object_id('pr_ErrorOther_SelectLog_Multi')

select * from sys.dm_exec_plan_attributes (0x05000600656E845A702D4D326400000001000000000000000000000000000000000000000000000000000000)
select * from sys.dm_exec_plan_attributes (0x05000600656E845A708FFB606400000001000000000000000000000000000000000000000000000000000000)

*/
