<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>


<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>

    <script type="text/javascript">
        var HostedURI = '<%: ViewBag.HostedURI %>';

        function AppViewModel() {

            this.AppID = ko.observable(ddnApp.value);
            this.ClientID = ko.observable(txtClientID.value);
            this.UserID = ko.observable(txtUserID.value);
            this.Environment = ko.observable(ddnEnvironment.value);
            this.LoggingFilterID = ko.observable(txtFilterID.value);
            this.SearchString = ko.observable(txtSearch.value);
            this.ActiveOnly = ko.observable(chkActiveOnly.checked);

            this.HostedURI = HostedURI;
            this.WriteOnlyAccessCode = ko.observable();
            <% if(WebMatrix.WebData.WebSecurity.IsAuthenticated) { %>
            this.WriteOnlyAccessCode(txtAccessCode.value ? txtAccessCode.value : '<%:General.ErrorLogging.GUI.Settings.APIWriteOnlyAccessCode%>');
            <% } %>
        }

        ko.applyBindings(new AppViewModel());
    </script>

        <script type="text/javascript">
            /*
            $().ready(function () {
                GetData('/api/0/LoggingFilter/ActiveFiltersInContext?ClientID=LAS&UserID=GARRISONG&Environment=dev&AccessCode=XMSdG8G3LC6kEGL8', [], function (data) {

                    console.log(data);

                });
            });
            */
    </script>
</asp:Content>

<asp:Content ID="contactTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Test API Calls - Logging Filters
</asp:Content>

