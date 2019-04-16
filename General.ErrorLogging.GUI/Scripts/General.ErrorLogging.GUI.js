function LoadApplicationList(blnActiveOnly, blnAddAnyOption, blnAddNullOption, fnSuccess)
{
    return GetData('/api/Application?AddAnyOption=' + blnAddAnyOption, [], function (data) {
        if (blnAddNullOption)
            data.unshift({ ID: null, Name: 'Select an Application' })
        fnSuccess(data);
    });
}

function GetAppName(intAppID, objAppList)
{
    if(objAppList)
    {
        for(var i = 0; i< objAppList.length; i++) {
            if (objAppList[i].AppIDString == intAppID)
                return objAppList[i].Name;
        }
        return null;
    }
    return null;
}


function LoadEventTypeList(blnActiveOnly, blnAddAnyOption, blnAddNullOption, fnSuccess)
{
    return GetData('/api/EventType?AddAnyOption=' + blnAddAnyOption, [], function (data) {
        if (blnAddNullOption)
            data.unshift({ ID: null, Name: 'Select an Event Type' })
        fnSuccess(data);
    });
}

function EventGroupModel(strName, objValue, strDisplayName, strDescription, blnIsDefault, blnIsOption)
{
    return {
        Name: strName,
        Value: objValue,
        DisplayName: strDisplayName,
        Description: strDescription,
        IsDefaultValue: blnIsDefault,
        IsDropDownListOption: blnIsOption,
    }
}

function LoadEventTypeGroups(blnActiveOnly, blnAddAnyOption, blnAddNullOption, fnSuccess) {
    return GetData('/api/EventType?AddAnyOption=false', [], function (data) {
        var groups = [];
        groups.push(new EventGroupModel("SQL", [2,3,4], "SQL Errors", "SQL Server error and connectivity events", false, true));

        $.each(data, function (index, value) {
            if (!EventTypeExistsInGroup(groups, value.Value)) {
                groups.push(value);
            }
        });

        if (blnAddNullOption)
            groups.unshift({ ID: null, Name: 'Select an Event Type' })
        if (blnAddNullOption)
            groups.unshift({ ID: null, Name: 'Any Type' })
        fnSuccess(groups);
    });
}

function EventTypeExistsInGroup(objGroups, intValue)
{
    for (var i = 0; i < objGroups.length; i++) {
        var group = objGroups[i];
        if (Object.prototype.toString.call(group.Value) === '[object Array]') {
            if ($.inArray(intValue, group.Value) != -1)
                return true;
        }
        return false;
    }
}

function LoadFilterList(intAppID, blnActiveOnly, blnAddAnyOption, blnAddNullOption, fnSuccess)
{
    if (!intAppID && intAppID != 0)
        intAppID = 'any';
    return GetData('/api/' + intAppID + '/LoggingFilter?ActiveOnly=' + blnActiveOnly, [], function (data) {
        if(blnAddNullOption)
            data.unshift({ID: null, Name: 'Select a Filter'})
        fnSuccess(data);
    });
}

function LoadClientList(intAppID, blnActiveOnly, blnAddAnyOption, blnAddNullOption, fnSuccess)
{
    if (!intAppID && intAppID != 0)
        intAppID = 'any';
    return GetData('/api/' + intAppID + '/ClientDictionary?AppID=' + intAppID + '&ActiveOnly=' + blnActiveOnly, [], function (data) {
        if (blnAddNullOption)
            data.unshift('Select a Client ID')
        if (blnAddAnyOption)
            data.unshift('Any Client')
        fnSuccess(data);
    });
}

function LoadUserList(intAppID, strClientID, blnActiveOnly, blnAddAnyOption, blnAddNullOption, fnSuccess) {
    var strClientQuery = '';
    if (strClientID)
        strClientQuery = '&ClientID=' + strClientID;

    return GetData('/api/' + intAppID + '/UserDictionary?AppID=' + intAppID + strClientQuery + '&ActiveOnly=' + blnActiveOnly, [], function (data) {
        if (blnAddNullOption)
            data.unshift('Select a User ID')
        if (blnAddAnyOption)
            data.unshift('Any User')
        fnSuccess(data);
    });
}


function LoadFilter(intAppID, intFilterID, fnSuccess) {
    return GetData('/api/' + intAppID + '/LoggingFilter?ID=' + intFilterID, [], fnSuccess);
}

function APPContextURI(vwModel) {
    if (!vwModel)
        vwModel = vwModelCurrent;

    if (!vwModel.AppID())
        return 'any';
    return vwModel.AppID();
}

