using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using General.Model;
using System.Threading.Tasks;

namespace General.ErrorLogging.GUI.Controllers
{
    
    //public class NotificationController : ApiController
    //{


        /*
        public async Task NotifyByFilterAsync(General.ErrorLogging.Client.RecordEventDataContext Data, string IncidentCode)
        {
            await Task.Run(() => NotifyByFilter(Data, IncidentCode));
        }

        public General.ErrorLogging.Client.RecordEventDataContext BackgroundData { get; set; }
        public string BackgroundIncidentCode { get; set; }
        public void NotifyByFilterBackground(object o)
        {
            NotifyByFilter(BackgroundData, BackgroundIncidentCode);
        }
        */
        /*
        // POST api/Notification/NotifyByFilter
        [HttpPost]
        [Authorize]
        public NotificationResult NotifyByFilter(General.ErrorLogging.Client.RecordEventDataContext Data, string IncidentCode)
        {
            NotificationResult result = new NotificationResult();
            //Process notifications
            try
            {
                if (Data.FilterContext != null && Data.FilterContext.MatchedFilters != null && Data.FilterContext.MatchedFilters.Length > 0)
                {
                    foreach (int intFilterID in Data.FilterContext.MatchedFilters)
                    {
                        //Load Filter settings
                        var objFilter = General.ErrorLogging.Data.LoggingFilter.GetFilter(intFilterID);

                        //Send email?
                        if (objFilter != null && objFilter.PageEmail != null && objFilter.PageEmail.Valid)
                        {
                            var oneResult = SendEmail(General.Debugging.Report.ErrorEmailFrom, objFilter.PageEmail, GetEventSubjectForEmail(Data), GetEventSummaryForEmail(Data, IncidentCode, objFilter), true);
                            if (oneResult.Success)
                            {
                                result.Success = true;
                                result.MessageCount += oneResult.MessageCount;
                            }
                            if (!String.IsNullOrWhiteSpace(oneResult.Detail))
                                result.Detail += oneResult.Detail + "\r\n";
                        }

                        //Send SMS message?
                        if (objFilter != null && objFilter.PageSMS != null && objFilter.PageSMS.Valid)
                        {
                            var oneResult = SendSMS(objFilter.PageSMS, GetEventSummaryForSMS(Data, IncidentCode, objFilter));
                            if (oneResult.Success)
                            {
                                result.Success = true;
                                result.MessageCount += oneResult.MessageCount;
                            }
                            if (!String.IsNullOrWhiteSpace(oneResult.Detail))
                                result.Detail += oneResult.Detail + "\r\n";
                        }
                    }
                }
            }
            catch { 
                //Throwing an exception here is risky, it could create a infinite loop of error reports
                //throw new Exception("An error occurred while sending notifications", ex); 
            }

            return result;
        }
        */

        /*
        // POST api/Notification/SendEmail
        [HttpPost]
        [Authorize]
        public NotificationResult SendEmail(EmailAddress From, EmailAddress To, String Subject, String Body, Boolean IsHtml)
        {
            NotificationResult result = new NotificationResult();
            if (General.Mail.MailTools.SendEmail(From, To, Subject, Body, IsHtml))
            {
                result.Success = true;
                result.MessageCount = 1;
            }
            return result;
        }

        // POST api/Notification/SendSMS
        [HttpPost]
        [Authorize]
        public NotificationResult SendSMS(PhoneNumber To, String Message)
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
                result.Detail = sms.Status;
            }
            return result;
        }
        */


    //}
    
}
