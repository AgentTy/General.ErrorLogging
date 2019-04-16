intellisense.annotate(window, {
    // The ErrorLogger class is a wrapper for the General.ErrorLogging API. You can use it to capture and store errors as well as trace level events in your web site. 
    // You must use the RegisterApplication method to enable manual logging, and call the ListenGlobal method to capture unhandled exceptions in the browser.
    ErrorLogger: undefined
});

intellisense.annotate(ErrorLogger, {
    //Log errors to javascript console
    DoConsole: undefined,
    //Store recent events in a cookie
    CookieEnabled: undefined,
    //The optional domain to store cookies in
    CookieDomain: undefined,
    //Set sliding expiration date of any cookie
    HistoryCookieDays: undefined,
    //Number of events to store in cookie
    HistoryCookieMax: undefined,
    //Accessor for the AppContextModel that was setup by the RegisterApplication method.
    AppContext: undefined,
    //The URI of the General.ErrorLogging API to communicate with
    APIEndpoint: undefined,
    //The delay (in ms) between pings to the logging server for updated filters (default: 5 minutes)
    PollingInterval: undefined,
    //The most recently recorded event
    LastEvent: undefined,
    //Recent events on this browser+domain (requires cookies)
    EventHistory: undefined,
    //The status of the ErrorLogger, returns false if the logger is paused or unregistered
    Active: undefined,
    //Accessor for the logging filters that apply to this instance of the application
    Filters: undefined,
    //An enumeration of all the types of events that can be recorded.
    //Access a value like: ErrorLogger.EventTypes.Javascript 
    //Access the Name: ErrorLogger.EventTypes.Properties[ErrorLogger.EventTypes.Javascript].Name
    //Access the Description: ErrorLogger.EventTypes.Properties[ErrorLogger.EventTypes.Javascript].Description
    EventTypes: undefined,

    //An enumeration of recommended severity levels for prioritizing your events. This enumeration is optional, you can use any integer for severity.
    //Access a value like: ErrorLogger.SeverityTypes.Low 
    //Access the Name: ErrorLogger.SeverityTypes.Properties[ErrorLogger.SeverityTypes.Normal].Name
    //Access the Description: ErrorLogger.SeverityTypes.Properties[ErrorLogger.SeverityTypes.High].Description
    SeverityTypes: undefined,

    'ReportError': function () {
        /// <signature>
        ///   <summary>Check an event against all active filters, and store it in the database if there is a match... or if no filters are setup.</summary>
        ///   <param name="strName" type="String">The name of the event</param>
        ///   <param name="intSeverity" type="Number">(optional) ENUM: SeverityTypes, How important is this event</param>
        ///   <param name="strDetails" type="String">More information about the event</param>
        ///   <param name="intCustomID" type="Number">(optional) A data key to attach to the log</param>
        ///   <param name="blnNotifyListener" type="Boolean">If true, this error will cause your global error listener to fire upon completion, there you will get the Incident Code.</param>
        /// </signature>
    },

    'ReportWarning': function () {
        /// <signature>
        ///   <summary>Check an event against all active filters, and store it in the database if there is a match... or if no filters are setup.</summary>
        ///   <param name="strName" type="String">The name of the event</param>
        ///   <param name="intSeverity" type="Number">(optional) ENUM: SeverityTypes, How important is this event</param>
        ///   <param name="strDetails" type="String">More information about the event</param>
        ///   <param name="intCustomID" type="Number">(optional) A data key to attach to the log</param>
        /// </signature>
    },

    'ReportAudit': function () {
        /// <signature>
        ///   <summary>Check an event against all active filters, and store it in the database if there is a match... or if no filters are setup.</summary>
        ///   <param name="strName" type="String">The name of the event</param>
        ///   <param name="intSeverity" type="Number">(optional) ENUM: SeverityTypes, How important is this event</param>
        ///   <param name="strDetails" type="String">More information about the event</param>
        ///   <param name="intCustomID" type="Number">(optional) A data key to attach to the log</param>
        /// </signature>
    },

    'ReportTrace': function () {
        /// <signature>
        ///   <summary>Check an event against all active filters, and store it in the database if there is a match... or if no filters are setup.</summary>
        ///   <param name="strName" type="String">The name of the event</param>
        ///   <param name="intSeverity" type="Number">(optional) ENUM: SeverityTypes, How important is this event</param>
        ///   <param name="strDetails" type="String">More information about the event</param>
        ///   <param name="intCustomID" type="Number">(optional) A data key to attach to the log</param>
        /// </signature>
    },

    'ReportEvent': function() {
        /// <signature>
        ///   <summary>Check an event against all active filters, and store it in the database if there is a match... or if no filters are setup.</summary>
        ///   <param name="objEventContext" type="EventContextModel">The EventContextModel to store</param>
        /// </signature>
    },

    'AppContextModel': function () {
        /// <signature>
        ///   <summary>Get an empty Application Context model.</summary>
        ///   <param name="intAppID" type="Number">The ID of this application, refers to table [dbo].[Application] in General.ErrorLogging Database.</param>
        ///   <param name="strAppName" type="String">A reader friendly name for this appliction, will be used to populate [dbo].[Application] when new apps are registered.</param>
        ///   <param name="strEnvironment" type="String">The hosting environment of this instance, Dev, QA, Stage, or Live.</param>
        ///   <returns type="AppContextModel" />
        /// </signature>
    },
    'EventContextModel': function () {
        /// <signature>
        ///   <summary>Get an empty Event Context model.</summary>
        ///   <param name="strEventName" type="String">A name for this event, multple events with the same name (plus other matching fields) will be aggregated in the log table rather than duplicated.</param>
        ///   <param name="objEventType" type="ErrorLogger.EventTypes">Use the EventType enum to classify this event</param>
        ///   <param name="intSeverity" type="Number">How important is this event? Enter your estimate as an integer value.</param>
        ///   <returns type="AppContextModel" />
        /// </signature>
    },
    'RegisterApplication': function () {
        /// <signature>
        ///   <summary>Initialize the ErrorLogger with your applications context and API credentials, and begins polling the API for active filters</summary>
        ///   <param name="strAPIEndpoint" type="String">The URI for the ErrorLogging API</param>
        ///   <param name="strAccessCode" type="String">Your API Access Code</param>
        ///   <param name="objAppContext" type="AppContextModel">The context variables for this application instance, includes AppID and AppName as well as ClientID, UserID, and Environment</param>
        /// </signature>
    },
    'ListenGlobal': function () {
        /// <signature>
        ///   <summary>Enables automatic capturing of unhandled errors via window.onerror</summary>
        /// </signature>
    },
    'Pause': function () {
        /// <signature>
        ///   <summary>Pause error logging and polling for filters</summary>
        /// </signature>
    },
    'Resume': function () {
        /// <signature>
        ///   <summary>Resume error logging and polling for filters</summary>
        /// </signature>
    },
    'Ready': function () {
        /// <signature>
        ///   <summary>Checks the active configuration and returns a report on it's ability to operate</summary>
        ///   <returns type="{isReady: Boolean, detail: String}" />
        /// </signature>
    },
    'ReadError': function () {
        /// <signature>
        ///   <summary>Parses a javascript error object and returns a EventContextModel that is ready to post</summary>
        ///   <param name="jsErrorObj" type="Error">The error to parse</param>
        ///   <returns type="EventContextModel" />
        /// </signature>
    },
    'ShouldStoreEvent': function () {
        /// <signature>
        ///   <summary>Checks an EventContextModel against active filters and returns a decision, to store this error or not</summary>
        ///   <param name="objEventContext" type="EventContextModel">The EventContextModel to match against the active filters</param>
        ///   <returns type="Boolean" />
        /// </signature>
    },
    'StoreEvent': function () {
        /// <signature>
        ///   <summary>Accepts an EventContextModel and posts it to the API via AJAX</summary>
        ///   <param name="objEventContext" type="EventContextModel">The EventContextModel to store</param>
        ///   <returns type="String" name="IncidentCode (Base16 encoded ErrorOtherLog.ID)" />
        /// </signature>
    },
    'LoadFilters': function () {
        /// <signature>
        ///   <summary>Manually load updated filters from the API. This will happen automatically on a scheduled basis so you should never need to call this method.</summary>
        /// </signature>
    }
});