function InitExpandableText(obj, intDefaultCutoff)
{
    if (!intDefaultCutoff)
        intDefaultCutoff = 10;

    $(obj).find('[expandableText]').each(function (index) {
        var obj = $(this);
        if (obj.text().length <= 0)
            return;
        
        var cutoff = obj.attr('expandableText');
        var mode = obj.attr('expandableMode');
        if (!cutoff || cutoff.length == 0)
            cutoff = intDefaultCutoff;
        else if (isNaN(cutoff)) {
            if (obj.text().indexOf(cutoff) == -1)
                cutoff = intDefaultCutoff;
            else
                cutoff = obj.text().indexOf(cutoff) + cutoff.length;
        }
        else
            cutoff = parseInt(cutoff);

        if (obj.text().length <= cutoff)
        {
            obj.attr('title', '');
            obj.attr('content-backup', '');
            obj.unbind('dblclick');
            return;
        }

        obj.attr('title', obj.text());
        obj.attr('content-backup', obj.text());
        if (mode == 'inverted')
            obj.text('...' + obj.text().substr(cutoff));
        else
            obj.text(obj.text().substr(0, cutoff) + '...');

        var is_safari = navigator.userAgent.indexOf("Safari") > -1;
        var intOffsetBottom = 0;
        if (is_safari || detectIE())
            intOffsetBottom = 34;

        obj.tooltip({
            show: 500,
            position: { my: "center top", at: "center bottom+" + intOffsetBottom }
        });

        obj.dblclick(function () {
            var obj = $(this);
            var txt = obj.attr('content-backup');
            if (!txt)
                txt = obj.attr('title');
            obj.attr('content-backup', obj.text());
            obj.text(txt);
            
            if(!obj.tooltip("option", "disabled"))
                obj.tooltip("option", "disabled", true);
            else
                obj.tooltip("option", "disabled", false);
        });

    });
}

function updateTips(t) {
    tips
      .text(t)
      .addClass("ui-state-highlight");
    setTimeout(function () {
        tips.removeClass("ui-state-highlight", 1500);
    }, 500);
}

function checkLength(o, n, min, max) {
    if (o.val().length > max || o.val().length < min) {
        o.addClass("ui-state-error");
        updateTips("Length of " + n + " must be between " +
          min + " and " + max + ".");
        return false;
    } else {
        return true;
    }
}

function checkRegexp(o, regexp, n) {
    if (!(regexp.test(o.val()))) {
        o.addClass("ui-state-error");
        updateTips(n);
        return false;
    } else {
        return true;
    }
}


var QuickSearchTimeout;
$().ready(
    function () {
        $('#txtSearch').on('paste', function () {
            var element = this;
            clearTimeout(QuickSearchTimeout);
            QuickSearchTimeout = setTimeout(function () {
                var text = $(element).val();
                SearchData(text);
            }, 500);
        });
    }
);

function DoSearch(strSearch, e, fnSearch) {
    var code = (e.keyCode ? e.keyCode : e.which);

    if (CheckClearSearch(strSearch, e, fnSearch)) {
        return false;
    }

    //console.log(strSearch + ':' + code + ':' + String.fromCharCode(code) + ':' + ListenForEnterKey(e) + ':' + e.altKey + ':' + e.ctrlKey);
    if (strSearch.length > 1) {
        if (!ListenForEnterKey(e)) {
            try {
                if (code != 8 && code != 32 && code <= 45) //Control keys
                {
                    clearTimeout(QuickSearchTimeout);
                    return;
                }
                if(e.altKey || e.ctrlKey) //Control modifiers
                {
                    clearTimeout(QuickSearchTimeout);
                    return;
                }

                /*
                if (code >= 97 && code <= 122)
                    code = code - 48; //Number Pad Support
                if (code == 8 || code == 46)
                    strSearch = strSearch.substring(0, strSearch.length - 1);
                else if (code == 222) //For some reason this comes up for apostrophe and double quotes
                    strSearch = strSearch + '"';
                else
                    strSearch = strSearch + String.fromCharCode(code).toLowerCase(); //Add the current key pressed due to KeyDown being used, current key isn't yet part of TextBox value
                */
            } catch (err) { }

            clearTimeout(QuickSearchTimeout);
            QuickSearchTimeout = setTimeout(function () {
                fnSearch(strSearch);
            }, 1500);
            return true;
        }
        else {
            clearTimeout(QuickSearchTimeout);
            fnSearch(strSearch);
            return false;
        }
    }
}

