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

    public class Error404RedirectController : ApiController
    {

        #region GetAll
        // GET api/[AppID]/Error404Redirect?StartDate=1/1/2015&EndDate=1/31/15&Environment=Dev
        [Authorize]
        public List<Error404Redirect> GetAll(string AppID)
        {
            return General.ErrorLogging.Data.Error404Redirect.GetError404Redirects(ParseAppID(AppID), null);
        }

        // GET api/[AppID]/Error404Redirect?StartDate=1/1/2015&EndDate=1/31/15&ClientID=1
        [Authorize]
        public List<Error404Redirect> GetAll(string AppID, string ClientID)
        {
            return General.ErrorLogging.Data.Error404Redirect.GetError404Redirects(ParseAppID(AppID), ClientID);
        }
        #endregion

        #region Search
        private bool FullTextMatch(string strSearch, Error404Redirect obj)
        {
            if(String.IsNullOrWhiteSpace(strSearch))
                return true;

            var tokens = FullTextSearch.Tokenize(strSearch);

            bool blnHasNotToken = tokens.Where(t => t.StartsWith("-")).Count() > 0;
            bool blnMatchedHardBlock = false;
            bool blnMatched = false;
            if (tokens.Where(t => t.StartsWith("-")).Count() == tokens.Count()) //If I'm only using negative matches, then show everything that isn't eliminated.
                blnMatched = true;

            if (FullTextSearch.TokenContains(obj.From, tokens, out blnMatchedHardBlock)) blnMatched = true;
            if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;

            if (FullTextSearch.TokenContains(obj.To, tokens, out blnMatchedHardBlock)) blnMatched = true;
            if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;

            if (!String.IsNullOrWhiteSpace(obj.ClientID))
            {
                if (FullTextSearch.TokenContains(obj.ClientID, tokens, out blnMatchedHardBlock)) blnMatched = true;
                if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;
            }

            if (FullTextSearch.TokenEquals(obj.RedirectType.ToString(), tokens, out blnMatchedHardBlock)) blnMatched = true;
            if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;

            return blnMatched;
            /*
             *  Original (simple) token matching
            if (tokens.Any(t => obj.From.ToLower().Contains(t)))
                return true;
            if (tokens.Any(t => obj.To.ToLower().Contains(t)))
                return true;
            if (obj.ClientID != null)
                if (tokens.Any(t => obj.ClientID.ToString().Equals(t)))
                    return true;
            if (tokens.Any(t => obj.RedirectType.ToString().Equals(t)))
                return true;
            */
        }

        // GET api/[AppID]/Error404Redirect/Search?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15
        [HttpGet]
        [Authorize]
        public List<Error404Redirect> Search(string AppID, string Search)
        {
            var data = GetAll(AppID);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }

        // GET api/[AppID]/Error404Redirect/Search?SearchString=test&StartDate=1/1/2015&EndDate=1/31/15&ClientID=1
        [HttpGet]
        [Authorize]
        public List<Error404Redirect> Search(string AppID, string Search, string ClientID)
        {
            var data = GetAll(AppID, ClientID);
            return (from obj in data where FullTextMatch(Search, obj) select obj).ToList();
        }
        #endregion

        #region Get One
        // GET api/[AppID]/Error404Redirect?ID=5
        [HttpGet]
        [Authorize]
        public object Get(string AppID, int ID)
        {
            var error = General.ErrorLogging.Data.Error404Redirect.GetError404Redirect(ID);
            if (error == null)
                return "Object not found.";
            if (error.AppID == int.Parse(AppID))
               return error;
           return "The requested object is out of scope for the AppID you specified.";
        }
        #endregion

        #region Post/Put
        // POST api/[AppID]/Error404Redirect
        [HttpPost]
        [Authorize]
        public Error404Redirect Post(string AppID, Error404Redirect error)
        {
            return General.ErrorLogging.Data.Error404Redirect.CreateError404Redirect(error);
        }

        // PUT api/[AppID]/Error404Redirect
        [HttpPut]
        [Authorize]
        public Error404Redirect Put(string AppID, Error404Redirect error) 
        {
            return General.ErrorLogging.Data.Error404Redirect.UpdateError404Redirect(error);
        }
        #endregion

        #region Delete
        // DELETE api/[AppID]/Error404Redirect?ID=1
        [HttpDelete]
        [Authorize]
        public string Delete(string AppID, int ID)
        {
            var error = General.ErrorLogging.Data.Error404Redirect.GetError404Redirect(ID);
            if (error == null)
                return "Object not found.";
            if (error.AppID == int.Parse(AppID))
            {
                General.ErrorLogging.Data.Error404Redirect.DeleteError404Redirect(ID);
                return "Object deleted.";
            }
            else 
            { 
                return "The requested object is out of scope for the AppID you specified.";
            }
            
        }
        #endregion

        #region Private
        private int ParseAppID(string strIn)
        {
            if (strIn.ToLower() == "any")
                throw new ArgumentException("You must specify an AppID.");
            return int.Parse(strIn);
        }
        #endregion

    }
}