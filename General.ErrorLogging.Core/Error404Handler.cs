using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

using General;
using General.Web;
using General.ErrorLogging;
using General.ErrorLogging.Model;
using System.Text.RegularExpressions;


    public class Error404Handler
    {
        private static System.Text.RegularExpressions.Regex rgxLocalHost = new System.Text.RegularExpressions.Regex(@"http://localhost:\d*/*");

        #region StaticHandler
        private static Error404Handler _objStaticHandler;
        public static Error404Handler StaticHandler
        {
            get
            {
                if (_objStaticHandler == null)
                    _objStaticHandler = new Error404Handler(ErrorReporter.AppID, null); //I am using a NULL ClientID always, 404 handling will be at the App level in this static handler
                return _objStaticHandler;
            }
            set
            {
                _objStaticHandler = value;
            }
        }
        #endregion

        #region Properties
        public int AppID { get; set; }
        public string ClientID { get; set; }
        public short RedirectCacheMinutes { get; set; }
        #endregion

        #region Constructors
        public Error404Handler(int intAppID, string strClientID)
        {
            AppID = intAppID;
            ClientID = strClientID;
            RedirectCacheMinutes = 1; //30 Minutes by default, remember... if the Cache doesn't hit a match the class will double check the database anyways.
        }
        #endregion

        #region Redirect Data

        private List<Error404Redirect> _lstRedirectData;
        private DateTimeOffset _dtRedirectDataLoaded;
        protected List<string> RedirectPagesAlreadyDBDoubleChecked = new List<string>();

        public List<Error404Redirect> PageRedirects
        {
            get
            {
                if (_lstRedirectData != null && (DateTimeOffset.Now - _dtRedirectDataLoaded).TotalMinutes < RedirectCacheMinutes)
                    return _lstRedirectData;

                LoadPageRedirects();
                return _lstRedirectData;
            }
        }

        private void LoadPageRedirects()
        {
            SavePageRedirects();
            RedirectPagesAlreadyDBDoubleChecked.Clear();

            #region Load Data
            List<Error404Redirect> lstRedirects = General.ErrorLogging.Data.Error404Redirect.GetError404Redirects(AppID, ClientID);
            if (lstRedirects != null)
            {
                _lstRedirectData = lstRedirects;
                _dtRedirectDataLoaded = DateTimeOffset.Now;
            }
            #endregion
        }

        public void ReloadPageRedirects()
        {
            LoadPageRedirects();
        }

        protected void ReloadPageRedirects(string key, object value, System.Web.Caching.CacheItemRemovedReason reason, string host)
        {
            SavePageRedirects((List<Error404Redirect>)value);
            LoadPageRedirects();
        }

        public void SavePageRedirects()
        {
            SavePageRedirects(_lstRedirectData);
        }

        private void SavePageRedirects(List<Error404Redirect> lstRedirects)
        {
            #region Update Database with usage data
            if (lstRedirects != null)
            {
                lstRedirects.Where(page => page.Changed == true).ToList().ForEach(delegate(Error404Redirect page)
                {
                    General.ErrorLogging.Data.Error404Redirect.UpdateLog(page);
                    page.Changed = false;
                });
            }
            #endregion
        }
        #endregion

        /// <summary>
        /// This will record a 404 error or 
        /// </summary>
        /// <param name="context"></param>
        /// <returns></returns>
        public bool Handle404(HttpContext context)
        {
            string strWebSiteDomain = WebTools.GetWebSiteURL();
            string strPage = context.Request.Url.ToString();

            string strOriginalRequestedPage;
            #region Strip Domain Name
            if (strPage.Contains("404;"))
                strPage = General.StringFunctions.AllAfter(strPage, "404;");
            if (strPage.Contains(":80/"))
                strPage = General.StringFunctions.AllAfter(strPage, ":80/");
            if (strPage.Contains(":443/"))
                strPage = General.StringFunctions.AllAfter(strPage, ":443/");

            strPage = strPage.Replace("404.aspx?", "");
            strPage = strPage.Replace(strWebSiteDomain + ":80/", "");
            strPage = strPage.Replace(strWebSiteDomain + ":443/", "");
            strPage = strPage.Replace(strWebSiteDomain + ":443/", "");
            strPage = strPage.Replace(strWebSiteDomain + "/", "");
            strPage = strPage.Replace(strWebSiteDomain.Replace("www.", "") + ":80/", "");
            strPage = strPage.Replace(strWebSiteDomain.Replace("www.", "") + ":443/", "");
            strPage = strPage.Replace(strWebSiteDomain.Replace("www.", "") + "/", "");
            strPage = strPage.Replace(strWebSiteDomain.Replace("www.", "beta.") + "/", "");
            strPage = strPage.Replace(strWebSiteDomain.Replace("www.", "beta1.") + "/", "");
            strPage = strPage.Replace(strWebSiteDomain.Replace("www.", "beta2.") + "/", "");
            strPage = strPage.Replace(strWebSiteDomain.Replace("www.", "beta3.") + "/", "");
            strPage = strPage.Replace("aspxerrorpath=/", "");
            strPage = rgxLocalHost.Replace(strPage, "");
            #endregion
            strOriginalRequestedPage = strPage;

            string strQuery = WebTools.GetQueryString(strPage); //Store Query String
            strPage = WebTools.RemoveQueryString(strPage); //Remove Query String

            #region Remove All After #
            if (strPage.Contains("#"))
            {
                string[] astrUrl = strPage.Split('#');
                strPage = astrUrl[0];
            }
            #endregion

            #region Forward to Toolkit CMS Redirects
        rechecklist: List<Error404Redirect> lstPageRedirects = PageRedirects;
            if (lstPageRedirects != null)
            {
                var objRedirPage = lstPageRedirects.Where(page => PageMatch(page.From, strPage) == true).FirstOrDefault();
                if (objRedirPage != null)
                {
                    objRedirPage.RecordUse();

                    if (objRedirPage.From.EndsWith("*"))
                    {
                        if (objRedirPage.To.EndsWith("*"))
                        {
                            string strNewPage = objRedirPage.To.Replace("*", Regex.Replace(strPage, objRedirPage.From.TrimEnd('*').TrimStart('/'), "", RegexOptions.IgnoreCase));
                            Forward(context, strNewPage, strQuery, objRedirPage.RedirectType);
                        }
                        else
                        {
                            Forward(context, objRedirPage.To, strQuery, objRedirPage.RedirectType);
                        }
                    }
                    else
                    {
                        Forward(context, objRedirPage.To, strQuery, objRedirPage.RedirectType);
                    }
                    return true; //True because the request was redirected
                }
                else if (!RedirectPagesAlreadyDBDoubleChecked.Contains(strPage))
                {
                    if (General.ErrorLogging.Data.Error404Redirect.GetError404Redirect(AppID, ClientID, strPage) != null)
                    {
                        ReloadPageRedirects(); //Save and Reload the data
                        goto rechecklist;
                    }
                    else
                        RedirectPagesAlreadyDBDoubleChecked.Add(strPage);
                }
            }
            #endregion

            #region Default Handling / Hard Coded Redirects
            switch (System.IO.Path.GetExtension(strPage))
            {
                case ".html": //HTML
                case ".htm":
                case ".xhtml":
                case ".jhtml":

                case ".aspx": //ASP
                case ".asp":

                case ".rb": //Ruby
                case ".rhtml":

                case ".php": //PHP
                case ".phtml":
                case ".php4":
                case ".php3":
                case ".shtml":

                case ".cfm": //Coldfusion

                case ".jsp": //Java
                case ".jspx":
                case ".do":
                case ".action":
                case ".wss":

                case ".pl": //Perl
                case ".py": //Python
                case ".cgi": //Other
                case ".dll":
                case "":
                    break;
                default:

                    #region Otherwise Report the 404 Error and let the 404 Page display

                    Report404(context, strOriginalRequestedPage, strQuery);
                    context.Server.ClearError();
                    return false;

                    #endregion
            }

            #region Remove File Extension
            string strPageWithExtention = strPage;
            strPage = strPage.Replace(".aspx", "");
            strPage = strPage.Replace(".html", "");
            strPage = strPage.Replace(".htm", "");
            strPage = strPage.Replace(".xhtml", "");
            strPage = strPage.Replace(".jhtml", "");
            strPage = strPage.Replace(".rhtml", "");
            strPage = strPage.Replace(".rb", "");
            strPage = strPage.Replace(".php", "");
            strPage = strPage.Replace(".shtml", "");
            strPage = strPage.Replace(".asp", "");
            strPage = strPage.Replace(".cfm", "");
            strPage = strPage.Replace(".pl", "");
            strPage = strPage.Replace(".jsp", "");
            strPage = strPage.Replace(".jspx", "");
            strPage = strPage.Replace(".ws", "");
            strPage = strPage.Replace(".action", "");
            strPage = strPage.Replace(".cgi", "");
            strPage = strPage.Replace(".dll", "");
            #endregion

            #region Forward to Hard Coded Redirects
            switch (strPage.ToLower())
            {
                case "default":
                case "index":
                    Forward(context, "/");
                    return true;
                default:
                    Report404(context, strOriginalRequestedPage, strQuery);
                    context.Server.ClearError();
                    break;
            }
            #endregion

            #endregion

            return false; //False because the request was not redirected
        }

        #region PageMatch
        protected bool PageMatch(string Page1, string Page2)
        {
            Page1 = Page1.ToLowerInvariant();
            Page2 = Page2.ToLowerInvariant();

            if (!Page1.StartsWith("/"))
                Page1 = "/" + Page1;
            if (!Page2.StartsWith("/"))
                Page2 = "/" + Page2;

            if (Page1.EndsWith("*")) //Wildcard Specified
            {
                return System.Text.RegularExpressions.Regex.IsMatch(Page2, Page1.Replace(".*", "*").Replace("*", ".*"));
            }
            return Page1 == Page2;
        }
        #endregion

        #region Forward with 301 Moved Permanently/Temporarily
        private void Forward(HttpContext context, string strNewURL)
        {
            Forward(context, strNewURL, "");
        }

        private void Forward(HttpContext context, string strNewURL, string strQueryString)
        {
            Forward(context, strNewURL, strQueryString, 301); //Permanent
        }

        private void Forward(HttpContext context, string strNewURL, string strQueryString, short intRedirectType)
        {
            if (!StringFunctions.IsNullOrWhiteSpace(strQueryString))
                strNewURL += "?" + strQueryString;
            if (intRedirectType > 0)
                context.Response.StatusCode = intRedirectType;
            else
                context.Response.StatusCode = 301;
            if (intRedirectType == 301)
                context.Response.Status = "301 Moved Permanently";
            else if (intRedirectType == 307)
                context.Response.Status = "307 Moved Temporarily";
            else
                context.Response.Status = intRedirectType.ToString() + " Moved";
            context.Response.AddHeader("Location", strNewURL);
            context.Response.End();
        }
        #endregion

        #region Report404 Error
        private void Report404(HttpContext context, string strPageRequested, string strQueryString)
        {
            context.Response.StatusCode = 404;
            context.Response.Status = "404 Not Found";

            string strPageLowerCase = strPageRequested.ToLower();

            #region Ignore These
            if (strPageLowerCase.EndsWith("404.aspx"))
                return;
            //if (strPageLowerCase.EndsWith(".jpg"))
            //    return;
            //if (strPageLowerCase.EndsWith(".png"))
            //    return;
            //if (strPageLowerCase.EndsWith(".gif"))
            //    return;
            if (strPageLowerCase.Contains("sitemap.xml"))
                return;
            if (strPageLowerCase.Contains("favicon.ico"))
                return;
            if (strPageLowerCase.Contains("favicon.gif"))
                return;
            if (strPageLowerCase.Contains("robots.txt"))
                return;
            if (strPageLowerCase.Contains("__utm.gif"))
                return;
            if (strPageLowerCase.Contains("scriptresource.axd"))
                return;
            if (strPageLowerCase.Contains("webresource.axd"))
                return;
            if (strPageLowerCase.Contains("expressInstall.swf"))
                return;
            if (strPageLowerCase.Contains("apple-touch-icon"))
                return;
            #endregion

            #region Other Info
            string strOtherInfo = String.Empty;
            string strUserAgent = String.Empty;
            string strOriginalPageRequested = General.Web.WebTools.GetRequestedPageWithQueryString();
            try
            {
                strUserAgent = context.Request.UserAgent;
                if (!strUserAgent.ToLower().Contains("bot") && !strUserAgent.ToLower().Contains("spider") && !strUserAgent.ToLower().Contains("crawl"))
                {
                    strUserAgent = context.Request.Browser.Browser;
                }

                strOtherInfo += "Referrer = " + General.Web.WebTools.GetReferrer() + "\r\n";
                strOtherInfo += "HostAddress = " + context.Request.UserHostAddress + "\r\n";
                strOtherInfo += "LocalPath = " + context.Server.MapPath("/" + strPageRequested) + "\r\n";
                strOtherInfo += "UserAgent = " + context.Request.UserAgent + "\r\n";
            }
            catch { }
            #endregion

            try
            {
                General.ErrorLogging.Data.Error404.RecordError404(AppID, General.Environment.Current.WhereAmI(), ClientID, strPageRequested, strUserAgent, strOtherInfo);
            }
            catch (Exception ex)
            {
                #region Last Resort - Report an Error
                try
                {
                    ErrorReporter.ReportError(ex, new ApplicationContext());
                }
                catch { }
                #endregion
            }
        }
        #endregion


    }
