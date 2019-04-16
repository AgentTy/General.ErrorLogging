function ShowDetail(id) {
    GetData('/api/' + APPContextURI(vm) + '/Error404?id=' + id, [], function (data) {
        //Format dates into local time
        var firstTime = moment(data.FirstTime).local();
        var lastTime = moment(data.LastTime).local();
        var timeStamp = moment(data.TimeStamp).local();
        data.FirstTimeString = firstTime.format('lll');
        data.LastTimeString = lastTime.format('lll');
        data.TimeStampString = timeStamp.format('lll');

        var strTime;
        if (data.FirstTimeString == data.LastTimeString)
            strTime = data.FirstTimeString;
        else
            strTime = data.FirstTimeString + ' - ' + data.LastTimeString;
        $('#dialog-detail .detailCount').html(data.Count + ' times<br/><small>' + strTime + '</small>');
        $('#dialog-detail .detailApplication').text(data.AppName + ' (' + data.EnvironmentName + ')');
        if (data.ClientID)
            $('#dialog-detail .detailClientID').text(data.ClientID);
        else
            $('#dialog-detail .detailClientID').text('none');

        $('#dialog-detail .detailRequestedURL').text(data.URLSafe);
        $('#dialog-detail .detailUserAgent').text(data.UserAgent);
        $('#dialog-detail .detailBody').text(data.Detail);

        InitExpandableText(dialogDetail);
        dialogDetail.dialog("open");
    });
}

function APIQuery(vwModel, blnLazy)
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

    if (vwModel.Environment() != 'any' || blnLazy)
        strQuery += amp() + 'Environment=' + vwModel.Environment();
    if (vwModel.ClientID() || blnLazy)
        strQuery += amp() + 'ClientID=' + vwModel.ClientID();
    if (vwModel.StartDate())
        strQuery += amp() + 'StartDate=' + MakeLocalTimeForQueryString(vwModel.StartDate(), false, true);
    if (vwModel.EndDate())
        strQuery += amp() + 'EndDate=' + MakeLocalTimeForQueryString(vwModel.EndDate(), true, true);
    if (vwModel.FilterFileType())
        strQuery += amp() + 'Filter=' + vwModel.FilterFileType();
    return strQuery;
}

var vwModelCurrent;
function ReloadData(vwModel) {
    if ($('#txtSearch').val()) {
        SearchData($('#txtSearch').val(), vwModel);
        return;
    }

    if (vwModel)
        vwModelCurrent = vwModel;
    else
        vwModel = vwModelCurrent;

    $('#DataLoading').show();
    $('#DataTable').find('tr:gt(0):not(#DataLoading)').remove();

    switch(vwModel.FilterOption())
    {
        case 'common': GetData('/api/' + APPContextURI(vwModel) + '/Error404/Common?' + APIQuery(vwModel), [], DrawData); break;
        case 'all': GetData('/api/' + APPContextURI(vwModel) + '/Error404/IncludeSuppressed?' + APIQuery(vwModel), [], DrawData); break;
        default: GetData('/api/' + APPContextURI(vwModel) + '/Error404/Normal?' + APIQuery(vwModel), [], DrawData); break;
    }
}

function SearchData(strSearch, vwModel) {
    if (vwModel)
        vwModelCurrent = vwModel;
    else
        vwModel = vwModelCurrent;

    if (strSearch == null || strSearch == '') {
        ReloadData(vwModel);
    }
    else {
        $('#DataLoading').show();
        $('#DataTable').find('tr:gt(0):not(#DataLoading)').remove();
        switch (vwModel.FilterOption()) {
            case 'common': GetData('/api/' + APPContextURI() + '/Error404/SearchCommon?search=' + strSearch + '&' + APIQuery(vwModel, true), null, DrawData); break;
            case 'all': GetData('/api/' + APPContextURI() + '/Error404/SearchIncludeSuppressed?search=' + strSearch + '&' + APIQuery(vwModel, true), null, DrawData); break;
            default: GetData('/api/' + APPContextURI() + '/Error404/Search?search=' + strSearch + '&' + APIQuery(vwModel, true), null, DrawData); break;
        }
    }
}

function DrawData(data) {
    vwModelCurrent.RowCount = data.length;
    for (var i = 0; i < data.length; i++) {
        DrawRow(data[i]);
    }
    InitExpandableText($('#DataTable'));
    $('#DataLoading').hide();
    ko.applyBindings(vwModelCurrent);
}

function DeleteObject(ObjectID) {
    if (confirm('Are you sure you want to delete this?')) {
        PostData('DELETE', '/api/' + APPContextURI() + '/Error404?id=' + ObjectID, null, function (response) {
            if (response != 'Object deleted.')
                alert(response);
            else
                ReloadData();
        })
    }
}

function SuppressObject(ObjectID) {
    PostData('POST', '/api/' + APPContextURI() + '/Error404/Suppress?id=' + ObjectID, null, function (response) {
        if (response != 'Object suppressed.')
            alert(response);
        else
            ReloadData();
    })
}

function RestoreObject(ObjectID) {
    PostData('POST', '/api/' + APPContextURI() + '/Error404/Restore?id=' + ObjectID, null, function (response) {
        if (response != 'Object restored.')
            alert(response);
        else
            ReloadData();
    })
}

var AltRow = false;
function DrawRow(rowData) {
    var row;
    if (AltRow)
        row = $('<tr class="AltRow" />');
    else
        row = $('<tr />');
    AltRow = !AltRow;

    $('#DataTable').append(row);
    var lnkSuppress;
    var lnkRedirect = '<a href="#" onclick="StartCreateRedirect(' + rowData.ID + ',\'' + rowData.URLSafe + '\',\'' + vwModelCurrent.ClientID() + '\')">[redirect]</a> ';
    if (!rowData.Hide)
        lnkSuppress = '<a href="#" onclick="SuppressObject(' + rowData.ID + ')" title="Don\'t show this 404 in the report.">[suppress]</a>';
    else
    {
        lnkSuppress = '<a href="#" onclick="RestoreObject(' + rowData.ID + ')" title="Include this 404 in the report.">[restore]</a>';
        lnkRedirect = '';
    }

    row.append($('<td class="toolL">' + lnkRedirect + lnkSuppress + ' <a href="#" onclick="DeleteObject(' + rowData.ID + ')">[delete]</a>' + '</td>'));
    row.append($('<td>' + rowData.URLSafe + '</td>'));
    row.append($('<td expandableText="50">' + rowData.UserAgentDisplay + '</td>'));
    row.append($('<td>' + rowData.Count + '</td>'));

    //Format dates into local time
    var firstTime = moment(rowData.FirstTime).local();
    var lastTime = moment(rowData.LastTime).local();
    rowData.FirstTimeString = firstTime.format('l');
    rowData.LastTimeString = lastTime.format('l');

    if (rowData.FirstTimeString == rowData.LastTimeString)
        row.append($('<td>' + rowData.FirstTimeString + '</td>'));
    else
        row.append($('<td>' + rowData.LastTimeString + '<br/>' + rowData.FirstTimeString + '</td>'));

    row.append($('<td class="toolS">' + '<a href="#" onclick="ShowDetail(' + rowData.ID + ')">[info]</a>' + '</td>'));
}
