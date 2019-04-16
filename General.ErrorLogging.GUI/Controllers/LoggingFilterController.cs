using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using General.ErrorLogging.Model;
using System.Text.RegularExpressions;
using System.Web.Http.Cors;
using General.Data;

namespace General.ErrorLogging.GUI.Controllers
{

    public class LoggingFilterController : ApiController
    {

        #region ActiveFiltersInContext / ActiveFiltersForRemoteApp
        // GET api/[AppID]/LoggingFilter/ActiveFiltersInContext?ClientID=STD&UserID=username&Environment=Dev
        [HttpGet]
        [ActionName("ActiveFiltersInContext")]
        public IEnumerable<ILoggingFilter> ActiveFiltersInContext(string AppID, string AccessCode, string ClientID, string UserID, Environment.EnvironmentContext? Environment)
        {
            if (String.IsNullOrWhiteSpace(AccessCode) || AccessCode != Settings.APIWriteOnlyAccessCode)
            {
                if (!(User != null && User.Identity != null && User.Identity.IsAuthenticated))
                    throw new UnauthorizedAccessException("Invalid Access Code");
            }

            Data.LoggingFilter.LoggingFilterRequestContext AppContext = new Data.LoggingFilter.LoggingFilterRequestContext();
            AppContext.AppID = ParseAppID(AppID);
            AppContext.ClientID = ClientID;
            AppContext.UserID = UserID;
            AppContext.Environment = Environment;
            return General.ErrorLogging.Data.LoggingFilter.GetFiltersCustomView(LoggingFilterViewType.Browser, ParseAppID(AppID), AppContext, blnActiveOnly: true);
        }

        // POST api/[AppID]/LoggingFilter/ActiveFiltersInContext
        [HttpPost]
        [EnableCors(origins: "*", headers: "*", methods: "*")]
        [ActionName("ActiveFiltersInContext")]
        public IEnumerable<ILoggingFilter> ActiveFiltersInContext(string AppID, General.ErrorLogging.Data.LoggingFilter.GetActiveFiltersDataContext Data)
        {
            if (Data == null)
                throw new ArgumentNullException("No data specified, please POST the error data as a parent object with a valid GetActiveFiltersDataContext property.");
            if (String.IsNullOrWhiteSpace(Data.AccessCode) || Data.AccessCode != Settings.APIWriteOnlyAccessCode)
            {
                if (!(User != null && User.Identity != null && User.Identity.IsAuthenticated))
                    throw new UnauthorizedAccessException("Invalid Access Code");
            }
            if (Data.AppContext.AppID == null)
                throw new ArgumentNullException("AppContext.AppID is null, please POST the error data as a parent object with a valid AppContext property.");
            if (Data.AppContext.AppID.HasValue && Data.AppContext.AppID.Value != int.Parse(AppID))
                throw new ArgumentException("AppID in API path doesn't match AppID specified in AppContext.");

            Data.AppContext.AppID = int.Parse(AppID);
            var filters = General.ErrorLogging.Data.LoggingFilter.GetFiltersCustomView(LoggingFilterViewType.Browser, Data.AppContext.AppID, Data.AppContext, blnActiveOnly: true);
            return filters;
        }

        // POST api/[AppID]/LoggingFilter/ActiveFiltersForRemoteApp
        [HttpPost]
        [EnableCors(origins: "*", headers: "*", methods: "*")]
        [ActionName("ActiveFiltersForRemoteApp")]
        public IEnumerable<ILoggingFilter> ActiveFiltersForRemoteApp(string AppID, General.ErrorLogging.Data.LoggingFilter.GetActiveFiltersDataContext Data)
        {
            if (Data == null)
                throw new ArgumentNullException("No data specified, please POST the error data as a parent object with a valid GetActiveFiltersDataContext property.");
            if (String.IsNullOrWhiteSpace(Data.AccessCode) || Data.AccessCode != Settings.APIWriteOnlyAccessCode)
            {
                if (!(User != null && User.Identity != null && User.Identity.IsAuthenticated))
                    throw new UnauthorizedAccessException("Invalid Access Code");
            }
            if (Data.AppContext.AppID == null)
                throw new ArgumentNullException("AppContext.AppID is null, please POST the error data as a parent object with a valid AppContext property.");
            if (Data.AppContext.AppID.HasValue && Data.AppContext.AppID.Value != int.Parse(AppID))
                throw new ArgumentException("AppID in API path doesn't match AppID specified in AppContext.");

            Data.AppContext.AppID = int.Parse(AppID);
            var filters = General.ErrorLogging.Data.LoggingFilter.GetFiltersCustomView(LoggingFilterViewType.RemoteServer, Data.AppContext.AppID, Data.AppContext, blnActiveOnly: true);
            return filters;
        }
        #endregion

