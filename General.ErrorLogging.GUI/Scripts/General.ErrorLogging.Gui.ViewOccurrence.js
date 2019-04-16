
function EventOccurrenceModel() {
    var self = this;

    self.ID = ko.observable();
    self.IncidentCode = ko.observable();
    self.ErrorOtherID = ko.observable();
    self.TimeStamp = ko.observable();
    self.TimeStampString = ko.observable();

    self.AppID = ko.observable();
    self.Environment = ko.observable();
    self.EnvironmentName = ko.observable();
    self.ClientID = ko.observable();
    self.FirstTime = ko.observable();
    self.FirstTimeString = ko.observable();
    self.LastTime = ko.observable();
    self.LastTimeString = ko.observable();
    self.Count = ko.observable();
    self.EventType = ko.observable();
    self.EventTypeID = ko.observable();
    self.EventTypeName = ko.observable();
    self.Severity = ko.observable();
    self.ErrorCode = ko.observable();
    self.CodeMethod = ko.observable();
    self.CodeFileName = ko.observable();
    self.CodeLineNumber = ko.observable();
    self.CodeColumnNumber = ko.observable();
    self.ExceptionType = ko.observable();
    self.EventName = ko.observable();
    self.EventDetail = ko.observable();
    self.EventURL = ko.observable();
    self.UserAgent = ko.observable();
    self.UserType = ko.observable();
    self.UserID = ko.observable();
    self.CustomID = ko.observable();
    self.AppName = ko.observable();
    self.MachineName = ko.observable();
    self.Custom1 = ko.observable();
    self.Custom2 = ko.observable();
    self.Custom3 = ko.observable();
    self.Duration = ko.observable();

    self.Permalink = function () {
        return '/Lookup?IC=' + self.IncidentCode();
    };

    self.FormatEventCount = function () {
        return self.Count();
    };
    self.HasSeverity = function () {
        return self.Severity() && self.Severity() > 0;
    };
    self.HasErrorInfo = function () {
        return self.CodeFileName() || self.CodeMethod() || self.ExceptionType() || self.ErrorCode() || self.Duration();
    };
    self.HasCustomFields = function () {
        return self.Custom1() || self.Custom2() || self.Custom3();
    };
    self.HasAppContextFields = function () {
        return self.AppName() || self.EnvironmentName() || self.MachineName();
    };
    self.HasClientContextFields = function () {
        return self.CustomID() || self.ClientID() || self.UserID() || self.UserType();
    };
    self.GetEventTypeColor = function () {
        var strColorClass = 'ColorDefault'
        if (self.EventTypeID() == 1) //Server Error
            strColorClass = 'ColorServerError';
        if (self.EventTypeID() == 6) //Javascript
            strColorClass = 'ColorJS';
        if (self.EventTypeID() == 2 || self.EventTypeID() == 3 || self.EventTypeID() == 4) //SQL
            strColorClass = 'ColorSQL';
        if (self.EventTypeID() >= 10) //Informational Logs
            strColorClass = 'ColorInfo';
        return strColorClass;
    };
}

function GetEventData(ID, AppID, func) {
    if(!AppID)
        AppID = 'any';
    GetData('/api/' + AppID + '/ErrorLog/Summary?id=' + ID, [], func);
}

function ShowEventDetail(ID, AppID) {
    GetEventData(ID, AppID, function (data) {
        if (data.ID) {
            //Format dates into local time
            var firstTime = moment(data.FirstTime).local();
            var lastTime = moment(data.LastTime).local();
            var timeStamp = moment(data.TimeStamp).local();
            data.FirstTimeString = firstTime.format('lll');
            data.LastTimeString = lastTime.format('lll');
            data.TimeStampString = timeStamp.format('lll');

            ko.mapping.fromJS(data, null, vmEventView.Event);

            if (data.LastIncidentID)
                vmEventView.Event.IncidentCode(data.LastIncidentCode);

            InitExpandableText(dialogDetail);
            dialogDetail.dialog("open");
        }
        else {
            alert(data);
        }
    });
}

function GetOccurrenceData(IC, AppID, func) {
    if(!AppID)
        AppID = 'any';
    GetData('/api/' + AppID + '/ErrorLog/Lookup?IC=' + IC, [], func);
}


function ShowOccurrenceDetail(strIC, AppID) {
    GetOccurrenceData(strIC, AppID, function (data) {
        if (data.ID) {
            //Format dates into local time
            var firstTime = moment(data.FirstTime).local();
            var lastTime = moment(data.LastTime).local();
            var timeStamp = moment(data.TimeStamp).local();
            data.FirstTimeString = firstTime.format('lll');
            data.LastTimeString = lastTime.format('lll');
            data.TimeStampString = timeStamp.format('lll');

            ko.mapping.fromJS(data, null, vmEventView.Event);
            InitExpandableText(dialogDetail);
            dialogDetail.dialog("open");
        }
        else {
            alert(data);
        }
    });
}