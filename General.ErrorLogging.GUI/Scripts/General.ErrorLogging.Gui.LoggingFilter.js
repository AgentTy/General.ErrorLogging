function APIQuery(vwModel) {
    if (!vwModel)
        vwModel = vwModelCurrent;

    var strQuery = '';

    var isAmp = false;
    function amp() {
        var result = '&';
        if (!isAmp)
            result = '';
        isAmp = true;
        return result;
    }

    strQuery += amp() + 'ActiveOnly=' + 'false';
    if (vwModel.ClientID())
        strQuery += amp() + 'ClientID=' + vwModel.ClientID();
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
    GetData('/api/' + APPContextURI(vwModel) + '/LoggingFilter?' + APIQuery(vwModel), [], DrawData);
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
        GetData('/api/' + APPContextURI() + '/LoggingFilter/Search?search=' + strSearch + '&' + APIQuery(vwModel), null, DrawData);
    }
}

function DrawData(data) {
    vwModelCurrent.RowCount = data.length;
    for (var i = 0; i < data.length; i++) {
        DrawRow(data[i]);
    }
    InitExpandableText($('#DataTable'));
    $('#DataLoading').hide();
    ko.applyBindings(vwModelCurrent, document.getElementById('body'));
}

function DeleteObject(ObjectID) {
    if (confirm('Are you sure you want to delete this?')) {
        PostData('DELETE', '/api/' + APPContextURI() + '/LoggingFilter?id=' + ObjectID, null, function (response) {
            if (response != 'Object deleted.')
                alert(response);
            else
                ReloadData();
        })
    }
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
    row.append($('<td>' + '<a href="#" onclick="StartEditObject(' + rowData.ID + ')">[edit]</a> <a href="Edit?AppID=' + rowData.AppID + '&FilterID=' + rowData.ID + '" target="_blank">[config]</a> <a href="#" onclick="DeleteObject(' + rowData.ID + ')">[delete]</a>' + '</td>'));
    row.append($('<td>' + rowData.Name + '</td>'));
    row.append($('<td>' + rowData.Status + '</td>'));

    if(rowData.EnvironmentFilter)
    {
        if(rowData.EnvironmentFilter.all)
            row.append($('<td>all</td>'));
        else if (rowData.EnvironmentFilter.environments.length == 0)
            row.append($('<td>config needed</td>'));
        else
            row.append($('<td>' + JSON.stringify(rowData.EnvironmentFilter.environments) + '</td>'));
    }
    else
        row.append($('<td></td>'));

    if (rowData.EventFilter)
    {
        if (rowData.EventFilter.all)
            row.append($('<td>all</td>'));
        else if (rowData.EventFilter.events.length == 0)
            row.append($('<td>config needed</td>'));
        else 
            row.append($('<td>' + JSON.stringify(rowData.EventFilter.events) + '</td>'));
    }
    else
        row.append($('<td></td>'));

    if (rowData.ClientFilter)
    {
        if (rowData.ClientFilter.all)
            row.append($('<td>all</td>'));
        else if (rowData.ClientFilter.clients.length == 0)
            row.append($('<td>config needed</td>'));
        else if(rowData.ClientFilter.clients.length <= 2)
            row.append($('<td>' + JSON.stringify(rowData.ClientFilter.clients) + '</td>'));
        else
            row.append($('<td>' + rowData.ClientFilter.clients.length + '</td>'));
    }
    else
        row.append($('<td></td>'));

    if (rowData.UserFilter) {
        if (rowData.UserFilter.all)
            row.append($('<td>all</td>'));
        else if (rowData.UserFilter.users.length == 0)
            row.append($('<td>config needed</td>'));
        else if (rowData.UserFilter.users.length <= 1)
            row.append($('<td>' + JSON.stringify(rowData.UserFilter.users) + '</td>'));
        else
            row.append($('<td>' + rowData.UserFilter.users.length + '</td>'));
    }
    else
        row.append($('<td></td>'));

    if (rowData.EndDateString)
        row.append($('<td>' + rowData.EndDateString + '</td>'));
    else
        row.append($('<td></td>'));

    var strPageList = '';
    if (rowData.PageEmail && rowData.PageSMS)
        strPageList += 'email + sms';
    else if (rowData.PageEmail)
        strPageList += 'email';
    else if (rowData.PageSMS)
        strPageList += 'sms';
    row.append($('<td>' + strPageList + '</td>'));

}

