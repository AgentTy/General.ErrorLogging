<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="indexTitle" ContentPlaceHolderID="TitleContent" runat="server">
    View Event Logs
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI.ErrorLog") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI.ViewOccurrence") %>

    <style type="text/css">

    </style>

    <script type="text/javascript">
        function FilterDataModel() {
            this.AppList = ko.observable();
            this.FilterList = ko.observable();
            this.AppID = ko.observable($.cookie('LogViewAppID'));
            this.FilterID = ko.observable($.cookie('LogViewFilterID'));
        }

        function AppViewModel() {
            var self = this;
            this.Data = null;
            this.SeverityList = null;
            this.TypeList = null;
            this.SelectedEventTypes = ko.observableArray();
            this.CurrentViewMode = ko.observable($.cookie('LogViewMode') || 'summary');
            this.SummaryViewMode = function () {
                return self.CurrentViewMode() == 'summary';
            };
            this.LogViewMode = function () {
                return self.CurrentViewMode() == 'log';
            };
            this.AppID = ko.observable($.cookie('LogViewAppID'));
            this.AppName = ko.observable();
            this.FilterID = ko.observable($.cookie('LogViewFilterID'));
            this.FilterName = ko.observable();
            this.EventType = ko.observable();
            this.Environment = ko.observable(ddnEnvironment.value);
            this.ClientID = ko.observable(txtClientID.value);
            this.Severity = ko.observable();
            this.RowCount = ko.observable();
            this.NotificationMessage = ko.observable();

            self.HasBeenSearched = ko.observable(false);
            self.IsSearching = ko.observable(false);
            self.IsReading = ko.observable(false);
            self.DataLength = ko.observable(0);
            self.PageSize = ko.observable(100);
            self.PageCount = ko.observable(1);
            self.PageIndex = ko.observable(1);

            self.SearchButtonLabel = ko.computed(function () {
                if (self.IsSearching())
                    return "Searching...";
                else if (self.IsReading())
                    return "Reading...";
                return "Search";
            });

            self.IsSearchingOrReading = ko.computed(function () {
                return self.IsSearching() || self.IsReading();
            });

            self.PageCount = ko.computed(function () {
                return Math.ceil(self.DataLength() / self.PageSize());
            });

            self.DataTooLong = ko.computed(function () {
                return self.DataLength() == 5000;
            });

            self.StartRowIndex = ko.computed(function () {
                if (self.PageIndex() <= 1)
                    return 0;
                return ((self.PageIndex() - 1) * self.PageSize()) - 1;
            });

            self.EndRowIndex = ko.computed(function () {
                var result;
                if (self.PageIndex() <= 1)
                    result = self.PageSize() - 1;
                else
                    result = self.StartRowIndex() + self.PageSize();
                if (result > self.DataLength() - 1)
                    result = self.DataLength() - 1;
                return Math.max(result, 0);
            });

            this.DataHeader = ko.computed(function () {
                //console.log(vmAppFilterData.AppList());
                //console.log(ddnApp.options.length);
                //console.log($("#ddnApp option[value='" + self.AppID() + "']").text());
                if (self.AppID() && self.AppID() != 'any' && self.FilterID())
                    return (self.AppName() || GetAppName(self.AppID(), vmAppFilterData.AppList())) + '->' + self.FilterName() + ': ';
                else if (self.FilterID())
                    return self.FilterName() + ': ';
                else if (self.AppID() && self.AppID() != 'any')
                    return (self.AppName() || GetAppName(self.AppID(), vmAppFilterData.AppList())) + ': ';
            });

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


            this.Locked = false;
            this.LockCount = 0;
            this.LockStamp = ko.observable();
            this.Lock = function () { self.Locked = true; self.LockCount++; }
            this.Release = function () { self.LockCount--; if (self.LockCount <= 0) { self.Locked = false; self.LockStamp(new Date()); } }
            this.ReleaseQuietly = function () { self.LockCount--; if (self.LockCount <= 0) { self.Locked = false; } }

            this.CurrentViewMode.subscribe(function (newViewMode) {
                $.cookie('LogViewMode', newViewMode, { expires: 10000, path: '/' });
                if(!self.IsSearching() && self.HasBeenSearched())
                    ReloadData(self);
            });

        }
        
        var vmAppFilterData = new FilterDataModel();
        var vm = new AppViewModel();
        var vmEventView = { Event: new EventOccurrenceModel() };

        var dialogDetail;
        ShowLoading(5);
        $().ready(function () {
            LoadApplicationList(true, true, false, function (appData) {
                vmAppFilterData.AppList(appData);
                UpdateLoadingProgress();
                BindIfReady();
            });

            LoadFilterList(APPContextURI(vm), true, false, true, function (data) {
                vmAppFilterData.FilterList(data);
                UpdateLoadingProgress();
                BindIfReady();
            });

            LoadEventTypeGroups(true, true, false, function (typeData) {
                vm.TypeList = typeData;
                UpdateLoadingProgress();
                BindIfReady();
            });

            SetupUI(vm);
        });

    </script>
</asp:Content>


