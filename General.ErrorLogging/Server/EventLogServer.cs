using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace General.ErrorLogging.Server
{
    public class EventLogServer
    {

        #region StoreEventInDatabase
        public static EventReporterResponse StoreEventInDatabase(EventContext exInfo, ApplicationContext context, FilterContext filterContext, EventHistoryContext historyContext = null)
        {
            if (context == null)
                context = new ApplicationContext();

            EventReporterResponse response = new EventReporterResponse();
            try
            {
                var enuEventType = General.ErrorLogging.Model.ErrorOtherTypes.Unknown;
                if (exInfo.EventType.HasValue)
                    enuEventType = exInfo.EventType.Value;

                string strAppName = "";
                try { strAppName = ErrorReporter.GetAppName(context); }
                catch { }

                try
                {
                    #region Send To Database
                    long intIncidentID = General.ErrorLogging.Data.ErrorOther.StoreEvent(ErrorReporter.GetAppID(context), ErrorReporter.GetEnvironment(context), context.ClientID
                        , enuEventType
                        , exInfo.Severity
                        , exInfo.ExceptionType
                        , exInfo.MethodName
                        , exInfo.FileName
                        , exInfo.LineNumber
                        , exInfo.ColumnNumber
                        , exInfo.ErrorCode
                        , exInfo.EventName
                        , exInfo.Details
                        , exInfo.URL
                        , exInfo.UserAgent
                        , context.UserType
                        , context.UserID
                        , context.CustomID
                        , strAppName
                        , context.MachineName
                        , context.Custom1 //Custom1
                        , context.Custom2 //Custom2
                        , context.Custom3 //Custom3
                        , exInfo.Duration //Duration
                        , filterContext
                        , historyContext);
                    response.Success = true;
                    response.IncidentID = intIncidentID;
                    return response;
                    #endregion
                }
                catch(Exception ex)
                {
                    try
                    {
                        General.ErrorLogging.Client.RecordEventDataContext request = new General.ErrorLogging.Client.RecordEventDataContext();
                        request.AppContext = context;
                        request.EventContext = exInfo;

                        try
                        {
                            request.EventContext.Details += "\r\n\r\nError In Logging DLL (EventLogServer)\r\n" + General.Debugging.ErrorReporter.GetErrorReport(ex, "\r\n").ToString();
                        }
                        catch
                        {
                            request.EventContext.Details += "\r\n\r\nError In Logging DLL (EventLogServer)\r\n" + ex.Message;
                        }

                        General.ErrorLogging.Client.EventLogClient.EmailEvent(request, response);
                    }
                    catch { }
                    throw;
                }
            }
            catch (Exception ex)
            {
                //DON'T TRY TO REPORT THIS ERROR NORMALLY OR YOU COULD CREATE AN INFINITE LOOP AND CRASH THE APP
                try
                {
                    if (exInfo != null)
                        General.Debugging.Report.SendError("Error occurred while generating an error report.", System.Environment.CurrentDirectory + "\r\n\r\n" + exInfo.ErrorName + "\r\n\r\n" + ex.ToString() + "\r\n\r\n\r\n\r\n\r\n\r\n" + exInfo.Details.ToString());
                    else
                        General.Debugging.Report.SendError("Error occurred while generating an error report.", System.Environment.CurrentDirectory + "\r\n\r\n" + ex.ToString());
                }
                catch { }
            }
            return response;
        }

        public static EventReporterResponse StoreEventInDatabase(Model.ErrorOther model, ApplicationContext context, FilterContext filterContext, EventHistoryContext historyContext = null)
        {
            EventReporterResponse response = new EventReporterResponse();
            response.IncidentID = General.ErrorLogging.Data.ErrorOther.StoreEvent(model, filterContext, historyContext);
            response.Success = true;
            return response;
        }
        #endregion

    }
}
