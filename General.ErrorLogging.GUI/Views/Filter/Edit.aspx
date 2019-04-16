<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="indexTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Manage Logging Filters
</asp:Content>

<asp:Content ContentPlaceHolderID="ScriptsSection" runat="server">
    <%: Styles.Render("~/Content/FilterEditor.css") %>
    <%: Scripts.Render("~/bundles/knockoutjs") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI.FilterEditor") %>
    <%: Scripts.Render("~/bundles/General.ErrorLogging.GUI.ViewOccurrence") %>

    <style type="text/css">

    </style>

    <script type="text/javascript">
        var AppIDQueryString = <%: ViewBag.AppID %>;
        var FilterIDQueryString = <%: ViewBag.FilterID %>;

        function AppViewModel(AppList, EnvironmentList, TypeList) {
            this.AppList = AppList;
            this.EnvironmentList = ko.observable(EnvironmentList);
            this.TypeList = ko.observable(TypeList);
            this.FilterList = ko.observable();
            this.ClientList = ko.observable();
            this.UserList = ko.observable();

            this.AppID = ko.observable(AppIDQueryString);
            this.AppName = ko.observable();
            this.FilterID = ko.observable(FilterIDQueryString);
            this.FilterName = ko.observable();
            this.CurrentFilter = ko.observable();

            this.SaveOptions = function () {
                this.CurrentFilter().EventFilter.minseverity = $('#txtMinSeverity').val();
                PersistFilterEventSection(this.CurrentFilter());
            }
        }

        var vm;
        var vmEventView = { Event: new EventOccurrenceModel() };
        ShowLoading(5);
        $().ready(function () {

            InitDroppables();
            dialogDetail = $("#dialog-detail").dialog({
                dialogClass: 'DetailDialog DetailDialogErrorLog',
                autoOpen: false,
                modal: true,
            });
            UpdateLoadingProgress();

            LoadEventTypeList(true, false, false, function (typeData) {
                UpdateLoadingProgress();
                LoadApplicationList(true, false, true, function (appData) {
                    UpdateLoadingProgress();
                    ko.applyBindings(vmEventView, document.getElementById('vwEvent'));

                    vm = new AppViewModel(appData, GetEnvironmentList(), typeData);
                    if (AppIDQueryString !== null)
                    {
                        LoadApplicationMetaData();
                        LoadFilterList(AppIDQueryString, false, false, true, function (filterData) {
                            UpdateLoadingProgress();
                            ko.mapping.fromJS(filterData, null, vm.FilterList);
                            ko.applyBindings(vm, document.getElementById('body'));
                            vm.AppName($('#ddnApp option:selected').text());
                            vm.FilterID(FilterIDQueryString);
                            if(FilterIDQueryString)
                                PushFilterToConfigurationInterface();
                            AddListeners();
                            InitDraggables();
                            UpdateLoadingProgress();
                        });
                    }
                    else
                    {
                        UpdateLoadingProgress();
                        ko.applyBindings(vm, document.getElementById('body'));
                        AddListeners();
                        InitDraggables();
                        UpdateLoadingProgress();
                    }
                });
            });

            

        });

    </script>
</asp:Content>

<asp:Content ID="indexFeatured" ContentPlaceHolderID="FeaturedContent" runat="server">
    <section class="featured">
        <div class="content-wrapper">
            <hgroup class="title">
                <h1>Configure Filter: <span data-bind="text: AppName"></span>\<span data-bind="    text: FilterName"></span></h1>
                <p>General.ErrorLogging clients will record every event/error they are aware of by default. 
                    With filters you can override this behavior on a per application basis by setting up specific rules about the kind of events that should be captured.
                    The application will periodically download this filter list and follow the instuctions you layout here. 
                </p>
            </hgroup>
            <section>
                <span><label for="ddnApp">Application</label>
                    <select id="ddnApp" data-bind="value: AppID, options: AppList, optionsText: 'Name', optionsValue: 'AppIDString'">
                    </select>
                </span>
                <span id="filterSelector">
                    <span><label for="ddnFilter">Filter</label>
                        <select id="ddnFilter" data-bind="value: FilterID, options: FilterList, optionsText: 'Name', optionsValue: 'ID'">
                            <option value="">Select A Filter To Edit</option>
                        </select>
                    </span>
                    <span style="float:right;">
                        Need to create a new filter? <%: Html.ActionLink("Click Here", "Manage", "Filter") %>
                    </span>
                </span>
            </section>
        </div>
    </section>
