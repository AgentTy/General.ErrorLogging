/*DBCC SHRINKFILE (ApplicationEventLogging_log, 1)
SELECT * FROM Application


SELECT TOP 10 * FROM ErrorOther 
WHERE AppID = 0
ORDER BY LastTime DESC
*/


DECLARE @Filters AS IDLISTTYPE
INSERT INTO @Filters SELECT 1
INSERT INTO @Filters SELECT 9


EXEC [dbo].[pr_ErrorOther_Insert] @AppID=0,
@EnvironmentID=1,
@ErrorType=6,
@ExceptionType='ReferenceError',
@CodeMethod='HTMLParagraphElement.onclick',
@CodeFileName='/Home/ErrorLog',
@CodeLineNumber=194,
@CodeColumnNumber=61,
@ErrorCode='',
@ErrorName='notavar is not defined',
@ErrorDetail='Stack: ReferenceError: notavar is not defined
    at HTMLParagraphElement.onclick (http://localhost:48179/Home/ErrorLog:194:61)


 ReferenceError: notavar is not defined
',
@ErrorURL='http://localhost:48179/Home/ErrorLog',
@UserAgent='Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36',
@UserID='tyh',
@AppName='General Library',
@MachineName='',
@Custom1='',
@Custom2='',
@Custom3='EVENT HISTORY: #372c09 #372c09 #36e325 #36e222 #36e221 #36e1ac #36e177 #36e0e7 #36dd61 #unknown #unknown #363d62 #3615b0 #3610e0 ',
@FiltersMatched=@Filters