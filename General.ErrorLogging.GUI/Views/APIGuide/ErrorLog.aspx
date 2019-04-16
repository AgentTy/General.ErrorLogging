<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>


<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>

    <script type="text/javascript">
        var HostedURI = '<%: ViewBag.HostedURI %>';

        function AppViewModel() {

            this.AppID = ddnApp.value;
            this.Environment = ddnEnvironment.value;
            this.ClientID = txtClientID.value;
            this.ErrorOtherID = txtErrorOtherID.value;
            this.IncidentCode = txtIncidentCode.value;
            this.SearchString = txtSearch.value;

            this.HostedURI = HostedURI;
            <% if(WebMatrix.WebData.WebSecurity.IsAuthenticated) { %>
            this.WriteOnlyAccessCode = txtAccessCode.value ? txtAccessCode.value : '<%:General.ErrorLogging.GUI.Settings.APIWriteOnlyAccessCode%>';
            <% } else { %> 
            this.WriteOnlyAccessCode = txtAccessCode.value;
            <% } %>

            var date = new Date();
            if(!txtStartDate.value)
                this.StartDate = (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear();
            else
                this.StartDate = txtStartDate.value;

            if(!txtEndDate.value)
                this.EndDate = (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear();
            else
                this.EndDate = txtEndDate.value;
        }

        ko.applyBindings(new AppViewModel());


        function GetErrorData()
        {
            var objEventContext =
                {
            EventType: ddnEventType.value,
            Severity: txtErrorSeverity.value,
            ErrorCode: txtErrorCode.value,
            EventName: txtEventName.value,
            ExceptionType: txtExceptionTypeName.value,
            MethodName: txtMethodName.value,
            FileName: txtErrorFile.value,
            LineNumber: txtErrorLineNumber.value,
            ColumnNumber: txtErrorColumnNumber.value,
            URL: txtEventURL.value,
            UserAgent: navigator.userAgent,
            Details: txtEventDetails.value,
            Duration: txtDuration.value
                }

            var objApplicationContext = 
                {
            ClientID: 'ClientID',
            UserType: 'UserType',
            UserID: 'UserID',
            CustomID: 4,
            Custom1: 'c1',
            Custom2: 'c2', 
            Custom3: 'c3',
            AppID: ddnApp.value,
            AppName: 'Test Application',
            Environment: 'dev',
            MachineName: 'MyComputerName'
                }

            return {
                AccessCode: txtAccessCode.value,
                EventContext: objEventContext,
                AppContext: objApplicationContext
            }
        }
    </script>
</asp:Content>

<asp:Content ID="contactTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Test API Calls - Error Log
</asp:Content>

<asp:Content ID="contactContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1>Error Log - API Test</h1>
        <h2><%: ViewBag.Message %></h2>
    </hgroup>
    <section class="contact">
        <h3>Common Parameters</h3>
        <p>
            Application ID: 
                    <select id="ddnApp" data-bind="value: AppID" onchange="ko.applyBindings(new AppViewModel());">
                        <option value="any">Any Application</option>
                        <option value="0">General Library</option>
                        <option value="1">App ID 1</option>
                        <option value="2">App ID 2</option>
                        <option value="3">App ID 3</option>
                    </select><br />
                    Start Date: <input type="text" id="txtStartDate" data-bind="value: StartDate" onchange="ko.applyBindings(new AppViewModel());" style="margin-right:50px;width:initial;height:19px;" />
                    End Date: <input type="text" id="txtEndDate" data-bind="value: EndDate" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" />
                <br /><br />
        </p>
        <header>
            <h1>SELECT (http get):</h1>
        </header>
            <p>
                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog/Lookup?IC=<span data-bind="    text: IncidentCode"></i><br />
                <input type="button" value="Get One Occurrence by Incident Code (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/Lookup?IC=' + txtIncidentCode.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/Lookup?IC=' + txtIncidentCode.value, 'jsonp');" />
                Incident Code: <input type="text" id="txtIncidentCode" data-bind="value: IncidentCode" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />

                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog/Summary?ID=<span data-bind="    text: ErrorOtherID"></i><br />
                <input type="button" value="Get One Event Summary (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/Summary?ID=' + txtErrorOtherID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/Summary?ID=' + txtErrorOtherID.value, 'jsonp');" />
                ErrorOther.ID: <input type="text" id="txtErrorOtherID" data-bind="value: ErrorOtherID" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />
                <i>ErrorOther (data table) = Event Summary aka Series, an Event Summary can have multiple occurrences (ErrorOtherLog table)</i><br />

                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog/Series?ID=<span data-bind="    text: ErrorOtherID"></i><br />
                <input type="button" value="Get All Occurrences in a Series (by ErrorOther.ID)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/Series?ID=' + txtErrorOtherID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/Series?ID=' + txtErrorOtherID.value, 'jsonp');" />
                <br />

                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog/LookupSeries?IC=<span data-bind="    text: IncidentCode"></i><br />
                <input type="button" value="Get All Occurrences in a Series (by any Incident Code)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/LookupSeries?IC=' + txtIncidentCode.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/LookupSeries?IC=' + txtIncidentCode.value, 'jsonp');" />
                <br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/ErrorLog/Summarized?StartDate=<span data-bind="text:StartDate"></span>&EndDate=<span data-bind="text:EndDate"></span>
                </i><br />
                <input type="button" value="Get Event summaries by Date (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/Summarized?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/Summarized?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value, 'jsonp');" />
                <br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/ErrorLog?StartDate=<span data-bind="    text:StartDate"></span>&EndDate=<span data-bind="    text:EndDate"></span>&Environment=<span data-bind="    text:Environment"></span>
                </i><br />
                <input type="button" value="Get Event summaries by Date and Environment (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/Summarized?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/Summarized?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value, 'jsonp');" />
                <select id="ddnEnvironment" data-bind="value: Environment" onchange="ko.applyBindings(new AppViewModel());">
                        <option value="any">Any Environment</option>
                        <option value="Dev">Dev (1)</option>
                        <option value="QA">QA (2)</option>
                        <option value="Stage">Stage (3)</option>
                        <option value="CustomEnv">CustomEnv (4)</option>
                        <option value="Live">Live (5)</option>
                    </select><br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/ErrorLog/Summarized?StartDate=<span data-bind="    text:StartDate"></span>&EndDate=<span data-bind="    text:EndDate"></span>&ClientID=<span data-bind="    text:ClientID"></span>
                </i><br />
                <input type="button" value="Get Event summaries by Date and ClientID (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/Summarized?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/Summarized?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&ClientID=' + txtClientID.value, 'jsonp');" />
                ClientID: <input type="text" id="txtClientID" data-bind="value: ClientID" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/ErrorLog/Summarized?StartDate=<span data-bind="    text:StartDate"></span>&EndDate=<span data-bind="    text:EndDate"></span>&Environment=<span data-bind="    text:Environment"></span>&ClientID=<span data-bind="    text:ClientID"></span>
                </i><br />
                <input type="button" value="Get Event summaries by Date, Environment, and ClientID (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/Summarized?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/Summarized?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'jsonp');" /><br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog/Expanded?StartDate=<span data-bind="    text: StartDate"></span>&EndDate=<span data-bind="    text: EndDate"></span>&Environment=<span data-bind="    text: Environment"></span>&ClientID=<span data-bind="    text: ClientID"></span>
                </i><br />
                <input type="button" value="Get Event Occurrences (log view) by Date, Environment, and ClientID (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/Expanded?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/Expanded?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'jsonp');" /><br />


                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog/SearchSummarized?search=StartDate=<span data-bind="    text: SearchString"></span>&<span data-bind="    text: StartDate"></span>&EndDate=<span data-bind="    text: EndDate"></span>&Environment=<span data-bind="    text: Environment"></span>&ClientID=<span data-bind="    text: ClientID"></span>
                </i><br />
                <input type="button" value="Text search these Events (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/SearchSummarized?search=' + encodeURI(txtSearch.value) + '&StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/SearchSummarized?search=' + encodeURI(txtSearch.value) + '&StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'jsonp');" />
                <input placeholder="Search Text (use quotes for exact match)" type="text" id="txtSearch" data-bind="value: SearchString" onchange="ko.applyBindings(new AppViewModel());" style="width:325px;height:19px;" /> <br />
            
                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog/SearchExpanded?search=StartDate=<span data-bind="    text: SearchString"></span>&<span data-bind="    text: StartDate"></span>&EndDate=<span data-bind="    text: EndDate"></span>&Environment=<span data-bind="    text: Environment"></span>&ClientID=<span data-bind="    text: ClientID"></span>
                </i><br />
                <input type="button" value="Text search these Occurrences (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/SearchExpanded?search=' + encodeURI(txtSearch.value) + '&StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/SearchExpanded?search=' + encodeURI(txtSearch.value) + '&StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'jsonp');" />

            
            </p>
    </section>

    <section class="contact">
        <header>
            <h1>RECORDEVENT (http post):</h1>
        </header>
        <p>
            <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog/RecordEvent</i><br />
            <span class="label">Use this method log an error via the API. </span><br />
            API AccessCode for Error Logging: <input type="text" id="txtAccessCode" data-bind="value: WriteOnlyAccessCode" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" placeholder="AccessCode" /><br />

            Event Type: <select id="ddnEventType">
                            <option value="1">Server Side Error</option>
                            <option value="2">SQL Error</option>
                            <option value="3">SQL Connectivity</option>
                            <option value="4">SQL Timeout</option>
                            <option value="6">Javascript</option>
                            <option value="10">Warning</option>
                            <option value="11">Audit</option>
                            <option value="12">Trace</option>
                            <option value="13">Auth</option>
                        </select>
            Event Name: <input type="text" id="txtEventName" style="width:initial;height:19px;" />  Exception Type: <input type="text" id="txtExceptionTypeName" style="width:initial;height:19px;" />  Error Code: <input type="text" id="txtErrorCode" style="width:initial;height:19px;" />  Method Name: <input type="text" id="txtMethodName" style="width:initial;height:19px;" /><br />
            File Name: <input type="text" id="txtErrorFile" style="width:initial;height:19px;" />  Line Number: <input type="text" id="txtErrorLineNumber" style="width:initial;height:19px;width:40px;" /> Column Number: <input type="text" id="txtErrorColumnNumber" style="width:initial;height:19px;width:40px;" /><br />
            URL: <input type="text" id="txtEventURL" style="width:initial;height:19px;" /> Severity: <input type="text" id="txtErrorSeverity" value="4" placeholder="Integer Value" style="width:initial;height:19px;" />  Duration (ms): <input type="text" id="txtDuration" value="4" placeholder="Integer Value" style="width:initial;height:19px;" /><br />
            Event Details: <textarea id="txtEventDetails" style="width:initial;height:19px;"></textarea><br />
            <input type="button" value="Record Event" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/RecordEvent/', 'json', 'POST', GetErrorData());" />
        </p>
    </section>
         
    <section class="contact">
        <header>
            <h1>Javascript Error Logging (General.ErrorLogging.js):</h1>
        </header>
        <p>
            <i style="margin-left:75px;">General.ErrorLogging.js</i><br />
            <span class="label">This javascript plugin is a wrapper for logging errors in client side script.</span><br />

            Write Only API AccessCode for Error Logging: <input type="text" id="txtAccessCode2" data-bind="value: WriteOnlyAccessCode" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" placeholder="AccessCode" /><br />
            <input type="button" value="RegisterApplication" onclick="ErrorLogger.RegisterApplication(HostedURI, txtAccessCode.value, GetErrorData().AppContext);" /> <input type="button" value="ListenGlobal" onclick="    ErrorLogger.ListenGlobal();" />
            <input type="button" value="Pause Logging" onclick="ErrorLogger.Pause();" /><input type="button" value="Resume Logging" onclick="    ErrorLogger.Resume();" /><input type="button" value="Show Last Error Name" onclick="    alert(ErrorLogger.LastEvent.EventName);" /><br />
            <br />
            <input type="button" value="Reference Error (inline)" onclick="alert(notavariable.property);" /> 
            <input type="button" value="Type Error (in a .js file)" onclick="GenerateTestError_Type();" /> <input type="button" value="Syntax Error" onclick="GenerateTestError_Syntax();" /> 
            <input type="button" value="Eval Error" onclick="GenerateTestError_Eval();" /> <input type="button" value="Reference Error" onclick="GenerateTestError_Reference();" />
        </p>
    </section>

    <section class="contact">
        <header>
            <h1>INSERT (http post):</h1>
        </header>
        <p>
            <span class="label">Insert is supported, just POST a General.ErrorLogging.Model.ErrorOther JSON model object. 
                While the INSERT method will save to the databse, it bypasses default values and business logic. 
                The RECORDEVENT method is preferred.</span>
            <span></span>
        </p>
    </section>

    <section class="contact">
        <header>
            <h1>UPDATE (http put):</h1>
        </header>
        <p>
            <span class="label">Update is supported, just PUT a General.ErrorLogging.Model.ErrorOther JSON model object.</span>
            <span></span>
        </p>
    </section>

    <section class="contact">
        <header>
            <h1>DELETE Event Summary/Series and its occurrences (http delete):</h1>
        </header>
        <p>
            <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog?ID=<span data-bind="    text: ErrorOtherID"></i><br />
            <input type="button" value="Delete An Event Series (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog?ID=' + txtErrorOtherID2.value, 'json', 'DELETE');" />
            <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog?ID=' + txtErrorOtherID2.value, 'jsonp', 'DELETE');" />
            ErrorOther.ID: <input type="text" id="txtErrorOtherID2" data-bind="value: ErrorOtherID" onchange="txtErrorOtherID.value = txtErrorOtherID2.value;ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />
        </p>
        <header>
            <h1>DELETE a single Occurrence (http delete):</h1>
        </header>
        <p>
            <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/ErrorLog/DeleteOccurrence?IC=<span data-bind="    text: IncidentCode"></i><br />
            <input type="button" value="Delete An Event Occurrence (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/ErrorLog/DeleteOccurrence?IC=' + txtIncidentCode2.value, 'json', 'DELETE');" />
            <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/ErrorLog/DeleteOccurrence?IC=' + txtIncidentCode2.value, 'jsonp', 'DELETE');" />
            Incident Code: <input type="text" id="txtIncidentCode2" data-bind="value: IncidentCode" onchange="txtIncidentCode.value = txtIncidentCode2.value;ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />
        </p>
    </section>

    <div style="height:150px"></div>
    <div id="divTestResult" style="border:2px solid black;margin: 2px; padding:3px;position:fixed;z-index:2;bottom:0px;left:0px;background:white;width:99%;max-height:250px;overflow:scroll;"></div>
</asp:Content>