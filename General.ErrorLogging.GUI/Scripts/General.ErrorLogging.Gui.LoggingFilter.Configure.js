
function PersistFilterTagAdd(strValue, strClass)
{
    var objFilter = vm.CurrentFilter();
    if (strClass == 'Environment') {
        if (objFilter.EnvironmentFilter.environments.indexOf(strValue) == -1)
            objFilter.EnvironmentFilter.environments.push(strValue);
        PersistFilterEnvironmentSection(objFilter);
    }
    else if (strClass == 'Event') {
        if (objFilter.EventFilter.events.indexOf(strValue) == -1)
            objFilter.EventFilter.events.push(strValue);
        PersistFilterEventSection(objFilter);
    }
    else if (strClass == 'Client') {
        if (objFilter.ClientFilter.clients.indexOf(strValue) == -1)
            objFilter.ClientFilter.clients.push(strValue);
        PersistFilterClientSection(objFilter);
    }
    else if (strClass == 'User') {
        if (objFilter.UserFilter.users.indexOf(strValue) == -1)
            objFilter.UserFilter.users.push(strValue);
        PersistFilterUserSection(objFilter);
    }
}

function PersistFilterTagRemove(strValue, strClass) {
    var objFilter = vm.CurrentFilter();
    if (strClass == 'Environment') {
        if (objFilter.EnvironmentFilter.environments.indexOf(strValue) > -1)
            objFilter.EnvironmentFilter.environments.splice(objFilter.EnvironmentFilter.environments.indexOf(strValue), 1);
        PersistFilterEnvironmentSection(objFilter);
    }
    else if (strClass == 'Event') {
        if (objFilter.EventFilter.events.indexOf(strValue) > -1)
            objFilter.EventFilter.events.splice(objFilter.EventFilter.events.indexOf(strValue), 1);
        PersistFilterEventSection(objFilter);
    }
    else if (strClass == 'Client') {
        if (objFilter.ClientFilter.clients.indexOf(strValue) > -1)
            objFilter.ClientFilter.clients.splice(objFilter.ClientFilter.clients.indexOf(strValue), 1);
        PersistFilterClientSection(objFilter);
    }
    else if (strClass == 'User') {
        if (objFilter.UserFilter.users.indexOf(strValue) > -1)
            objFilter.UserFilter.users.splice(objFilter.UserFilter.users.indexOf(strValue), 1);
        PersistFilterUserSection(objFilter);
    }
}

function PersistFilterEnvironmentSection(objFilter)
{
    PostData("PUT", '/api/' + objFilter.AppID + '/LoggingFilter/UpdateFilterEnvironmentSection',
    JSON.stringify({ FilterID: vm.CurrentFilter().ID, FilterSection: objFilter.EnvironmentFilter }), function (data) {
        objFilter.EnvironmentFilter = data.EnvironmentFilter;
        vm.CurrentFilter(objFilter);
    });
}

function PersistFilterEventSection(objFilter) {
    PostData("PUT", '/api/' + objFilter.AppID + '/LoggingFilter/UpdateFilterEventSection',
    JSON.stringify({ FilterID: vm.CurrentFilter().ID, FilterSection: objFilter.EventFilter }), function (data) {
        objFilter.EventFilter = data.EventFilter;
        vm.CurrentFilter(objFilter);
    });
}

function PersistFilterClientSection(objFilter) {
    PostData("PUT", '/api/' + objFilter.AppID + '/LoggingFilter/UpdateFilterClientSection',
    JSON.stringify({ FilterID: vm.CurrentFilter().ID, FilterSection: objFilter.ClientFilter }), function (data) {
        objFilter.ClientFilter = data.ClientFilter;
        vm.CurrentFilter(objFilter);
    });
}

function PersistFilterUserSection(objFilter) {
    PostData("PUT", '/api/' + objFilter.AppID + '/LoggingFilter/UpdateFilterUserSection',
    JSON.stringify({ FilterID: vm.CurrentFilter().ID, FilterSection: objFilter.UserFilter }), function (data) {
        objFilter.UserFilter = data.UserFilter;
        vm.CurrentFilter(objFilter);
    });
}

