<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="indexTitle" ContentPlaceHolderID="TitleContent" runat="server">
    View 404 Errors
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI.Error404") %>

    <script type="text/javascript">
        function AppViewModel(AppList) {
            var self = this;
            this.AppList = AppList;

            this.AppID = ko.observable($.cookie('LogViewAppID'));
            this.AppName = ko.computed(function () {
                return GetAppName(self.AppID(), AppList);
            });
            this.Environment = ko.observable(ddnEnvironment.value);
            this.ClientID = ko.observable(txtClientID.value);
            this.FilterOption = ko.observable($("input:radio[name=rdoFilterOption]:checked").val());
            this.FilterFileType = ko.observable($("input:radio[name=rdoFilterFileType]:checked").val());

            this.RowCount = document.CurrentRowCount || 0;

            var date = $("#txtStartDate").datepicker("getDate");
            if (date)
                this.StartDate = ko.observable((date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear());
            else
                this.StartDate = ko.observable();

            date = $("#txtEndDate").datepicker("getDate");
            if(date)
                this.EndDate = ko.observable((date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear());
            else
                this.EndDate = ko.observable();

            date = new Date();
            if (!this.StartDate())
                this.StartDate((date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear());
            if (!this.EndDate())
                this.EndDate((date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear());
        }
        
        var vm;
        var dialogDetail;
        $().ready(function () {
            $('#txtStartDate').datepicker();
            $('#txtEndDate').datepicker();
            
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

            dialogDetail = $("#dialog-detail").dialog({
                dialogClass: 'DetailDialog',
                autoOpen: false,
                modal: true,
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
                <h1>404 Errors</h1>
                <h2><%: ViewBag.Message %></h2>
            </hgroup>
            <div id="filters" class="ShowTooltips">
                <div>
                    <label for="txtStartDate">Start Date</label>
                    <input type="text" id="txtStartDate" data-bind="value: StartDate" />
                </div>
                <div>
                    <label for="txtEndDate">End Date</label>
                    <input type="text" id="txtEndDate" data-bind="value: EndDate" />
                </div>
                <div>
                    <span><label for="ddnApp">Application</label>
                        <select id="ddnApp" data-bind="value: AppID, options: AppList, optionsText: 'Name', optionsValue: 'AppIDString'">
                        </select>
                    </span>
                </div>
                <div>
                    <label for="ddnEnvironment">Environment</label>
                    <select id="ddnEnvironment" data-bind="value: Environment">
                        <option value="any">Any Environment</option>
                        <option value="Dev">Dev (1)</option>
                        <option value="QA">QA (2)</option>
                        <option value="Stage">Stage (3)</option>
                        <option value="CustomEnv">CustomEnv (4)</option>
                        <option value="Live">Live (5)</option>
                    </select>
                </div>
                <div>
                    <label for="txtClientID">Client ID</label>
                    <span><input type="text" id="txtClientID" data-bind="value: ClientID" /><input type="button" id="btnUpdate" value="Go"/></span>
                </div>
                <div style="min-height:20px;">
                    <div style="padding-right:30px;margin-right:30px;display:inline-block;">
                        <label for="rdoFilterOption" style="display:inline;">Display Filter</label>
                        <span>
                            <span><input type="radio" name="rdoFilterOption" value="common" data-bind="checked: FilterOption" checked>Common (5+)</span>
                            <span><input type="radio" name="rdoFilterOption" value="normal" data-bind="checked: FilterOption">All</span>
                            <span><input type="radio" name="rdoFilterOption" value="all" data-bind="checked: FilterOption">All (inc. Suppressed)</span>
                        </span>
                    </div>
                    <div style="display:inline-block;">
                        <label for="rdoFilterOption" style="display:inline;">File Types</label>
                        <span>
                            <span><input type="radio" name="rdoFilterFileType" value="all" data-bind="checked: FilterFileType" checked>All</span>
                            <span><input type="radio" name="rdoFilterFileType" value="pages" data-bind="checked: FilterFileType">Pages Only</span>
                            <span><input type="radio" name="rdoFilterFileType" value="images" data-bind="checked: FilterFileType">Images Only</span>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>


<asp:Content ID="indexContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="ShowTooltips">
        <div style="position:relative;">
            <div id="tableHeader"><h3 style="display:inline;"><span data-bind="text: AppName"></span>: <span data-bind="    text: RowCount"></span> 404s Matched</h3>
                <input type="button" id="btnRefresh" value="Refresh" onclick="ReloadData(vm);"/><br />
                <p style="margin-top:2px;">Showing 404s whos first or last occurrence was in the specified date range, subject to the filters above.</p>
            </div>
            <div id="searchContainer">
                Search: <input type="text" id="txtSearch" onkeyup="return DoSearch(this.value, event, SearchData);" />
            </div>
        </div>
        <table id="DataTable">
            <tr>
                    <th></th>
                    <th><span title="The URL path that was requested.">URL</span></th>
                    <th><span title="The Requestors UserAgent header">UserAgent</span></th>
                    <th><span title="Number of times this 404 has occurred.">Count</span></th>
                    <th><span title="The earliest and the most recent date this 404 occurred.">Dates</span></th>
                    <th></th>
            </tr>
            <tr id="DataLoading">
                <td></td>
                <td colspan="5" style="font-weight:bold;font-style:italic;font-size:1.5em;">Loading...</td>
            </tr>
        </table>
    </div>
    
    <%: Html.Partial("_RedirectDialogPartial") %>

    <div id="dialog-detail" title="Details" class="ShowTooltips">
        <h2 class="detailRequestedURL"></h2>
        <span class="detailCount"></span>
        <i class="detailUserAgent" style="margin-left:15px;"></i><br />
        Application: <i class="detailApplication"></i><br />
        ClientID: <i class="detailClientID"></i><br />
        <br />
        <pre><code class="detailBody"></code></pre>
    </div>

</asp:Content>