</asp:Content>

<asp:Content ID="indexContent" ContentPlaceHolderID="MainContent" runat="server">
    <p>Drag a tag from any of the outer sections into the "Active Filter Tags" box in order to limit the events that will be recorded by the application. Remember this filter will not exclude events from logging if they are being captured by another active filter for the application.</p>

<label style="font-weight:bold;">Options</label>
<div id="optionsContainer" style="border:solid 1px black;margin-top:2px;">
    <div class="PadBox">
        <label>Minimum Severity: </label>
        <input style="margin-left:4px;" id="txtMinSeverity" type="number" /> 
        <input style="margin-left:20px;" type="button" id="btnSaveOptions" value="Save Minimum Severity" data-bind="click:SaveOptions" />
    </div>
</div>

<div id="zoneContainer" style="display:none;">
    <div class="row">
        <div id="zoneEnvironments" class="DragOut Normal DragZone Environment"><label>Environments</label>
            <div class="PadBox DropZone" data-bind="foreach: EnvironmentList">
                <span class="DragItem FilterTag Environment" data-bind="text: $data, attr: { 'data-value': $data }"></span>
            </div>
        </div>
        <div id="zoneEvents" class="DragOut Normal DragZone Event"><label>Events</label>
            <div class="PadBox DropZone" data-bind="foreach: TypeList">
                <span class="DragItem FilterTag Event" data-bind="text: DisplayName, attr: { 'data-value': Name }"></span>
            </div>
        </div>
    </div>
    <div class="row">
        <div id="zoneClients" class="DragOut Huge DragZone Client"><label for="zoneClients">Clients</label>
            <div class="PadBox DropZone" data-bind="foreach: ClientList">
                <span class="DragItem FilterTag Client"  data-bind="text: $data, attr: { 'data-value': $data }"></span>
            </div>
            <div class="AddTagSection">
                <input type="text" id="txtNewClientTag" onkeypress="if(ListenForEnterKey(event)) { AddClientTag(this.value, this); }" />
                <input type="button" id="btnAddClientTag" value="Add" onclick="AddClientTag($('#txtNewClientTag').val(), '#txtNewClientTag');" />
            </div>
        </div>
        <div id="zoneFilter" class="DragIn DragZone"><label for="zoneFilter">Active Filter Tags</label>
            <div class="PadBox">
                <section>
                    <label>Env</label>
                    <span class="FilterTag All Environment">All</span>
                    <div id="lstActiveEnvironments" class="DragBack DropZone Environment" ></div>
                </section>
                <section>
                    <label>Events</label>
                    <span class="FilterTag All Event">All</span>
                    <div id="lstActiveEvents" class="DragBack DropZone Event"></div>
                </section>
                <section>
                    <label>Clients</label>
                    <span class="FilterTag All Client">All</span>
                    <div id="lstActiveClients" class="DragBack DropZone Client"></div>
                </section>
                <section>
                    <label>Users</label>
                    <span class="FilterTag All User">All</span>
                    <div id="lstActiveUsers" class="DragBack DropZone User"></div>
                </section>
            </div>
        </div>
        <div id="zoneUsers" class="DragOut Huge DragZone User"><label for="zoneUsers">Users</label>
            <div class="PadBox DropZone" data-bind="foreach: UserList">
                <span class="DragItem FilterTag User"  data-bind="text: $data, attr: { 'data-value': $data }"></span>
            </div>
            <div class="AddTagSection">
                <input type="text" id="txtNewUserTag" onkeypress="if(ListenForEnterKey(event)) { AddUserTag(this.value, this); }" />
                <input type="button" id="btnAddUserTag" value="Add" onclick="AddUserTag($('#txtNewUserTag').val(), '#txtNewUserTag');" />
            </div>
        </div>
    </div>
</div>


</asp:Content>

<asp:Content ContentPlaceHolderID="NonBodyContent" runat="server">
    <div id="dialog-detail" title="Details" class="ShowTooltips ErrorLogDetail">
        <%: Html.Partial("_ViewEventOccurrence") %>
    </div>
</asp:Content>