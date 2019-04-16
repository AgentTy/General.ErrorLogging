<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="indexTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Manage 404 Redirects
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI.Error404Redirect") %>

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

        $().ready(function () {
            $('.ShowTooltips').tooltip({
                show: 1500,
                position: { my: "left+10 center", at: "right" }
            });

            LoadApplicationList(true, false, false, function (appData) {
                vm = new AppViewModel(appData);
                ko.applyBindings(vm);

                vm.ModelStatus = new ko.changedFlag(vm);
                vm.ModelStatus.isChanged.subscribe(function (isChanged) {
                    if (isChanged) {
                        ReloadData(vm);
                    }
                });

                ReloadData(vm);
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
                <h1>Automaic 404 Redirects</h1>
                <h2><%: ViewBag.Message %></h2>
            </hgroup>
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
        <div id="tableHeader"><h3><span data-bind="text: AppName"></span>: <span data-bind="    text: RowCount"></span> Active Redirects</h3>
            <p style="margin-top:2px;">404 Errors that match the patterns setup here will be automatically redirected.</p>
        </div>
        <div id="searchContainer">
            Search: <input type="text" id="txtSearch" onkeyup="return DoSearch(this.value, event, SearchData);" />
        </div>
    </div>
    <table id="DataTable">
        <tr>
             <th style="width:103px;"></th>
             <th><span title="Type of redirection. (301 Permanent or 307 Temporary)">Type</span></th>
             <th><span title="A path to catch for redirection. (supports * wildcard)">From</span></th>
             <th><span title="The location to redirect to. (* wildcard will append wildcard text in From)">To</span></th>
             <th><span title="An optional Client ID to apply this redirect rule to.">Client</span></th>
             
             <th><span title="How many times this redirection has been used.">Use Count</span></th>
             <th><span title="The first date of use.">First</span></th>
             <th><span title="The most recent date of use.">Last</span></th>
        </tr>
        <tr id="DataLoading">
            <td></td>
            <td colspan="5" style="font-weight:bold;font-style:italic;font-size:1.5em;">Loading...</td>
        </tr>
    </table>
    <br />
    <button id="create-object">Add New Redirect</button>

         <%: Html.Partial("_RedirectDialogPartial") %>
    </div>
</asp:Content>
