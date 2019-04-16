using System;
using General;
using General.ErrorLogging.Model;
using General.Data;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Net.Mail;
using System.Reflection;

namespace General.ErrorLogging.Client
{

	/// <summary>
    /// This wrapper class will facilitate communication between a client and an Error Logging server in one of two ways...
    ///     1. Via directly connection to the Logging Database via SQL objects
    ///     2. Via JSON over HTTP
    /// Which method will be used is determined by the configuration key: ErrorLogUseSQLConnToReport
    /// <add key="ErrorLogUseSQLConnToReport" value="true" />
    /// The default is false, so no value means use JSON over HTTP
    /// Please note: direct SQL communication will currently bypass filters and notifications, meaning every event will be recorded and no notifications will be sent.
	/// </summary>
    public class EventLogClient
    {
        static string APIActionPattern_RecordEvent = "api/[AppID]/ErrorLog/RecordEvent/";

        public static FilterCacheManager FilterCache = new FilterCacheManager();

        #region StoreEvent

        public static async Task<EventReporterResponse> StoreEvent(Model.ErrorOther model, ApplicationContext appContext, FilterContext filterContext = null, EventHistoryContext historyContext = null)
        {
            try
            {
                EventReporterResponse result = new EventReporterResponse();
                if (ErrorReporter.ErrorLogUseSQLConnToReport)
                {
                    //Read the AppContext into the model
                    if (appContext.AppID.HasValue)
                        model.AppID = appContext.AppID.Value;
                    model.AppName = appContext.AppName;
                    model.ClientID = appContext.ClientID;
                    model.Custom1 = appContext.Custom1;
                    model.Custom2 = appContext.Custom2;
                    model.Custom3 = appContext.Custom3;
                    model.CustomID = appContext.CustomID;
                    model.Environment = ErrorReporter.GetEnvironment(appContext);
                    model.MachineName = appContext.MachineName;
                    model.UserID = appContext.UserID;
                    model.UserType = appContext.UserType;

                    //Talk to database
                    try
                    {
                        result = General.ErrorLogging.Server.EventLogServer.StoreEventInDatabase(model, appContext, filterContext, historyContext);
                    }
                    catch (Exception ex)
                    {
                        throw;
                    }
                }
                else
                {
                    //Read the model into an EventContext
                    EventContext eventContext = new EventContext(model);

                    //Prepare Web Service request
                    RecordEventDataContext request = new RecordEventDataContext();
                    request.AccessCode = ErrorReporter.ErrorAPIWriteOnlyAccessCode;
                    request.AppContext = appContext;
                    request.EventContext = eventContext;
                    request.FilterContext = filterContext;
                    request.EventHistory = historyContext;

                    //Make Web Service Call
                    result = await StoreEvent(request).ConfigureAwait(false);
                }
                return result;
            }
            catch
            {
                throw;
            }
        }

        public static async Task<EventReporterResponse> StoreEvent(EventContext eventContext, ApplicationContext appContext, FilterContext filterContext = null, EventHistoryContext historyContext = null)
        {
            //Prepare Web Service request
            RecordEventDataContext request = new RecordEventDataContext();
            request.AccessCode = ErrorReporter.ErrorAPIWriteOnlyAccessCode;
            request.EventContext = eventContext;
            request.AppContext = appContext;
            request.FilterContext = filterContext;
            request.EventHistory = historyContext;
            return await StoreEvent(request).ConfigureAwait(false);
        }

