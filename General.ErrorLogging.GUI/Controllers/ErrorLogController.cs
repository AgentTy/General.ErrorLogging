using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Text.RegularExpressions;
using System.Web.Http.Cors;
using General.Data;
using General.ErrorLogging.Model;
using System.Data.SqlClient;
using Newtonsoft.Json;
using System.IO;

namespace General.ErrorLogging.GUI.Controllers
{

    public class ErrorLogController : ApiController
    {

        #region Get Event Summaries or Expanded Occurrance Logs
        // GET api/[AppID]/ErrorLog?StartDate=1/1/2015&EndDate=1/31/15
        [Authorize]
        [HttpGet]
        [Route("api/[AppID]/ErrorLog/Summarized")]
        public List<ErrorOther> Summarized(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Type = "any", int? MinimumSeverity = null, int? FilterID = null, bool? IncludeDetail = true)
        {
            List<General.ErrorLogging.Model.ErrorOtherTypes> aryTypes = ParseTypes(Type);
            List<int> aryApps = ParseApps(AppID);

            if (FilterID.HasValue)
            {
                var objFilter = General.ErrorLogging.Data.LoggingFilter.GetFilter(FilterID.Value);
                if (!String.IsNullOrWhiteSpace(ClientID) || ParseEnvironment(Environment) != null || aryTypes != null || MinimumSeverity.HasValue)
                    return General.ErrorLogging.Data.ErrorOther.FindEventSummariesByFilter(objFilter, StartDate, EndDate, ClientID, ParseEnvironment(Environment), aryTypes, MinimumSeverity, IncludeDetail);
                return General.ErrorLogging.Data.ErrorOther.FindEventSummariesByFilter(objFilter, StartDate, EndDate, null, null, aryTypes, null, IncludeDetail);
            }
            else
            {
                if (!String.IsNullOrWhiteSpace(ClientID) || ParseEnvironment(Environment) != null || aryTypes != null || MinimumSeverity.HasValue)
                    return General.ErrorLogging.Data.ErrorOther.FindEventSummaries(StartDate, EndDate, aryApps, ClientID, ParseEnvironment(Environment), aryTypes, MinimumSeverity, IncludeDetail);
                return General.ErrorLogging.Data.ErrorOther.FindEventSummaries(StartDate, EndDate, aryApps, null, null, aryTypes, null, IncludeDetail);
            }
        }

        // GET api/[AppID]/ErrorLog/ExpandedSlowQuery?StartDate=1/1/2015&EndDate=1/31/15
        [Authorize]
        [HttpGet]
        [Route("api/[AppID]/ErrorLog/ExpandedSlowQuery")]
        public List<ErrorOtherOccurrence> ExpandedSlowQuery(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Type = "any", int? MinimumSeverity = null, int? FilterID = null, bool? IncludeDetail = true)
        {
            List<General.ErrorLogging.Model.ErrorOtherTypes> aryTypes = ParseTypes(Type);
            List<int> aryApps = ParseApps(AppID);

            if (FilterID.HasValue)
            {
                var objFilter = General.ErrorLogging.Data.LoggingFilter.GetFilter(FilterID.Value);
                if (!String.IsNullOrWhiteSpace(ClientID) || ParseEnvironment(Environment) != null || aryTypes != null || MinimumSeverity.HasValue)
                    return General.ErrorLogging.Data.ErrorOther.FindEventLogsByFilter(objFilter, StartDate, EndDate, ClientID, ParseEnvironment(Environment), aryTypes, MinimumSeverity, IncludeDetail);
                return General.ErrorLogging.Data.ErrorOther.FindEventLogsByFilter(objFilter, StartDate, EndDate, null, null, aryTypes, null, IncludeDetail);
            }
            else
            {
                if (!String.IsNullOrWhiteSpace(ClientID) || ParseEnvironment(Environment) != null || aryTypes != null || MinimumSeverity.HasValue)
                    return General.ErrorLogging.Data.ErrorOther.FindEventLogs(StartDate, EndDate, aryApps, ClientID, ParseEnvironment(Environment), aryTypes, MinimumSeverity, IncludeDetail);
                return General.ErrorLogging.Data.ErrorOther.FindEventLogs(StartDate, EndDate, aryApps, null, null, aryTypes, null, IncludeDetail);
            }
        }
        

