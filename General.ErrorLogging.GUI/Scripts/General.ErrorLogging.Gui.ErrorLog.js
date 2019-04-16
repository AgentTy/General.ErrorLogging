
function SetupUI(vwModel) {
    $('#txtStartDate').datepicker();
    $('#txtEndDate').datepicker();

    $('.ShowTooltips').tooltip({
        show: 1500,
        position: { my: "left+10 center", at: "right" }
    });

    dialogDetail = $("#dialog-detail").dialog({
        dialogClass: 'DetailDialog DetailDialogErrorLog',
        autoOpen: false,
        modal: true,
    });

    $('#ddnApp').change(function () {
        if (!vm.Locked) {
            vm.Lock();
            vm.AppID($(this).val());
            $.cookie('LogViewAppID', vm.AppID(), { expires: 10000, path: '/' });
            vm.AppName($(this).find('option:selected').text());
            vm.FilterID(null);
            vm.FilterName('');
            $.removeCookie('LogViewFilterID');
            vmAppFilterData.FilterID(null);

            LoadFilterList(vm.AppID(), true, false, true, function (filterData) {
                vmAppFilterData.FilterList(filterData);
                ko.mapping.fromJS(filterData, null, vmAppFilterData.FilterList);

            });
            vm.Release();
            ClearData();
            //ReloadData(vm);
        }
    });

    $('#ddnFilter').change(function () {
        vm.Lock();
        vm.FilterID($(this).val());
        $.cookie('LogViewFilterID', vm.FilterID(), { expires: 10000, path: '/' });
        vm.FilterName($(this).find('option:selected').text());
        vm.Release();
        ReloadData(vm);
    });
    UpdateLoadingProgress();

    $('#areaPagination').pagination({
        onPageClick: PageSelected,
        items: 0,
        itemsOnPage: vwModel.PageSize(),
        cssStyle: 'light-theme'
    });

    //This code will make the page selector stay fixed at the bottom of viewport until you scroll to the bottom of the page
    var $window = $(window);
    var $paginationContainer = $('#paginationContainer');
    var changeHeight = 0;
    $window.scroll(function (e) {
        var dockHeight = document.documentElement.scrollHeight - ($window.height() + $window.scrollTop());
        if (dockHeight <= 58 && Math.abs(changeHeight - dockHeight) > 58) {
            changeHeight = dockHeight;
            $paginationContainer.css({
                position: 'relative'
            });
        } else if (dockHeight > 58 && Math.abs(changeHeight - dockHeight) > 58) {
            changeHeight = dockHeight;
            $paginationContainer.css({
                position: 'fixed'
            });
        }
    });
}

var wasBound = false;
function BindIfReady() {
    if (!wasBound) {
        if (vmAppFilterData.AppList() && vmAppFilterData.FilterList() && vm.TypeList) {
            wasBound = true;

            vm.Lock();
            ko.applyBindings(vm, document.getElementById('areaDataFilters'));
            ko.applyBindings(vm, document.getElementById('areaDataView'));
            ko.applyBindings(vm, document.getElementById('areaSearchButton'));
            ko.applyBindings(vmAppFilterData, document.getElementById('areaAppFilters'));
            ko.applyBindings(vmEventView, document.getElementById('vwEvent'));
            vm.ReleaseQuietly();

            //vm.ModelStatus = new ko.changedFlag(vm);
            /*vm.ModelStatus.isChanged.subscribe(function (isChanged) {
                if (isChanged && !vm.Locked) {
                    ReloadData(vm);
                }
            });*/
            UpdateLoadingProgress();
            if (vm.FilterID())
                ReloadData(vm);
            else
                ClearData();
        }
    }
}



