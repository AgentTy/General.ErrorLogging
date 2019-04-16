<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="apiGuideTitle" ContentPlaceHolderID="TitleContent" runat="server">
    API Guide - Index
</asp:Content>

<asp:Content ID="apiGuideContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1>About the API</h1>
        <h2><%: ViewBag.Message %></h2>
    </hgroup>

    <article>
        <p>
            All user actions can be enacted via AJAX calls using JSON as a medium. The linked API Test pages can be used to explore and test the methods that have been setup for reading and manipulating data.
        </p>
        <h3>API Sections</h3>
        <ul>
            <li><%: Html.ActionLink("Implementation Guide", "ImplementationGuide", "APIGuide") %></li>
            <li><%: Html.ActionLink("Application Errors", "ErrorLog", "APIGuide") %></li>
            <li><%: Html.ActionLink("Logging Filters", "LoggingFilters", "APIGuide") %></li>
            <li><%: Html.ActionLink("404 Errors", "Error404", "APIGuide") %></li>
            <li><%: Html.ActionLink("404 Redirects", "Error404Redirect", "APIGuide") %></li>
            <li><%: Html.ActionLink("Authentication / Misc", "Misc", "APIGuide") %></li>
        </ul>
    </article>
</asp:Content>