        // GET api/[AppID]/ErrorLog/Expanded?StartDate=1/1/2015&EndDate=1/31/15
        [Authorize]
        [HttpGet]
        [Route("api/[AppID]/ErrorLog/Expanded")]
        public IEnumerable<ErrorOtherOccurrence> Expanded(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Type = "any", int? MinimumSeverity = null, int? FilterID = null, bool? IncludeDetail = true, string Search = "")
        {
            List<General.ErrorLogging.Model.ErrorOtherTypes> aryTypes = ParseTypes(Type);
            List<int> aryApps = ParseApps(AppID);
            ILoggingFilter objFilter = null;
            if (FilterID.HasValue)
            {
                objFilter = General.ErrorLogging.Data.LoggingFilter.GetFilter(FilterID.Value);
                //Set the AppID to the one assigned to the selected filter
                aryApps = new List<int>();
                aryApps.Add(objFilter.AppID);
            }
            bool DoSearch = !String.IsNullOrWhiteSpace(Search);

            SqlCommand cmd;
            if (!String.IsNullOrWhiteSpace(ClientID) || ParseEnvironment(Environment) != null || aryTypes != null || MinimumSeverity.HasValue)
                cmd = General.ErrorLogging.Data.ErrorOther.FindEventLogs_GetCommand(StartDate, EndDate, aryApps, ClientID, ParseEnvironment(Environment), aryTypes, MinimumSeverity, IncludeDetail);
            else
                cmd = General.ErrorLogging.Data.ErrorOther.FindEventLogs_GetCommand(StartDate, EndDate, aryApps, null, null, aryTypes, null, IncludeDetail);

            using (SqlConnection conn = DBConnection.GetOpenConnection(DBConnection.GetConnectionString(Data.ErrorOther.ConnectionStringName)))
            {
                cmd.Connection = conn;
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        if (objFilter != null)
                        {
                            if (!Data.ErrorOther.DataRowMatchesFilter(rdr, objFilter))
                                continue;
                        }
                        var incident = Data.ErrorOther.GetErrorOtherOccurrenceModel(rdr);
                        if (!DoSearch || FullTextMatch(Search, incident))
                            yield return incident;
                    }
                }
            }
        }
        #endregion

        #region Search
        private bool FullTextMatch(string strSearch, ErrorOther obj)
        {
            if(String.IsNullOrWhiteSpace(strSearch))
                return true;

            var tokens = FullTextSearch.Tokenize(strSearch);

            bool blnHasNotToken = tokens.Where(t => t.StartsWith("-")).Count() > 0;
            bool blnMatchedHardBlock = false;
            bool blnMatched = false;
            if (tokens.Where(t => t.StartsWith("-")).Count() == tokens.Count()) //If I'm only using negative matches, then show everything that isn't eliminated.
                blnMatched = true;

            if (FullTextSearch.TokenContains(obj.AppName, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;
            if (FullTextSearch.TokenContains(obj.CodeMethod, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            if (FullTextSearch.TokenContains(obj.CodeFileName, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;
            if (FullTextSearch.TokenEquals(obj.CodeLineNumber.ToString(), tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;
            if (obj.Custom1 != null)
            {
                if (FullTextSearch.TokenContains(obj.Custom1, tokens, out blnMatchedHardBlock)) blnMatched = true;
                    if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;
            }
            if (obj.Custom2 != null)
            {
                if (FullTextSearch.TokenContains(obj.Custom2, tokens, out blnMatchedHardBlock)) blnMatched = true;
                    if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;
            }
            if (obj.Custom3 != null)
            {
                if (FullTextSearch.TokenContains(obj.Custom3, tokens, out blnMatchedHardBlock)) blnMatched = true;
                    if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;
            }
            if (obj.CustomID != null)
            {
                if (FullTextSearch.TokenEquals(obj.CustomID.ToString(), tokens, out blnMatchedHardBlock)) blnMatched = true;
                    if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;
            }
            if (FullTextSearch.TokenContains(obj.ErrorCode, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;
            if (FullTextSearch.TokenContains(obj.EventName, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            if (FullTextSearch.TokenContains(obj.EventURL, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;
            if (FullTextSearch.TokenContains(obj.ExceptionType, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            if (FullTextSearch.TokenContains(obj.MachineName, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if(!blnHasNotToken && blnMatched) return true;

            if (!String.IsNullOrWhiteSpace(obj.ClientID))
            {
                if (FullTextSearch.TokenContains(obj.ClientID, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }
            if (!String.IsNullOrWhiteSpace(obj.UserType))
            {
                if (FullTextSearch.TokenContains(obj.UserType, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }
            if(!String.IsNullOrWhiteSpace(obj.UserID))
            {
                if (FullTextSearch.TokenContains(obj.UserID, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }
            if (!String.IsNullOrWhiteSpace(obj.EventDetail))
            {
                //The big one is last
                if (FullTextSearch.TokenContains(obj.EventDetail, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }
            return blnMatched;
        }

        // GET api/[AppID]/ErrorLog/SearchSummarized?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15
        [HttpGet]
        [Authorize]
        public List<ErrorOther> SearchSummarized(string AppID, string Search, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Type = "any", int? MinimumSeverity = null, int? FilterID = null, bool IncludeDetail = true)
        {
            var data = Summarized(AppID, StartDate, EndDate, ClientID, Environment, Type, MinimumSeverity, FilterID, IncludeDetail);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }

        // GET api/[AppID]/ErrorLog/SearchExpandedSlowQuery?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15

        [HttpGet]
        [Authorize]
        public List<ErrorOtherOccurrence> SearchExpandedSlowQuery(string AppID, string Search, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Type = "any", int? MinimumSeverity = null, int? FilterID = null, bool IncludeDetail = true)
        {
            var data = ExpandedSlowQuery(AppID, StartDate, EndDate, ClientID, Environment, Type, MinimumSeverity, FilterID, IncludeDetail);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }
        
        #endregion

        #region Get One Event Summary
        // GET api/[AppID]/ErrorLog/Summary?ID=5
        [HttpGet]
        [Authorize]
        [Route("api/[AppID]/ErrorLog/Summary?ID={id}")]
        public object Summary(string AppID, int ID)
        {
            var error = General.ErrorLogging.Data.ErrorOther.GetEventSummary(ID);
            if (error == null)
                return "Object not found.";
            if (ParseAppID(AppID) == null || error.AppID == int.Parse(AppID))
               return error;
           return "The requested object is out of scope for the AppID you specified.";
        }
        #endregion

        #region Get One Event Occurrence

        // GET api/[AppID]/ErrorLog/Lookup?IC=dc1
        [HttpGet]
        [Authorize]
        [Route("api/[AppID]/ErrorLog/Lookup?IC={ic}")]
        public object Lookup(string AppID, string IC)
        {
            if (String.IsNullOrWhiteSpace(IC))
                return "Incident Code is required.";

            long? intOccurrenceID;
            try { 
                intOccurrenceID = Convert.ToInt64(IC.Trim(), 16); //Convert from Base16
            }
            catch { return "Invalid Incident Code"; }

            if (!intOccurrenceID.HasValue)
                return "Incident Code is required.";

            var error = General.ErrorLogging.Data.ErrorOther.GetEventOccurrence(intOccurrenceID.Value);
            if (error == null)
                return "Incident not found.";
            if (ParseAppID(AppID) == null || error.AppID == int.Parse(AppID))
                return error;
            return "The requested object is out of scope for the AppID you specified.";
        }
        #endregion

        #region Get A Event Occurrence Series

        // GET api/[AppID]/ErrorLog/Series?ID=5
        [HttpGet]
        [Authorize]
        [Route("api/[AppID]/ErrorLog/Series?ID={id}")]
        public object Series(string AppID, int ID)
        {
            var series = General.ErrorLogging.Data.ErrorOther.GetEventSeries(ID);
            if (series.Count > 0)
                if (ParseAppID(AppID) != null && series[0].AppID == int.Parse(AppID))
                    return "The requested object is out of scope for the AppID you specified.";
            return series;
        }


        // GET api/[AppID]/ErrorLog/LookupSeries?IC=dc1
        [HttpGet]
        [Authorize]
        [Route("api/[AppID]/ErrorLog/LookupSeries?IC={ic}")]
        public object LookupSeries(string AppID, string IC)
        {
            if (String.IsNullOrWhiteSpace(IC))
                return "Incident Code is required.";

            long? intOccurrenceID;
            try
            {
                intOccurrenceID = Convert.ToInt64(IC.Trim(), 16); //Convert from Base16
            }
            catch { return "Invalid Incident Code"; }

            if (!intOccurrenceID.HasValue)
                return "Incident Code is required.";

            var error = General.ErrorLogging.Data.ErrorOther.GetEventOccurrence(intOccurrenceID.Value);
            if (error == null)
                return "Incident not found.";
            if (ParseAppID(AppID) == null || error.AppID == int.Parse(AppID))
                return Series(AppID, error.ErrorOtherID);
            return "The requested object is out of scope for the AppID you specified.";
        }

        #endregion

        #region RecordEvent
        // POST api/[AppID]/ErrorLog/RecordEvent
        [HttpPost]
        [EnableCors(origins: "*", headers: "*", methods: "*")]
        public EventReporterResponse RecordEvent(string AppID, General.ErrorLogging.Client.RecordEventDataContext Data)
        {
            if (Data == null)
                throw new ArgumentNullException("No data specified, please POST the error data as a parent object with a valid AppContext and EventContext property.");
            if (String.IsNullOrWhiteSpace(Data.AccessCode) || Data.AccessCode != Settings.APIWriteOnlyAccessCode)
            {
                if (!(User != null && User.Identity != null && User.Identity.IsAuthenticated))
                    throw new UnauthorizedAccessException("Invalid Access Code");
            }
            if (Data.AppContext.AppID == null)
                throw new ArgumentNullException("AppContext.AppID is null, please POST the error data as a parent object with a valid AppContext property.");
            if (Data.EventContext.EventName == null)
                throw new ArgumentNullException("EventContext.EventName is null, please POST the error data as a parent object with a valid EventContext property.");
            if (Data.AppContext.AppID.HasValue && Data.AppContext.AppID.Value != int.Parse(AppID))
                throw new ArgumentException("AppID in API path doesn't match AppID specified in AppContext.");

            Data.AppContext.AppID = int.Parse(AppID);
            var objResponse = General.ErrorLogging.Server.EventLogServer.StoreEventInDatabase(Data.EventContext, Data.AppContext, Data.FilterContext, Data.EventHistory);
            /*
            //Process notifications
            try
            {
                NotificationController objNotifyController = new NotificationController();
                objNotifyController.BackgroundData = Data;
                objNotifyController.BackgroundIncidentCode = objResponse.IncidentCode;
                General.ErrorLogging.Threading.BackgroundWorker.RunInSeparateThread(new System.Threading.WaitCallback(objNotifyController.NotifyByFilterBackground));
            }
            catch { }
            */
            return objResponse;
        }
        #endregion

        #region Post/Put
        // POST api/[AppID]/ErrorLog
        [HttpPost]
        [Authorize]
        public void Post(string AppID, ErrorOther error)
        {
            General.ErrorLogging.Data.ErrorOther.StoreEvent(error, null, null);
        }

        // PUT api/[AppID]/ErrorLog
        [HttpPut]
        [Authorize]
        public ErrorOther Put(string AppID, ErrorOther error) 
        {
            return General.ErrorLogging.Data.ErrorOther.UpdateEvent(error);
        }
        #endregion

        #region Delete
        // DELETE api/[AppID]/ErrorLog?ID=1
        [HttpDelete]
        [Authorize]
        public string Delete(string AppID, int ID)
        {
            var error = General.ErrorLogging.Data.ErrorOther.GetEventSummary(ID);
            if (error == null)
                return "Event series not found.";
            if (ParseAppID(AppID) == null || error.AppID == int.Parse(AppID))
            {
                General.ErrorLogging.Data.ErrorOther.DeleteEventSeries(ID);
                return "Object deleted.";
            }
            else 
            { 
                return "The requested object is out of scope for the AppID you specified.";
            }
            
        }

        // DELETE api/[AppID]/ErrorLog?ID=1
        [HttpDelete]
        [Authorize]
        [Route("api/[AppID]/ErrorLog/DeleteOccurrence")]
        public string DeleteOccurrence(string AppID, string IC)
        {
            if (String.IsNullOrWhiteSpace(IC))
                return "Incident Code is required.";

            long? intOccurrenceID;
            try
            {
                intOccurrenceID = Convert.ToInt64(IC.Trim(), 16); //Convert from Base16
            }
            catch { return "Invalid Incident Code"; }

            if (!intOccurrenceID.HasValue)
                return "Incident Code is required.";

            var error = General.ErrorLogging.Data.ErrorOther.GetEventOccurrence(intOccurrenceID.Value);
            if (error == null)
                return "Occurrence not found.";
            if (ParseAppID(AppID) == null || error.AppID == int.Parse(AppID))
            {
                General.ErrorLogging.Data.ErrorOther.DeleteEventOccurrence(intOccurrenceID.Value);
                return "Object deleted.";
            }
            else
            {
                return "The requested object is out of scope for the AppID you specified.";
            }

        }
        #endregion

        #region Private
        
        private int? ParseAppID(string strIn)
        {
            if (strIn.ToLower() == "any")
                return null;
            return int.Parse(strIn);
        }
        
        private List<int> ParseApps(string strIn)
        {
            var aryApps= new List<int>();
            if (String.IsNullOrWhiteSpace(strIn))
                return null;
            strIn = strIn.Trim().Trim(',');
            if (strIn == "any")
                return null;
            if (!strIn.Contains(","))
                aryApps.Add(int.Parse(strIn));
            else
            {
                //I have a list of types
                var ary = strIn.Trim().Split(',');
                foreach (string strApp in ary)
                {
                    aryApps.Add(int.Parse(strApp));
                }
            }
            return aryApps;
        }

        private General.Environment.EnvironmentContext? ParseEnvironment(string strIn)
        {
            if (String.IsNullOrWhiteSpace(strIn))
                return null;
            if (strIn.ToLower() == "any")
                return null;
            return (General.Environment.EnvironmentContext)Enum.Parse(typeof(General.Environment.EnvironmentContext), strIn);
        }

        private List<General.ErrorLogging.Model.ErrorOtherTypes> ParseTypes(string strIn)
        {
            var aryTypes = new List<General.ErrorLogging.Model.ErrorOtherTypes>();
            if (String.IsNullOrWhiteSpace(strIn))
                return Enum.GetValues(typeof(General.ErrorLogging.Model.ErrorOtherTypes)).Cast<General.ErrorLogging.Model.ErrorOtherTypes>().ToList();
            strIn = strIn.Trim().Trim(',').ToLower();
            if (strIn == "any")
                return Enum.GetValues(typeof(General.ErrorLogging.Model.ErrorOtherTypes)).Cast<General.ErrorLogging.Model.ErrorOtherTypes>().ToList();
            if (!strIn.Contains(","))
                aryTypes.Add((General.ErrorLogging.Model.ErrorOtherTypes)Enum.Parse(typeof(General.ErrorLogging.Model.ErrorOtherTypes), strIn));
            else
            {
                //I have a list of types
                var ary = strIn.Trim().Split(',');
                foreach (string strType in ary)
                {
                    aryTypes.Add((General.ErrorLogging.Model.ErrorOtherTypes)Enum.Parse(typeof(General.ErrorLogging.Model.ErrorOtherTypes), strType));
                }
            }
            return aryTypes;
        }
        /*
        private General.ErrorLogging.Model.ErrorOtherTypes? ParseTypeOld(string strIn, out List<General.ErrorLogging.Model.ErrorOtherTypes> aryTypes)
        {
            aryTypes = new List<General.ErrorLogging.Model.ErrorOtherTypes>();
            if (String.IsNullOrWhiteSpace(strIn))
                return null;
            strIn = strIn.Trim().Trim(',').ToLower();
            if (strIn == "any")
                return null;
            if (!strIn.Contains(","))
                return (General.ErrorLogging.Model.ErrorOtherTypes)Enum.Parse(typeof(General.ErrorLogging.Model.ErrorOtherTypes), strIn);
            //I have a list of types
            var ary = strIn.Trim().Split(',');
            foreach(string strType in ary)
            {
                aryTypes.Add((General.ErrorLogging.Model.ErrorOtherTypes)Enum.Parse(typeof(General.ErrorLogging.Model.ErrorOtherTypes), strType));
            }
            return null;
        }
        */
        #endregion

    }
}