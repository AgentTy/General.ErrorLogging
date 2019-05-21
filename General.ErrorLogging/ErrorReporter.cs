using System;
using System.Collections.Generic;
using System.Text;
using General;
using General.ErrorLogging;
using System.Collections;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json;
using System.Collections.Specialized;

public class EventContext
{
    public General.ErrorLogging.Model.ErrorOtherTypes? EventType;
    public int? Severity;
    public string ErrorCode;
    public string EventName;
    public string ExceptionType;
    public string MethodName;
    public string FileName;
    public int LineNumber;
    public int ColumnNumber;
    public string URL;
    public string UserAgent;
    public string Details;
    public int? Duration;

    #region Legacy Support Code
    public General.ErrorLogging.Model.ErrorOtherTypes? ErrorType
    {
        get
        {
            return EventType;
        }
        set
        {
            EventType = value;
        }
    }

    public string ErrorName
    {
        get
        {
            return EventName;
        }
        set
        {
            EventName = value;
        }
    }
    #endregion

    public EventContext() { }

    public EventContext(string strEventName, string strExceptionType, string strDetails, string strFileName, string strURL)
    {
        EventType = General.ErrorLogging.Model.ErrorOtherTypes.Unknown;
        Severity = null;
        ErrorCode = null;
        EventName = strEventName;
        ExceptionType = strExceptionType;
        MethodName = null;
        FileName = strFileName;
        LineNumber = 0;
        ColumnNumber = 0;
        URL = strURL;
        UserAgent = null;
        Details = strDetails;
    }

    public EventContext(General.ErrorLogging.Model.ErrorOther model) 
    {
        this.EventType = model.EventType;
        this.Severity = model.Severity;
        this.ExceptionType = model.ExceptionType;
        this.MethodName = model.CodeMethod;
        this.FileName = model.CodeFileName;
        this.LineNumber = model.CodeLineNumber;
        this.ColumnNumber = model.CodeColumnNumber;
        this.ErrorCode = model.ErrorCode;
        this.EventName = model.EventName;
        this.Details = model.EventDetail;
        this.URL = model.EventURL;
        this.UserAgent = model.UserAgent;
        this.Duration = model.Duration;
    }

}

public class ApplicationContext
{
    public string ClientID;
    public string UserType;
    public string UserID;
    public int? CustomID;
    public string Custom1, Custom2, Custom3;
    public int? AppID;
    public string AppName;
    public string Environment;
    public string MachineName;

    public ApplicationContext() { }

    public ApplicationContext(string strClientID, string strUserType, string strUserID)
    {
        ClientID = strClientID;
        UserType = strUserType;
        UserID = strUserID;
        CustomID = null;
        Custom1 = null;
        Custom2 = null;
        Custom3 = null;
        AppID = null;
        AppName = null;
        Environment = null;
        MachineName = null;
    }

    public ApplicationContext(int? intClientID, int? intUserType, int intUserID)
    {
        if (intClientID.HasValue)
            ClientID = intClientID.Value.ToString();
        if (intUserType.HasValue)
            UserType = intUserType.Value.ToString();
        UserID = intUserID.ToString();
        CustomID = null;
        Custom1 = null;
        Custom2 = null;
        Custom3 = null;
        AppID = null;
        AppName = null;
        Environment = null;
    }
}

public class ExecutionContext
{
    public Uri RequestedURI;
    public string RequestMethod;
    public string RequestBody;
    public List<string> DatabaseQueries = new List<string>();

    public ExecutionContext()
    {

    }

    public ExecutionContext(Uri requestedURI, String requestMethod, string requestBody)
    {
        RequestedURI = requestedURI;
        RequestMethod = requestMethod;
        RequestBody = requestBody;
    }

    public ExecutionContext(System.Net.HttpWebRequest request)
    {
        RequestedURI = request.RequestUri;
        RequestMethod = request.Method;

        string retval = "[Accept] = " + request.Accept.ToString()
        + "\r\n[Address] = " + request.Address.ToString()
        + "\r\n[AllowAutoRedirect] = " + request.AllowAutoRedirect.ToString()
        + "\r\n[AllowReadStreamBuffering] = " + request.AllowReadStreamBuffering.ToString()
        + "\r\n[AllowWriteStreamBuffering] = " + request.AllowWriteStreamBuffering.ToString()
        + "\r\n[AuthenticationLevel] = " + request.AuthenticationLevel.ToString()
        + "\r\n[AutomaticDecompression] = " + request.AutomaticDecompression.ToString()
        + "\r\n[CachePolicy] = " + request.CachePolicy.ToString()
        + "\r\n[ClientCertificates] = " + request.ClientCertificates.ToString()
        + "\r\n[Connection] = " + request.Connection.ToString()
        + "\r\n[ConnectionGroupName] = " + request.ConnectionGroupName.ToString()
        + "\r\n[ContentLength] = " + request.ContentLength.ToString()
        + "\r\n[ContentType] = " + request.ContentType.ToString()
        + "\r\n[ContinueDelegate] = " + request.ContinueDelegate.ToString()
        + "\r\n[ContinueTimeout] = " + request.ContinueTimeout.ToString()
        + "\r\n[CookieContainer] = " + request.CookieContainer.ToString()
        + "\r\n[Credentials] = " + request.Credentials.ToString()
        + "\r\n[Date] = " + request.Date.ToString()
        + "\r\n[Expect] = " + request.Expect.ToString()
        + "\r\n[HaveResponse] = " + request.HaveResponse.ToString()
        + "\r\n[Headers] = " + request.Headers.ToString()
        + "\r\n[Host] = " + request.Host.ToString()
        + "\r\n[IfModifiedSince] = " + request.IfModifiedSince.ToString()
        + "\r\n[ImpersonationLevel] = " + request.ImpersonationLevel.ToString()
        + "\r\n[KeepAlive] = " + request.KeepAlive.ToString()
        + "\r\n[MaximumAutomaticRedirections] = " + request.MaximumAutomaticRedirections.ToString()
        + "\r\n[MaximumResponseHeadersLength] = " + request.MaximumResponseHeadersLength.ToString()
        + "\r\n[MediaType] = " + request.MediaType.ToString()
        + "\r\n[Method] = " + request.Method.ToString()
        + "\r\n[Pipelined] = " + request.Pipelined.ToString()
        + "\r\n[PreAuthenticate] = " + request.PreAuthenticate.ToString()
        + "\r\n[ProtocolVersion] = " + request.ProtocolVersion.ToString()
        + "\r\n[Proxy] = " + request.Proxy.ToString()
        + "\r\n[ReadWriteTimeout] = " + request.ReadWriteTimeout.ToString()
        + "\r\n[Referer] = " + request.Referer.ToString()
        + "\r\n[RequestUri] = " + request.RequestUri.ToString()
        + "\r\n[SendChunked] = " + request.SendChunked.ToString()
        + "\r\n[ServerCertificateValidationCallback] = " + request.ServerCertificateValidationCallback.ToString()
        + "\r\n[ServicePoint] = " + request.ServicePoint.ToString()
        + "\r\n[SupportsCookieContainer] = " + request.SupportsCookieContainer.ToString()
        + "\r\n[Timeout] = " + request.Timeout.ToString()
        + "\r\n[TransferEncoding] = " + request.TransferEncoding.ToString()
        + "\r\n[UnsafeAuthenticatedConnectionSharing] = " + request.UnsafeAuthenticatedConnectionSharing.ToString()
        + "\r\n[UseDefaultCredentials] = " + request.UseDefaultCredentials.ToString()
        + "\r\n[UserAgent] = " + request.UserAgent.ToString();
        RequestBody = retval;
    }

}

