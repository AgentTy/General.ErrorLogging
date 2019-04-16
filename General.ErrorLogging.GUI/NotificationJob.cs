using General.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using WebBackgrounder;

namespace General.ErrorLogging.GUI
{
    public class NotificationJob : Job
    {

        public struct NotificationResult
        {
            public bool Success;
            public int MessageCount;
            public string Detail;
            public bool SMSSent;
            public bool EmailSent;
        }


        public NotificationJob(TimeSpan interval, TimeSpan timeout)
            : base("Notifications Job", interval, timeout)
        {

        }

        public override Task Execute()
        {
            return new Task(() => SendNotifications());
        }

        protected void SendNotifications()
        {
            var pendingTriggers = General.ErrorLogging.Data.ErrorOtherLogTrigger.GetPendingTriggers();
            foreach (var trigger in pendingTriggers)
            {
                try
                {
                    var result = NotifyByTrigger(trigger);
                    if (result.Success || result.SMSSent || result.EmailSent)
                        General.ErrorLogging.Data.ErrorOtherLogTrigger.MarkAsProcessed(trigger.ID, result.Success, result.SMSSent, result.EmailSent, result.Detail);
                }
                catch (Exception ex)
                {
                    ApplicationContext context;
                    try
                    {
                        context = ErrorLogging.GetApplicationContext();
                    }
                    catch { context = new ApplicationContext(); }

                    if(trigger.Event.AppID > 0) //Don't report errors on yourself, it could create a loop of errors.
                        ErrorReporter.ReportError(ex, context);
                }
            }

        }

