<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="aboutTitle" ContentPlaceHolderID="TitleContent" runat="server">
    API Statistics
</asp:Content>

<asp:Content ID="aboutContent" ContentPlaceHolderID="MainContent" runat="server">
    <hgroup class="title">
        <h1>API Stats</h1><br />
        <h2><%: ViewBag.Count.ToString() %> Actions Tracked</h2>
    </hgroup>
        <p>
            Use this area to provide additional information.
        </p>

        <p>
           
        </p>

        <table id="DataTable">
            <thead>
                <tr>
                    <th>App</th>
                    <th>Controller</th>
                    <th>Action</th>
                    <th>Avg Speed</th>
                    <th>Avg Per Min</th>
                    <th>This Min</th>
                    <th>Last Min</th>
                    <th>This Hour</th>
                    <th>Last Hour</th>
                    <th>Today</th>
                    <th>Yesterday</th>
                    <th>Lifetime</th>
                    <th>First Date</th>
                </tr>
            </thead>
            <% foreach (var statLine in ViewBag.Data)
            { %>
            <tr>
                <td><%: statLine.Value.AppName %></td>
                <td><%: statLine.Value.ControllerName %></td>
                <td><%: statLine.Value.ActionName %></td>
                <td><%: statLine.Value.AverageSpeed.ToString("0.###ms") %></td>
                <td><%: statLine.Value.AverageCallsPerMinute.ToString("0.###") %></td>
                <td><%: statLine.Value.RunCount_ThisMinute %></td>
                <td><%: statLine.Value.RunCount_LastMinute %></td>
                <td><%: statLine.Value.RunCount_ThisHour %></td>
                <td><%: statLine.Value.RunCount_LastHour %></td>
                <td><%: statLine.Value.RunCount_Today %></td>
                <td><%: statLine.Value.RunCount_Yesterday %></td>
                <td><%: statLine.Value.RunCount_Lifetime %></td>
                <td><%: statLine.Value.TimeStampStart %></td>
            </tr>
           <%  } %>
        </table>
</asp:Content>