public class FilterContext
{
    public bool IShouldStoreEvent;
    public int[] MatchedFilters;

    public FilterContext() { }
}

public class EventHistoryContext
{
    /// <summary>
    /// Last Incident Code recorded in a client browser
    /// </summary>
    public string Last;
    public string[] History;

    public EventHistoryContext() { }
}

public class EventReporterResponse
{
    public long IncidentID;
    public string IncidentCode
    {
        get
        {
            return Convert.ToString(IncidentID, 16);
        }
    }
    public bool Success;
    public string Message;
    public bool BackupLogSent;
    public string BackupLogMessage;
    public EventReporterResponse() 
    {
    }
}

/// <summary>
/// The ErrorReporter will log errors and notify operators
/// </summary>
public class ErrorReporter
{
    //These are the default Severity numbers for Low/Normal/High Methods
    private const int LowSeverity = 1;
    private const int NormalSeverity = 5;
    private const int HighSeverity = 10;

    #region Settings

    #region Configure (.Net Core) 

    private static NameValueCollection coreConfig;
    public static void Configure(NameValueCollection config)
    {
        coreConfig = config;
    }
    #endregion

    #region IsConfiguredAndEnabled
        public static bool IsConfiguredAndEnabled()
    {
        var result = true;
        if (!Enabled)
            result = false;
        if (AppID < 0)
            result = false;
        if (StringFunctions.IsNullOrWhiteSpace(ErrorAPIWriteOnlyAccessCode))
            result = false;
        if (StringFunctions.IsNullOrWhiteSpace(ErrorAPIEndpoint) && !ErrorLogUseSQLConnToReport)
            result = false;
        if (System.Configuration.ConfigurationManager.ConnectionStrings["ErrorLog"] == null && ErrorLogUseSQLConnToReport)
            result = false;
        return result;
    }

    private static EventReporterResponse NotConfiguredResponse()
    {
        EventReporterResponse response = new EventReporterResponse();
        response.Success = false;
        if (Enabled)
            response.Message = "General.ErrorLogging is not configured";
        else
            response.Message = "General.ErrorLogging is disabled";
        return response;
    }
    #endregion

    public static string AppConfigBranchForErrorLog { get { return System.Configuration.ConfigurationManager.AppSettings["AppConfigBranchForErrorLog"]; } }
    public static string DefaultAppNameForErrorLog { get { return GetSetting("DefaultAppNameForErrorLog"); } }
    public static int AppID { get { return int.Parse(GetSetting("AppIDForErrorLogging", "-1")); } }
    public static string ErrorAPIEndpoint { get { return GetSetting("ErrorAPIEndpoint"); } }
    public static Uri ErrorEndpointUri()
    {
        //This rule is important for supporting instances hosted in a subfolder.
        if (!ErrorReporter.ErrorAPIEndpoint.EndsWith("/"))
            return new Uri(ErrorReporter.ErrorAPIEndpoint + "/");
        else
            return new Uri(ErrorReporter.ErrorAPIEndpoint);
    }

    public static string ErrorAPIWriteOnlyAccessCode { get { return GetSetting("ErrorAPIWriteOnlyAccessCode"); } }
    /// <summary>
    /// Number(seconds) The amount of time to keep logging filters in memory before retrieving updates from the logging server
    /// default: 60
    /// </summary>

    public static int FilterCacheExpireSeconds { get { return int.Parse(GetSetting("FilterCacheExpireSeconds", "350")); } }
    /// <summary>
    /// True/False: Ship events via a direct SQL Server connection using the "ErrorLog" connection string, or use the JSON API wrapper. 
    /// default: False
    /// </summary>
    public static bool ErrorLogUseSQLConnToReport { get { return GetSettingAsBool("ErrorLogUseSQLConnToReport"); } }

    /// <summary>
    /// True/False: Enable/Disable the entire logging plugin
    /// default: True
    /// </summary>