<asp:Content ID="indexFeatured" ContentPlaceHolderID="FeaturedContent" runat="server">
    <section class="featured">
        <div class="content-wrapper" style="padding-bottom:10px;">
            <hgroup class="title">
                <h1>Error Log</h1>
                <h2><%: ViewBag.Message %></h2>
                <div id="LookupForm" style="float:right;text-align:right;">
                    <input id="txtIC" type="text" name="IC" placeholder="Incident Code" onkeypress="if(ListenForEnterKey(event)) { ShowOccurrenceDetail(txtIC.value); }" />
                    <input type="submit" value="Lookup" onclick="ShowOccurrenceDetail(txtIC.value);" />
                </div><div style="clear:both;"></div>
            </hgroup>
            <div id="filters" class="ShowTooltips">
                <section id="areaAppFilters">
                <div>
                    <span><label for="ddnApp">Application</label>
                        <select id="ddnApp" data-bind="value: AppID, options: AppList, optionsText: 'Name', optionsValue: 'AppIDString'">
                        </select>
                    </span>
                </div>
                <div style="min-height:0px;">
                OR
                </div>
                <div>
                    <span><label for="ddnFilter">Filter <i style="font-weight:normal;">(auto-load on select)</i></label>
                        <select id="ddnFilter" data-bind="value: FilterID, options: FilterList, optionsText: 'Name', optionsValue: 'ID'">
                        </select>
                    </span>
                </div>
                </section>
                <hr />
                <section id="areaDataFilters">
                <div>
                    <label for="txtStartDate">Start Date</label>
                    <input type="text" id="txtStartDate" data-bind="value: StartDate" />
                </div>
                <div>
                    <label for="txtEndDate">End Date</label>
                    <input type="text" id="txtEndDate" data-bind="value: EndDate" />
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
                    <span><input type="text" id="txtClientID" data-bind="value: ClientID" /></span>
                </div>   
                <br />
                <span id="EventTypeFilter">
                    <label for="EventTypeFilter">Event Types</label>
                    <span class="CheckBoxList" data-bind="foreach: TypeList">
                        <span><label data-bind="text: DisplayName"></label><input type="checkbox" data-bind="    attr: { value: Value }, checked: $root.SelectedEventTypes" /></span>
                    </span>
                </span>
                <span id="SeverityFilter">
                    <label for="objSeveritySlider">Severity >= <span id="lblSeverityValue">any</span></label>
                    <div id="objSeveritySlider"></div>
                </span>
                </section>
                <div id="areaSearchButton">
                    <input type="button" value="Search" id="btnRefresh" onclick="ReloadData(vm);" data-bind="disable:IsSearchingOrReading(),value: SearchButtonLabel"/>
                    <input type="button" value="Cancel" id="btnCancel" onclick="CancelSearch(vm);" data-bind="enable:IsSearchingOrReading()"/>
                </div> 
            </div>
        </div>
    </section>
</asp:Content>


<asp:Content ID="indexContent" ContentPlaceHolderID="MainContent" runat="server">
    <div id="areaDataView" class="ShowTooltips" style="min-height:250px;">
    <div style="position:relative;">
        <div id="setupHeader" data-bind="visible: !HasBeenSearched() && !IsSearching()"><h3 style="display:inline;">Click Search to view the log...</h3></div>
        <div id="tableHeader" data-bind="visible: HasBeenSearched()"><h3 style="display:inline;"><span data-bind="text: DataHeader"></span><span data-bind="    text: DataLength"></span> Events Matched</h3> 
            <div id="tableViewAs">
                <input type="radio" id="rdoViewAsSummaries" name="ViewAs" value="summary" data-bind="checked: CurrentViewMode" /> <label for="rdoViewAsSummaries">Summary View</label>
                <input type="radio" id="rdoViewAsOccurrences" name="ViewAs" value="log" data-bind="checked: CurrentViewMode" /> <label for="rdoViewAsOccurrences">Log View</label>
            </div>
            <span style="margin-left:50px;font-weight:bold;color:orangered;" data-bind="visible: DataTooLong">Results are limited to 5,000 per search, try narrowing your filters.</span>
            <br />
            <p style="margin-top:2px;">Click search to show events (except 404 errors) whos first or last occurrence was in the specified date range, subject to the filters above.</p>
        </div>
        <div id="searchContainer">
            Search: <input type="text" id="txtSearch" onkeyup="return DoSearch(this.value, event, SearchData);" />
        </div>
    </div>
    <table id="DataTable">
        <tr>
             <th></th>
             <th data-bind="visible: SummaryViewMode()"><span title="Number of times this event has occurred.">Count</span></th>
             <th data-bind="visible: LogViewMode()"><span title="How often events like this are occurring. L (low), M (medium), H (high) frequency">Freq</span></th>
             <th data-bind="visible: SummaryViewMode()"><span title="The first date and the most recent date this event occurred.">Time (last/first)</span></th>
             <th data-bind="visible: LogViewMode()"><span title="The date/time this event occurred.">Time</span></th>
             <th class="colType"><span title="Type of event">Type</span></th>
             <th><span title="A short description of the event.">Event</span></th>
             <th class="MobileHidden"><span title="The URL path of the location what was requested when the event occurred.">URL</span></th>
             <th class="MobileHidden colCode"><span title="The line of code where the event occurred, and/or the duration of execution.">Info</span></th>
             <th class="MobileHidden"><span title="The User type / User ID in the session.">User</span></th>
             <th></th>
        </tr>
        <tr id="DataLoading">
            <td></td>
            <td colspan="5" style="font-weight:bold;font-style:italic;font-size:1.5em;">Loading...</td>
        </tr>
    </table>
    <div id="areaNotification" data-bind="text:NotificationMessage, visible: NotificationMessage">
    </div>
    <div id="paginationContainer" data-bind="visible: PageCount() > 1" class="paginationFixed">
        <div id="areaBottomInfo" data-bind="visible: HasBeenSearched()"><h3 style="display:inline;"><span data-bind="text: DataHeader"></span><span data-bind="    text: DataLength"></span> Events Matched</h3></div>
        <div id="areaPagination">
        </div>
    </div>

    </div>
</asp:Content>

<asp:Content ContentPlaceHolderID="NonBodyContent" runat="server">
    <div id="dialog-detail" title="Details" class="ShowTooltips ErrorLogDetail">
        <%: Html.Partial("_ViewEventOccurrence") %>
    </div>
</asp:Content>