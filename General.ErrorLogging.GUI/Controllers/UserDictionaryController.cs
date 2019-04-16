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

    public class UserDictionaryController : ApiController
    {

        #region GetAll
        // GET api/[AppID]/UserDictionary
        [Authorize]
        public IEnumerable<string> GetAll(string AppID, string ClientID = null, bool ActiveOnly = true)
        {
            return General.ErrorLogging.Data.Application.GetUsers(ParseAppID(AppID), ClientID);
        }
        #endregion

        #region Search
        private bool FullTextMatch(string strSearch, string obj)
        {
            if (String.IsNullOrWhiteSpace(strSearch))
                return true;

            var tokens = FullTextSearch.Tokenize(strSearch);

            bool blnHasNotToken = tokens.Where(t => t.StartsWith("-")).Count() > 0;
            bool blnMatchedHardBlock = false;
            bool blnMatched = false;
            if (tokens.Where(t => t.StartsWith("-")).Count() == tokens.Count()) //If I'm only using negative matches, then show everything that isn't eliminated.
                blnMatched = true;

            if (FullTextSearch.TokenContains(obj, tokens, out blnMatchedHardBlock)) blnMatched = true;
            if (blnHasNotToken && blnMatchedHardBlock) return false; else if (!blnHasNotToken && blnMatched) return true;

            return blnMatched;
        }

        // GET api/[AppID]/UserDictionary/Search?Search=test
        [HttpGet]
        [Authorize]
        public IEnumerable<string> Search(string AppID, string Search, bool ActiveOnly = true)
        {
            var data = GetAll(AppID);
            return (from obj in data where FullTextMatch(Search, obj) select obj);
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