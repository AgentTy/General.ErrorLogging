<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="aboutTitle" ContentPlaceHolderID="TitleContent" runat="server">
    General.ErrorLogging Demo
</asp:Content>

<asp:Content ID="aboutContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1><a href="../Demo/Index">Demo</a></h1>
    </hgroup>
    <div style="width:100%;background-color:#DDD;min-height:10px;font-size:1.3em;font-style:italic;"><%: ViewBag.Message %></div>
    <article>
        <div>
        <h2>Server side error logging</h2>
        <p>
            General.ErrorLogging can capture all the relevent details of unhandled exceptions inside your managed code and quietly ship them off to a database for storage and review.
        </p>
            <div style="display:inline-block;">
            <form action="../Demo/UnhandledException" method="post">
                <input type="submit" value="Throw Exception" />
            </form>
            </div>
            <div style="display:inline-block;">
            <form action="../Demo/HandledException" method="post">
                <input type="submit" value="Handled Exception" />
            </form>
            </div>
            <code><pre>            try
            {
                throw new Exception("Demo Exception");
            }
            catch(Exception ex)
            {
                ErrorReporter.ReportErrorHighSeverity(ex, ErrorLogging.GetApplicationContext(User));
            }</pre></code>
        </div>

        <div>
        <h2>Javascript Errors</h2>
        <p>
            Unhandled exceptions occurring in the user's browser can also be logged, as well as other trace information.
        </p>
            <input type="button" value="Pause Logging" onclick="ErrorLogger.Pause();" /><input type="button" value="Resume Logging" onclick="    ErrorLogger.Resume();" /><br />
            <br />
            <input type="button" value="Reference Error (inline)" onclick="alert(notavariable.property);" /> 
            <input type="button" value="Type Error (in a .js file)" onclick="GenerateTestError_Type();" /> <input type="button" value="Syntax Error" onclick="    GenerateTestError_Syntax();" /> 
            <input type="button" value="Eval Error" onclick="GenerateTestError_Eval();" /> <input type="button" value="Reference Error" onclick="    GenerateTestError_Reference();" />
        
                    <pre><code>
    &lt;script type="text/javascript">
        $().ready(function () {
            var strErrorAPIEndpoint = 'https://errorserver.mydomain.com/';
            var strAPIAccessCode = 'AccessKey#$sdff';
            var objAppContext = ErrorLogger.AppContextModel(&#60;%:ErrorReporter.AppID %>, '&#60;%:ErrorReporter.DefaultAppNameForErrorLog %>', '&#60;%:General.Environment.Current.WhereAmI() %>');
            ErrorLogger.RegisterApplication(strErrorAPIEndpoint, strAPIAccessCode, objAppContext); //Setup Application Context data
            ErrorLogger.ListenGlobal(); //Start monitoring unhandled exceptions
        });
    &lt;/script>
            </code></pre>
        </div>
        <div>
        <h2>Trace/Warning/Audit logging</h2>
        <p>
            General.ErrorLogging can let's you store non-error related events.
        </p>
            
            <div style="display:inline-block;">
            <form action="../Demo/Trace" method="post">
                <input type="text" name="message" />
                <input type="submit" name="messageType" value="Trace" />
                <input type="submit" name="messageType" value="Warning" />
                <input type="submit" name="messageType" value="Audit" />
            </form>
            </div>
        <pre><code>ErrorReporter.ReportWarning(message);</code></pre>
        </div>
        <div>
        <h2>Email/SMS Notifications</h2>
        <p>
            General.ErrorLogging can notify stakeholders when events are logged. The filter configuration controls these notifications, with each filter having the option to notify by email or sms when an event meets it's criteria.
        </p>
            
            <div style="display:inline-block;">
            <form action="../Demo/PageViaSMS" method="post">
                TO: <input type="text" name="phone" />
                <input type="submit" name="messageType" value="Send Sample Notification" />
            </form>
            </div>
        </div>
    </article>

    <aside>
        <h3>Features</h3>
        <ul>
            <li>Universal Implementation</li>
            <li>Javascript support</li>
            <li>Hosting environment awareness</li>
            <li>Authenticated Web API</li>
            <li>GUI with filtering</li>
            <li>Full text search!</li>
            <li>404 Error redirects</li>
        </ul>
    </aside>
</asp:Content>