function CheckClearSearch(strSearch, e, fnSearch) {
    var code = (e.keyCode ? e.keyCode : e.which);
    if (strSearch.length == 0 && (code == 8 || code == 46)) {
        clearTimeout(QuickSearchTimeout);
        ReloadData();
        return true;
    }
    return false;
}

function ListenForEnterKey(e) {
    try {
        var code = (e.keyCode ? e.keyCode : e.which);
        if (code == 13) {
            return true;
        }
        return false;
    }
    catch (err) { return false; }
}


function FixActionPathForHost(strAction) {
    if (window.HostedURI && window.HostedURI != '' && window.HostedURI != null) {
        return window.HostedURI + strAction;''
    }
    return strAction;
}

function GetData(strAction, objParams, fnSuccess, fnFail) {
    strAction = FixActionPathForHost(strAction);
    var strDataType = 'json';

    jQuery.support.cors = true;
    return $.ajax({
        type: "GET",
        url: strAction,
        data: JSON.stringify(objParams),
        dataType: strDataType,
        timeout: 45000, //45 Seconds
        success: function (data, textStatus, jqXHR) {
            fnSuccess(data);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            if (fnFail)
                fnFail(jqXHR, textStatus, errorThrown);
            else
                alert('Error: ' + jqXHR.status + ' ' + jqXHR.statusText + '\r\n' + jqXHR.responseText);
        }
    });
}

function GetDataStream(strAction, objParams, fnStream, fnSuccess, fnFail) {
    strAction = FixActionPathForHost(strAction);
    return oboe({
        url: strAction,
        method: 'GET',          // optional
        //headers: Object,         // optional
        //body: String|Object,     // optional
        cached: false,         // optional
        //withCredentials: Boolean // optional, browser only
    })
        .node('{IncidentCode}', function (incident) {
            // This callback will be called everytime a new incident is read from the data stream
            // it will send the item to a callback, then purge it from memory
            fnStream(incident);
            return oboe.drop;
        })
        .done(function (data) {
            // we got it
            fnSuccess(data);
        })
        .fail(function (errorReport) {
            // we don't got it
            console.log('json streaming failed', errorReport);
            if (fnFail)
                fnFail(null, errorReport.statusCode, errorReport.thrown, errorReport);
            else {
                if (confirm('An error stopped the log search, would you like me to try again another way?\r\nError: ' + errorReport.statusCode + '\r\n' + errorReport.body))
                    GetData(strAction, objParams, fnSuccess, fnFail);
            }
        });

}

function PostData(strPostType, strAction, objParams, fnSuccess) {
    strAction = FixActionPathForHost(strAction);

    jQuery.support.cors = true;
    return $.ajax({
        type: strPostType,
        url: strAction,
        data: objParams,
        dataType: 'json',
        contentType: 'application/json; charset=utf-8',
        timeout: 30000, //30 Seconds
        success: function (data, textStatus, jqXHR) {
            fnSuccess(data);
        },
        error: function (jqXHR, textStatus, errorThrown) {
            alert('Error: ' + jqXHR.status + ' ' + jqXHR.statusText + '\r\n' + jqXHR.responseText);
        }
    });
}


function TestAPI(strURL, strDataType, strPostType, objParams) {
    strURL = FixActionPathForHost(strURL);

    if (!strPostType)
        strPostType = "GET";

    var targetdiv = $('#divTestResult');
    $(targetdiv).html('Running...');
    var username = null;
    var password = null;

    var isRemote = false;
    if (strDataType == "jsonp") {
        isRemote = true;

        var strProtocol = strURL.substring(0, strURL.indexOf("://") + 3);
        if (strProtocol == null)
            strProtocol = "http://";
        var strAddress = strURL.substring(strURL.indexOf("://") + 3);
        strURL = strProtocol + username + ':' + password + "@@" + strAddress;
    }

    if (!objParams)
        objParams = {};
    var objData = JSON.stringify(objParams);

    var strContentType = '';
    if (strDataType == 'json')
        strContentType = 'application/json; charset=utf-8';

    jQuery.support.cors = true;
    $.ajax({
        type: strPostType,
        url: strURL,
        data: objData,
        dataType: strDataType,
        contentType: strContentType,
        timeout: 120000, //120 Seconds
        success: function (data, textStatus, jqXHR) {
            $(targetdiv).html(JSON.stringify(data));

            //alert(data);
            //alert(jqXHR.responseText);
            PostProcessHeaders(jqXHR);
            //alert("API Call Success!");

        },
        beforeSend: function (jqXHR) {
            jqXHR.setRequestHeader('Authorization', make_base_auth(username, password));
        },
        error: function (jqXHR, textStatus, errorThrown) {
            $(targetdiv).html(textStatus + ": " + errorThrown);
            //alert(jqXHR.status);
            //alert(jqXHR.statusText);
            //alert(jqXHR.responseText);
            //alert(jqXHR.getAllResponseHeaders());
            PostProcessHeaders(jqXHR);
        }
    });

    function make_base_auth(user, password) {
        var tok = user + ':' + password;
        var hash = btoa(tok);
        return "Basic " + hash;
    }

    function PostProcessHeaders(jqXHR) {
        if (jqXHR.getResponseHeader('Debug-Database-Time') != null) {
            /*
            var DataTime = jqXHR.getResponseHeader('Debug-Database-Time');
            var DataRequests = jqXHR.getResponseHeader('Debug-Database-Requests');
            var ServerTime = jqXHR.getResponseHeader('Debug-Server-Time');
            var CustomTime = jqXHR.getResponseHeader('Debug-Custom-Time');
            var TransmissionStart = jqXHR.getResponseHeader('Debug-Transmission-Start');
            var TotalTime = jqXHR.getResponseHeader('Debug-Total-Time');
            debugShowTimeReport(DataTime, DataRequests, ServerTime, TransmissionStart, TotalTime, CustomTime)
            */
        }
    }

}


