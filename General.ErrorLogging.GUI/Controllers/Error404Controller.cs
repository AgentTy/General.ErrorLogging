using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using General.ErrorLogging.Model;
using System.Text.RegularExpressions;
using General.Data;

namespace General.ErrorLogging.GUI.Controllers
{

    public class Error404Controller : ApiController
    {

        #region GET Normal
        // GET api/[AppID]/Error404/Normal?StartDate=1/1/2015&EndDate=1/31/15&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Normal(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Filter = "all")
        {
            if (!String.IsNullOrWhiteSpace(ClientID) || ParseEnvironment(Environment) != null)
                return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s(ParseAppID(AppID), ClientID, ParseEnvironment(Environment), StartDate, EndDate), Filter);
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s(ParseAppID(AppID), StartDate, EndDate), Filter);
        }

        /*

        // GET api/[AppID]/Error404/Normal?StartDate=1/1/2015&EndDate=1/31/15&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Normal(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string Environment, string Filter = "all")
        {
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s(ParseAppID(AppID), null, ParseEnvironment(Environment), StartDate, EndDate), Filter);
        }

      
        // GET api/[AppID]/Error404/Normal?StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Normal(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID, string Filter = "all")
        {
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s(ParseAppID(AppID), ClientID, null, StartDate, EndDate), Filter);
        }
      

        // GET api/[AppID]/Error404/Normal?StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Normal(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID, string Environment = "any", string Filter = "all")
        {
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s(ParseAppID(AppID), ClientID, ParseEnvironment(Environment), StartDate, EndDate), Filter);
        }

        */
        #endregion

        #region GET Common
        // GET api/[AppID]/Error404/Common?StartDate=1/1/2015&EndDate=1/31/15&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Common(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Filter = "all")
        {
            if (!String.IsNullOrWhiteSpace(ClientID) || ParseEnvironment(Environment) != null)
                return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_CommonOnly(ParseAppID(AppID), ClientID, ParseEnvironment(Environment), StartDate, EndDate), Filter);
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_CommonOnly(ParseAppID(AppID), null, null, StartDate, EndDate), Filter);
        }


        /*
        // GET api/[AppID]/Error404/Common?StartDate=1/1/2015&EndDate=1/31/15&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Common(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string Environment, string Filter = "all")
        {
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_CommonOnly(ParseAppID(AppID), null, ParseEnvironment(Environment), StartDate, EndDate), Filter);
        }

        
        // GET api/[AppID]/Error404/Common?StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Common(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID, string Filter = "all")
        {
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_CommonOnly(ParseAppID(AppID), ClientID, null, StartDate, EndDate), Filter);
        }
        

        // GET api/[AppID]/Error404/Common?StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Common(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID, string Environment = "any", string Filter = "all")
        {
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_CommonOnly(ParseAppID(AppID), ClientID, ParseEnvironment(Environment), StartDate, EndDate), Filter);
        }
        */
        #endregion

        #region GET IncludeSuppressed
        // GET api/[AppID]/Error404/IncludeSuppressed?StartDate=1/1/2015&EndDate=1/31/15&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> IncludeSuppressed(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Filter = "all")
        {
            if (!String.IsNullOrWhiteSpace(ClientID) || ParseEnvironment(Environment) != null)
                return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_Hidden(ParseAppID(AppID), ClientID, ParseEnvironment(Environment), StartDate, EndDate), Filter);
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_Hidden(ParseAppID(AppID), null, null, StartDate, EndDate), Filter);
        }

        /*
        // GET api/[AppID]/Error404/IncludeSuppressed?StartDate=1/1/2015&EndDate=1/31/15&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> IncludeSuppressed(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string Environment, string Filter = "all")
        {
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_Hidden(ParseAppID(AppID), null, ParseEnvironment(Environment), StartDate, EndDate), Filter);
        }

        
        // GET api/[AppID]/Error404/IncludeSuppressed?StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> IncludeSuppressed(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID, string Filter = "all")
        {
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_Hidden(ParseAppID(AppID), ClientID, null, StartDate, EndDate), Filter);
        }
        

        // GET api/[AppID]/Error404/IncludeSuppressed?StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> IncludeSuppressed(string AppID, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID, string Environment = "any", string Filter = "all")
        {
            return ApplyFilters(General.ErrorLogging.Data.Error404.GetError404s_Hidden(ParseAppID(AppID), ClientID, ParseEnvironment(Environment), StartDate, EndDate), Filter);
        }
        */
        #endregion

        #region Search
        private bool FullTextMatch(string strSearch, Error404 obj)
        {
            if(String.IsNullOrWhiteSpace(strSearch))
                return true;

            var tokens = FullTextSearch.Tokenize(strSearch);

            bool blnHasNotToken = tokens.Where(t => t.StartsWith("-")).Count() > 0;
            bool blnMatchedHardBlock = false;
            bool blnMatched = false;
            if (tokens.Where(t => t.StartsWith("-")).Count() == tokens.Count()) //If I'm only using negative matches, then show everything that isn't eliminated.
                blnMatched = true;

            if (FullTextSearch.TokenContains(obj.ClientID, tokens, out blnMatchedHardBlock)) blnMatched = true;
            if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;

            if (FullTextSearch.TokenContains(obj.URL, tokens, out blnMatchedHardBlock)) blnMatched = true;
            if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;

            if (FullTextSearch.TokenContains(obj.UserAgent, tokens, out blnMatchedHardBlock)) blnMatched = true;
            if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;

            if (FullTextSearch.TokenContains(obj.Detail, tokens, out blnMatchedHardBlock)) blnMatched = true;
            if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;

            return blnMatched;

            /*
             *  Original (simple) token matching
            if(tokens.Any(t => obj.URL.ToLower().Contains(t)))
                return true;
            if (tokens.Any(t => obj.UserAgent.ToLower().Contains(t)))
                return true;
            if (tokens.Any(t => obj.Detail.ToLower().Contains(t)))
                return true;
            */
           
        }

        // GET api/[AppID]/Error404/Search?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Search(string AppID, string Search, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Filter = "all")
        {
            var data = Normal(AppID, StartDate, EndDate, ClientID, Environment, Filter);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }
        /*
        // GET api/[AppID]/Error404/Search?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Search(string AppID, string Search, DateTimeOffset StartDate, DateTimeOffset EndDate, string Environment, string Filter = "all")
        {
            var data = Normal(AppID, StartDate, EndDate, Environment, Filter);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }

        
        // GET api/[AppID]/Error404/Search?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Search(string AppID, string Search, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID, string Filter = "all")
        {
            var data = Normal(AppID, StartDate, EndDate, ClientID, Filter);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }
        

        // GET api/[AppID]/Error404/Search?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> Search(string AppID, string Search, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID, string Environment = "any", string Filter = "all")
        {
            var data = Normal(AppID, StartDate, EndDate, ClientID, Environment, Filter);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }
        */

        // GET api/[AppID]/Error404/SearchCommonOnly?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> SearchCommon(string AppID, string Search, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Filter = "all")
        {
            var data = Common(AppID, StartDate, EndDate, ClientID, Environment, Filter);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }

        // GET api/[AppID]/Error404/SearchCommonOnly?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15&ClientID=1&Environment=Dev&Filter=all
        [HttpGet]
        [Authorize]
        public List<Error404> SearchIncludeSuppressed(string AppID, string Search, DateTimeOffset StartDate, DateTimeOffset EndDate, string ClientID = "", string Environment = "any", string Filter = "all")
        {
            var data = IncludeSuppressed(AppID, StartDate, EndDate, ClientID, Environment, Filter);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }
        #endregion

        #region Get One
        // GET api/[AppID]/Error404?ID=5
        [HttpGet]
        [Authorize]
        public object Get(string AppID, int ID)
        {
            var error = General.ErrorLogging.Data.Error404.GetError404(ID);
            if (error == null)
                return "Object not found.";
            if (error.AppID == int.Parse(AppID))
               return error;
           return "The requested object is out of scope for the AppID you specified.";
        }
        #endregion

        #region Post/Put

        [HttpPost]
        [Authorize]
        public Error404 Post(int AppID, General.Environment.EnvironmentContext Environment, string ClientID, string URL, string UserAgent, string Detail)
        {
            return General.ErrorLogging.Data.Error404.RecordError404(AppID, Environment, ClientID, URL, UserAgent, Detail);
        }

        // POST api/[AppID]/Error404
        [HttpPost]
        [Authorize]
        public Error404 Post(string AppID, Error404 error)
        {
            return General.ErrorLogging.Data.Error404.RecordError404(error.AppID, error.Environment, error.ClientID, error.URL, error.UserAgent, error.Detail);
        }

        // PUT api/[AppID]/Error404
        [HttpPut]
        [Authorize]
        public Error404 Put(string AppID, Error404 error) 
        {
            return General.ErrorLogging.Data.Error404.UpdateError404(error);
        }
        
        #endregion

        #region Delete
        // DELETE api/[AppID]/Error404?ID=1
        [HttpDelete]
        [Authorize]
        public string Delete(string AppID, int ID)
        {
            var error = General.ErrorLogging.Data.Error404.GetError404(ID);
            if (error == null)
                return "Object not found.";
            if (error.AppID == int.Parse(AppID))
            { 
                General.ErrorLogging.Data.Error404.DeleteError404(ID);
                return "Object deleted.";
            }
            else 
            { 
                return "The requested object is out of scope for the AppID you specified.";
            }
            
        }
        #endregion

        #region Suppress / Restore
        // POST api/[AppID]/Error404/Suppress?ID=1
        [HttpPost]
        [Authorize]
        public string Suppress(string AppID, int ID)
        {
            var error = General.ErrorLogging.Data.Error404.GetError404(ID);
            if (error == null)
                return "Object not found.";
            if (error.AppID == int.Parse(AppID))
            {
                General.ErrorLogging.Data.Error404.UpdateError404Visibility(ID, true);
                return "Object suppressed.";
            }
            else
            {
                return "The requested object is out of scope for the AppID you specified.";
            }
        }

        // POST api/[AppID]/Error404/Restore?ID=1
        [HttpPost]
        [Authorize]
        public string Restore(string AppID, int ID)
        {
            var error = General.ErrorLogging.Data.Error404.GetError404(ID);
            if (error == null)
                return "Object not found.";
            if (error.AppID == int.Parse(AppID))
            {
                General.ErrorLogging.Data.Error404.UpdateError404Visibility(ID, false);
                return "Object restored.";
            }
            else
            {
                return "The requested object is out of scope for the AppID you specified.";
            }
        }
        #endregion

        #region Private
        private List<Error404> ApplyFilters(List<Error404> data, string strFilter)
        {
            if (String.IsNullOrWhiteSpace(strFilter))
                return data;
            
            strFilter = strFilter.Trim().ToLower();
            if (strFilter == "all")
                return data;

            switch(strFilter)
            {
                case "pages": //Pages Only
                    data = data.Where(err => General.Model.URL.IsPage(err.URL) == true).ToList(); break;
                case "images": //Images Only
                    data = data.Where(err => General.Model.URL.IsImage(err.URL) == true).ToList(); break;
            }
            return data;
        }

        private int ParseAppID(string strIn)
        {
            if (strIn.ToLower() == "any")
                throw new ArgumentException("You must specify an AppID.");
            return int.Parse(strIn);
        }

        private General.Environment.EnvironmentContext? ParseEnvironment(string strIn)
        {
            if (String.IsNullOrWhiteSpace(strIn))
                return null;
            if (strIn.ToLower() == "any")
                return null;
            return (General.Environment.EnvironmentContext)Enum.Parse(typeof(General.Environment.EnvironmentContext), strIn);
        }
        #endregion

    }
}