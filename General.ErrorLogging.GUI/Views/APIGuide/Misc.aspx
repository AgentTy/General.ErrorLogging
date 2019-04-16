<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>


<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>

    <script type="text/javascript">
        var HostedURI = '<%: ViewBag.HostedURI %>';

        function AppViewModel() {
            this.HostedURI = HostedURI;

        }

        ko.applyBindings(new AppViewModel());
    </script>
</asp:Content>

<asp:Content ID="contactTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Test API Calls - Miscellaneous
</asp:Content>

<asp:Content ID="contactContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1>Miscellaneous - API Test</h1>
        <h2><%: ViewBag.Message %></h2>
    </hgroup>
    <section class="contact">
        <header>
            <h1>SELECT (http get):</h1>
        </header>
            <p>
                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/Hello</i><br />
                <input type="button" value="Hello (local json)" onclick="TestAPI('/api/Hello', 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/Hello', 'jsonp');" /><br />
            </p>

            <p>
                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/Application</i><br />
                <input type="button" value="Get Applications (local json)" onclick="TestAPI('/api/Application', 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/Application', 'jsonp');" /><br />
            </p>

            <p>
                <i style="margin-left:75px;"><%: ViewBag.HostedURI %>/api/Application?id=1</i><br />
                <input type="button" value="Get One Application (local json)" onclick="TestAPI('/api/Application?id=1', 'json');" />
                <input type="button" value="(remote jsonp)" onclick="TestAPI(HostedURI + '/api/Application?id=1', 'jsonp');" /><br />
            </p>
 
    <div style="height:150px"></div>
    <div id="divTestResult" style="border:2px solid black;margin: 2px; padding:3px;position:fixed;z-index:2;bottom:0px;left:0px;background:white;width:99%;max-height:250px;overflow:scroll;"></div>
</asp:Content>