        protected NotificationResult NotifyByTrigger(General.ErrorLogging.Model.ErrorOtherLogTrigger Data)
        {
            NotificationResult result = new NotificationResult();
            result.Success = true;

            //Send email?
            try
            {
                if (Data.Filter != null && Data.Filter.PageEmail != null && Data.Filter.PageEmail.Valid)
                {
                    var oneResult = SendEmail(General.Debugging.Report.ErrorEmailFrom, Data.Filter.PageEmail, GetEventSubjectForEmail(Data), GetEventSummaryForEmail(Data), true);
                    if (oneResult.Success)
                    {
                        result.EmailSent = true;
                        result.MessageCount += oneResult.MessageCount;
                    }
                    else
                        result.Success = false;
                    if (!String.IsNullOrWhiteSpace(oneResult.Detail))
                        result.Detail += oneResult.Detail + "\r\n";
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Detail = General.Debugging.ErrorReporter.GetErrorReport(ex, "\r\n").ToString();

                if (Data.Event.AppID > 0) //Don't report errors on yourself, it could create a loop of errors.
                    ErrorReporter.ReportError(ex);
            }

            try
            {
                //Send SMS message?
                if (Data.Filter != null && Data.Filter.PageSMS != null && Data.Filter.PageSMS.Valid)
                {
                    var oneResult = SendSMS(Data.Filter.PageSMS, GetEventSummaryForSMS(Data));
                    if (oneResult.Success)
                    {
                        result.SMSSent = true;
                        result.MessageCount += oneResult.MessageCount;
                    }
                    else
                        result.Success = false;
                    if (!String.IsNullOrWhiteSpace(oneResult.Detail))
                        result.Detail += oneResult.Detail + "\r\n";
                }
            }
            catch (Exception ex)
            {
                result.Success = false;
                result.Detail = General.Debugging.ErrorReporter.GetErrorReport(ex, "\r\n").ToString();

                if (Data.Event.AppID > 0) //Don't report errors on yourself, it could create a loop of errors.
                    ErrorReporter.ReportError(ex);
            }
            return result;
        }

        public static NotificationResult SendEmail(EmailAddress From, EmailAddress To, String Subject, String Body, Boolean IsHtml)
        {
            NotificationResult result = new NotificationResult();
            if (General.Mail.MailTools.SendEmail(From, To, Subject, Body, IsHtml))
            {
                result.Success = true;
                result.MessageCount = 1;
            }
            return result;
        }

        public static NotificationResult SendSMS(PhoneNumber To, String Message)
        {
            NotificationResult result = new NotificationResult();
            var twilio = new Twilio.TwilioRestClient(Settings.TwilioAccount, Settings.TwilioToken);
            var sms = twilio.SendMessage(Settings.TwilioPhoneNumber, To.ToInternationalDialString(), Message);
            if (sms.ErrorCode.HasValue)
            {
                result.Success = false;
                result.MessageCount = 0;
                result.Detail = sms.ErrorMessage;
            }
            else
            {
                result.Success = true;
                result.MessageCount = 1;
                if (sms.Status != "queued")
                    result.Detail = sms.Status;
            }
            return result;
        }

        protected string GetEventSubjectForEmail(General.ErrorLogging.Model.ErrorOtherLogTrigger Data)
        {
            try
            {
                string strSubject = Settings.EventNotificationSubjectPrefix;
                if (!String.IsNullOrWhiteSpace(strSubject)) {
                    if(strSubject.Contains("]"))
                        strSubject += " ";
                    else
                        strSubject += ": ";
                }

                if (Data.Event.EventType != Model.ErrorOtherTypes.Unknown)
                    strSubject += General.Reflection.EnumSerializer.GetDisplayName<General.ErrorLogging.Model.ErrorOtherTypes>(Data.Event.EventType);
                if (!String.IsNullOrWhiteSpace(Data.Event.AppName))
                    strSubject += " " + Data.Event.AppName;
                return strSubject;
            }
            catch { return "Application Event Matched Your Filters"; }
        }

        protected string GetEventSummaryForEmail(General.ErrorLogging.Model.ErrorOtherLogTrigger Data)
        {
            string s = "";
            s += "App: " + Data.Event.AppName + "<br/>";
            try
            {
                string strEventName = General.Debugging.ErrorReporter.SanitizeString(Data.Event.EventName);
                if (!String.IsNullOrWhiteSpace(strEventName))
                {
                    s += "Msg: " + LimitStr(strEventName, 150) + "<br/>";
                }
            }
            catch { }
            if (!String.IsNullOrWhiteSpace(Data.Event.ClientID))
                s += "ClientID: " + Data.Event.ClientID + "<br/>";
            if (!String.IsNullOrWhiteSpace(Data.Event.UserType))
                s += "UserType: " + Data.Event.UserType + "<br/>";
            else if (!String.IsNullOrWhiteSpace(Data.Event.UserID))
                s += "UserID: " + Data.Event.UserID + "<br/>";
            s += "Environment: " + Data.Event.Environment.ToString() + "<br/>";
            if (String.IsNullOrWhiteSpace(Data.Filter.Name))
                s += "Filter: " + Data.Filter.ID.ToString() + "<br/>";
            else
                s += "Filter: " + Data.Filter.Name + "<br/>";
            s += "Detail: " + GetEventViewLink(Data.Event.IncidentCode) + "<br/>";
            return s;
        }

        protected string GetEventSummaryForSMS(General.ErrorLogging.Model.ErrorOtherLogTrigger Data)
        {
            //Max length is 160 chars, about 60 will be used up by the Prefix and EventViewLink
            string strMessage = Settings.EventNotificationSubjectPrefix;
            if (!String.IsNullOrWhiteSpace(strMessage))
                strMessage += ": ";
            if (Data.Event.EventType != Model.ErrorOtherTypes.Unknown)
                strMessage += LimitStr(Data.Event.EventType.ToString(), 10) + "\n";
            if (!String.IsNullOrWhiteSpace(Data.Event.EventName))
                strMessage += LimitStr(Data.Event.EventName, 45) + "\n";
            if (!String.IsNullOrWhiteSpace(Data.Event.AppName))
                strMessage += LimitStr(Data.Event.AppName, 25) + "\n";
            strMessage += "\n" + GetEventViewLink(Data.Event.IncidentCode);
            if (!String.IsNullOrWhiteSpace(Data.Filter.Name))
                strMessage += "\n(" + LimitStr(Data.Filter.Name.Replace("filter","fltr").Replace("Filter","Fltr"), 20) + ")";
            return strMessage;
        }

        protected string GetEventViewLink(string IncidentCode)
        {
            return Settings.HostedURI + "/Lookup?IC=" + IncidentCode;
        }

        protected string LimitStr(string input, int maxLen)
        {
            if (String.IsNullOrWhiteSpace(input))
                return "";
            if (input.Length > maxLen)
                return input.Substring(0, maxLen);
            return input;
        }


    }
}