using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace General.ErrorLogging
{
    class ReadMe
    {
        /// <summary>
        /// The General.ErrorLogging library is designed to help track bugs in an application. 
        /// It is able to store verbose error information into a SQL database, including Code File/Line Number, Stack Trace, User context, Environment context, and more.
        /// It is also able to log 404 errors in a separate SQL Table, and store preferred 301 permanent redirections at the admin's descretion.
        /// See the code samples below for ideas...
        /// </summary>

        #region Required Keys in Web.config / App.config
        /// <summary>
        /// In order for the General.ErrorLogging Library to function, some keys need to be added to the config file that setup the General library and the Logging preferences
        /// The Connection String and the first two Keys are REQUIRED! That is AppIDForErrorLogging, and DefaultAppNameForErrorLog.
        /// The remaining keys setup email capibilities and recipients, that is for an edge case where an error CANNOT be logged to the database, it will try to email it instead.
        /// </summary>
        /*
          <connectionStrings>
            <add name="ErrorLog" connectionString="My Connection String For Error Database" providerName="System.Data.SqlClient" />
          </connectionStrings>
        */


        /* 
            <!-- Config for General.ErrorLogging -->
            <add key="AppIDForErrorLogging" value="1"/> <!-- This will go into the AppID column in the ErrorOther/Error404 tables -->
            <add key="DefaultAppNameForErrorLog" value="Name"/> <!-- This will go into the AppName column in the ErrorOther table, and it will be used to AutoPopulate the Application table. -->

            <!-- Config for General.Environment -->
            <!-- These keys allow you to tell the General library which servers are for Development or Staging use
            The method General.Environment.Current.AmIDev(), AmIStage(), and AmILive() will return T/F based on these settings. -->
            <add key="ServerNameList_Dev" value="COMPUTER1,COMPUTER2"/>
            <add key="ServerNameList_Staging" value="COMPUTER3"/>

         *  <!-- Config for General.Debugging -->
            <add key="DebugEmailFrom" value=""/>
            <add key="DebugEmailTo" value=""/>
            <add key="ErrorEmailFrom" value=""/>
            <add key="ErrorEmailTo" value=""/>
         * 
            <!-- Config for General.Mail -->
            <add key="MailServerLive" value=""/>
            <add key="MailServerLive_Port" value=""/>
            <add key="MailServerLive_UserName" value=""/>
            <add key="MailServerLive_Password" value=""/>
         */
        #endregion

        private void Examples()
        {
            //Here are examples of how to use this library.

            #region Automatic Error Logging Implementation in Global.asax
            /*
            /// <summary>
            /// The following Try/Catch block should be added to your Global.asax file in this method
            ///      void Application_Error(object sender, EventArgs e)
            /// </summary>
            try
            {
                ApplicationContext context;
                if (HttpContext.Current.Session != null)
                {
                    //Populate the report context with my session variables, ClientID, UserID, etc...
                    //ClientID (optional) is intended to identify which Client/Organization/Group of users is in context, it can be any number, guid, or string
                    //UserType (optional) can be used to differentiate different kinds of users, or different Unique Key pools so that UserType + UserID becomes a Unique key
                    //UserID (optional) is your systems Unique ID for the current user
                    context = new ApplicationContext(strClientID: "OrganizationID", strUserType: "UserType", strUserID: "UserID");

                    context.CustomID = null; //Any additonal integer you want to store
                    context.Custom1 = ""; //Custom String #1
                    context.Custom2 = ""; //Custom String #2
                    context.Custom3 = ""; //Custom String #3
                }
                else
                {
                    //I don't have a session, so user context may not be available
                    context = new ApplicationContext(null, null, null);
                }

                Exception ex = HttpContext.Current.Server.GetLastError();

                //Finally, we will send the error to the log, I can optionally put a condition here to only record the error in specific environments using the General.Environment library.
                //if (General.Environment.Current.AmILive())
                ErrorReporter.ReportError(ex, context);

                //If you want to combine Error handling and 404 handling... skip the line above and do this...
                try
                {
                    if (ex is HttpException)
                        if (((HttpException)ex).GetHttpCode() == 404)
                        {
                            //Here I can handle a 404 Error with redirects, using Error404Handner.StaticHandler or a managed pool of handlers for different ClientID's.
                            bool blnRedirected = Error404Handler.StaticHandler.Handle404(HttpContext.Current);
                            return; //Don't continue to process like a normal error
                        }
                }
                catch (Exception ex404)
                {
                    ErrorReporter.ReportError(ex404, context);
                }
                //if (General.Environment.Current.AmILive()) //Only record the error in a Live/Production environment
                ErrorReporter.ReportError(ex, context);


            }
            catch { }
            */

            //Now that you have added the handler to your Global.asax, simply throw an Exception to test.
            throw new Exception("test exception");
            #endregion

            #region Manual Error Logging  (with Exception Object)
            var exError = new Exception("test exception");

            var objErrorContext = new ApplicationContext(strClientID: "OrganizationID", strUserType: "UserType", strUserID: "UserID");
            objErrorContext.AppName = ""; //Override the default Application Name that is specified in the App.config/Web.config file.
            objErrorContext.CustomID = null; //Any additonal integer you want to store
            objErrorContext.Custom1 = ""; //Custom String #1
            objErrorContext.Custom2 = ""; //Custom String #2
            objErrorContext.Custom3 = ""; //Custom String #3

            //The ErrorReporter class will get the stack trace and other debugging info from the Exception
            ErrorReporter.ReportError(exError, objErrorContext);
            #endregion

            #region Manual Event Logging (without Exception Object)
            General.ErrorLogging.Model.ErrorOther error = new General.ErrorLogging.Model.ErrorOther();
            error.EventName = "My kind of trace";
            error.EventType = General.ErrorLogging.Model.ErrorOtherTypes.Trace;
            General.ErrorLogging.Data.ErrorOther.StoreEvent(error, null, null);
            #endregion

            #region Get Event Data
            //Get an Event Summary by ID
            var oneError = General.ErrorLogging.Data.ErrorOther.GetEventSummary(1);

            //Get a report of events by date range
            var errors = General.ErrorLogging.Data.ErrorOther.FindEventSummaries_Basic(DateTime.Today, DateTime.Today, intAppID: 1, strClientID: null, enuEnvironment: General.Environment.EnvironmentContext.Dev);
            foreach (var err in errors)
            {
                //System.Web.HttpContext.Current.Response.Write(err.ToString() + "<br/><br/>");
            }
            #endregion



            #region Automatic 404 Error Logging Implementation in Global.asax (with data driven redirection)
            /*
            /// <summary>
            /// You can use this library to record your 404 errors in the Error404 table, report on them, and setup Temporary and/or Permanent redirections for common 404 errors.
            /// 
            /// Look above at the example of Error Handling in Global.asax, it shows how to handle both general errors and 404 errors. Here is the part that is relevant to 404.
            /// 
            Exception ex2 = HttpContext.Current.Server.GetLastError();
            if (ex2 is HttpException)
                if (((HttpException)ex2).GetHttpCode() == 404)
                {
                    //Here I can handle a 404 Error with redirects, using Error404Handner.StaticHandler or a managed pool of handlers for different ClientID's.
                    bool blnRedirected = Error404Handler.StaticHandler.Handle404(HttpContext.Current);
                    return; //Don't continue to process like a normal error
                }
            /// 
            /// Finally, I need to add some traps in Global.asax to make sure that the database gets updated with the number of times a redirect has been used.
            /// The work of saving those stats is queued and batch updated... so if you never call SavePageRedirects() you will probably never know if the redirections have been used.
            /// 
            //// public static void Application_End(object sender, EventArgs e)
            //// {
            ////    // Code that runs on application shutdown
            ////    try {
            ////        if (Error404Handler.StaticHandler != null)
            ////            Error404Handler.StaticHandler.SavePageRedirects();
            ////    } catch {}
            //// }
            ////
            //// public static void Session_End(object sender, EventArgs e)
            //// {
            ////    // Code that runs when a new session ends
            ////    try {
            ////        if (System.Web.HttpContext.Current != null)
            ////        {
            ////            if (Error404Handler.StaticHandler != null)
            ////                Error404Handler.StaticHandler.SavePageRedirects();
            ////        }
            ////    } catch {}
            //// }
            /// 
            /// </summary>
            */
            #endregion

            #region Setting up a 404.aspx page for your visitors (optional)
            //It is not necessary to do this in order to record and redirect basic 404 errors (unless you want static files too), but if you want a nice "Page not found" page on your site, here's how to do it.
            /// <summary>
            /// In order to catch 404 errors for ALL FILE TYPES you need two different 404 handling registrations.
            /// 
            //// <customErrors mode="On" defaultRedirect="Error.aspx" redirectMode="ResponseRewrite">
            ////    <error statusCode="404" redirect="~/404.aspx" />
            //// </customErrors>
            /// 
            //// <system.webServer>
            ////    <httpErrors errorMode="Custom">
            ////      <remove statusCode="404" subStatusCode="-1" />
            ////      <error statusCode="404" prefixLanguageFilePath="" path="/404.aspx" responseMode="ExecuteURL" />
            ////    </httpErrors>
            //// </system.webServer>
            ///
            /// Now, create your 404.aspx page.
            /// 
            /// If you did NOT handle 404 errors in your Global.asax file, then you can do it here in your Page_Load
            ////    protected void Page_Load(object sender, EventArgs e)
            ////    {
            ////        bool blnRedirected = Error404Handler.StaticHandler.Handle404(HttpContext.Current);
            ////    }
            /// </summary>
            #endregion

            #region Manual 404 Error Logging
            General.ErrorLogging.Data.Error404.RecordError404(AppID: 1, Environment: General.Environment.EnvironmentContext.Live, ClientID: null, URL: "http://www.google2.com", UserAgent: "TestAgent", Detail: "detail");
            #endregion

            #region Get 404 Error Data
            var one404 = General.ErrorLogging.Data.Error404.GetError404(1);
            var lst404s = General.ErrorLogging.Data.Error404.GetError404s(1, General.Environment.EnvironmentContext.Live, DateTime.Today, DateTime.Today);
            lst404s = General.ErrorLogging.Data.Error404.GetError404s(1, "", DateTime.Today, DateTime.Today);
            #endregion



            #region Setup a 404 Redirection
            var mdlRedirect = new General.ErrorLogging.Model.Error404Redirect();
            mdlRedirect.From = "/testredirect/*"; //Wildcard is supported!
            mdlRedirect.To = "/*"; //This will redirect to the root directory of the site, and append the remainder of the requested path.
            mdlRedirect.RedirectType = 301; //301 Permanent or 307 Temporary, or any other HTTP Response code
            mdlRedirect = General.ErrorLogging.Data.Error404Redirect.CreateError404Redirect(mdlRedirect);
            #endregion

            #region Get 404 Redirection Data
            var lstRedirects = General.ErrorLogging.Data.Error404Redirect.GetError404Redirects(1, null);
            foreach (var redir in lstRedirects)
            {
                //System.Web.HttpContext.Current.Response.Write(redir.ToString() + "<br/><br/>");
            }
            #endregion

        }
    }
}