        #region GetAll
        // GET api/[AppID]/LoggingFilter
        [Authorize]
        public IEnumerable<ILoggingFilter> GetAll(string AppID, string ClientID = null, string UserID = null, Environment.EnvironmentContext? Environment = null, bool ActiveOnly = true)
        {
            Data.LoggingFilter.LoggingFilterRequestContext AppContext = null;
            if (!String.IsNullOrWhiteSpace(ClientID) || !String.IsNullOrWhiteSpace(UserID) || Environment != null)
            {
                AppContext = new Data.LoggingFilter.LoggingFilterRequestContext();
                AppContext.AppID = ParseAppID(AppID, blnAllowAny: true);
                AppContext.ClientID = ClientID;
                AppContext.UserID = UserID;
                AppContext.Environment = Environment;
            }
            return General.ErrorLogging.Data.LoggingFilter.GetFilters(ParseAppID(AppID, blnAllowAny: true), AppContext, ActiveOnly);
        }
        #endregion

        #region Search
        private bool FullTextMatch(string strSearch, ILoggingFilter obj)
        {
            if (String.IsNullOrWhiteSpace(strSearch))
                return true;

            var tokens = FullTextSearch.Tokenize(strSearch);

            bool blnHasNotToken = tokens.Where(t => t.StartsWith("-")).Count() > 0;
            bool blnMatchedHardBlock = false;
            bool blnMatched = false;
            if (tokens.Where(t => t.StartsWith("-")).Count() == tokens.Count()) //If I'm only using negative matches, then show everything that isn't eliminated.
                blnMatched = true;

            if (FullTextSearch.TokenContains(obj.Name, tokens, out blnMatchedHardBlock)) blnMatched = true;
            if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;

            if (obj.ClientFilter.ClientIDList != null && obj.ClientFilter.ClientIDList.Count > 0)
            {
                if (FullTextSearch.TokenEquals(obj.ClientFilter.ClientIDList.ToArray(), tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }
            if (obj.UserFilter.UserIDList != null && obj.UserFilter.UserIDList.Count > 0)
            {
                if (FullTextSearch.TokenEquals(obj.UserFilter.UserIDList.ToArray(), tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }
            if (!String.IsNullOrWhiteSpace(obj.Custom1))
            {
                if (FullTextSearch.TokenContains(obj.Custom1, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }
            if (!String.IsNullOrWhiteSpace(obj.Custom2))
            {
                if (FullTextSearch.TokenContains(obj.Custom2, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }
            if (!String.IsNullOrWhiteSpace(obj.Custom3))
            {
                if (FullTextSearch.TokenContains(obj.Custom3, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }


            return blnMatched;
        }

        // GET api/[AppID]/ErrorLog/Search?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15
        [HttpGet]
        [Authorize]
        public IEnumerable<ILoggingFilter> Search(string AppID, string Search, string ClientID = null, string UserID = null, Environment.EnvironmentContext? Environment = null, bool ActiveOnly = true)
        {
            var data = GetAll(AppID, ClientID, UserID, Environment, ActiveOnly);
            return (from obj in data where FullTextMatch(Search, obj) select obj);
        }
        #endregion

        #region Get One
        // GET api/[AppID]/LoggingFilter?ID=5
        [HttpGet]
        [Authorize]
        public object Get(string AppID, int ID)
        {
            var filter = General.ErrorLogging.Data.LoggingFilter.GetFilter(ID);
            if (filter == null)
                return "Object not found.";
            if (ParseAppID(AppID) == null || filter.AppID == int.Parse(AppID))
                return filter;
            return "The requested object is out of scope for the AppID you specified.";
        }
        #endregion

        #region Post/Put
        // POST api/[AppID]/LoggingFilter
        [HttpPost]
        [Authorize]
        public ILoggingFilter CreateFilter(string AppID, LoggingFilter filter)
        {
            return General.ErrorLogging.Data.LoggingFilter.CreateLoggingFilter(filter);
        }

        // PUT api/[AppID]/LoggingFilter
        [HttpPut]
        [Authorize]
        public ILoggingFilter Put(string AppID, LoggingFilter filter)
        {
            return General.ErrorLogging.Data.LoggingFilter.UpdateLoggingFilter(filter);
        }

        // PUT api/[AppID]/LoggingFilter/UpdateFilterMeta
        [HttpPut]
        [Authorize]
        public ILoggingFilter UpdateFilterMeta(string AppID, LoggingFilter filter)
        {
            //This will update the non-Json fields only.
            LoggingFilter objData = (LoggingFilter) General.ErrorLogging.Data.LoggingFilter.GetFilter(filter.ID);
            objData.Name = filter.Name;
            objData.Enabled = filter.Enabled;
            objData.StartDate = filter.StartDate;
            objData.EndDate = filter.EndDate;
            objData.PageSMS = filter.PageSMS;
            objData.PageEmail = filter.PageEmail;
            return General.ErrorLogging.Data.LoggingFilter.UpdateLoggingFilter(objData);
        }

        // PUT api/[AppID]/LoggingFilter/UpdateFilterEnvironmentSection
        [HttpPut]
        [Authorize]
        public object UpdateFilterEnvironmentSection(string AppID, UpdateFilterEnvironmentSectionContext Data)
        {
            LoggingFilter objData = (LoggingFilter)General.ErrorLogging.Data.LoggingFilter.GetFilter(Data.FilterID);
            objData.EnvironmentFilter = Data.FilterSection;
            return General.ErrorLogging.Data.LoggingFilter.UpdateLoggingFilter(objData);
        }

        public class UpdateFilterEnvironmentSectionContext
        {
            public int FilterID { get; set; }
            public EnvironmentFilterModel FilterSection { get; set; }
        }

        // PUT api/[AppID]/LoggingFilter/UpdateFilterEnvironmentSection
        [HttpPut]
        [Authorize]
        public object UpdateFilterEventSection(string AppID, UpdateFilterEventSectionContext Data)
        {
            LoggingFilter objData = (LoggingFilter)General.ErrorLogging.Data.LoggingFilter.GetFilter(Data.FilterID);
            objData.EventFilter = Data.FilterSection;
            return General.ErrorLogging.Data.LoggingFilter.UpdateLoggingFilter(objData);
        }

        public class UpdateFilterEventSectionContext
        {
            public int FilterID { get; set; }
            public EventFilterModel FilterSection { get; set; }
        }

        // PUT api/[AppID]/LoggingFilter/UpdateFilterEnvironmentSection
        [HttpPut]
        [Authorize]
        public object UpdateFilterClientSection(string AppID, UpdateFilterClientSectionContext Data)
        {
            LoggingFilter objData = (LoggingFilter)General.ErrorLogging.Data.LoggingFilter.GetFilter(Data.FilterID);
            objData.ClientFilter = Data.FilterSection;
            return General.ErrorLogging.Data.LoggingFilter.UpdateLoggingFilter(objData);
        }

        public class UpdateFilterClientSectionContext
        {
            public int FilterID { get; set; }
            public ClientFilterModel FilterSection { get; set; }
        }

        // PUT api/[AppID]/LoggingFilter/UpdateFilterEnvironmentSection
        [HttpPut]
        [Authorize]
        public object UpdateFilterUserSection(string AppID, UpdateFilterUserSectionContext Data)
        {
            LoggingFilter objData = (LoggingFilter)General.ErrorLogging.Data.LoggingFilter.GetFilter(Data.FilterID);
            objData.UserFilter = Data.FilterSection;
            return General.ErrorLogging.Data.LoggingFilter.UpdateLoggingFilter(objData);
        }

        public class UpdateFilterUserSectionContext
        {
            public int FilterID { get; set; }
            public UserFilterModel FilterSection { get; set; }
        }
        #endregion

        #region Delete
        // DELETE api/[AppID]/LoggingFilter?ID=1
        [HttpDelete]
        [Authorize]
        public string Delete(string AppID, int ID)
        {
            var filter = General.ErrorLogging.Data.LoggingFilter.GetFilter(ID);
            if (filter == null)
                return "Object not found.";
            if (ParseAppID(AppID) == null || filter.AppID == int.Parse(AppID))
            {
                General.ErrorLogging.Data.LoggingFilter.DeleteLoggingFilter(ID);
                return "Object deleted.";
            }
            else
            {
                return "The requested object is out of scope for the AppID you specified.";
            }
        }
        #endregion

        #region Private
        private int? ParseAppID(string strIn, bool blnAllowAny = false)
        {
            if (strIn.ToLower() == "any")
                if (blnAllowAny)
                    return null;
                else
                    throw new ArgumentException("You must specify an AppID.");
            return int.Parse(strIn);
        }
        #endregion

    }

}