function APIQuery(vwModel, blnIncludeDetail)
{
    if (!vwModel)
        vwModel = vwModelCurrent;

    var strQuery = '';

    var isAmp = false;
    function amp()
    {
        var result = '&';
        if (!isAmp)
            result = '';
        isAmp = true;
        return result;
    }

    if (vwModel.FilterID())
        strQuery += amp() + 'FilterID=' + vwModel.FilterID();
    if (vwModel.Environment() != 'any')
        strQuery += amp() + 'Environment=' + vwModel.Environment();
    //I'm gonna do this with a multiselect tool
    //if (vwModel.EventType() != 'any' && vwModel.EventType() > 0)
    //  strQuery += amp() + 'Type=' + vwModel.EventType();
    strQuery += amp() + 'Type=' + vwModel.SelectedEventTypes();
    //I'm gonna do this client side
    //if (vwModel.Severity() > 0)
    //    strQuery += amp() + 'MinimumSeverity=' + vwModel.Severity();
    if (vwModel.ClientID())
        strQuery += amp() + 'ClientID=' + vwModel.ClientID();
    if (vwModel.StartDate())
        strQuery += amp() + 'StartDate=' + MakeLocalTimeForQueryString(vwModel.StartDate(), false, true);
    if (vwModel.EndDate())
        strQuery += amp() + 'EndDate=' + MakeLocalTimeForQueryString(vwModel.EndDate(), true, true);
    if (blnIncludeDetail)
        strQuery += amp() + 'IncludeDetail=true';
    else
        strQuery += amp() + 'IncludeDetail=false';

    return strQuery;
}


function ClearData() {
    vwModelCurrent.Data = null;
    vwModelCurrent.HasBeenSearched(false);
    vwModelCurrent.IsSearching(false);
    vwModelCurrent.SeverityList = null;
    InitSeveritySlider(vwModelCurrent.SeverityList);
    vwModelCurrent.NotificationMessage('');
    vwModelCurrent.RowCount(0);
    vwModelCurrent.DataLength(0);
    vwModelCurrent.PageIndex(1);
    $('#DataTable').find('tr:gt(0):not(#DataLoading)').remove();
    HideSpinner();
}


var vwModelCurrent;
var oboeStream;
var jqxhRequest;
function ReloadData(vwModel) {
    if (vwModel)
        vwModelCurrent = vwModel;
    else
        vwModel = vwModelCurrent;

    if (!vwModel.Locked) {
        if ($('#txtSearch').val()) {
            SearchData($('#txtSearch').val(), vwModel);
            return;
        }

        vwModelCurrent.NotificationMessage('');
        vwModelCurrent.RowCount(0);
        vwModelCurrent.DataLength(0);
        vwModelCurrent.PageIndex(1);
        vwModelCurrent.IsSearching(true);
        vwModel.Lock();
        ShowSpinner();
        $('#DataTable').find('tr:gt(0):not(#DataLoading)').remove();

        if (vwModel.CurrentViewMode() == 'summary')
            jqxhRequest = GetData('/api/' + APPContextURI(vwModel) + '/ErrorLog/Summarized?' + APIQuery(vwModel, false), [], DrawData, HandleAPIDataFail);
        else {
            oboeStream = GetDataStream('/api/' + APPContextURI(vwModel) + '/ErrorLog/Expanded?' + APIQuery(vwModel, false), [], StreamDataReceived, StreamDataComplete, HandleAPIDataFail);
            vwModel.IsReading(true);
        }
    }
}

function SearchData(strSearch, vwModel) {
    if (vwModel)
        vwModelCurrent = vwModel;
    else
        vwModel = vwModelCurrent;

    if (!vwModel.Locked) {
        vwModel.NotificationMessage('');
        vwModel.RowCount(0);
        vwModel.DataLength(0);
        vwModel.PageIndex(1);

        if (strSearch == null || strSearch == '') {
            ReloadData(vwModel);
        }
        else {
            vwModel.IsSearching(true);
            vwModel.Lock();
            ShowSpinner();
            $('#DataTable').find('tr:gt(0):not(#DataLoading)').remove();

            if (vwModel.CurrentViewMode() == 'summary')
                jqxhRequest = GetData('/api/' + APPContextURI(vwModel) + '/ErrorLog/SearchSummarized?search=' + strSearch + '&' + APIQuery(vwModel, true), null, DrawData, HandleAPIDataFail);
            else {
                oboeStream = GetDataStream('/api/' + APPContextURI(vwModel) + '/ErrorLog/Expanded?search=' + strSearch + '&' + APIQuery(vwModel, true), [], StreamDataReceived, StreamDataComplete, HandleAPIDataFail);
                vwModel.IsReading(true);
            }

        }
    }
}