    public static bool Enabled { get { return GetSettingAsBool("ErrorLogEnabled", true); } }
    /// <summary>
    /// True/False: Do API calls in a separate thread. This will avoid holding up the main thread for more than 1 second, but risks non-completion if the http request takes more than 1 second.
    /// default: True
    /// </summary>

    public static bool ErrorLogUseAsyncLogging { get { return GetSettingAsBool("ErrorLogUseAsyncLogging", true); } }

    /// <summary>
    /// True/False: Send an email to the configured admin if an attempt to post the error fails, this will only apply to Error event types.
    /// default: True
    /// </summary>
    public static bool ErrorLogUseEmailBackup { get { return GetSettingAsBool("ErrorLogUseEmailBackup", true); } }

    public static string ErrorEmailFrom { get { return GetSetting("ErrorEmailFrom"); } }
    public static string ErrorEmailTo { get { return GetSetting("ErrorEmailTo"); } }

    public static System.Net.Mail.SmtpClient GetEmailServer() { return General.Mail.MailTools.GetMailServer(General.Mail.MailTools.MailServerTypes.Normal); }

    private static bool GetSettingAsBool(string Key, bool Default = false)
    {
        string value = GetSetting(Key);
        if (value == null)
            return Default;
        if (value.ToLower() == "yes")
            return true;
        if (value.ToLower() == "no")
            return false;
        if (value == "1")
            return true;
        if (value == "0")
            return false;
        bool parseValue;
        if (bool.TryParse(value, out parseValue))
            return parseValue;
        return Default;
    }


    private static string GetSetting(string Key, string Default = null)
    {
        string strSuffix = "_" + General.Environment.Current.WhereAmI().ToString().ToLower();

        //Support for a config passed in via a NameValueCollection
        if(coreConfig != null)
        {
            foreach(string key in coreConfig)
            {
                if (key.ToLower() == Key.ToLower())
                    return coreConfig[key];
            }
        }

        //Support for environmental variables in Azure
        if (!String.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable(Key + strSuffix)))
        {
            return Environment.GetEnvironmentVariable(Key + strSuffix);
        }
        else if (!String.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable(Key)))
        {
            return Environment.GetEnvironmentVariable(Key);
        }

        //Support for custom config section
        if (!StringFunctions.IsNullOrWhiteSpace(AppConfigBranchForErrorLog)) 
        {
            string value = ((System.Collections.Specialized.NameValueCollection)System.Configuration.ConfigurationManager.GetSection(AppConfigBranchForErrorLog))[Key];
            if (!StringFunctions.IsNullOrWhiteSpace(value))
                return value;
        }

        //Support Web.config/App.config files
        if (System.Configuration.ConfigurationManager.AppSettings[Key + strSuffix] != null)
        {
            return System.Configuration.ConfigurationManager.AppSettings[Key + strSuffix];
        }
        else if (System.Configuration.ConfigurationManager.AppSettings[Key] != null)
        {
            return System.Configuration.ConfigurationManager.AppSettings[Key];
        }
        return Default;
    }
#endregion

#region Constructor
    public ErrorReporter()
    {

    }
#endregion

#region ReportError

#region By Exception Object

