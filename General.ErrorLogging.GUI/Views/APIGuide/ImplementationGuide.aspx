<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>


<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">

</asp:Content>

<asp:Content ID="contactTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Implementation Guide
</asp:Content>

<asp:Content ID="contactContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1>Implementation Guide</h1>
        <h2><%: ViewBag.Message %></h2>
    </hgroup>
    <section class="guide">
        <header>
            <h2>How to start logging errors in your application...</h2>
            <i>For expanded code samples, see ReadMe.cs in the General.ErrorLogging class library.</i>
            <p>
                The General.ErrorLogging library is designed to help track bugs in an application. 
                It is able to store verbose error information from Managed Code and/or Javascript into a SQL database, including Code File + Line/Column Number, Stack Trace, User context, Environment context, and more. 
                It is also able to log 404 errors in a separate SQL Table, and store preferred 301 permanent redirections at the admin's discretion.
            </p>
        </header>
        <section>
            <h3>Web.config / App.config</h3>
            <p>
                In order for the General.ErrorLogging Library to function, some keys need to be added to the config file that setup the General library and the Logging preferences
                The Connection String and the first two Keys are REQUIRED! That is AppIDForErrorLogging, and DefaultAppNameForErrorLog.
                The remaining keys setup email capibilities and recipients, that is for an edge case where an error CANNOT be logged to the database, it will try to email it instead.
            </p>
            <pre><h4>Add Connection String</h4><code>
        &lt;connectionStrings>
            &lt;add name="ErrorLog" connectionString="My Connection String For Error Database" providerName="System.Data.SqlClient" />
        &lt;/connectionStrings>
            </code></pre>

            <pre><a style="float:right;" href="Misc">click here to see registered App ID's</a><h4 style="clear:both;">Required config keys (You can pick the AppID, just make sure it's unique)</h4><code>
                &lt;add key="AppIDForErrorLogging" value="1"/>
                &lt;add key="DefaultAppNameForErrorLog" value="Name"/>
                &lt;!-- The next three are only required for Javascript error logging -->
                &lt;add key="ErrorAPIEndpoint" value="https://errorlogger.mydomain.com" />
                &lt;add key="ErrorAPIEndpoint_Dev" value="http://localhost:9999" /> &lt;!-- Any key can be given an _Dev,_QA,_Stage,_Live suffix. This will use General.Environment.Current to choose the right setting. -->
                &lt;add key="ErrorAPIWriteOnlyAccessCode" value="AccessCode" />
            </code></pre>

            <pre><h4>Required for Environment awareness (General.Environment.Current.AmIDev(), AmIQA(), AmIStage(), and AmILive())</h4><code>
                &lt;add key="ServerNameList_Dev" value="COMPUTER1,COMPUTER2"/>
                &lt;add key="ServerNameList_Staging" value="COMPUTER3"/>
            </code></pre>

            <pre><h4>Required for email backup (email the error if logging fails)</h4><code>
                &lt;add key="DebugEmailFrom" value="from@email.com"/>
                &lt;add key="DebugEmailTo" value="to@email.com"/>
                &lt;add key="ErrorEmailFrom" value="from@email.com"/>
                &lt;add key="ErrorEmailTo" value="to@email.com"/>

                &lt;add key="MailServerLive" value="smtp.myserver.com"/>
                &lt;add key="MailServerLive_Port" value="25"/>
                &lt;add key="MailServerLive_UserName" value=""/>
                &lt;add key="MailServerLive_Password" value=""/>
            </code></pre>
        </section>
        <section>
            <h3>A Requirement for 404 Redirect logging</h3>
            <p>
                I need to add some traps in Global.asax to make sure that the database gets updated with the number of times a redirect has been used.
                The work of saving those stats is queued and batch updated... so if you never call SavePageRedirects() you will probably never know if the redirections have been used.
            </p>
            <pre><code>
        public static void Application_End(object sender, EventArgs e)
        {
            // Code that runs on application shutdown
            try {
                if (Error404Handler.StaticHandler != null)
                    Error404Handler.StaticHandler.SavePageRedirects();
            } catch {}
        }

        public static void Session_End(object sender, EventArgs e)
        {
            // Code that runs when a new session ends
            try {
                if (System.Web.HttpContext.Current != null)
                {
                    if (Error404Handler.StaticHandler != null)
                        Error404Handler.StaticHandler.SavePageRedirects();
                }
            } catch {}
        }
            </code></pre>
        </section>
        <section>
            <h3>Automatic error logging via Global.asax (option 1, quick and easy, best for MVC)</h3>
            <p>
                The following Try/Catch block should be added to your Global.asax file.<br />
                This implementation will capture all errors, and in MVC it will catch all 404 errors as long as you have the following in your Web.config under system.webServer.
                <pre><code>
       &lt;modules runAllManagedModulesForAllRequests="true">
       &lt;/modules>
                </code></pre>
            </p>
            <p>
                In classic ASP.Net however, it only captures 404 errors when they are .Net server side files like ASPX, CSHTML, ASMX, etc. It won't capture images, or plain HTML files.
            </p>
            <pre><code>
       void Application_Error(object sender, EventArgs e) {
            try
            {
                ApplicationContext context;
                if (HttpContext.Current.Session != null)
                {
                    //Populate the report context with my session variables, ClientID, UserID, etc...
                    //ClientID (optional) is intended to identify which Client/Organization/Group of users is in context
                    //UserType (optional) can be used to differentiate different kinds of users, or different Unique Key pools so that UserType + UserID becomes a Unique key
                    //UserID (optional) is your systems Unique ID for the current user
                    context = new ApplicationContext(strClientID: "Organization ID/Name", strUserType: "UserType", strUserID: "UserID");

                    context.CustomID = null; //Any additional integer you want to store
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
                try
                {
                    if (ex is HttpException)
                        if (((HttpException)ex).GetHttpCode() == 404)
                        {
                            //Here I can handle a 404 Error with redirects, using Error404Handner.StaticHandler or a managed pool of handlers for different ClientID's.
                            //Server.ClearError(); may be required for redirection to work, depending...
                            bool blnRedirected = Error404Handler.StaticHandler.Handle404(HttpContext.Current);
                            return; //Don't continue to process like a normal error
                        }
                }
                catch (Exception ex404)
                {
                    ErrorReporter.ReportError(ex404, context);
                }
                //if (General.Environment.Current.AmILive()) //I can optionally put a condition here to only record the error in specific environments using the General.Environment library.
                ErrorReporter.ReportError(ex, context);

            }
            catch { }
       }
            </code></pre>
        </section>
        <section>
            <h3>Automatic error logging for Classic ASP.Net with separate 404 handler (option 2, all inclusive)</h3>
            <p>
                The following Try/Catch block should be added to your Global.asax file.<br />
                This implementation will capture all errors and ignore any 404 errors at the Application Level. We will get the 404's next.
            </p>
            <pre><code>
       void Application_Error(object sender, EventArgs e) {
            try
            {
                ApplicationContext context;
                if (HttpContext.Current.Session != null)
                {
                    //Populate the report context with my session variables, ClientID, UserID, etc...
                    //ClientID (optional) is intended to identify which Client/Organization/Group of users is in context
                    //UserType (optional) can be used to differentiate different kinds of users, or different Unique Key pools so that UserType + UserID becomes a Unique key
                    //UserID (optional) is your systems Unique ID for the current user
                    context = new ApplicationContext(strClientID: "Organization ID/Name", strUserType: "UserType", strUserID: "UserID");

                    context.CustomID = null; //Any additional integer you want to store
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
                try
                {
                    if (ex is HttpException)
                        if (((HttpException)ex).GetHttpCode() == 404)
                        {
                            return; //Don't process like a normal error
                        }
                }
                catch { }

                //if (General.Environment.Current.AmILive()) //I can optionally put a condition here to only record the error in specific environments using the General.Environment library.
                ErrorReporter.ReportError(ex, context);
            }
            catch { }
        }
            </code></pre>
            <p>
                Now, to capture all 404 errors, including static files. We'll need to do a little more to the Web.config file. In order to catch 404 errors for ALL FILE TYPES you need two different 404 handling registrations.
            </p>
            <pre><code>
            &lt;customErrors mode="On" defaultRedirect="Error.aspx" redirectMode="ResponseRewrite">
                &lt;error statusCode="404" redirect="~/404.aspx" />
            &lt;/customErrors>
            </code></pre>

            <pre><code>
            &lt;system.webServer>
               &lt;httpErrors errorMode="Custom">
                 &lt;remove statusCode="404" subStatusCode="-1" />
                 &lt;error statusCode="404" prefixLanguageFilePath="" path="/404.aspx" responseMode="ExecuteURL" />
               &lt;/httpErrors>
            &lt;/system.webServer>
            </code></pre>
            <p>
            Now, create your 404.aspx page, and add this to it
            </p>
            <pre><code>
               protected void Page_Load(object sender, EventArgs e)
               {
                   bool blnRedirected = Error404Handler.StaticHandler.Handle404(HttpContext.Current);
               }
            </code></pre>
        </section>
        <section>
            <h3>Custom Error Logging (without an Exception object)</h3>
            <p>
                You can record handled errors or informational events without an Exception object by using the EventContext class.
            </p>
            <pre><code>
            EventContext exInfo = new EventContext("Error Name", "Exception Type Name", "Details / Stack Trace", "CodeFile.cs", "/home/test");
            exInfo.Severity = 10;
            exInfo.ErrorCode = "501";
            exInfo.EventType = Model.ErrorOtherTypes.Server;
            exInfo.MethodName = "MethodName";
            exInfo.LineNumber = 124;

            ApplicationContext context = new ApplicationContext(strClientID: "Organization ID/Name", strUserType: "UserType", strUserID: "UserID");
            //Fill in application context here
            ErrorReporter.ReportError(exInfo, context);
            </code></pre>
        </section>
        <section>
            <h3>Custom Logging Shortcuts</h3>
            <p>
                You can quickly log Errors, Warnings, Traces and  Audits like this. Each paid of lines shows the quickest way, just passing a name for the event... and different forms of simple customization. 
                Remember, the ApplicationContext object is how the system knows your authenticated user context and client context. It reccommmended that always include this object when that information is available.
            </p>
            <pre><code>
            var context = new ApplicationContext(strClientID: "Organization ID/Name", strUserType: "UserType", strUserID: "UserID");

            ErrorReporter.ReportError("Error 1", context, intSeverity: 8);
            ErrorReporter.ReportError("Error 2");

            ErrorReporter.ReportAudit("Audit 1", context, strDetails: "This is what happened in detail");
            ErrorReporter.ReportAudit("Audit 2");

            ErrorReporter.ReportTrace("Trace 1", context, strDetails: "Details", strMethodName: System.Reflection.MethodBase.GetCurrentMethod().Name);
            ErrorReporter.ReportTrace("Trace 2");

            ErrorReporter.ReportWarning("Warning 1", context, strDetails: "A file couldn't be loaded, restoring from cache", strFileName: "File.jpg");
            ErrorReporter.ReportWarning("Warning 2");
            </code></pre>
        </section>
        <section>
            <h3>Manually Logging Javascript Events</h3>
            <p>
                You can record errors and events in Javascript by making an API call to the ErrorLogger service via the General.ErrorLogging.js plugin.<br />
                <i>/api/[AppID]/ErrorLog/RecordEvent</i><br />
                <i style="margin-left:10px;">requires General.ErrorLogging.js and jQuery</i>
            </p>
            This code runs once per page load, it sets up the ErrorLogger. Here is where you can modify the Application Context to store ClientID/UserID/Custom Fields
            <pre><code>
    &lt;script type="text/javascript">
        $().ready(function () {
            var strErrorAPIEndpoint = '&#60;%: ErrorReporter.ErrorAPIEndpoint %>';
            var strAPIAccessCode = '&#60;%:ErrorReporter.ErrorAPIWriteOnlyAccessCode %>';
            var objAppContext = ErrorLogger.AppContextModel(&#60;%:ErrorReporter.AppID %>, '&#60;%:ErrorReporter.DefaultAppNameForErrorLog %>', '&#60;%:General.Environment.Current.WhereAmI() %>');
            //objAppContext.ClientID = 'Client Name/ ID';
            //objAppContext.UserID = 'User Name / ID';
            //objAppContext.UserType = 'User Type';
            ErrorLogger.RegisterApplication(strErrorAPIEndpoint, strAPIAccessCode, objAppContext); //Setup Application Context data

            //After the logger has been registered, you can modify the AppContext like this...
            //ErrorLogger.AppContext.UserID = 555;
        });
    &lt;/script>
            </code></pre>
        Then you can store an error any time like this...
            <pre><code>
        var objErrorContext = ErrorLogger.EventContextModel('My Error Name', ErrorLogger.EventTypes.Javascript, 5); //Severity (Integer (optional))
        objErrorContext.ErrorCode = 100; //Integer (optional)
        objErrorContext.ExceptionType = 'SomeExceptionObject'; //String (optional)
        objErrorContext.FileName = 'File.js'; //String (optional)
        objErrorContext.Details = 'Full details of error.';
        ErrorLogger.ReportEvent(objErrorContext); //Store the event if it matches current filters
        // OR
        ErrorLogger.StoreEvent(objErrorContext); //Store the event regardless of filters
            </code></pre>
            You can also store errors inside a try/catch block like this...
            <pre><code>
        try
        {
            var s = NotAVariable.Property;
        }
        catch(jsError)
        {
            var objErrorContext = ErrorLogger.ReadError(jsError);
            //Modify properties here if needed
            ErrorLogger.ReportEvent(objErrorContext);
        }
            </code></pre>
        </section>
        <section>
            <h3>Automatically Logging Unhandled Javascript Errors (ASP.Net MVC Razor)</h3>
            <p>
                You can record unhandled errors in Javascript by making an API call to the ErrorLogger service via the General.ErrorLogging.js plugin.<br />
                <i>/api/[AppID]/ErrorLog/RecordEvent</i><br />
                <i style="margin-left:10px;">requires General.ErrorLogging.js and jQuery</i>
            </p>
            <pre><code>
    &lt;script src="https://cdn.mynetwork.com/General.ErrorLogging.js">&lt;/script>
    &lt;script type="text/javascript">
        //Prepare Application Context Data
        var objAppContext = ErrorLogger.AppContextModel(@ErrorReporter.AppID, '@ErrorReporter.DefaultAppNameForErrorLog', '@General.Environment.Current.WhereAmI()');
        objAppContext.UserID = '@Request.GetOwinContext().Authentication.User.Identity.Name';
        //Enable Event Logging
        ErrorLogger.RegisterApplication('@ErrorReporter.ErrorAPIEndpoint', '@ErrorReporter.ErrorAPIWriteOnlyAccessCode', objAppContext);
        //Start monitoring unhandled exceptions
        ErrorLogger.ListenGlobal(function(event) {
            //event is an instance of EventContextModel with all it's properties
            if(event.SavedToDatabase && typeof console !== 'undefined')
                console.log('An error occurred in this application, you can use incident code ' + event.IncidentCode + ' when contacting support');
        });
    &lt;/script>
            </code></pre>
        </section>
        <section>
            <h3>Automatically Logging Unhandled Javascript Errors (ASP.Net Web Forms)</h3>
            <p>
                You can record unhandled errors in Javascript by making an API call to the ErrorLogger service via the General.ErrorLogging.js plugin.<br />
                <i>/api/[AppID]/ErrorLog/RecordEvent</i><br />
                <i style="margin-left:10px;">requires General.ErrorLogging.js and jQuery</i>
            </p>
            <pre><code>
    &lt;script src="https://cdn.mynetwork.com/General.ErrorLogging.js">&lt;/script>
    &lt;script type="text/javascript">
        var strErrorAPIEndpoint = '&#60;%: ErrorReporter.ErrorAPIEndpoint %>';
        var strAPIAccessCode = '&#60;%:ErrorReporter.ErrorAPIWriteOnlyAccessCode %>';
        var objAppContext = ErrorLogger.AppContextModel(&#60;%:ErrorReporter.AppID %>, '&#60;%:ErrorReporter.DefaultAppNameForErrorLog %>', '&#60;%:General.Environment.Current.WhereAmI() %>');
        ErrorLogger.RegisterApplication(strErrorAPIEndpoint, strAPIAccessCode, objAppContext); //Setup Application Context data
        //Start monitoring unhandled exceptions
        ErrorLogger.ListenGlobal(function(event) {
            //event is an instance of EventContextModel with all it's properties
            if(event.SavedToDatabase && typeof console !== 'undefined')
                console.log('An error occurred in this application, you can use incident code ' + event.IncidentCode + ' when contacting support');
        }); 
        //ErrorLogger.Pause(); //Pause error logging
        //ErrorLogger.Resume(); //Resume error logging
    &lt;/script>
            </code></pre>
        </section>
        <section>
            <h3>Safe loading the Error Logger from a low-availability host.</h3>
            <p>Loading the javascript logger from a single source can make deployment of updates easy, 
                but if you use a traditional script tag you run the risk of slowing down your web site while it waits for General.ErrorLogging.js to load. 
                The best option is to host the file on a highly available CDN, but if that's not an option keep reading...
                Here is a way to load the script after the page loads, so it will have no affect on the user experience. 
                If you use this option you should place this script early in the page, even still it's likely that $.ready() will fire before the logger is activated, which means that log-worthy events could be missed.
            </p>
            <pre><code>
&lt;script type="text/javascript">
    (function (d, id, url, loaded) {
        var js, fjs = d.getElementsByTagName('script')[0];
        if (d.getElementById(id)) return;
        js = d.createElement('script'); js.id = id;
        js.src = url;
        fjs.parentNode.insertBefore(js, fjs);
        if (js.readyState){ 
            js.onreadystatechange = function(){ if (js.readyState == 'loaded' || js.readyState == 'complete'){ js.onreadystatechange = null; if(loaded) loaded(); } };
        } else {
            js.onload = function(){if(loaded)loaded();};
        }
    }(document, 'ErrorLogger', 'https://my.cdn.com/Scripts/General.ErrorLogging.js', function() {
            //Initialize the Error Reporter here
            var strErrorAPIEndpoint = '&#60;%: ErrorReporter.ErrorAPIEndpoint %>';
            var strAPIAccessCode = '&#60;%:ErrorReporter.ErrorAPIWriteOnlyAccessCode %>';
            var objAppContext = ErrorLogger.AppContextModel(&#60;%:ErrorReporter.AppID %>, '&#60;%:ErrorReporter.DefaultAppNameForErrorLog %>', '&#60;%:General.Environment.Current.WhereAmI() %>');
            ErrorLogger.RegisterApplication(strErrorAPIEndpoint, strAPIAccessCode, objAppContext); //Setup Application Context data
            //Start monitoring unhandled exceptions
            ErrorLogger.ListenGlobal(function(event) {
                //event is an instance of EventContextModel with all it's properties
                if(event.SavedToDatabase && typeof console !== 'undefined')
                    console.log('An error occurred in this application, you can use incident code ' + event.IncidentCode + ' when contacting support');
            }); 
    }));
&lt;/script>
            </code></pre>
            <p>Here is a compressed version.</p>
            <pre><code>
    &lt;script type="text/javascript">
        (function(e,t,r,n){var a,o=e.getElementsByTagName('script')[0];e.getElementById(t)||(a=e.createElement('script'),a.id=t,a.src=r,o.parentNode.insertBefore(a,o),a.readyState?a.onreadystatechange=function(){('loaded'==a.readyState||'complete'==a.readyState)&&(a.onreadystatechange=null,n&&n())}:a.onload=function(){n&&n()})}
        (document,'ErrorLogger','https://my.cdn.com/Scripts/General.ErrorLogging.js',function(){
            //Initialize the Error Reporter here
            var strErrorAPIEndpoint = '&#60;%: ErrorReporter.ErrorAPIEndpoint %>';
            var strAPIAccessCode = '&#60;%:ErrorReporter.ErrorAPIWriteOnlyAccessCode %>';
            var objAppContext = ErrorLogger.AppContextModel(&#60;%:ErrorReporter.AppID %>, '&#60;%:ErrorReporter.DefaultAppNameForErrorLog %>', '&#60;%:General.Environment.Current.WhereAmI() %>');
            ErrorLogger.RegisterApplication(strErrorAPIEndpoint, strAPIAccessCode, objAppContext); //Setup Application Context data
            //Start monitoring unhandled exceptions
            ErrorLogger.ListenGlobal(function(event) {
                //event is an instance of EventContextModel with all it's properties
                if(event.SavedToDatabase && typeof console !== 'undefined')
                    console.log('An error occurred in this application, you can use incident code ' + event.IncidentCode + ' when contacting support');
            }); 
        }));
    &lt;/script>
            </code></pre>
        </section>
        <section>
            <h3>IE6 Compatibility</h3>
            <p>This library will work with IE6 as long as you include the JSON3 library in your site.</p>
            <pre><code>&lt;script src="http://cdnjs.cloudflare.com/ajax/libs/json3/3.3.2/json3.min.js">&lt;/script></code></pre>
        </section>
              
    </section> 
</asp:Content>