        public static async Task<EventReporterResponse> StoreEvent(RecordEventDataContext request)
        {
            if (General.StringFunctions.IsNullOrWhiteSpace(request.AccessCode))
                request.AccessCode = ErrorReporter.ErrorAPIWriteOnlyAccessCode;

            try
            {
                EventReporterResponse response = new EventReporterResponse();

                if (ErrorReporter.ErrorLogUseSQLConnToReport)
                {
                    #region SQL call via data layer
                    try
                    {
                        response = General.ErrorLogging.Server.EventLogServer.StoreEventInDatabase(request.EventContext, request.AppContext, request.FilterContext, request.EventHistory);
                    }
                    catch (Exception ex)
                    {
                        throw;
                    }
                    #endregion
                }
                else
                {
                    #region Remote Web Service call
                    string apiPath = APIActionPattern_RecordEvent.Replace("[AppID]", request.AppContext.AppID.ToString());

                    //Make Web Service call, do NOT wait for response
                    if (ErrorReporter.ErrorLogUseAsyncLogging)
                    {
                        #region Async Web API Call
                        response.Success = true;
                        response.Message = "Running in separate thread, status unknown.";

                        //Test code: adds 2 seconds of delay before initiating the task
                        //await Task.Delay(2000).ConfigureAwait(false);

                        await Task.Run
                           (async () =>
                           {
                               //Test code: adds 2 seconds of delay before calling StoreEventViaAPI
                               //await Task.Delay(2000).ConfigureAwait(false);

                               DateTime timeStart = DateTime.Now;
                               try
                               {
                                   HttpResponseMessage httpResult = await StoreEventViaAPI(ErrorReporter.ErrorEndpointUri(), apiPath, request).ConfigureAwait(false);
                                   if (httpResult.IsSuccessStatusCode)
                                   {
                                       response = await httpResult.Content.ReadAsAsync<EventReporterResponse>().ConfigureAwait(false);
                                   }
                                   else
                                   {
                                       TimeSpan timeElapsed = TimeSpan.Zero;
                                       try
                                       {
                                           DateTime timeEnd = DateTime.Now;
                                           timeElapsed = timeEnd - timeStart;
                                       }
                                       catch { }

                                       response.Success = false;
                                       response.Message = httpResult.StatusCode.ToString();
                                       if(!String.IsNullOrWhiteSpace(httpResult.ReasonPhrase) && httpResult.ReasonPhrase != httpResult.StatusCode.ToString())
                                           response.Message += ": " + httpResult.ReasonPhrase;

                                       request.EventContext.Details += "    logging service message: " + response.Message + "\r\n";
                                       request.EventContext.Details += "    time spent waiting on logging server: " + timeElapsed.TotalSeconds + " seconds\r\n";
                                   }
                               }
                               catch (Exception ex)
                               {
                                   response.Success = false;
                                   response.Message = ex.Message;
                                   if (ex.InnerException != null)
                                       response.Message += "\r\n" + ex.InnerException.Message;

                                   request.EventContext.Details += "\r\n\r\nError In Logging DLL (EventLogClient)\r\n";
                                   try
                                   {
                                       DateTime timeEnd = DateTime.Now;
                                       TimeSpan timeElapsed = timeEnd - timeStart;
                                       request.EventContext.Details += "    time spent waiting on logging server:" + timeElapsed.TotalSeconds + " seconds\r\n";
                                   }
                                   catch { }

                                   try
                                   {
                                       request.EventContext.Details += General.Debugging.ErrorReporter.GetErrorReport(ex, "\r\n").ToString();
                                   }
                                   catch
                                   {
                                       request.EventContext.Details += response.Message;
                                   }

                               }

                               if (!response.Success && request.EventContext.EventType.HasValue && ErrorReporter.IsErrorEvent(request.EventContext.EventType.Value))
                               {
                                   //Email Backup
                                   await EmailEvent(request, response).ConfigureAwait(false);
                               }

#if DEBUG
                               try
                               {
                                   string strConsoleMsg = "";
                                   if(response.Success)
                                   {
                                       if (ErrorReporter.IsErrorEvent(request.EventContext.EventType.Value))
                                           strConsoleMsg += "Error Incident Code: " + response.IncidentCode + "\r\n";
                                       else
                                           strConsoleMsg += "Log Incident Code: " + response.IncidentCode + "\r\n";
                                   }
                                   else
                                   {
                                       if (ErrorReporter.IsErrorEvent(request.EventContext.EventType.Value))
                                           strConsoleMsg += "Error occurred but could not be logged: " + response.Message + "\r\n";
                                       else
                                           strConsoleMsg += "Event occurred but could not be logged: " + response.Message + "\r\n";
                                   }
                                   strConsoleMsg += request.EventContext.EventType.Value.ToString() + ": " + request.EventContext.EventName + "\r\n";

                                   System.Diagnostics.Debug.Write(strConsoleMsg, "General.ErrorLogging");
                               }
                               catch { }
#endif

                           }
                           ).ConfigureAwait(false);

                        #endregion
                    }
                    else
                    {
                        #region Synchronous Web API Call
                        //Make Web Service call, wait for response
                        HttpResponseMessage httpResult = StoreEventViaAPI_Synchronous(ErrorReporter.ErrorEndpointUri(), apiPath, request);
                        if (httpResult.IsSuccessStatusCode)
                        {
                            response = httpResult.Content.ReadAsAsync<EventReporterResponse>().Result;
                        }
                        else
                        {
                            response.Success = false;
                            response.Message = httpResult.StatusCode.ToString() + ": " + httpResult.ReasonPhrase;
                        }
                        #endregion
                    }
                    #endregion
                }
                //try { ClearQueue(); }
                //catch { }
                return response;
            }
            catch
            {
                //ErrorQueue.Add(cmd);
                throw;
            }
        }