<asp:Content ID="contactContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1>Logging Filters - API Test</h1>
        <h2><%: ViewBag.Message %></h2>
    </hgroup>
    <section class="contact">
        <h3>Common Parameters</h3>
        <p>
                    Application ID: 
                    <select id="ddnApp" data-bind="value: AppID">
                        <option value="0">General Library</option>
                        <option value="1">App ID 1</option>
                        <option value="2">App ID 2</option>
                        <option value="3">App ID 3</option>
                    </select><br />
                    ClientID: <input type="text" id="txtClientID" data-bind="value: ClientID" style="width:initial;height:19px;" placeholder="optional" /> <br />
                    UserID: <input type="text" id="txtUserID" data-bind="value: UserID" style="width:initial;height:19px;" placeholder="optional" /> <br />
                    Environment: 
                    <select id="ddnEnvironment" data-bind="value: Environment">
                        <option value="any">Any Environment</option>
                        <option value="Dev">Dev (1)</option>
                        <option value="QA">QA (2)</option>
                        <option value="Stage">Stage (3)</option>
                        <option value="CustomEnv">CustomEnv (4)</option>
                        <option value="Live">Live (5)</option>
                    </select><br />
                <br />
        </p>
        <header>
            <h1>ActiveFiltersInContext (http get):</h1>
        </header>
            <p>
                This method accepts the API WriteOnlyAccessCode in lieu of authorized credentials. This is here for General.ErrorLogging.js to access filters, it will return the relevant filter settings without exposing ClientID's or UserID's and other sensitive data.
                API AccessCode for Error Logging: <input type="text" id="txtAccessCode" data-bind="value: WriteOnlyAccessCode" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" placeholder="AccessCode" /><br />
                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/LoggingFilter/ActiveFiltersInContext?ClientID=<span data-bind="    text: ClientID"></span>&UserID=<span data-bind="    text: UserID"></span>&Environment=<span data-bind="    text: Environment"></span>&AccessCode=<span data-bind="    text: WriteOnlyAccessCode"></span></i><br />
                <input type="button" value="Get My Active Filters (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/LoggingFilter/ActiveFiltersInContext?ClientID=' + txtClientID.value + '&UserID=' + txtUserID.value + '&Environment=' + ddnEnvironment.value + '&AccessCode=' + txtAccessCode.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/LoggingFilter/ActiveFiltersInContext?ClientID=' + txtClientID.value + '&UserID=' + txtUserID.value + '&Environment=' + ddnEnvironment.value + '&AccessCode=' + txtAccessCode.value, 'jsonp');" />
            </p>

        <header>
            <h1>SELECT (http get):</h1>
        </header>
            <p>
                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/LoggingFilter?ClientID=<span data-bind="    text: ClientID"></span>&UserID=<span data-bind="    text: UserID"></span>&Environment=<span data-bind="    text: Environment"></span>&ActiveOnly=<span data-bind="    text: ActiveOnly"></span></i><br />
                <input type="button" value="Get Filters (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/LoggingFilter?ClientID=' + txtClientID.value + '&UserID=' + txtUserID.value + '&Environment=' + ddnEnvironment.value + '&ActiveOnly=' + chkActiveOnly.checked, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/LoggingFilter?ClientID=' + txtClientID.value + '&UserID=' + txtUserID.value + '&Environment=' + ddnEnvironment.value + '&ActiveOnly=' + chkActiveOnly.checked, 'jsonp');" />
                Active Only: <input type="checkbox" id="chkActiveOnly" data-bind="checked: ActiveOnly" />
                <br />

                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/LoggingFilter?ID=<span data-bind="    text: LoggingFilterID"></i><br />
                <input type="button" value="Get One LoggingFilter (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/LoggingFilter?ID=' + txtFilterID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/LoggingFilter?ID=' + txtFilterID.value, 'jsonp');" />
                LoggingFilter.ID: <input type="text" id="txtFilterID" data-bind="value: LoggingFilterID" style="width:initial;height:19px;" /> <br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/LoggingFilter/Search?search=<span data-bind="    text: SearchString"></span>&ClientID=<span data-bind="    text: ClientID"></span>&UserID=<span data-bind="    text: UserID"></span>&Environment=<span data-bind="    text: Environment"></span>&ActiveOnly=<span data-bind="    text: ActiveOnly"></span>
                </i><br />
                <input type="button" value="Text Search Filters (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/LoggingFilter/Search?search=' + encodeURI(txtSearch.value) + '&ClientID=' + txtClientID.value + '&UserID=' + txtUserID.value + '&Environment=' + ddnEnvironment.value + '&ActiveOnly=' + chkActiveOnly.checked, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/LoggingFilter?search=' + encodeURI(txtSearch.value) + '&ClientID=' + txtClientID.value + '&UserID=' + txtUserID.value + '&Environment=' + ddnEnvironment.value + '&ActiveOnly=' + chkActiveOnly.checked, 'jsonp');" />
                <input placeholder="Search Text (use quotes for exact match)" type="text" id="txtSearch" data-bind="value: SearchString" style="width:325px;height:19px;" /> <br />
            </p>
    </section>

    <section class="contact">
        <header>
            <h1>INSERT (http post):</h1>
        </header>
        <p>
            <span class="label">Insert is supported, just POST a General.ErrorLogging.Model.LoggingFilter JSON model object.</span>
            <span></span>
        </p>
    </section>

    <section class="contact">
        <header>
            <h1>UPDATE (http put):</h1>
        </header>
        <p>
            <span class="label">Insert is supported, just PUT a General.ErrorLogging.Model.LoggingFilter JSON model object.</span>
            <span></span>
        </p>
    </section>

    <section class="contact">
        <header>
            <h1>DELETE (http delete):</h1>
        </header>
        <p>
            <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/LoggingFilter?ID=<span data-bind="    text: LoggingFilterID"></span></i><br />
            <input type="button" value="Delete A Filter (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/LoggingFilter?ID=' + txtFilterID2.value, 'json', 'DELETE');" />
            <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/LoggingFilter?ID=' + txtFilterID2.value, 'jsonp', 'DELETE');" />
            LoggingFilter.ID: <input type="text" id="txtFilterID2" data-bind="value: LoggingFilterID" style="width:initial;height:19px;" /> <br />
        </p>
    </section>

    <div style="height:150px"></div>
    <div id="divTestResult" style="border:2px solid black;margin: 2px; padding:3px;position:fixed;z-index:2;bottom:0px;left:0px;background:white;width:99%;max-height:250px;overflow:scroll;"></div>
</asp:Content>