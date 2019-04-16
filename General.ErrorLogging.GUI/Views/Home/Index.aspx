<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="aboutTitle" ContentPlaceHolderID="TitleContent" runat="server">
    General.ErrorLogging Interface
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>
</asp:Content>

<asp:Content ID="aboutContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1>What am I?</h1>
        <h2><%: ViewBag.Message %></h2>
    </hgroup>

    <article>
        <p>
            This GUI will allow you to <%: Html.ActionLink("browse", "ErrorLog", "Home") %> and manage the General.ErrorLogging database. It includes the ability to view Application Errors, Trace Logs, 404 Errors and more. 
            These events can be collected inside your .Net application by adding a reference to General.ErrorLogging, or in client browsers by referencing General.ErrorLogging.js, and configuring per the <%: Html.ActionLink("Implementation Guide", "ImplementationGuide", "APIGuide") %>.
        </p>
        <p>
            By default, all errors/events triggered in your application will be stored here. You can use  <%: Html.ActionLink("Filters", "Manage", "Filter") %> to limit the type of events stored at any time, and to set up notifications via SMS or Email for specific errors, even for a single user.
        </p>
        <p>
            It can also be used to setup HTTP <%: Html.ActionLink("Redirects", "Error404Redirect", "Home") %> for common <%: Html.ActionLink("404 errors", "Error404", "Home") %> on your ASP.Net web application.
        </p>

        <p>
            All the functionality of this site is exercised via a JSON API, which can be explored and tested in the <%: Html.ActionLink("API Guide", "Index", "APIGuide") %>.
        </p>
    </article>

    <aside>
        <div id="LookupForm" style="margin-bottom:5px;">
            <input id="txtIC" type="text" name="IC" placeholder="Incident Code" onkeypress="if(ListenForEnterKey(event)) { window.location = '<%=General.ErrorLogging.GUI.Settings.HostedURI %>/Lookup?IC=' + txtIC.value; }" />
            <input type="submit" value="Lookup" onclick="window.location = '<%=General.ErrorLogging.GUI.Settings.HostedURI %>/Lookup?IC=' + txtIC.value;" />
        </div>

        <h3>Links</h3>
        <p>
            What do you want to do?
        </p>
        <ul>
            <li><%: Html.ActionLink("Home", "Index", "Home") %></li>
            <li><%: Html.ActionLink("Event Log", "ErrorLog", "Home") %></li>
            <li><%: Html.ActionLink("Incident Lookup", "", "Lookup") %></li>
            <li><%: Html.ActionLink("404 Error Log", "Error404", "Home") %></li>
            <li style="background:none;"> Management Pages
                <ul>
                    <li><%: Html.ActionLink("Filter Manager", "Manage", "Filter") %></li>
                    <li><%: Html.ActionLink("404 Redirection", "Error404Redirect", "Home") %></li>
                 </ul>
            </li>
            <li><%: Html.ActionLink("API Guide", "Index", "APIGuide") %></li>
            <li><%: Html.ActionLink("API Statistics", "Stats", "Home") %></li>
        </ul>
    </aside>
</asp:Content>

