function APIQuery(vwModel)
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

    if(vwModel.ClientID())
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
    GetData('/api/' + APPContextURI(vwModel) + '/Error404Redirect?' + APIQuery(vwModel), [], DrawData);
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
        GetData('/api/' + APPContextURI() + '/Error404Redirect/Search?search=' + strSearch + '&' + APIQuery(vwModel), null, DrawData);
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
        PostData('DELETE', '/api/' + APPContextURI() + '/Error404Redirect?id=' + ObjectID, null, function (response) {
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
    row.append($('<td>' + '<a href="#" onclick="StartEditObject(' + rowData.ID + ')">[edit]</a> <a href="#" onclick="DeleteObject(' + rowData.ID + ')">[delete]</a>' + '</td>'));
    row.append($('<td>' + rowData.RedirectType + '</td>'));
    row.append($('<td>' + rowData.From + '</td>'));
    row.append($('<td>' + rowData.To + '</td>'));
    if (rowData.ClientID)
        row.append($('<td>' + rowData.ClientID + '</td>'));
    else
        row.append($("<td></td>"));

    row.append($('<td class="StatCell">' + rowData.Count + '</td>'));
    row.append($('<td class="StatCell">' + rowData.FirstTimeString + '</td>'));
    row.append($('<td class="StatCell">' + rowData.LastTimeString + '</td>'));
}