function AddListeners() {
    /*
    vm.ModelStatus = new ko.changedFlag(vm);
    vm.ModelStatus.isChanged.subscribe(function (isChanged) {
        if (isChanged) {
            console.log('changed');
        }
    });
    */

    $('#ddnApp').change(function () {
        //AppChanged(this.value, $(this).find('option:selected').text());
        ShowLoading(2);
        vm.AppID($(this).val());
        vm.AppName($(this).find('option:selected').text());
        vm.FilterID(null);
        vm.FilterName('');
        ClearConfigurationInterface();

        LoadApplicationMetaData();
        LoadFilterList(vm.AppID(), false, false, true, function (filterData) {
            UpdateLoadingProgress();
            ko.mapping.fromJS(filterData, null, vm.FilterList);
            UpdateLoadingProgress();
        });
    });

    $('#ddnFilter').change(function () {
        if ($(this).val()) {
            //vm.FilterName($(this).find('option:selected').text());
            ResetFilterStage();
            PushFilterToConfigurationInterface();
        }
        else
            ClearConfigurationInterface();
    });
}

function ClearConfigurationInterface() {
    $('#zoneContainer').hide();
    ResetFilterStage();
}

function LoadApplicationMetaData() {
    ShowLoading(4);
    LoadClientList(vm.AppID(), true, false, false, function (clientData) {
        UpdateLoadingProgress();
        ko.mapping.fromJS(clientData, null, vm.ClientList);
        InitDraggables($('#zoneClients .DragItem'));
        UpdateLoadingProgress();
    });

    LoadUserList(vm.AppID(), null, true, false, false, function (userData) {
        UpdateLoadingProgress();
        ko.mapping.fromJS(userData, null, vm.UserList);
        InitDraggables($('#zoneUsers .DragItem'));
        UpdateLoadingProgress();
    });
}

function PushFilterToConfigurationInterface() {
    //HideLoading();
    ShowLoading(2);
    LoadFilter(vm.AppID(), vm.FilterID(), function (filter) {
        vm.FilterName(filter.Name);
        vm.CurrentFilter(filter);
        $('#txtMinSeverity').val(vm.CurrentFilter().EventFilter.minseverity);
        UpdateLoadingProgress();

        var zoneFilter = $("#zoneFilter");
        PopulateConfigurationToZone(zoneFilter, filter.EnvironmentFilter.environments, '#zoneEnvironments', 'Environment');
        PopulateConfigurationToZone(zoneFilter, filter.EventFilter.events, '#zoneEvents', 'Event');
        PopulateConfigurationToZone(zoneFilter, filter.ClientFilter.clients, '#zoneClients', 'Client');
        PopulateConfigurationToZone(zoneFilter, filter.UserFilter.users, '#zoneUsers', 'User');

        InitDraggables($('#zoneFilter .DragItem'));
        $('#zoneContainer').show();
        UpdateLoadingProgress();
    });
}

function PopulateConfigurationToZone(zoneFilter, values, zoneID, zoneClass)
{
    if (values && values.length > 0) {
        zoneFilter.find('.' + zoneClass + '.All').hide();
        $.each(values, function (index, value) {
            var existing = $(zoneID + ' .DragItem[data-value="' + value + '"]');
            if (existing.length > 0) {
                //Move the tag from the stage
                zoneFilter.find('.DropZone.' + zoneClass).append(existing);
            }
            else {
                //Create a new tag
                zoneFilter.find('.DropZone.' + zoneClass).append(CompileFilterTag(value, zoneClass));
            }
        });
    }
}

function CompileFilterTag(strValue, strClass)
{
    return $('<span />').addClass('DragItem FilterTag').addClass(strClass).attr('data-value', strValue).html(strValue);
}

function AddClientTag(strValue, source) {
    $('#zoneClients .DropZone').append(CompileFilterTag(strValue, 'Client'));
    InitDraggables($('#zoneClients .DragItem'));
    if (source)
        $(source).val('');
}

function AddUserTag(strValue, source) {
    $('#zoneUsers .DropZone').append(CompileFilterTag(strValue, 'User'));
    InitDraggables($('#zoneUsers .DragItem'));
    if (source)
        $(source).val('');
}

function ResetFilterStage()
{
    ShowLoading();

    $('.DragBack .DragItem').remove();
    $('.FilterTag.All').show();

    var backupEnvironments = vm.EnvironmentList();
    vm.EnvironmentList([]); //Clear it out so the viewmodel updates.
    vm.EnvironmentList(backupEnvironments);
    InitDraggables($('#zoneEnvironments .DragItem'));

    var backupEvents = vm.TypeList();
    vm.TypeList([]); //Clear it out so the viewmodel updates.
    vm.TypeList(backupEvents);
    InitDraggables($('#zoneEvents .DragItem'));

    UpdateLoadingProgress();
}

function GetEnvironmentList()
{
    return ['Dev', 'QA', 'Stage', 'CustomEnv', 'Live'];
}