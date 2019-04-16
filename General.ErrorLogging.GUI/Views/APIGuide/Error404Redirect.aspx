<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>


<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>

    <script type="text/javascript">
        var HostedURI = '<%: ViewBag.HostedURI %>';

        function AppViewModel() {

            this.AppID = ddnApp.value;
            this.ClientID = txtClientID.value;
            this.Error404RedirectID = txtError404RedirectID.value;
            this.SearchString = txtSearch.value;

            this.HostedURI = HostedURI;
        }

        ko.applyBindings(new AppViewModel());
    </script>
</asp:Content>

<asp:Content ID="contactTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Test API Calls - 404 Redirect
</asp:Content>

<asp:Content ID="contactContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1>404 Redirect - API Test</h1>
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
                    ClientID: <input type="text" id="txtClientID" data-bind="value: ClientID" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" placeholder="optional" /> <br />
                <br />
        </p>
        <header>
            <h1>SELECT (http get):</h1>
        </header>
            <p>
                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/Error404Redirect?ID=<span data-bind="    text: Error404RedirectID"></i><br />
                <input type="button" value="Get One Error404Redirect (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404Redirect?ID=' + txtError404RedirectID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404Redirect?ID=' + txtError404RedirectID.value, 'jsonp');" />
                Error404Redirect.ID: <input type="text" id="txtError404RedirectID" data-bind="value: Error404RedirectID" onchange="ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/Error404Redirect
                </i><br />
                <input type="button" value="Get Redirects by App (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404Redirect', 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404Redirect', 'jsonp');" /><br />
        

                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text:AppID"></span>/Error404Redirect?ClientID=<span data-bind="    text:ClientID"></span>
                </i><br />
                <input type="button" value="Get Redirects by ClientID (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404Redirect?ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404Redirect?ClientID=' + txtClientID.value, 'jsonp');" /><br />
                
                <i style="margin-left:75px;">
                    <%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/Error404Redirect/Search?search=<span data-bind="    text: SearchString"></span>&ClientID=<span data-bind="    text: ClientID"></span>
                </i><br />
                <input type="button" value="Text Search Redirects (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404Redirect/Search?search=' + encodeURI(txtSearch.value) + '&ClientID=' + txtClientID.value, 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404Redirect?search=' + encodeURI(txtSearch.value) + '&ClientID=' + txtClientID.value, 'jsonp');" />
                <input placeholder="Search Text (use quotes for exact match)" type="text" id="txtSearch" data-bind="value: SearchString" onchange="ko.applyBindings(new AppViewModel());" style="width:325px;height:19px;" /> <br />
            </p>
    </section>

    <section class="contact">
        <header>
            <h1>INSERT (http post):</h1>
        </header>
        <p>
            <span class="label">Insert is supported, just POST a General.ErrorLogging.Model.Error404Redirect JSON model object.</span>
            <span></span>
        </p>
    </section>

    <section class="contact">
        <header>
            <h1>UPDATE (http put):</h1>
        </header>
        <p>
            <span class="label">Insert is supported, just PUT a General.ErrorLogging.Model.Error404Redirect JSON model object.</span>
            <span></span>
        </p>
    </section>

    <section class="contact">
        <header>
            <h1>DELETE (http delete):</h1>
        </header>
        <p>
            <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/<span data-bind="text: AppID"></span>/Error404Redirect?ID=<span data-bind="    text: Error404RedirectID"></i><br />
            <input type="button" value="Delete A Redirect (local json)" onclick="TestAPI('/api/' + ddnApp.value + '/Error404Redirect?ID=' + txtError404RedirectID2.value, 'json', 'DELETE');" />
            <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/' + ddnApp.value + '/Error404Redirect?ID=' + txtError404RedirectID2.value, 'jsonp', 'DELETE');" />
            Error404Redirect.ID: <input type="text" id="txtError404RedirectID2" data-bind="value: Error404RedirectID" onchange="txtError404RedirectID.value = txtError404RedirectID2.value;ko.applyBindings(new AppViewModel());" style="width:initial;height:19px;" /> <br />
        </p>
    </section>

    <div style="height:150px"></div>
    <div id="divTestResult" style="border:2px solid black;margin: 2px; padding:3px;position:fixed;z-index:2;bottom:0px;left:0px;background:white;width:99%;max-height:250px;overflow:scroll;"></div>
</asp:Content>