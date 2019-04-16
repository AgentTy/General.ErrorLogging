/// <reference path="General.ErrorLogging.intellisense.js" />
// General.ErrorLogging.js (copyright 2016 Ty Hansen)
(function (ns) {
    var APIActionPattern_RecordEvent = '/api/[AppID]/ErrorLog/RecordEvent/';
    var APIActionPattern_GetFilters = '/api/[AppID]/LoggingFilter/ActiveFiltersInContext';
    var GUIActionURL_ViewEvent = '/Lookup?IC=[IncidentCode]'
    var HistoryCookie = 'GenErrLogHist';
    var AccessCode = '';
    var UseLocalStorage = supportsStorage();
    ns.DoConsole = true;
    ns.LocalHistoryEnabled = true;
    ns.LocalHistoryMax = 30;
    ns.CookieDomain = null;
    ns.HistoryCookieDays = 60;
    ns.PollingInterval = 300000; //5 Minutes
    ns.APIEndpoint = null;
    ns.APIActionPath_RecordEvent = null;
    ns.APIActionPath_GetFilters = null;
    ns.LastEvent = null;
    ns.EventHistory = null;
    ns.Active = false;
    ns.Filters = null;
    ns.Listener = null;

    ns.EventTypes = {
        //Managed Code errors and other server side exceptions
        Server: "Server",
        //SQL Server errors
        SQL: "SQL",
        //SQL Server connectivity errors
        SQLConnectivity: "SQLConnectivity",
        //SQL Server timeouts
        SQLTimeout: "SQLTimeout",
        //Client side javascript errors
        Javascript: "Javascript",
        //A warning level trace record
        Warning: "Warning",
        //An audit level trace record
        Audit: "Audit",
        //A trace record
        Trace: "Trace",
        //An authentication event
        Auth: "Auth",
        //Access the enumerations Name, Value, and Description
        Properties: {
            "Server": { Name: "Server", Value: 1, Description: "Managed Code errors and other server side exceptions" },
            "SQL": { Name: "SQL", Value: 2, Description: "SQL Server errors" },
            "SQLConnectivity": { Name: "SQL Connectivity", Value: 3, Description: "SQL Server connectivity errors" },
            "SQLTimeout": { Name: "SQL Timeout", Value: 4, Description: "SQL Server timeouts" },
            "Javascript": { Name: "Javascript", Value: 6, Description: "Client side javascript errors" },
            "Warning": { Name: "Warning", Value: 10, Description: "A warning level trace record" },
            "Audit": { Name: "Audit", Value: 11, Description: "An audit level trace record" },
            "Trace": { Name: "Trace", Value: 12, Description: "A trace record" },
            "Auth": { Name: "Auth", Value: 13, Description: "An authentication event" }
        }
    };

    ns.SeverityTypes = {
        //Managed Code errors and other server side exceptions
        Low: 1,
        //SQL Server errors
        Normal: 5,
        //SQL Server connectivity errors
        High: 10,
        //Access the enumerations Name, Value, and Description
        Properties: {
            1: { Name: "Low Severity", Value: 1, Description: "Low Severity Event" },
            5: { Name: "Normal Severity", Value: 5, Description: "Normal Severity Event" },
            10: { Name: "High Severity", Value: 10, Description: "High Severity Event" },
        }
    };

    ns.AppContextModel = function (intAppID, strAppName, strEnvironment) {
        return {
            ClientID: null,
            UserType: null,
            UserID: null,
            CustomID: null,
            Custom1: null,
            Custom2: null,
            Custom3: null,
            AppID: intAppID,
            AppName: strAppName,
            Environment: strEnvironment,

            Validate: function (model) {
                if (!model)
                    model = this;

                var strProblem = '';
                var blnResult = true;
                if ((!model.AppID && model.AppID != 0) || isNaN(model.AppID))
                {
                    strProblem += 'AppContext.AppID is invalid. ';
                    blnResult = false;
                }
                if (!model.Environment)
                {
                    strProblem += 'AppContext.Environment is null. ';
                    blnResult = false;
                }
                if (!(/dev|1|qa|2|stage|3|customenv|4|live|5/).test(model.Environment.toLowerCase()))
                {
                    strProblem += 'AppContext.Environment is invalid. ';
                    blnResult = false;
                }
                return { isValid: blnResult, detail: strProblem };
            }
        }
    }

    ns.AppContext = ns.AppContextModel();

    ns.EventContextModel = function (strEventName, objEventType, intSeverity) {
        return {
            EventType: objEventType,
            Severity: intSeverity,
            ErrorCode: null,
            EventName: strEventName,
            ExceptionType: null,
            MethodName: null,
            FileName: null,
            LineNumber: 0,
            ColumnNumber: 0,
            URL: window.location.href,
            UserAgent: navigator.userAgent,
            Details: null,
            Duration: null,

            //Not part of actual model
            ShouldNotifyListener: false,
            SavedToDatabase: false,
            IncidentCode: null,

            Validate: function (model) {
                if (!model)
                    model = this;

                var strProblem = '';
                var blnResult = true;
                if (!model.EventName)
                {
                    strProblem += 'Event Name is required';
                    blnResult = false;
                }
                return { isValid: blnResult, detail: strProblem };
            }
        }
    }

    //Setup Application Context data
    ns.RegisterApplication = function (strAPIEndpoint, strAccessCode, objAppContext) {
        if (strAPIEndpoint)
            strAPIEndpoint = strAPIEndpoint.replace(/\/+$/, '');
        this.APIEndpoint = strAPIEndpoint;
        AccessCode = strAccessCode;
        this.AppContext = objAppContext;
        
        var ready = this.Ready();
        if (ready.isReady)
        {
            this.APIActionPath_RecordEvent = APIActionPattern_RecordEvent.replace('[AppID]', this.AppContext.AppID);
            this.APIActionPath_GetFilters = APIActionPattern_GetFilters.replace('[AppID]', this.AppContext.AppID);
            this.LoadFilters();
            StartFilterTimer();
        }
        else
            throw new Error(ready.detail + ' Event Logging cannot be started until a valid API Endpoint and Application Context have been set.');
    }

    //Start monitoring unhandled exceptions
    ns.ListenGlobal = function (fnListener) {
        var ready = this.Ready();
        if (!ready.isReady)
            throw new Error(ready.detail + ' Event Logging cannot be started until a valid API Endpoint and Application Context have been set via ErrorLogger.RegisterApplication.');
        else
        {
            window.onerror = HandleError;
            this.Listener = fnListener;
            this.Active = true;
        }
    };

    //Pause logging
    ns.Pause = function () {
        window.onerror = null;
        StopFilterTimer();
        this.Active = false;
    }

    //Resume logging
    ns.Resume = function () {
        window.onerror = HandleError;
        StartFilterTimer();
        this.Active = true;
    }

    //Library is setup and ready to use
    ns.Ready = function () {
        var strProblem = '';
        var blnResult = true;
        if (!this.APIEndpoint) {
            strProblem += 'APIEndpoint is invalid. ';
            blnResult = false;
        }
        if (!this.AppContext) {
            strProblem += 'AppContext is null. ';
            blnResult = false;
        }
        if (this.AppContext && this.AppContext.Validate) {
            var result = this.AppContext.Validate();
            if (!result.isValid) {
                strProblem += result.detail + 'AppContext is invalid. ';
                blnResult = false;
            }
        }
        else if (this.AppContext && !this.AppContext.Validate) {
            var result = this.AppContextModel().Validate(this.AppContext);
            if (!result.isValid) {
                strProblem += result.detail + 'AppContext is invalid. ';
                blnResult = false;
            }
        }
        return { isReady: blnResult, detail: strProblem };
    }

    ns.ReportError = function (strName, intSeverity, strDetails, intCustomID, blnNotifyListener) {
        PrepAndReportEvent(strName, ErrorLogger.EventTypes.Javascript, intSeverity, strDetails, intCustomID, blnNotifyListener);
    }

    ns.ReportWarning = function (strName, intSeverity, strDetails, intCustomID) {
        PrepAndReportEvent(strName, ErrorLogger.EventTypes.Warning, intSeverity, strDetails, intCustomID, false);
    }

    ns.ReportAudit = function (strName, intSeverity, strDetails, intCustomID) {
        PrepAndReportEvent(strName, ErrorLogger.EventTypes.Audit, intSeverity, strDetails, intCustomID, false);
    }

    ns.ReportTrace = function (strName, intSeverity, strDetails, intCustomID) {
        PrepAndReportEvent(strName, ErrorLogger.EventTypes.Trace, intSeverity, strDetails, intCustomID, false);
    }

    function PrepAndReportEvent(strName, enuEventType, intSeverity, strDetails, intCustomID, blnNotifyListener) {
        var evt = new ErrorLogger.EventContextModel(strName, enuEventType, intSeverity);
        evt.Details = strDetails;
        evt.ShouldNotifyListener = blnNotifyListener;
        if (intCustomID)
            ErrorLogger.AppContext.CustomID = intCustomID;
        try {
            ErrorLogger.ReportEvent(evt);
        } catch (e) { if (typeof console !== 'undefined' && ns.DoConsole) console.log(e); }
    }

    ns.ReportEvent = function (objEventContext) {
        //I will store this event if it matches any filters
        var objFilterContext = ErrorLogger.ShouldStoreEvent(objEventContext);
        if (objFilterContext.IShouldStoreEvent) {
            ErrorLogger.StoreEvent(objEventContext, objFilterContext);
        }
    }

    //window.onerror function call
    var InternalErrorLoopCount = 0;
    function HandleError(errorMsg, file, lineNumber, column, jsErrorObj) {
        //if (errorMsg.indexOf('Script error.') > -1) //http://stackoverflow.com/questions/5913978/cryptic-script-error-reported-in-javascript-in-chrome-and-firefox
        //    return;
        
        var ex;
        if (typeof jsErrorObj !== 'undefined' && jsErrorObj != null)
            ex = ErrorLogger.ReadError(jsErrorObj);
        else
            ex = ErrorLogger.EventContextModel(errorMsg, ErrorLogger.EventTypes.Javascript);
        ex.ShouldNotifyListener = true;

        try {
            if (lineNumber)
                ex.LineNumber = parseInt(lineNumber);
            if (column)
                ex.ColumnNumber = parseInt(column);
        } catch (e) { if (typeof console !== 'undefined' && ns.DoConsole) console.log(e); }

        try {
            ex.FileName = RemoveHostFromURL(file);
            if (ex.FileName.indexOf('General.ErrorLogging.js') > -1) {
                InternalErrorLoopCount++;
                if (InternalErrorLoopCount > 1)
                    return; //Stop an infinite loop of errors if this library is being buggy
            }
            else
                InternalErrorLoopCount = 0;
        } catch (e) { if (typeof console !== 'undefined' && ns.DoConsole) console.log(e); }

        try {
            ErrorLogger.ReportEvent(ex);
        } catch (e) { if (typeof console !== 'undefined' && ns.DoConsole) console.log(e); }
    }

    ns.ReadError = function(jsErrorObj)
    {
        var ex;
        if (jsErrorObj != null && typeof jsErrorObj !== 'undefined' && typeof jsErrorObj.message !== 'undefined') {
            ex = new ErrorLogger.EventContextModel(jsErrorObj.message, ErrorLogger.EventTypes.Javascript);
            if (jsErrorObj.name)
                ex.ExceptionType = jsErrorObj.name;

            //I'm not going to collect this for now, because it seems to be IE only and it makes duplicate rows in the report since the 'number' can be different for each browser.
            //if(jsErrorObj.number) 
            //    ex.ErrorCode = jsErrorObj.number;

            ex.Details = '';
            if (jsErrorObj.stack)
            {
                ex.Details += 'Stack: ' + jsErrorObj.stack + '\r\n';

                try {
                    //Attempt to get the file name, line number, and column number from the stack
                    var fileInfo = GetFileLineColumnFromStack(jsErrorObj.stack);
                    if(fileInfo)
                    {
                        if (fileInfo.MethodName)
                            ex.MethodName = fileInfo.MethodName;
                        if (fileInfo.FileName)
                            ex.FileName = fileInfo.FileName;
                        if (fileInfo.LineNumber)
                            ex.LineNumber = fileInfo.LineNumber;
                        if (fileInfo.ColumnNumber)
                            ex.ColumnNumber = fileInfo.ColumnNumber;
                    }
                } catch (e) { }
            }
            if (jsErrorObj.description && jsErrorObj.description != ex.EventName)
                ex.Details += 'Description: ' + jsErrorObj.description + '\r\n';
            if (jsErrorObj.toSource)
                ex.Details += '\r\n\r\nSource: ' + jsErrorObj.toSource() + '\r\n';
            if (jsErrorObj.toString)
                ex.Details += '\r\n\r\n ' + jsErrorObj.toString() + '\r\n';
        }
        else
        {
            ex = new ErrorLogger.EventContextModel(jsErrorObj, ErrorLogger.EventTypes.Javascript);
        }
        return ex;
    }

    ns.ShouldStoreEvent = function (objEventContext)
    {
        if (ErrorLogger.Filters && ErrorLogger.Filters.length > 0) {
            var match = false;
            var aryMatches = [];
            $.each(ErrorLogger.Filters, function (index, filter) {
                if (filter.EventFilter.all) {
                    match = true;
                    aryMatches.push(filter.ID);
                }
                else if (filter.EventFilter.events && filter.EventFilter.events.length > 0) {
                    for (var i = 0; i < filter.EventFilter.events.length; i++) {
                        if (filter.EventFilter.events[i] == objEventContext.EventType) {
                            match = true;
                            aryMatches.push(filter.ID);
                        }
                    }
                }
            });
            return {
                IShouldStoreEvent: match,
                MatchedFilters: aryMatches
            };
        }
        else //There are no filters available, so I'm going to store everything.
            return {
                IShouldStoreEvent: true,
                MatchedFilters: []
            };
    }

    ns.StoreEvent = function(objEventContext, objFilterContext)
    {
        //Add on the UserAgent and current URL when available
        try {
            if (!objEventContext.UserAgent)
                objEventContext.UserAgent = navigator.userAgent;
            if (!objEventContext.URL)
                objEventContext.URL = window.location.href;
        } catch (e) { if (typeof console !== 'undefined' && ns.DoConsole) console.log(e); }

        //POST to API
        try {
            PostData(ErrorLogger.APIActionPath_RecordEvent,
            {
                AccessCode: AccessCode,
                EventContext: objEventContext,
                AppContext: ErrorLogger.AppContext,
                FilterContext: objFilterContext
            },
            function (data) {
                if (data.Success)
                {
                    objEventContext.SavedToDatabase = true;
                    objEventContext.IncidentCode = data.IncidentCode;
                    AddHistory(data.IncidentCode, objEventContext.EventName);
                }
                else
                {
                    objEventContext.SavedToDatabase = false;
                    console.log('An attempt was made to report an issue with this application but did not succeed due to a server side error.');
                    AddHistory('unknown', objEventContext.EventName);
                }
                ErrorLogger.LastEvent = objEventContext;
                if(ErrorLogger.Listener && objEventContext.ShouldNotifyListener)
                    ErrorLogger.Listener(objEventContext);
            },
            function (jqXHR, textStatus, errorThrown) {
                if (typeof console !== 'undefined' && ns.DoConsole)
                    console.log('An attempt was made to report an issue with this application but did not succeed due to a communication error.');
            });
        }
        catch(e)
        {
            console.log('An attempt was made to report an issue with this application but did not succeed. (' + e.name + ')')
        }
    }

    ns.LoadFilters = function () {
        PostData(ErrorLogger.APIActionPath_GetFilters,
             {
                AccessCode: AccessCode,
                AppContext: ErrorLogger.AppContext
             },
            function (data) {
                ErrorLogger.Filters = data;
             },
            function (jqXHR, textStatus, errorThrown) {
                if (typeof console !== 'undefined' && ns.DoConsole)
                    console.log('Unable to load error logging filters')
            });
    }

    ns.DisplayHistory = function (domContainer) {
        var intResult = 0;
        var tblID = 'tblGenErrLocalHistory';
        var tbl = $('<table id="' + tblID + '"> <thead> <tr> <td colspan="3">Recent javascript errors/events recorded for this browser on this site are listed here. *requires cookies</td></tr><tr> <td>Time (local)</td><td>Incident Code</td><td>Name</td></tr></thead> <tbody> </tbody> </table>');
        var tbody = tbl.find('tbody')[0];

        if (ns.EventHistory && ns.EventHistory.History.length > 0) {
            intResult = ns.EventHistory.History.length;
            $.each(ns.EventHistory.History, function (index) {
                var err = ns.EventHistory.History[index];
                var row = $('<tr>');
                if (err.Time) {
                    var objDate = new Date(err.Time);
                    $('<td>').text(objDate.toLocaleDateString() + ' ' + objDate.toLocaleTimeString()).appendTo(row);
                }
                else
                    $('<td>').text('unknown').appendTo(row);
                if (err.IC != 'unknown' && ns.APIEndpoint)
                    $('<a>').attr('href', ns.APIEndpoint + GUIActionURL_ViewEvent.replace('[IncidentCode]', err.IC)).text(err.IC).appendTo($('<td>').appendTo(row));
                else
                    $('<td>').text(err.IC).appendTo(row);
                if (err.Name)
                    $('<td>').text(decodeURIComponent(err.Name)).appendTo(row);
                else
                    $('<td>').text('unknown').appendTo(row);
                row.appendTo(tbody);
            });
        }
        else {
            $('<tr> <td colspan="3">No events found, cookie expires after ' + ns.HistoryCookieDays + ' days</td> </tr>').appendTo(tbody);
        }

        $('#' + tblID).remove();
        if (domContainer)
            tbl.appendTo(domContainer);
        else
            tbl.appendTo($('body')[0]);

        return intResult;
    }

    var FilterTimer;
    function StartFilterTimer()
    {
        FilterTimer = setInterval(function () { ErrorLogger.LoadFilters(); }, ErrorLogger.PollingInterval);
    }

    function StopFilterTimer() {
        clearInterval(FilterTimer);
    }

    function PostData(strActionPath, objData, fnSuccess, fnFail) {
        jQuery.support.cors = true;
        $.ajax({
            type: 'POST',
            url: ErrorLogger.APIEndpoint + strActionPath,
            data: JSON.stringify(objData),
            dataType: 'json',
            contentType: 'application/json; charset=utf-8',
            timeout: 20000, //20 Seconds
            success: function (data, textStatus, jqXHR) {
                if (fnSuccess)
                    fnSuccess(data, textStatus, jqXHR);
            },
            error: function (jqXHR, textStatus, errorThrown) {
                if (typeof console !== 'undefined' && ns.DoConsole)
                    console.log('Could not post to ErrorLogging database: ' + jqXHR.status + ' ' + jqXHR.statusText + '\r\n' + jqXHR.responseText);
                if (fnFail)
                    fnFail(jqXHR, textStatus, errorThrown);
            }
        });
    }

    function RemoveHostFromURL(strURL)
    {
        try{
            var pathArray = strURL.replace('http://','').replace('https://','').split('/');
            var newPath = "";
            for (i = 1; i < pathArray.length; i++) {
                newPath += "/";
                newPath += pathArray[i];
            }
            if (newPath == '')
                newPath = '/';
            return newPath;
        }
        catch(e)
        {
            return strURL;
        }
    }

    function GetFileLineColumnFromStack(strStack)
    {
        var strFileInfo;
        //(http://localhost:49170/Home/ErrorLog:156:21)\n //Chrome,IE
        var aryMatches = strStack.match(/\((.*?)\)\n/);
        if (aryMatches && aryMatches.length > 0) {
            strFileInfo = aryMatches[0].substr(1, aryMatches[0].length - 3); //Remove parenthesis\n
        }
        else {
            //@http://localhost:49170/Home/ErrorLog:156:25\n //Firefox
            aryMatches = strStack.match(/^@(.*?)\n/);
            if (aryMatches && aryMatches.length > 0) {
                strFileInfo = aryMatches[0].substr(1, aryMatches[0].length - 2); //Remove @\n
            }
            else {
                //http://172.16.81.4:49170/Home/ErrorLog#:156:41\n //Safari
                aryMatches = strStack.match(/^http(.*?)\n/);
                if (aryMatches && aryMatches.length > 0) {
                    strFileInfo = aryMatches[0];
                }
            }
        }

        var strMethodName;
        aryMatches = strStack.match(/.*at [^\s]*/);
        if (aryMatches && aryMatches.length > 0) {
            var intOffset = aryMatches[0].indexOf('at ') + 3;
            strMethodName = aryMatches[0].substr(intOffset, aryMatches[0].length - intOffset); //Remove whitespace and "at "
        }

        if (strFileInfo) {
            var aryParts = RemoveHostFromURL(strFileInfo).split(':');
            var strFileName = aryParts[0];
            var intLineNumber = aryParts[1];
            var intColumnNumber = aryParts[2];

            return {
                MethodName: strMethodName,
                FileInfo: strFileInfo,
                FileName: strFileName,
                LineNumber: intLineNumber,
                ColumnNumber: intColumnNumber
            };
        }
        else
            return {
                MethodName: strMethodName,
                FileInfo: null,
                FileName: null,
                LineNumber: null,
                ColumnNumber: null
            };
    }

    function LoadHistory() {
        var empty = { Last: null, History: [] };
        var hist = null;
        if (ns.LocalHistoryEnabled) {
            if (UseLocalStorage) {
                hist = localStorage.getItem(HistoryCookie);
                try {
                    hist = (hist ? JSON.parse(hist) : null)
                } catch (e) {
                    hist = null;
                    if (typeof console !== 'undefined' && ns.DoConsole) console.log(e);
                }
                if (hist && typeof hist.History !== 'undefined') {
                    ns.EventHistory = hist;
                    return;
                }
            }
            hist = getCookie(HistoryCookie);
            try {
                hist = (hist ? JSON.parse(hist) : empty)
            } catch (e) {
                hist = empty;
                if (typeof console !== 'undefined' && ns.DoConsole) console.log(e);
            }
            if (hist && typeof hist.History === 'undefined')
                hist = empty;
            else if (hist && hist.Last && typeof hist.Last.Name === 'undefined')
                hist = readSimpleHistory(hist);
        }
        if (hist) 
            ns.EventHistory = hist;
        else
            ns.EventHistory = empty;
    }

    function AddHistory(IncidentCode, EventName) {
        if (!UseLocalStorage && EventName && EventName.length > 60)
            EventName = EventName.substr(0, 57) + '...';
        else if (UseLocalStorage && EventName && EventName.length > 300)
            EventName = EventName.substr(0, 297) + '...';
        var last =  { IC: IncidentCode, Name: EventName, Time: new Date() };
        ns.EventHistory.Last = last;
        ns.EventHistory.History.unshift(last);
        if (ns.EventHistory.History.length > (UseLocalStorage ? ns.LocalHistoryMax : ns.LocalHistoryMax / 2))
            ns.EventHistory.History.pop();
        if (ns.LocalHistoryEnabled) {
            if (UseLocalStorage) {
                localStorage.setItem(HistoryCookie, JSON.stringify(ns.EventHistory));
                setCookie(HistoryCookie, JSON.stringify(simpleHistory(ns.EventHistory)), ns.HistoryCookieDays);
            }
            else
                setCookie(HistoryCookie, JSON.stringify(ns.EventHistory), ns.HistoryCookieDays);
        }
    }

    function simpleHistory(objHistory) {
        var objSimpleHist = { Last: null, History: [] };
        $.each(objHistory.History, function (index) {
            var err = objHistory.History[index];
            objSimpleHist.History.push(err.IC);
            if (objHistory.Last)
                objSimpleHist.Last = objHistory.Last.IC;
        });
        return objSimpleHist;
    }

    function readSimpleHistory(objSimpleHist) {
        var objHist = { Last: null, History: [] };
        objHist.Last = { IC: objSimpleHist.Last, Name: null, Time: null };
        $.each(objSimpleHist.History, function (index) {
            var err = objSimpleHist.History[index];
            objHist.History.push({ IC: err, Name: null, Time: null });
        });
        return objHist;
    }

    function supportsStorage() {
        var tst = 'testls321';
        try {
            localStorage.setItem(tst, tst);
            localStorage.removeItem(tst);
            return true;
        } catch (e) {
            return false;
        }
    }

    function getCookie(name, b) {
        b = document.cookie.match('(^|;)\\s*' + name + '\\s*=\\s*([^;]+)');
        return b ? decodeURIComponent(b.pop()) : '';
    }

    function setCookie(name, value, days) {
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            var expires = '; expires=' + date.toGMTString();
        }
        else var expires = '';

        var cookiestr = name + '=' + encodeURIComponent(value) + expires + '; path=/';
        if (ns.CookieDomain)
            cookiestr += '; domain=.' + ns.CookieDomain + '; path=/';
        else
            cookiestr += '; path=/';
        document.cookie = cookiestr;
    }

    LoadHistory();
}(this.ErrorLogger = this.ErrorLogger || {}));


