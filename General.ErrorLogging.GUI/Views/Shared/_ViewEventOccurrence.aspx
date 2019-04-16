<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage" %>

<% if (Request.IsAuthenticated) { %>
    <div id="vwEvent" class="ShowTooltips EventView">
        <div class="detail-left">
            <h2 id="detailHeader"><span data-bind="visible: Event.IncidentCode()">#<span data-bind="    text: Event.IncidentCode" id="detailIncidentNumber"></span></span>
                <i data-bind="visible: Event.EventTypeName()" id="detailEventType">type: <span data-bind="    text: Event.EventTypeName, css: Event.GetEventTypeColor()"></span></i>
                <i data-bind="visible: Event.HasSeverity()" id="detailSeverity">severity: <span id="detailSeverity_Number" data-bind="    text: Event.Severity, css: { LowSeverity: Event.Severity() <= 3, MedSeverity: Event.Severity() <= 6 && Event.Severity() > 3, HighSeverity: Event.Severity() > 6 } "></span></i>
                <a style="margin-left:50px;text-decoration:none;color:#777;" data-bind="attr: { href: Event.Permalink() }" onclick="copyStringToClipboard(this.href);return false;">[copy link]</a>
            </h2>
            <h1 data-bind="text: Event.EventName" id="detailEventName" expandableText="100"></h1>
            <h3 id="detailURL"><a data-bind="attr: { href: Event.EventURL }, text: Event.EventURL" target="_blank"></a></h3>

            <ul class="DetailList" data-bind="visible: Event.HasErrorInfo()">
                <li data-bind="visible: Event.CodeFileName()"><label>File: </label><span data-bind="    text: Event.CodeFileName" class="important"></span><span data-bind="visible: Event.CodeLineNumber()" style="padding:0;margin:0;">:<span data-bind="text: Event.CodeLineNumber"  style="padding:0;margin:0;"></span></span></li>
                <li data-bind="visible: Event.CodeMethod()"><label>Method: </label><span data-bind="    text: Event.CodeMethod"></span></li>
                <li data-bind="visible: Event.ExceptionType()"><label>Exception: </label><span data-bind="    text: Event.ExceptionType"></span></li>
                <li data-bind="visible: Event.ErrorCode()"><label>Error Code: </label><span data-bind="    text: Event.ErrorCode"></span></li>
                 <li data-bind="visible: Event.Duration()"><label>Duration: </label><span data-bind="    text: Event.Duration"></span>ms</li>
            </ul>

            <ul class="DetailList DetailHorizontal" data-bind="visible: Event.HasCustomFields()">
                <li data-bind="visible: Event.Custom1()"><label>Custom1: </label><span data-bind="    text: Event.Custom1"></span></li>
                <li data-bind="visible: Event.Custom2()"><label>Custom2: </label><span data-bind="    text: Event.Custom2"></span></li>
                <li data-bind="visible: Event.Custom3()"><label>Custom3: </label><span data-bind="    text: Event.Custom3"></span></li>
            </ul>

            <ul class="DetailList" data-bind="visible: Event.HasAppContextFields()">
                <li data-bind="visible: Event.AppName()"><label>App: </label><span data-bind="    text: Event.AppName"></span> (<em data-bind="text:Event.EnvironmentName"></em>)</li>
                <li data-bind="visible: Event.MachineName()"><label>Server: </label><span data-bind="    text: Event.MachineName"></span></li>
            </ul>

        </div>
        <div class="detail-right">
            <h4 data-bind="text: Event.TimeStampString" id="detailTimeStamp"></h4>
            <div data-bind="visible: Event.Count() > 0" class="column" id="detailDateRange">
                <span id="detailCount" data-bind="text: Event.FormatEventCount()"></span>
                <span data-bind="text: Event.FirstTimeString" id="detailFirstTime"></span>
                <span data-bind="text: Event.LastTimeString" id="detailLastTime"></span>
            </div>
            <div class="column" style="clear:both;">
                <ul class="DetailList" data-bind="visible: Event.HasClientContextFields()">
                    <li data-bind="visible: Event.ClientID()"><label>Last Client: </label><span data-bind="    text: Event.ClientID"></span></li>
                    <li data-bind="visible: Event.UserID()"><label>Last User: </label><span data-bind="    text: Event.UserID"></span></li>
                    <li data-bind="visible: Event.UserType()"><label>Last UserType: </label><span data-bind="    text: Event.UserType"></span></li>
                    <li data-bind="visible: Event.CustomID()"><label>Last Custom ID: </label><span data-bind="    text: Event.CustomID"></span></li>
                </ul>
            </div>
        </div>

        <pre data-bind="visible: Event.EventDetail()" id="detailBody"><code data-bind="    text: Event.EventDetail"></code></pre>
        <i data-bind="visible: Event.UserAgent(), text: Event.UserAgent" id="detailUserAgent"></i>
    </div>
<% } else { %>
    <h2>You must login!</h2>
<% } %>