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
            this.Error404ID = txtError404ID.value;
            this.SearchString = txtSearch.value;

            this.HostedURI = HostedURI;

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
    </script>
</asp:Content>

<asp:Content ID="contactTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Test API Calls - Error Log
</asp:Content>

<asp:Content ID="contactContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1>404 Log - API Test</h1>
        <h2><%: ViewBag.Message %></h2>
    </hgroup>
    <section class="contact">
        <h3>Common Parameters</h3>
        <p>
            Application ID: 
                    <select id="ddnApp" data-bind="value: AppID" onchange="ko.applyBindings(new AppViewModel());">
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
                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/Error404?ID=<span data-bind="    text: Error404ID"></i><br />
                <input type="button" value="Get One 404 Log (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404?ID=' + txtError404ID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404?ID=' + txtError404ID.value, 'jsonp');" />
                Error404.ID: <input type="text" id="txtError404ID" data-bind="value: Error404ID" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/Error404/Normal?StartDate=<span data-bind="text:StartDate"></span>&EndDate=<span data-bind="text:EndDate"></span>
                </i><br />
                <input type="button" value="Get 404s by Date (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404/Normal?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404/Normal?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value, 'jsonp');" /><br />
        
                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/Error404/Normal?StartDate=<span data-bind="    text:StartDate"></span>&EndDate=<span data-bind="    text:EndDate"></span>&Environment=<span data-bind="    text:Environment"></span>
                </i><br />
                <input type="button" value="Get 404s by Date and Environment (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404/Normal?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404/Normal?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value, 'jsonp');" />
                <select id="ddnEnvironment" data-bind="value: Environment" onchange="ko.applyBindings(new AppViewModel());">
                        <option value="any">Any Environment</option>
                        <option value="Dev">Dev (1)</option>
                        <option value="QA">QA (2)</option>
                        <option value="Stage">Stage (3)</option>
                        <option value="CustomEnv">CustomEnv (4)</option>
                        <option value="Live">Live (5)</option>
                    </select><br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/Error404/Normal?StartDate=<span data-bind="    text:StartDate"></span>&EndDate=<span data-bind="    text:EndDate"></span>&ClientID=<span data-bind="    text:ClientID"></span>
                </i><br />
                <input type="button" value="Get 404s by Date and ClientID (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404/Normal?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404/Normal?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&ClientID=' + txtClientID.value, 'jsonp');" />
                ClientID: <input type="text" id="txtClientID" data-bind="value: ClientID" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/Error404/Normal?StartDate=<span data-bind="    text:StartDate"></span>&EndDate=<span data-bind="    text:EndDate"></span>&Environment=<span data-bind="    text:Environment"></span>&ClientID=<span data-bind="    text:ClientID"></span>
                </i><br />
                <input type="button" value="Get 404s by Date, Environment, and ClientID (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404/Normal?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404/Normal?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'jsonp');" /><br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/Error404/Common?StartDate=<span data-bind="    text: StartDate"></span>&EndDate=<span data-bind="    text: EndDate"></span>&Environment=<span data-bind="    text: Environment"></span>&ClientID=<span data-bind="    text: ClientID"></span>
                </i><br />
                <input type="button" value="Get Common (5+) 404s by Date, Environment, and ClientID (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404/Common?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404/Common?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'jsonp');" /><br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/Error404/IncludeSuppressed?StartDate=<span data-bind="    text: StartDate"></span>&EndDate=<span data-bind="    text: EndDate"></span>&Environment=<span data-bind="    text: Environment"></span>&ClientID=<span data-bind="    text: ClientID"></span>
                </i><br />
                <input type="button" value="Get All (including suppressed) 404s by Date, Environment, and ClientID (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404/IncludeSuppressed?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404/IncludeSuppressed?StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'jsonp');" /><br />


                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/Error404/Search?search=StartDate=<span data-bind="    text: SearchString"></span>&<span data-bind="    text: StartDate"></span>&EndDate=<span data-bind="    text: EndDate"></span>&Environment=<span data-bind="    text: Environment"></span>&ClientID=<span data-bind="    text: ClientID"></span>
                </i><br />
                <input type="button" value="Text search these filtered 404s (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404/Search?search=' + encodeURI(txtSearch.value) + '&StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404/Search?search=' + encodeURI(txtSearch.value) + '&StartDate=' + txtStartDate.value + '&EndDate=' + txtEndDate.value + '&Environment=' + ddnEnvironment.value + '&ClientID=' + txtClientID.value, 'jsonp');" />
                <input placeholder="Search Text (use quotes for exact match)" type="text" id="txtSearch" data-bind="value: SearchString" onchange="ko.applyBindings(new AppViewModel());" style="width:325px;height:19px;" /> <br />
            </p>
    </section>

    <section class="contact">
        <header>
            <h1>INSERT (http post):</h1>
        </header>
        <p>
            <span class="label">Insert is supported, just POST a General.ErrorLogging.Model.Error404 JSON model object.</span>
            <span></span>
        </p>
    </section>

    <section class="contact">
        <header>
            <h1>UPDATE (http put):</h1>
        </header>
        <p>
            <span class="label">Update is supported, just PUT a General.ErrorLogging.Model.Error404 JSON model object.</span>
            <span></span>
        </p>
    </section>

    <section class="contact">
        <header>
            <h1>DELETE (http delete):</h1>
        </header>
        <p>
            <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/Error404?ID=<span data-bind="    text: Error404ID"></i><br />
            <input type="button" value="Delete a 404 log (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404?ID=' + txtError404ID2.value, 'json', 'DELETE');" />
            <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404?ID=' + txtError404ID2.value, 'jsonp', 'DELETE');" />
            Error404.ID: <input type="text" id="txtError404ID2" data-bind="value: Error404ID" onchange="txtError404ID.value = txtError404ID2.value;ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />
        </p>
    </section>

    <div style="height:150px"></div>
    <div id="divTestResult" style="border:2px solid black;margin: 2px; padding:3px;position:fixed;z-index:2;bottom:0px;left:0px;background:white;width:99%;max-height:250px;overflow:scroll;"></div>
</asp:Content>