function CancelSearch(vwModel) {
    if (vwModel)
        vwModelCurrent = vwModel;
    else
        vwModel = vwModelCurrent;

    if (oboeStream) {
        oboeStream.abort();
        StreamDataComplete();
        oboeStream = null;
    } else if (jqxhRequest) {
        ClearData();
        jqxhRequest.abort();
        jqxhRequest = null;
    }
}

function HandleAPIDataFail(jqXHR, textStatus, errorThrown) {
    vwModelCurrent.ReleaseQuietly();
    HideSpinner();
    if (errorThrown != 'abort')
        vwModelCurrent.NotificationMessage('An error occurred while searching the log data. (' + errorThrown + ')');
}

var lastStreamIndex = 0;
var pushingBuffer = false;
var streamBuffer = new Array();
function StreamDataReceived(incident) {
    var pageSize = vwModelCurrent.PageSize();
    streamBuffer.push(incident);

    //Draw the first page as soon as it is available
    if (streamBuffer.length >= pageSize && lastStreamIndex == 0) {
        pushingBuffer = true;
        lastStreamIndex = lastStreamIndex + pageSize;
        DrawData(streamBuffer);
        pushingBuffer = false;
    }
    //Draw remaining pages in blocks of 10
    else if (streamBuffer.length - lastStreamIndex >= pageSize * 10 && !pushingBuffer) {
        pushingBuffer = true;
        lastStreamIndex = lastStreamIndex + (pageSize * 10);
        AppendData(streamBuffer);
        pushingBuffer = false;
    }
    else {
        vwModelCurrent.DataLength(streamBuffer.length);
    }
}

function StreamDataComplete(data) {
    if (lastStreamIndex == 0)
        DrawData(streamBuffer); //Result set was less than one page
    else 
        AppendData(streamBuffer); //Update UI with the last remaining rows in the buffer

    vwModelCurrent.IsSearching(false);
    vwModelCurrent.IsReading(false);
    lastStreamIndex = 0;
    pushingBuffer = false;
    streamBuffer = new Array();
}

function AppendData(data) {
    vwModelCurrent.Data = data;
    var arySeverityList = [];
    vwModelCurrent.DataLength(data.length);
    $('#areaPagination').pagination('updateItems', vwModelCurrent.DataLength());
}

function DrawData(data) {
    vwModelCurrent.Data = data;
    vwModelCurrent.HasBeenSearched(true);
    vwModelCurrent.IsSearching(false);
    var arySeverityList = [];
    vwModelCurrent.DataLength(data.length);
    $('#areaPagination').pagination('updateItems', vwModelCurrent.DataLength());
    for (var i = vwModelCurrent.StartRowIndex() ; i < data.length && i <= vwModelCurrent.EndRowIndex() ; i++) {
        arySeverityList = DrawRow(data[i], vwModelCurrent.Severity(), arySeverityList);
    }
    arySeverityList.sort(function (a, b) { return a - b });
    vwModelCurrent.SeverityList = arySeverityList;
    InitSeveritySlider(arySeverityList);
    InitExpandableText($('#DataTable'));
    vwModelCurrent.RowCount($('#DataTable tr').length - 2 || 0);
    vwModelCurrent.ReleaseQuietly();
    HideSpinner();
}

function PageSelected(pageNumber, event) {
    vwModelCurrent.Lock();
    ShowSpinner();
    $('#DataTable').find('tr:gt(0):not(#DataLoading)').remove();
    vwModelCurrent.PageIndex(pageNumber);
    DrawData(vwModelCurrent.Data);
    $('#paginationContainer').css({
        position: 'fixed'
    });
}

function SeveritySelected(minSeverity) {
    vwModelCurrent.Lock();
    ShowSpinner();
    $('#DataTable').find('tr:gt(0):not(#DataLoading)').remove();
    vwModelCurrent.Severity(minSeverity);
    DrawData(vwModelCurrent.Data);
}

function DeleteEventSeries(ErrorOtherID) {
    if (confirm('Are you sure you want to delete this series and all its history?')) {
        PostData('DELETE', '/api/' + APPContextURI() + '/ErrorLog?id=' + ErrorOtherID, null, function (response) {
            if (response != 'Object deleted.')
                alert(response);
            else
                ReloadData();
        })
    }
}