#region Without A Name (overloads)
    public static async Task<EventReporterResponse> ReportErrorLowSeverity(Exception exObj, ApplicationContext context = null, ExecutionContext xContext = null)
    {
        return await ReportError(exObj, String.Empty, context, xContext, String.Empty, intSeverity: LowSeverity).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportErrorNormalSeverity(Exception exObj, ApplicationContext context = null, ExecutionContext xContext = null)
    {
        return await ReportError(exObj, String.Empty, context, xContext, String.Empty, intSeverity: NormalSeverity).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportErrorHighSeverity(Exception exObj, ApplicationContext context = null, ExecutionContext xContext = null)
    {
        return await ReportError(exObj, String.Empty, context, xContext, String.Empty, intSeverity: HighSeverity).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportError(Exception exObj, ApplicationContext context = null, ExecutionContext xContext = null, int? intSeverity = null)
    {
        return await ReportError(exObj, String.Empty, context, xContext, String.Empty, intSeverity).ConfigureAwait(false);
    }
#endregion

#region With A Name

#region overloads
    public static async Task<EventReporterResponse> ReportErrorLowSeverity(Exception exObj, string strErrorName, ApplicationContext context = null, ExecutionContext xContext = null, string strDetails = null, int? intDuration = null)
    {
        return await ReportError(exObj, strErrorName, context, xContext, strDetails, intSeverity: LowSeverity, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportErrorNormalSeverity(Exception exObj, string strErrorName, ApplicationContext context = null, ExecutionContext xContext = null, string strDetails = null, int? intDuration = null)
    {
        return await ReportError(exObj, strErrorName, context, xContext, strDetails, intSeverity: NormalSeverity, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportErrorHighSeverity(Exception exObj, string strErrorName, ApplicationContext context = null, ExecutionContext xContext = null, string strDetails = null, int? intDuration = null)
    {
        return await ReportError(exObj, strErrorName, context, xContext, strDetails, intSeverity: HighSeverity, intDuration: intDuration).ConfigureAwait(false);
    }
#endregion

    public static async Task<EventReporterResponse> ReportError(Exception exObj, string strErrorName, ApplicationContext context = null, ExecutionContext xContext = null, string strDetails = null, int? intSeverity = null, int? intDuration = null)
    {
        if (!IsConfiguredAndEnabled())
            return NotConfiguredResponse();

        EventReporterResponse response = new EventReporterResponse();
        try
        {
            General.ErrorLogging.Model.ErrorOther req = PrefillEventModel(ref context, strErrorName
                , Details: strDetails
                , Severity: intSeverity
                , Duration: intDuration);
            req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.Server;

#region Error Details
            StringBuilder sbDetail = new StringBuilder();
            if (exObj != null)
                sbDetail = General.Debugging.ErrorReporter.GetErrorReport(exObj, "\r\n");

            if (!StringFunctions.IsNullOrWhiteSpace(strDetails))
                sbDetail.Insert(0, strDetails + "\r\n");

#region Read Execution Context for HttpRequest or DB Log
            if (xContext != null)
            {
                if(xContext.RequestedURI != null)
                    req.EventURL = xContext.RequestedURI.ToString();

                if (xContext.DatabaseQueries != null && xContext.DatabaseQueries.Count > 0)
                {
                    sbDetail.AppendLine("DATABASE CALLS:");
                    foreach(string query in xContext.DatabaseQueries)
                    {
                        sbDetail.AppendLine(query);
                    }
                    sbDetail.AppendLine();
                }

                if (!String.IsNullOrWhiteSpace(xContext.RequestMethod))
                    sbDetail.AppendLine("REQUEST METHOD: " + xContext.RequestMethod);
                if(!String.IsNullOrWhiteSpace(xContext.RequestBody))
                    sbDetail.AppendLine(xContext.RequestBody);
            }
#endregion

            req.EventDetail = sbDetail.ToString();
#endregion

#region Handle NULL Exception
            if(exObj == null)
            {
                exObj = new Exception("Unspecified Error");
            }
#endregion

            try
            {
                Exception exBase = exObj.GetBaseException();

#region Detect EventType
                if (exBase is System.Data.SqlClient.SqlException || exObj is System.Data.SqlClient.SqlException || req.EventDetail.Contains("System.Data.SqlClient"))
                {
                    req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.SQL;

                    if (exBase.Message.Contains("timeout period elapsed") || exObj.Message.Contains("timeout period elapsed"))
                        req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.SQLTimeout;
                    if (exBase.Message.Contains("wait operation timed out") || exObj.Message.Contains("wait operation timed out"))
                        req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.SQLConnectivity;
                    if (exBase.Message.Contains("network name is no longer available") || exObj.Message.Contains("network name is no longer available"))
                        req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.SQLConnectivity;
                    if (exBase.Message.Contains("semaphore timeout period") || exObj.Message.Contains("semaphore timeout period"))
                        req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.SQLConnectivity;
                    if (exBase.Message.Contains("connection attempt failed") || exObj.Message.Contains("connection attempt failed"))
                        req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.SQLConnectivity;
                    if (exBase.Message.Contains("server was not found or was not accessible") || exObj.Message.Contains("server was not found or was not accessible"))
                        req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.SQLConnectivity;

                }
#endregion

#region Get HTTP Error Code
#if NET472 || NET471 || NET47 || NET462 || NET461 || NET46 || NET452 || NET451 || NET45 || NET40 || NET35 || NET20
                if (exObj is HttpException)
                    req.ErrorCode = ((HttpException)exObj).GetHttpCode().ToString();
                else if (exBase is HttpException)
                    req.ErrorCode = ((HttpException)exBase).GetHttpCode().ToString();
#endif
                if (exObj is System.Net.WebException)
                    req.ErrorCode = ((System.Net.WebException)exObj).Status.ToString();
                else if (exBase is System.Net.WebException)
                    req.ErrorCode = ((System.Net.WebException)exBase).Status.ToString();
#endregion

#region Get Method / FileName / LineNumber
                try
                {
                    System.Reflection.MethodBase objMethod = exBase.TargetSite;
                    req.CodeMethod = objMethod == null ? null : objMethod.DeclaringType.FullName + "." + objMethod.Name;
                }
                catch { }

                try
                {
                    System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(exBase, true);
                    System.Diagnostics.StackFrame[] frames = st.GetFrames();

                    /*
                        * Requires LINQ
                    var fileFrames = 
                        from frame in frames.AsEnumerable()
                        where frame.GetFileName() != null 
                        select frame;

                    if (fileFrames != null && fileFrames.Count() > 0)
                    {
                        var firstFrame = fileFrames.First();
                        strFileName = StringFunctions.AllAfterReverse(firstFrame.GetFileName(), "\\");
                        intLineNumber = firstFrame.GetFileLineNumber();
                    }
                    */

                    if (frames != null)
                    {
                        req.CodeFileName = null;
                        foreach (System.Diagnostics.StackFrame frame in frames)
                        {
                            if (!StringFunctions.IsNullOrWhiteSpace(frame.GetFileName()))
                            {
                                string strFileName = StringFunctions.AllAfterReverse(frame.GetFileName(), "\\");
                                //Go ahead and grab the first file name
                                if (StringFunctions.IsNullOrWhiteSpace(req.CodeFileName))
                                    req.CodeFileName = strFileName;
                                req.CodeLineNumber = frame.GetFileLineNumber();

                                //But keep looking for one with a line number.
                                if (req.CodeLineNumber > 0)
                                {
                                    req.CodeFileName = strFileName;
                                    break;
                                }
                            }
                        }
                    }

                }
                catch { }
#endregion

#region Error Name
                                if (!StringFunctions.IsNullOrWhiteSpace(strErrorName))
                                    strErrorName = strErrorName + " - " + exBase.Message;
                                else
                                    strErrorName = exBase.Message;
                                /*
                                if (StringFunctions.IsNullOrWhiteSpace(strErrorName) && intLineNumber == 0)
                                    strErrorName = strSubject;
                                else if (StringFunctions.IsNullOrWhiteSpace(strErrorName))
                                    strErrorName = strFileName + ":" + intLineNumber.ToString();
                                */
                                strErrorName = General.Debugging.ErrorReporter.SanitizeString(strErrorName); //Remove private stuff like passwords
                                req.EventName = strErrorName;
#endregion

#region Exception Type
                req.ExceptionType = exBase.GetType().Name;
#endregion

#region Event History (from cookie)
                EventHistoryContext histContext = null;
#if NET472 || NET471 || NET47 || NET462 || NET461 || NET46 || NET452 || NET451 || NET45 || NET40 || NET35 || NET20
                    
                    try
                    {
                        HttpContext _context = System.Web.HttpContext.Current;
                        if(_context != null && _context.Request != null && _context.Request.Cookies != null)
                        {
                            if(_context.Request.Cookies["GenErrLogHist"] != null)
                            {
                                var cookieHist = _context.Request.Cookies["GenErrLogHist"];
                                var jsonHist = HttpUtility.UrlDecode(cookieHist.Value);
                                using (var ms = new System.IO.MemoryStream(Encoding.Unicode.GetBytes(jsonHist)))
                                {
                                    // Deserialization from JSON  
                                    System.Runtime.Serialization.Json.DataContractJsonSerializer deserializer = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(EventHistoryContext));
                                    histContext = (EventHistoryContext)deserializer.ReadObject(ms);
                                }
                            }
                        }
                    }
                    catch(Exception ex) { req.Custom3 = ex.Message; }
#endif
#endregion

#region Send To Database
                //I will store this event if it matches any filters
                var filterContext = await ErrorReporter.ShouldStoreEvent(req, context).ConfigureAwait(false);
                if (filterContext.IShouldStoreEvent)
                {
                    response = await General.ErrorLogging.Client.EventLogClient.StoreEvent(req, context, filterContext, histContext).ConfigureAwait(false);
                }
                else
                {
                    response = SetNoMatchedFilterResponse(response, req);
                }
#endregion

            }
            catch (Exception ex)
            {
                try
                {
                    General.ErrorLogging.Client.RecordEventDataContext request = new General.ErrorLogging.Client.RecordEventDataContext();
                    request.AppContext = context;
                    request.EventContext = new EventContext(req);

                    try
                    {
                        request.EventContext.Details += "\r\n\r\nError In Logging DLL (ErrorReporter)\r\n" + General.Debugging.ErrorReporter.GetErrorReport(ex, "\r\n").ToString();
                    }
                    catch
                    {
                        request.EventContext.Details += "\r\n\r\nError In Logging DLL (ErrorReporter)\r\n" + ex.Message;
                    }


                    await General.ErrorLogging.Client.EventLogClient.EmailEvent(request, response);
                }
                catch { }
                throw;
            }

        }
        catch (Exception ex)
        {
            response.Message = ex.Message;

#region Last Resort Email
            //DON'T TRY TO REPORT THIS ERROR NORMALLY OR YOU COULD CREATE AN INFINITE LOOP AND CRASH THE APP
            try
            {
                if(exObj != null)
                    General.Debugging.Report.SendError("Error occurred while generating an error report.", System.Environment.CurrentDirectory + "\r\n\r\n" + strErrorName + "\r\n\r\n" + ex.ToString() + "\r\n\r\n\r\n\r\n\r\n\r\n" + exObj.ToString());
                else
                    General.Debugging.Report.SendError("Error occurred while generating an error report.", System.Environment.CurrentDirectory + "\r\n\r\n" + strErrorName + "\r\n\r\n" + ex.ToString());
            }
            catch { }
#endregion

            if (General.Environment.Current.AmIDev())
                throw;
        }
        return response;
    }
#endregion

#endregion

#region By EventContext
    public static async Task<EventReporterResponse> ReportError(EventContext exInfo, ApplicationContext context = null)
    {
        return await ReportEvent(exInfo, context).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportEvent(EventContext exInfo, ApplicationContext context = null)
    {
        if (!IsConfiguredAndEnabled())
            return NotConfiguredResponse();

        EventReporterResponse response = new EventReporterResponse();
        try
        {
            if (context == null)
                context = new ApplicationContext();
            context.AppID = GetAppID(context);
            context.AppName = GetAppName(context);
            context.Environment = GetEnvironment(context).ToString();

            //I will store this event if it matches any filters
            var filterContext = await ErrorReporter.ShouldStoreEvent(exInfo, context).ConfigureAwait(false);
            if (filterContext.IShouldStoreEvent)
            {
                try
                {
                    response = await General.ErrorLogging.Client.EventLogClient.StoreEvent(exInfo, context, filterContext).ConfigureAwait(false);
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
                            request.EventContext.Details += "\r\n\r\nError In Logging DLL (ErrorReporter)\r\n" + General.Debugging.ErrorReporter.GetErrorReport(ex, "\r\n").ToString();
                        }
                        catch
                        {
                            request.EventContext.Details += "\r\n\r\nError In Logging DLL (ErrorReporter)\r\n" + ex.Message;
                        }

                        await General.ErrorLogging.Client.EventLogClient.EmailEvent(request, response);
                    }
                    catch { }
                    throw;
                }
            }
            else
            {
                response = SetNoMatchedFilterResponse(response, exInfo);
            }

        }
        catch (Exception ex)
        {
            response.Message = ex.Message;
            //DON'T TRY TO REPORT THIS ERROR NORMALLY OR YOU COULD CREATE AN INFINITE LOOP AND CRASH THE APP
            try
            {
                if (exInfo != null)
                    General.Debugging.Report.SendError("Error occurred while generating an error report.", System.Environment.CurrentDirectory + "\r\n\r\n" + exInfo.ErrorName + "\r\n\r\n" + ex.ToString() + "\r\n\r\n\r\n\r\n\r\n\r\n" + exInfo.Details.ToString());
                else
                    General.Debugging.Report.SendError("Error occurred while generating an error report.", System.Environment.CurrentDirectory + "\r\n\r\n" + ex.ToString());
            }
            catch { }

            if (General.Environment.Current.AmIDev())
                throw;
        }
        return response;
    }
#endregion

#region By String Name

#region overloads
    public static async Task<EventReporterResponse> ReportErrorLowSeverity(string strErrorName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportError(strErrorName, context, intSeverity: LowSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportErrorNormalSeverity(string strErrorName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportError(strErrorName, context, intSeverity: NormalSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportErrorHighSeverity(string strErrorName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportError(strErrorName, context, intSeverity: HighSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }
#endregion

    public static async Task<EventReporterResponse> ReportError(string strErrorName, ApplicationContext context = null, int? intSeverity = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        if (!IsConfiguredAndEnabled())
            return NotConfiguredResponse();

        try
        {
            General.ErrorLogging.Model.ErrorOther req = PrefillEventModel(ref context, strErrorName
                , Details: strDetails
                , Severity: intSeverity
                , MethodName: strMethodName
                , FileName: strFileName
                , CallingMethod: objCallingMethod
                , Duration: intDuration);
            req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.Server;

            return await MaybeStoreEvent(req, context).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            if (General.Environment.Current.AmIDev())
                throw;

            EventReporterResponse response = new EventReporterResponse();
            response.Message = ex.Message;
            return response;
        }
    }
#endregion

#endregion

#region ReportWarning

#region overloads
    public static async Task<EventReporterResponse> ReportWarningLowSeverity(string strWarningName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportWarning(strWarningName, context, intSeverity: LowSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportWarningNormalSeverity(string strWarningName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportWarning(strWarningName, context, intSeverity: NormalSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportWarningHighSeverity(string strWarningName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportWarning(strWarningName, context, intSeverity: HighSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }
#endregion

    public static async Task<EventReporterResponse> ReportWarning(string strWarningName, ApplicationContext context = null, int? intSeverity = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        if (!IsConfiguredAndEnabled())
            return NotConfiguredResponse();

        if (context == null)
            context = new ApplicationContext();

        try
        {
            General.ErrorLogging.Model.ErrorOther req = PrefillEventModel(ref context, strWarningName
                , Details: strDetails
                , Severity: intSeverity
                , MethodName: strMethodName
                , FileName: strFileName
                , CallingMethod: objCallingMethod
                , Duration: intDuration);
            req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.Warning;

            return await MaybeStoreEvent(req, context).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            if (General.Environment.Current.AmIDev())
                throw;

            EventReporterResponse response = new EventReporterResponse();
            response.Message = ex.Message;
            return response;
        }
    }
#endregion

#region ReportAudit

#region overloads
    public static async Task<EventReporterResponse> ReportAuditLowSeverity(string strAuditMessageName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportAudit(strAuditMessageName, context, intSeverity: LowSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportAuditNormalSeverity(string strAuditMessageName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportAudit(strAuditMessageName, context, intSeverity: NormalSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportAuditHighSeverity(string strAuditMessageName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportAudit(strAuditMessageName, context, intSeverity: HighSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }
#endregion

    public static async Task<EventReporterResponse> ReportAudit(string strAuditMessageName, ApplicationContext context = null, int? intSeverity = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        if (!IsConfiguredAndEnabled())
            return NotConfiguredResponse();

        if (context == null)
            context = new ApplicationContext();

        try
        {
            General.ErrorLogging.Model.ErrorOther req = PrefillEventModel(ref context, strAuditMessageName
                , Details: strDetails
                , Severity: intSeverity
                , MethodName: strMethodName
                , FileName: strFileName
                , CallingMethod: objCallingMethod
                , Duration: intDuration);
            req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.Audit;

            return await MaybeStoreEvent(req, context).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            if (General.Environment.Current.AmIDev())
                throw;

            EventReporterResponse response = new EventReporterResponse();
            response.Message = ex.Message;
            return response;
        }
    }
#endregion

#region ReportTrace

#region overloads
    public static async Task<EventReporterResponse> ReportTraceLowSeverity(string strTraceName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportTrace(strTraceName, context, intSeverity: LowSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportTraceNormalSeverity(string strTraceName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportTrace(strTraceName, context, intSeverity: NormalSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }

    public static async Task<EventReporterResponse> ReportTraceHighSeverity(string strTraceName, ApplicationContext context = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        return await ReportTrace(strTraceName, context, intSeverity: HighSeverity, strDetails: strDetails, strMethodName: strMethodName, strFileName: strFileName, objCallingMethod: objCallingMethod, intDuration: intDuration).ConfigureAwait(false);
    }
#endregion

    public static async Task<EventReporterResponse> ReportTrace(string strTraceName, ApplicationContext context = null, int? intSeverity = null, string strDetails = null, string strMethodName = null, string strFileName = null, System.Reflection.MethodBase objCallingMethod = null, int? intDuration = null)
    {
        if (!IsConfiguredAndEnabled())
            return NotConfiguredResponse();

        if (context == null)
            context = new ApplicationContext();

        try
        {
            General.ErrorLogging.Model.ErrorOther req = PrefillEventModel(ref context, strTraceName
                , Details: strDetails
                , Severity: intSeverity
                , MethodName: strMethodName
                , FileName: strFileName
                , CallingMethod: objCallingMethod
                , Duration: intDuration);
            req.EventType = General.ErrorLogging.Model.ErrorOtherTypes.Trace;

            return await MaybeStoreEvent(req, context).ConfigureAwait(false);
        }
        catch (Exception ex) {
            if (General.Environment.Current.AmIDev())
                throw;

            EventReporterResponse response = new EventReporterResponse();
            response.Message = ex.Message;
            return response;
        }
    }
#endregion

#region MaybeStoreEvent
    public static async Task<EventReporterResponse> MaybeStoreEvent(General.ErrorLogging.Model.ErrorOther req, ApplicationContext context)
    {
        EventReporterResponse response = new EventReporterResponse();
        try
        {
            //I will store this event if it matches any filters
            var filterContext = await ErrorReporter.ShouldStoreEvent(req, context).ConfigureAwait(false);
            if (filterContext.IShouldStoreEvent)
            {
                response = await General.ErrorLogging.Client.EventLogClient.StoreEvent(req, context, filterContext).ConfigureAwait(false);
            }
            else
            {
                response = SetNoMatchedFilterResponse(response, req);
            }
            
        }
        catch(Exception ex)
        {
            try
            {
                General.ErrorLogging.Client.RecordEventDataContext request = new General.ErrorLogging.Client.RecordEventDataContext();
                request.AppContext = context;
                request.EventContext = new EventContext(req);

                try
                {
                    request.EventContext.Details += "\r\n\r\nError In Logging DLL (ErrorReporter)\r\n" + General.Debugging.ErrorReporter.GetErrorReport(ex, "\r\n").ToString();
                }
                catch
                {
                    request.EventContext.Details += "\r\n\r\nError In Logging DLL (ErrorReporter)\r\n" + ex.Message;
                }

                await General.ErrorLogging.Client.EventLogClient.EmailEvent(request, response);
            }
            catch { }
            throw;
        }
        return response;
    }
#endregion

#region ShouldStoreEvent

    public static async Task<FilterContext> ShouldStoreEvent(General.ErrorLogging.Model.ErrorOther model, ApplicationContext context)
    {
        return await ShouldStoreEvent(new EventContext(model), context).ConfigureAwait(false);
    }

    public static async Task<FilterContext> ShouldStoreEvent(EventContext request, ApplicationContext context)
    {
        var filterContext = new FilterContext();

        var filters = await General.ErrorLogging.Client.EventLogClient.FilterCache.Active().ConfigureAwait(false);
        if (filters != null && filters.Count > 0)
        {
            List<int> aryMatches = new List<int>();
            foreach (var filter in filters)
            {

#region Environment Matching
                bool EnvironmentMatch = false;
                if (filter.EnvironmentFilter.WildcardAll)
                    EnvironmentMatch = true;
                else if (filter.EnvironmentFilter.EnvironmentList != null && filter.EnvironmentFilter.EnvironmentList.Contains(GetEnvironment(context)))
                    EnvironmentMatch = true;
#endregion

#region Event Matching
                bool EventMatch = false;
                if (filter.EventFilter.WildcardAll)
                    EventMatch = true;
                else if (filter.EventFilter.Events != null && request.EventType.HasValue && filter.EventFilter.Events.Contains(request.EventType.Value))
                    EventMatch = true;

                if(filter.EventFilter.MinSeverity > 0)
                {
                    //When a minimum severity is specified, clear any match to events with no severity or low severity
                    if (!request.Severity.HasValue)
                        EventMatch = false;
                    else if (request.Severity.Value < filter.EventFilter.MinSeverity)
                        EventMatch = false;
                }
#endregion

#region Client Matching
                bool ClientMatch = false;
                if (filter.ClientFilter.WildcardAll)
                    ClientMatch = true;
                else if (filter.ClientFilter.ClientIDList != null 
                        && !General.StringFunctions.IsNullOrWhiteSpace(context.ClientID) 
                        && filter.ClientFilter.ClientIDList.Any(cid => cid.Equals(context.ClientID, StringComparison.OrdinalIgnoreCase)))
                    ClientMatch = true;
#endregion

#region User Matching
                bool UserMatch = false;
                if (filter.UserFilter.WildcardAll)
                    UserMatch = true;
                else if (filter.UserFilter.UserIDList != null 
                        && !General.StringFunctions.IsNullOrWhiteSpace(context.UserID) 
                        && filter.UserFilter.UserIDList.Any(uid => uid.Equals(context.UserID, StringComparison.OrdinalIgnoreCase)))
                    UserMatch = true;
#endregion

                if (EnvironmentMatch && EventMatch && ClientMatch && UserMatch)
                {
                    filterContext.IShouldStoreEvent = true;
                    aryMatches.Add(filter.ID);
                }
            }
            filterContext.MatchedFilters = aryMatches.ToArray();
        }
        else
        {
            //When in doubt, log errors only!
            filterContext.IShouldStoreEvent = false;
            if (request.EventType.HasValue)
                if (IsErrorEvent(request.EventType.Value))
                    filterContext.IShouldStoreEvent = true;
            
        }
        return filterContext;
    }

#endregion

#region SetNoMatchedFilterResponse
    public static EventReporterResponse SetNoMatchedFilterResponse(EventReporterResponse response, EventContext exInfo)
    {
        response.Success = false;
        response.Message = "Event did not match any active filters";

#if DEBUG
        try
        {
            string strConsoleMsg = "";
            if (ErrorReporter.IsErrorEvent(exInfo.EventType.Value))
                strConsoleMsg += "Error was not logged: " + response.Message + "\r\n";
            else
                strConsoleMsg += "Event was not logged: " + response.Message + "\r\n";

            strConsoleMsg += exInfo.EventType.Value.ToString() + ": " + exInfo.EventName + "\r\n";

            System.Diagnostics.Debug.Write(strConsoleMsg, "General.ErrorLogging");
        }
        catch { }
#endif

        return response;
    }

    public static EventReporterResponse SetNoMatchedFilterResponse(EventReporterResponse response, General.ErrorLogging.Model.ErrorOther exInfo)
    {
        response.Success = false;
        response.Message = "Event did not match any active filters";

#if DEBUG
        try
        {
            string strConsoleMsg = "";
            if (ErrorReporter.IsErrorEvent(exInfo.EventType))
                strConsoleMsg += "Error was not logged: " + response.Message + "\r\n";
            else
                strConsoleMsg += "Event was not logged: " + response.Message + "\r\n";

            strConsoleMsg += exInfo.EventType.ToString() + ": " + exInfo.EventName + "\r\n";

            System.Diagnostics.Debug.Write(strConsoleMsg, "General.ErrorLogging");
        }
        catch { }
#endif

        return response;
    }
#endregion

#region EmailBackup (DEPRECATED)
    /*
    public static void EmailBackup(StringBuilder sb, string strEventName, string strSubjectComment)
    {
        EmailBackup(sb.ToString(), strEventName, strSubjectComment);
    }

    public static void EmailBackup(String strDetail, string strEventName, string strSubjectComment)
    {
#region Email Subject
        string strSubject = "Event unable to save: " + strEventName;
        if (!StringFunctions.IsNullOrWhiteSpace(strSubjectComment))
            strSubject += " - " + strSubjectComment;
#endregion

        //Send an email
        General.Debugging.Report.SendError(strSubject, strDetail);
    }
    */
#endregion

#region PrefillEventModel
    public static General.ErrorLogging.Model.ErrorOther PrefillEventModel(ref ApplicationContext context, string ErrorName, string Details = null, int? Severity = null, string MethodName = null, string FileName = null, System.Reflection.MethodBase CallingMethod = null, int? Duration = null)
    {
        General.ErrorLogging.Model.ErrorOther req = new General.ErrorLogging.Model.ErrorOther();

        if (context == null)
            context = new ApplicationContext();
        context.AppID = GetAppID(context);
        context.AppName = GetAppName(context);
        context.Environment = GetEnvironment(context).ToString();
        context.MachineName = System.Environment.MachineName;

        req.EventName = ErrorName;
        req.EventDetail = Details;
        req.CodeFileName = FileName;
        req.Severity = Severity;
        req.Duration = Duration;

#if NET472 || NET471 || NET47 || NET462 || NET461 || NET46 || NET452 || NET451 || NET45 || NET40 || NET35 || NET20

#region Get HTTP UserAgent
        try
        {
            if (System.Web.HttpContext.Current != null)
            {
                req.UserAgent = System.Web.HttpContext.Current.Request.UserAgent;
            }
        }
        catch { }
#endregion

#region URL
        try
        {
            req.EventURL = General.Web.WebTools.GetRequestedUrl();
        }
        catch { req.EventURL = "Unknown URL"; }
#endregion

#endif

#region GetMethodInfo
        if (CallingMethod != null)
        {
            MethodName = CallingMethod.DeclaringType.FullName + "." + CallingMethod.Name;
        }
        req.CodeMethod = MethodName;
#endregion

        return req;
    }
#endregion

#region GetAppID
    public static int GetAppID(ApplicationContext context)
    {
        int intAppID;
        if (context.AppID.HasValue)
            intAppID = context.AppID.Value;
        else
            intAppID = AppID;
        return intAppID;
    }
#endregion

#region GetAppName
    public static string GetAppName(ApplicationContext context)
    {
        string strAppName = context.AppName; //First look for App Name in context
        if(AppID == 0 && General.ErrorLogging.Data.Application.HasErrorLogConnectionString) //Behavior for remote requests via API
        {
            try
            {
                if (StringFunctions.IsNullOrWhiteSpace(strAppName) && context.AppID.HasValue)
                {
                    var app = General.ErrorLogging.Data.Application.GetApplication(context.AppID.Value);
                    if (app != null)
                        strAppName = app.Name;
                }
            }
            catch { }
        }
        else //Don't default the AppName in this way when this code is running in the General.ErrorLogging.GUI API site, because it will receive requests from remote sites with different App Names
        { 
            if (StringFunctions.IsNullOrWhiteSpace(strAppName))
                strAppName = DefaultAppNameForErrorLog; //Then look in config file
            if (StringFunctions.IsNullOrWhiteSpace(strAppName))
            {
#if NET472 || NET471 || NET47 || NET462 || NET461 || NET46 || NET452 || NET451 || NET45 || NET40 || NET35 || NET20

                //Finally, choose a default AppName
                if (System.Web.HttpContext.Current != null)
                {
                    try
                    {
                        strAppName = System.Web.HttpContext.Current.Request.ServerVariables["SERVER_NAME"];

                        if (StringFunctions.IsNullOrWhiteSpace(strAppName) || strAppName == "localhost")
                        {
                            strAppName = System.Web.HttpContext.Current.Request.ServerVariables["APPL_PHYSICAL_PATH"];
                            if (!StringFunctions.IsNullOrWhiteSpace(strAppName))
                            {
                                strAppName = StringFunctions.AllAfterReverse(strAppName.Trim('\\'), "\\");
                            }
                        }
                    }
                    catch { }
                }

#endif

                if (StringFunctions.IsNullOrWhiteSpace(strAppName))
                {
                    //Last resort, use the current directory on the machine
                    try
                    {
                        strAppName = System.Environment.CurrentDirectory;

                        if (!StringFunctions.IsNullOrWhiteSpace(strAppName))
                        {
                            strAppName = StringFunctions.AllAfterReverse(strAppName.Trim('\\'), "\\");
                        }
                    }
                    catch { }
                }
            }
        }
        return strAppName;
    }
#endregion

#region GetEnvironment
    public static General.Environment.EnvironmentContext GetEnvironment(ApplicationContext context)
    {
        var enuEnvironment = General.Environment.Current.WhereAmI();
        if (!StringFunctions.IsNullOrWhiteSpace(context.Environment))
        {
            try
            {
                enuEnvironment = (General.Environment.EnvironmentContext)Enum.Parse(typeof(General.Environment.EnvironmentContext), context.Environment, true);
            }
            catch { }
        }
        return enuEnvironment;
    }
#endregion

#region IsErrorEvent 
    public static bool IsErrorEvent(General.ErrorLogging.Model.ErrorOtherTypes eventType)
    {
        switch (eventType)
        {
            case General.ErrorLogging.Model.ErrorOtherTypes.Server:
            case General.ErrorLogging.Model.ErrorOtherTypes.Javascript:
            case General.ErrorLogging.Model.ErrorOtherTypes.SQL:
            case General.ErrorLogging.Model.ErrorOtherTypes.SQLConnectivity:
            case General.ErrorLogging.Model.ErrorOtherTypes.SQLTimeout:
                return true;
        }
        return false;
    }
#endregion

}
