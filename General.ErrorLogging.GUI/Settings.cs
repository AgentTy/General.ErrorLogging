using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace General.ErrorLogging.GUI
{
    public class Settings
    {

        #region Application Settings
        public static string AdminSignupAccessCode
        {
            get
            {
                return GetSetting("AdminSignupAccessCode");
            }
        }

        public static string APIWriteOnlyAccessCode
        {
            get
            {
                return GetSetting("APIWriteOnlyAccessCode");
            }
        }

        public static string HostedURI
        {
            get
            {
                if (!String.IsNullOrWhiteSpace(GetSetting("HostedURI")))
                    return GetSetting("HostedURI");
                else
                    return General.Web.WebTools.GetWebSiteURL();
            }
        }
        #endregion

        #region Twilio SMS API
        public static string TwilioAccount
        {
            get
            {
                return GetSetting("TwilioAccount");
            }
        }

        public static string TwilioToken
        {
            get
            {
                return GetSetting("TwilioToken");
            }
        }

        public static string TwilioPhoneNumber
        {
            get
            {
                return GetSetting("TwilioPhoneNumber");
            }
        }
        #endregion

        #region Notification Settings
        public static string EventNotificationSubjectPrefix
        {
            get
            {
                return GetSetting("EventNotificationSubjectPrefix");
            }
        }
        #endregion

        public static string GetSetting(string Key)
        {
            if (!String.IsNullOrWhiteSpace(System.Configuration.ConfigurationManager.AppSettings[Key]))
                return System.Configuration.ConfigurationManager.AppSettings[Key].ToString();
            else if (!String.IsNullOrWhiteSpace(System.Configuration.ConfigurationManager.AppSettings[Key + "_" + General.Environment.Current.WhereAmI()]))
                return System.Configuration.ConfigurationManager.AppSettings[Key + "_" + General.Environment.Current.WhereAmI()].ToString();
            else
                return "";
        }
    }
}