function DeleteEventOccurrence(IncidentCode) {
    if (confirm('Are you sure you want to delete this occurrence?')) {
        PostData('DELETE', '/api/' + APPContextURI() + '/ErrorLog/DeleteOccurrence?IC=' + IncidentCode, null, function (response) {
            if (response != 'Object deleted.')
                alert(response);
            else
                ReloadData();
        })
    }
}


var AltRow = false;
var LastRowEventID = null;
function DrawRow(rowData, intMinSeverity, arySeverityList) {
    if (arySeverityList) {
        if ($.inArray(rowData.Severity, arySeverityList) == -1) {
            arySeverityList.push(rowData.Severity);
        }
    }
    if (intMinSeverity)
    {
        if (!(rowData.Severity >= intMinSeverity))
            return arySeverityList; //Skip this row
    }

    var row;
    var strRowClass = 'rowDefault'
    if (rowData.EventTypeID == 6) //Javascript
        strRowClass = 'rowJS';
    if (rowData.EventTypeID == 2 || rowData.EventTypeID == 3 || rowData.EventTypeID == 4) //SQL
        strRowClass = 'rowSQL';
    if (rowData.EventTypeID >= 10) //Informational Logs
        strRowClass = 'rowInfo';

    if (vwModelCurrent.LogViewMode()) {
        if (rowData.ErrorOtherID != LastRowEventID && LastRowEventID != null)
            AltRow = !AltRow;
        LastRowEventID = rowData.ErrorOtherID;
    }

    if (AltRow)
        row = $('<tr class="AltRow ' +  strRowClass + '" />');
    else
        row = $('<tr class="' + strRowClass + '" />');

    if (vwModelCurrent.SummaryViewMode())
        AltRow = !AltRow;
    

    $('#DataTable').append(row);
    
    if (vwModelCurrent.SummaryViewMode()) {
        row.append($('<td class="toolS">' + '<a href="#" onclick="DeleteEventSeries(' + rowData.ID + ')">[delete]</a>' + '</td>'));
        row.append($('<td class="nb">' + rowData.Count + '</td>'));
    }
    else if (vwModelCurrent.LogViewMode()) {
        row.append($('<td class="toolS">' + '<a href="#" onclick="DeleteEventOccurrence(\'' + rowData.IncidentCode + '\')">[delete]</a>' + '</td>'));
        if (rowData.Count > 10)
            row.append($('<td class="nb">Hi</td>'));
        else if (rowData.Count > 4)
            row.append($('<td class="nb">Md</td>'));
        else
            row.append($('<td class="nb">Lo</td>'));
    }

    //Format dates into local time
    var firstTime = moment(rowData.FirstTime).local();
    var lastTime = moment(rowData.LastTime).local();
    rowData.FirstTimeString = firstTime.format('lll');
    rowData.LastTimeString = lastTime.format('lll');
    if (rowData.TimeStamp) {
        var timeStamp = moment(rowData.TimeStamp).local();
        rowData.TimeStampString = timeStamp.format('lll');
    }

    if (vwModelCurrent.SummaryViewMode()) {
        if (rowData.FirstTimeString == rowData.LastTimeString)
            row.append($('<td class="colTime">' + rowData.FirstTimeString + '</td>'));
        else
            row.append($('<td class="colTime">' + rowData.LastTimeString + '<br/>' + rowData.FirstTimeString + '</td>'));
    }
    else {
        row.append($('<td class="colTime">' + rowData.TimeStampString + '</td>'));
    }

    if (rowData.ExceptionType)
        row.append($('<td class="colType">' + rowData.EventTypeName + ': ' + rowData.ExceptionType + '</td>'));
    else
        row.append($('<td class="colType">' + rowData.EventTypeName + '</td>'));
    row.append($('<td expandableText="50">' + CleanString(rowData.EventName) + '</td>'));

    var intExpandableAt = 50;
    try {
        if (rowData.EventURL.indexOf('?') > -1)
            rowData.EventURL = rowData.EventURL.substr(0, rowData.EventURL.indexOf('?'));

        if (rowData.EventURL.indexOf('://') >= 0)
            intExpandableAt = rowData.EventURL.indexOf('/', rowData.EventURL.indexOf('://') + 3);
    }
    catch (ex) { }
    row.append($('<td expandableText="' + intExpandableAt + '" expandableMode="inverted" class="MobileHidden">' + rowData.EventURL + '</td>'));

    try {
        if (rowData.CodeFileName && rowData.CodeFileName.indexOf('?') > 0)
            rowData.CodeFileName = rowData.CodeFileName.substr(0, rowData.CodeFileName.indexOf('?'));
    } catch (err) { }

    var codeFileInfo = null;
    if (rowData.CodeFileName && rowData.CodeLineNumber && rowData.CodeColumnNumber)
        codeFileInfo = rowData.CodeFileName + ':' + rowData.CodeLineNumber + ',' + rowData.CodeColumnNumber;
    else if (rowData.CodeFileName && rowData.CodeLineNumber)
        codeFileInfo = rowData.CodeFileName + ':' + rowData.CodeLineNumber;
    else if (rowData.CodeFileName)
        codeFileInfo = rowData.CodeFileName;

    var durationInfo = null;
    if (rowData.Duration)
        if (rowData.Duration > 1000)
            durationInfo = (rowData.Duration/1000) + ' sec';
        else
            durationInfo = rowData.Duration + ' ms';
    
    if(codeFileInfo && durationInfo)
        row.append($('<td class="MobileHidden colCode">' + codeFileInfo + ' (' + durationInfo + ')</td>'));
    else if (codeFileInfo)
        row.append($('<td class="MobileHidden colCode">' + codeFileInfo + '</td>'));
    else if (durationInfo)
        row.append($('<td class="MobileHidden colCode">' + durationInfo + '</td>'));
    else
        row.append($('<td class="MobileHidden colCode"></td>'));

    /*
    if (rowData.Severity)
        row.append($('<td>' + rowData.Severity + '</td>'));
    else
        row.append($('<td>' + '' + '</td>'));
    */

    if (rowData.ClientID && rowData.UserID)
        row.append($('<td class="MobileHidden colUser">' + rowData.ClientID + '\\' + rowData.UserID + '</td>'));
    else if (rowData.ClientID)
        row.append($('<td class="MobileHidden colUser">' + 'Client: ' + rowData.ClientID + '</td>'));
    else if (rowData.UserID)
        row.append($('<td class="MobileHidden colUser">' + rowData.UserID + '</td>'));
    else
        row.append($('<td class="MobileHidden colUser"></td>'));
    if (vwModelCurrent.LogViewMode()) 
        row.append($('<td class="toolS">' + '<a href="#" onclick="ShowOccurrenceDetail(\'' + rowData.IncidentCode + '\',' + rowData.AppID + ')">[info]</a>' + '</td>'));
    else
        row.append($('<td class="toolS">' + '<a href="#" onclick="ShowEventDetail(' + rowData.ID + ',' + rowData.AppID + ')">[info]</a>' + '</td>'));
    return arySeverityList;
}


function InitSeveritySlider(arySeverityList)
{
    vm.Lock();
    if (arySeverityList && arySeverityList.length > 1)
    {
        $("#SeverityFilter").show();
        $("#objSeveritySlider").slider({
            min: 0,
            max: arySeverityList.length - 1,
            animate: true,
            slide: function (event, ui) {
                if (!vwModelCurrent.SeverityList[ui.value])
                    $('#lblSeverityValue').text('any');
                else
                    $('#lblSeverityValue').text(vwModelCurrent.SeverityList[ui.value]);
            },
            change: function (event, ui) {
                SeveritySelected(vwModelCurrent.SeverityList[ui.value]);
            }
        });
    }
    else
    {
        vwModelCurrent.Severity(null);
        $("#SeverityFilter").hide();
    }
    vm.ReleaseQuietly();
}


function ShowSpinner() {
    spinner.spin($('#areaDataView')[0]);
    $('#DataLoading').show();
}

function HideSpinner() {
    spinner.stop();
    $('#DataLoading').hide();
}