        protected static async Task<HttpResponseMessage> StoreEventViaAPI(Uri uriEndpoint, string apiPath, RecordEventDataContext request)
        {
            //Test code: adds 5 seconds of delay before initiating the HttpClient request
            //await Task.Delay(5000).ConfigureAwait(false);

            using (var client = new HttpClient())
            {
                client.BaseAddress = uriEndpoint;
                client.Timeout = TimeSpan.FromSeconds(10);
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                return await client.PostAsJsonAsync(apiPath, request).ConfigureAwait(false);
            }
        }


        protected static HttpResponseMessage StoreEventViaAPI_Synchronous(Uri uriEndpoint, string apiPath, RecordEventDataContext request)
        {
            using (var client = new HttpClient())
            {
                client.BaseAddress = uriEndpoint;
                client.Timeout = TimeSpan.FromSeconds(3);
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                return client.PostAsJsonAsync(apiPath, request).Result;
            }
        }

        #endregion StoreEvent

        #region EmailEvent
        public static async Task<bool> EmailEvent(RecordEventDataContext request, EventReporterResponse response, string strSubjectComment = "")
        {
            if (ErrorReporter.ErrorLogUseEmailBackup)
            {
                #region Email Subject
                string strSubject = "Event unable to save: " + request.EventContext.EventName;
                if (!StringFunctions.IsNullOrWhiteSpace(strSubjectComment))
                    strSubject += " - " + strSubjectComment;
                #endregion

                #region Email Body

                #region HTML Template
                string strSiteBase = ErrorReporter.ErrorEndpointUri().ToString().TrimEnd('/');
                string strBodyTemplate = @"
<html>
<head>
    <link href=""" + strSiteBase + @"/Content/EventView.css"" rel=""stylesheet""/>
</head>
<body>
<div class=""ErrorLogDetail"">
    <div class=""EventView"">
        <h2 id=""detailHeader"">
            <i id=""detailEventType"" class=""ColorServerError""<span>*|Event.EventType|*</span> *|EventClass|*</i>
        </h2>
        <h1 id=""detailEventName"">*|Event.EventName|*</h1>
        <h4 id=""detailTimeStamp"">*|TimeStamp|*</h4>
        <h3 id=""detailURL""><a href=""*|Event.URL|*"" target=""_blank"">*|Event.URL|*</a></h3>
        <table><tr><td>
        <div>
            <ul class=""DetailList"">
                <li><label>File: </label><span class=""important"">*|Event.FileName|*:*|Event.LineNumber|*</span></li>
                <li><label>Method: </label><span>*|Event.MethodName|*</span></li>
                <li><label>Exception: </label><span>*|Event.ExceptionType|*</span></li>
                <li><label>Error Code: </label><span>*|Event.ErrorCode|*</span></li>
                <li><label>Duration: </label><span>*|Event.Duration|*ms</span></li>
            </ul>

            <ul class=""DetailList"">
                <li><label>App: </label><span>*|App.AppName|*</span> (<em>*|App.Environment|*</em>)</li>
                <li><label>Server: </label><span>*|App.MachineName|*</span></li>
            </ul>

        </div>
        </td><td>
        <div>
            <div class=""column"">
                <ul class=""DetailList"">
                    <li><label>Client: </label><span>*|App.ClientID|*</span></li>
                    <li><label>User: </label><span>*|App.UserID|*</span></li>
                    <li><label>UserType: </label><span>*|App.UserType|*</span></li>
                    <li><label>Custom ID: </label><span>*|App.CustomID|*</span></li>
                </ul>
                <ul class=""DetailList DetailHorizontal"">
                    <li><label>Custom1: </label><span>*|App.Custom1|*</span></li>
                    <li><label>Custom2: </label><span>*|App.Custom2|*</span></li>
                    <li><label>Custom3: </label><span>*|App.Custom3|*</span></li>
                </ul>
            </div>
        </div>
        </td></tr></table>
        <pre><code>*|Event.Details|*</code></pre>
        <i id=""detailUserAgent"">*|Event.UserAgent|*</i>
    </div>
</div>
</body>
</html>
";
                #endregion

                #region Bind The Message Body
                string strBody = strBodyTemplate;
                bool isHtml = true;
                try
                {
                    Dictionary<string, string> Variables = new Dictionary<string, string>();

                    void AddVariables(object obj, string prefix)
                    {
                        Type type = obj.GetType();
                        PropertyInfo[] properties = type.GetProperties();

                        foreach (PropertyInfo property in properties)
                        {
                            object value = property.GetValue(obj, null);
                            string stringValue = "";
                            if (value != null)
                                stringValue = value.ToString();
                            if (!Variables.ContainsKey(prefix + property.Name))
                                Variables.Add(prefix + property.Name, stringValue);
                        }

                        FieldInfo[] fields = type.GetFields();
                        foreach (var field in fields)
                        {
                            object value = field.GetValue(obj);
                            string stringValue = "";
                            if (value != null)
                                stringValue = value.ToString();
                            if (!Variables.ContainsKey(prefix + field.Name))
                                Variables.Add(prefix + field.Name, stringValue);
                        }
                    }

                    if (request.EventContext.EventType.HasValue)
                        Variables.Add("EventClass", ErrorReporter.IsErrorEvent(request.EventContext.EventType.Value) ? "Error" : "Event");
                    else
                        Variables.Add("EventClass", "Event");
                    Variables.Add("TimeStamp", DateTimeOffset.Now.ToString());
                    AddVariables(request.AppContext, "App.");
                    AddVariables(request.EventContext, "Event.");

                    foreach (var variable in Variables)
                    {
                        strBody = General.StringFunctions.ReplaceCaseInsensitive(strBody, "*|" + variable.Key + "|*", variable.Value);
                    }
                }
                catch (Exception ex)
                {
                    isHtml = false;
                    strBody = request.EventContext.ErrorName + "\r\n";
                    strBody += request.AppContext.AppName + " (" + request.AppContext.MachineName + ")\r\n\r\n";
                    strBody += request.EventContext.Details + "\r\n\r\n";
                    strBody += "Html Email Error: \r\n";
                    strBody += ex.Message + "\r\n";
                    if (ex.InnerException != null)
                        strBody += ex.InnerException.Message + "\r\n";
                }
                #endregion

                #endregion

                //Send an email
                var emailResult = await SendEmailToAdmin(strSubject, strBody, isHtml).ConfigureAwait(false);

                //Update the response object
                response.BackupLogSent = emailResult;
                if (emailResult)
                    response.BackupLogMessage = "Email sent to backup contact";
                else
                    response.BackupLogMessage = "Email attempt failed";
                return emailResult;
            }
            else
                return false;
        }

        public static async Task<bool> SendEmailToAdmin(string Subject, string Body, bool IsHtml = false)
        {
            return await SendEmail(ErrorReporter.ErrorEmailFrom, ErrorReporter.ErrorEmailTo, Subject, Body, IsHtml).ConfigureAwait(false);
        }

        public static async Task<bool> SendEmail(General.Model.EmailAddress FromEmail, General.Model.EmailAddress ToEmail, string Subject, string Body, bool IsHtml = false, List<string> Attachments = null)
        {
            List<General.Model.EmailAddress> recipients = new List<General.Model.EmailAddress>();
            recipients.Add(ToEmail);

            return await SendEmail(FromEmail, recipients, Subject, Body, IsHtml, Attachments).ConfigureAwait(false);
        }

        public static async Task<bool> SendEmail(General.Model.EmailAddress FromEmail, List<General.Model.EmailAddress> Recipients, string Subject, string Body, bool IsHtml = false, List<string> Attachments = null, bool SendWithBCC = true)
        {
            
            MailMessage objMailMessage = new MailMessage();

            #region From/To
            objMailMessage.From = new MailAddress(FromEmail, FromEmail.Name);

            if (Recipients == null || Recipients.Count == 0)
                return false;
            else if (Recipients.Count == 1)
            {
                General.Model.EmailAddress objEmail = Recipients.First();
                if (StringFunctions.IsNullOrWhiteSpace(objEmail.Name))
                    objMailMessage.To.Add(objEmail.Value);
                else
                    objMailMessage.To.Add(new MailAddress(objEmail, objEmail.Name));
            }
            else if (Recipients.Count > 1)
            {
                foreach (General.Model.EmailAddress objEmail in Recipients)
                {
                    if (objEmail != null)
                        if (objEmail.Valid)
                        {
                            if (SendWithBCC)
                            {
                                if (StringFunctions.IsNullOrWhiteSpace(objEmail.Name))
                                    objMailMessage.Bcc.Add(objEmail.Value);
                                else
                                    objMailMessage.Bcc.Add(new MailAddress(objEmail, objEmail.Name));
                            }
                            else
                            {
                                if (StringFunctions.IsNullOrWhiteSpace(objEmail.Name))
                                    objMailMessage.To.Add(objEmail.Value);
                                else
                                    objMailMessage.To.Add(new MailAddress(objEmail, objEmail.Name));
                            }
                        }
                }

            }
            #endregion

            #region Message Content
            objMailMessage.Subject = Subject;
            objMailMessage.Body = Body;
            if (!String.IsNullOrEmpty(Body) && (Body.ToLower().Contains("<br") || Body.ToLower().Contains("<div") || Body.ToLower().Contains("<body")))
                IsHtml = true;
            objMailMessage.IsBodyHtml = IsHtml;
            #endregion

            #region Attachments
            if (Attachments != null)
            {
                foreach (string s in Attachments)
                {
                    if (System.IO.File.Exists(s))
                    {
                        Attachment objAttachment = new Attachment(s);
                        objMailMessage.Attachments.Add(objAttachment);
                    }
                }
            }
            #endregion

            #region Send Asynchronously
            using (System.Net.Mail.SmtpClient objMailServer = ErrorReporter.GetEmailServer())
            {
                try
                {
                    await objMailServer.SendMailAsync(objMailMessage).ConfigureAwait(false);
                    return true;
                }
                catch
                {
                    return false;
                }
            }
            #endregion

        }
        #endregion


    } //End Class

    public class FilterCacheManager
    {
        static string APIActionPattern_GetFilters = "api/[AppID]/LoggingFilter/ActiveFiltersForRemoteApp";

        protected List<LoggingFilterRemoteServerView> CurrentFilters;
        protected DateTimeOffset CurFiltersTimeStamp;

        public async Task<List<LoggingFilterRemoteServerView>> Active()
        {
            if (CurrentFilters == null || (DateTimeOffset.Now - CurFiltersTimeStamp).TotalSeconds > ErrorReporter.FilterCacheExpireSeconds)
            {
                CurrentFilters = await Get().ConfigureAwait(false);
                CurFiltersTimeStamp = DateTimeOffset.Now;
            }
            return CurrentFilters;
        }

        public async Task Reload()
        {
            CurrentFilters = await Get().ConfigureAwait(false);
            CurFiltersTimeStamp = DateTimeOffset.Now;
        }

        protected async Task<List<LoggingFilterRemoteServerView>> Get()
        {
            General.ErrorLogging.Data.LoggingFilter.GetActiveFiltersDataContext request = new General.ErrorLogging.Data.LoggingFilter.GetActiveFiltersDataContext();
            request.AccessCode = ErrorReporter.ErrorAPIWriteOnlyAccessCode;
            request.AppContext = new Data.LoggingFilter.LoggingFilterRequestContext();
            request.AppContext.AppID = ErrorReporter.AppID;
            request.AppContext.Environment = General.Environment.Current.WhereAmI();

            try
            {
                if (ErrorReporter.ErrorLogUseSQLConnToReport)
                {
                    return General.ErrorLogging.Data.LoggingFilter.GetFiltersForRemoteServer(ErrorReporter.AppID, request.AppContext, blnActiveOnly: true);
                }
                else
                {
                    string apiPath = APIActionPattern_GetFilters.Replace("[AppID]", ErrorReporter.AppID.ToString());
                    using (var client = new HttpClient())
                    {
                        client.BaseAddress = ErrorReporter.ErrorEndpointUri();
                        client.DefaultRequestHeaders.Accept.Clear();
                        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                        HttpResponseMessage httpResult = await client.PostAsJsonAsync(apiPath, request).ConfigureAwait(false);
                        if (httpResult.IsSuccessStatusCode)
                        {
                            var filters = await httpResult.Content.ReadAsAsync<List<LoggingFilterRemoteServerView>>().ConfigureAwait(false);
                            return filters;
                        }
                        else
                            return new List<LoggingFilterRemoteServerView>(); //If all else fails... use default settings defined in ErrorReporter.ShouldStoreEvent
                    }
                }
            }
            catch
            {
                return new List<LoggingFilterRemoteServerView>(); //If all else fails... use default settings defined in ErrorReporter.ShouldStoreEvent
            }
        }

    }

} //End Namespace
