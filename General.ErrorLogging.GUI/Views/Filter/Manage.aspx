<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="indexTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Manage Filters
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI.FilterManager") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI.ViewOccurrence") %>

    <style type="text/css">
         .StatCell {
            background-color:#aaaacc !important;
            text-align:center;
            border-right: 1px solid #bbb;
            border-bottom: 1px solid #bbb;
        }
    </style>

    <script type="text/javascript">
        function AppViewModel(AppList) {
            var self = this;
            this.AppList = AppList;

            this.AppID = ko.observable($.cookie('LogViewAppID'));
            this.AppName = ko.computed(function () {
                return GetAppName(self.AppID(), AppList);
            });

            this.ClientID = ko.observable(txtClientID.value);
            this.RowCount = document.CurrentRowCount || 0;
        }


        var vm;
        var vmEventView = { Event: new EventOccurrenceModel() };
        ShowLoading(3);
        $().ready(function () {
            $('.ShowTooltips').tooltip({
                show: 1500,
                position: { my: "left+10 center", at: "right" }
            });

            $('#txtFilterStartDate_Dialog').datepicker();
            $('#txtFilterEndDate_Dialog').datepicker();
            dialogDetail = $("#dialog-detail").dialog({
                dialogClass: 'DetailDialog DetailDialogErrorLog',
                autoOpen: false,
                modal: true,
            });
            UpdateLoadingProgress();

            LoadApplicationList(true, false, false, function (appData) {
                UpdateLoadingProgress();
                vm = new AppViewModel(appData);
                ko.applyBindings(vm, document.getElementById('body'));
                ko.applyBindings(vmEventView, document.getElementById('vwEvent'));
                vm.ModelStatus = new ko.changedFlag(vm);
                vm.ModelStatus.isChanged.subscribe(function (isChanged) {
                    if (isChanged) {
                        ReloadData();
                    }
                });
                ReloadData(vm);
                HideLoading();
            });

            $('#ddnApp').change(function () {
                $.cookie('LogViewAppID', $(this).val(), { expires: 10000, path: '/' });
            });

        });
    </script>
</asp:Content>


<asp:Content ID="indexFeatured" ContentPlaceHolderID="FeaturedContent" runat="server">
    <section class="featured">
        <div class="content-wrapper">
            <hgroup class="title">
                <h1>Manager Filters</h1>
            </hgroup>
            <p style="margin-top:2px;">Filters can be used to manage logging for each application in three ways. 
                <ol>
                    <li>Limit the kind of events that are stored in the log</li>
                    <li>Create custom views of your logs</li>
                    <li>Notify by sms or email when specific events occurr</li>
                </ol>
                <b>Things to know...</b>
                <ul>
                    <li>The default behavior is <b>"When in doubt, log everything"</b>. No active filters = log every event.</li>
                    <li>An event will be logged if <b>any</b> filters are matched.</li>
                    <li>Creating your first filter will change the behavior from "log everything" to "log only what I specified", tread carefully and make sure you have a "catch all" filter as well as your custom view filters.</li>
                    <li>Filter settings are cached on the client side, so no resources are wasted by applications trying to report events you didn't ask for.</li>
                    <li>Filter changes can take up to 1 minute to propagate to client applications, and 5 minutes to web browsers.</li>
                </ul>
            </p>
            <div id="filters" class="ShowTooltips">
                <div>
                    <span><label for="ddnApp">Application</label>
                        <select id="ddnApp" data-bind="value: AppID, options: AppList, optionsText: 'Name', optionsValue: 'AppIDString'">
                        </select>
                    </span>
                </div>
                 <div>
                    <label for="txtClientID">Client ID</label>
                    <span><input type="text" id="txtClientID" data-bind="value: ClientID" /><input type="button" id="btnUpdate" value="Go" /></span>
                </div>
            </div>
        </div>
    </section>
</asp:Content>


<asp:Content ID="indexContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="ShowTooltips">
    <div style="position:relative;">
        <div id="tableHeader"><h3><span data-bind="text: AppName"></span>: <span data-bind="    text: RowCount"></span> Filters</h3>
        </div>
        <div id="searchContainer">
            Search: <input type="text" id="txtSearch" onkeyup="return DoSearch(this.value, event, SearchData);" />
        </div>
    </div>
    <table id="DataTable">
        <tr>
            <th style="width:155px;"></th>
            <th><span title="Name of filter">Name</span></th>
            <th><span title="Active/Disabled/Expired">Status</span></th>
            <th><span title="Environment Filter">Environments</span></th>
            <th><span title="Event Filter">Events</span></th>
            <th><span title="Client Filter">Clients</span></th>
            <th><span title="User Filter">Users</span></th>
            <th><span title="Expire">Expire</span></th>
            <th><span title="Paging is enabled">Page</span></th>
        </tr>
        <tr id="DataLoading">
            <td></td>
            <td colspan="5" style="font-weight:bold;font-style:italic;font-size:1.5em;">Loading...</td>
        </tr>
    </table>
    <br />
    <button id="create-object">Add New Filter</button>
         <%: Html.Partial("_FilterDialogPartial") %>
    </div>
</asp:Content>

<asp:Content ContentPlaceHolderID="NonBodyContent" runat="server">
    <div id="dialog-detail" title="Details" class="ShowTooltips ErrorLogDetail">
        <%: Html.Partial("_ViewEventOccurrence") %>
    </div>
</asp:Content>