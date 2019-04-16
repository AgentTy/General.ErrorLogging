using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace General.ErrorLogging.GUI
{
    public class ErrorLogging
    {
        public static ApplicationContext GetApplicationContext(System.Security.Principal.IPrincipal User = null)
        {
            ApplicationContext context;
            //Populate the report context with my session variables, ClientID, UserID, etc...
            //ClientID (optional) is intended to identify which Client/Organization/Group of users is in context, it can be any number
            //UserType (optional) can be used to differentiate different kinds of users, or different Unique Key pools so that UserType + UserID becomes a Unique key
            //UserID (optional) is your systems Unique ID for the current user

            string strUserID = null;
            if (User != null)
            {
                try
                {
                    strUserID = User.Identity.Name;
                }
                catch { }
            }

            if (String.IsNullOrWhiteSpace(strUserID))
            {
                try
                {
                    strUserID = WebMatrix.WebData.WebSecurity.CurrentUserId.ToString();
                }
                catch { }
            }

            context = new ApplicationContext(strClientID: null, strUserType: null, strUserID: strUserID);
            context.CustomID = null; //Any additonal integer you want to store
            context.Custom1 = ""; //Custom String #1
            context.Custom2 = ""; //Custom String #2
            context.Custom3 = ""; //Custom String #3
            return context;
        }
    }
}