function GenerateTestError_Type() {
    var obj = undefined;
    alert(obj.prop);
}

function GenerateTestError_Syntax() {
    eval('alert("Hello world)');
}

function GenerateTestError_Eval() {
    var sum = eval = 'x';
    alert("NO ERROR CAUGHT: Your browser doesn't seem to mind that we just set eval to the letter 'x'!");
}

function GenerateTestError_Reference() {
    var sum = x + y;
    alert(sum);
}

/**
 * detect IE
 * returns version of IE or false, if browser is not Internet Explorer
 */
function detectIE() {
    var ua = window.navigator.userAgent;

    var msie = ua.indexOf('MSIE ');
    if (msie > 0) {
        // IE 10 or older => return version number
        return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
    }

    var trident = ua.indexOf('Trident/');
    if (trident > 0) {
        // IE 11 => return version number
        var rv = ua.indexOf('rv:');
        return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
    }

    var edge = ua.indexOf('Edge/');
    if (edge > 0) {
        // IE 12 => return version number
        return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
    }

    // other browser
    return false;
}

function MakeLocalTimeForQueryString(dtDate, endOfDay, encode) {
    var ment = moment(dtDate).local();
    var date;
    if (endOfDay)
        date = ment.endOf('day').format();
    date = ment.format();
    if (encode)
        return encodeURIComponent(date)
    return date;
}

function CleanString(input, strict) {
    if (strict)
        return input.replace(/([^a-z0-9]+)/gi, '-');
    else
        return input.replace(/[|&;$%@"'<>()+,]/g, "");
}


var spinnerOptions = {
    lines: 15 // The number of lines to draw
, length: 56 // The length of each line
, width: 14 // The line thickness
, radius: 42 // The radius of the inner circle
, scale: .7 // Scales overall size of the spinner
, corners: 1 // Corner roundness (0..1)
, color: '#000' // #rgb or #rrggbb or array of colors
, opacity: 0.25 // Opacity of the lines
, rotate: 0 // The rotation offset
, direction: 1 // 1: clockwise, -1: counterclockwise
, speed: 1.3 // Rounds per second
, trail: 60 // Afterglow percentage
, fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
, zIndex: 2e9 // The z-index (defaults to 2000000000)
, className: 'spinner' // The CSS class to assign to the spinner
, top: '50%' // Top position relative to parent
, left: '50%' // Left position relative to parent
, shadow: false // Whether to render a shadow
, hwaccel: false // Whether to use hardware acceleration
, position: 'absolute' // Element positioning
}
var spinner = new Spinner(spinnerOptions);


function copyStringToClipboard(str) {
    if (navigator && navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(str).then(function () {
            console.log('Copied to clipboard successfully!');
        }, function () {
            console.error('Unable to write to clipboard. : - (');
        });
    }
    else {
        // Create new element
        var el = document.createElement('textarea');
        // Set value (string to be copied)
        el.value = str;
        // Set non-editable to avoid focus and move outside of view
        el.setAttribute('readonly', '');
        el.style = { position: 'absolute', left: '-9999px' };
        document.body.appendChild(el);
        // Select text inside element
        el.select();
        // Copy text to clipboard
        document.execCommand('copy');
        // Remove temporary element
        document.body.removeChild(el);
    }
}