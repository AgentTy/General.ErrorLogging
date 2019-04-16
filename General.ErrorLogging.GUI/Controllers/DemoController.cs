using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace General.ErrorLogging.GUI.Controllers
{
    public class DemoController : Controller
    {
        // GET: Demo
        public ActionResult Index()
        {
            int i = 14332;
            i = 100;
            i = 1000;
            i = 10000;
            i = 100000;
            i = 1000000;
            i = 10000000;
            i = 100000000;
            ViewBag.Message = Convert.ToString(i, 16);
            //ViewBag.Message = "";
            return View();
        }

        public ActionResult Trace(string message, string messageType)
        {
            if(messageType.ToLower() == "trace")
            {
                ErrorReporter.ReportTrace(message);
                ViewBag.Message = "Trace message stored.";
            }
            else if (messageType.ToLower() == "warning")
            {
                ErrorReporter.ReportWarning(message);
                ViewBag.Message = "Warning message stored.";
            }
            else if (messageType.ToLower() == "audit")
            {
                ErrorReporter.ReportAudit(message);
                ViewBag.Message = "Audit message stored.";
            }
            return View("Index");
        }


        public ActionResult UnhandledException()
        {
            throw new Exception("Demo Unhandled Exception");
            ViewBag.Message = "Unhandled Exception Thrown";
            return View("Index");
        }

        public ActionResult HandledException()
        {
            ViewBag.Message = "";
            try
            {
                throw new Exception("Demo Exception");
            }
            catch(Exception ex)
            {
                ErrorReporter.ReportErrorHighSeverity(ex, ErrorLogging.GetApplicationContext(User));
                ViewBag.Message = "Exception was handled safely.";
            }
            return View("Index");
        }

        public ActionResult PageViaSMS(string phone)
        {
            string message = "An event has occurred";
            var twilio = new Twilio.TwilioRestClient(Settings.TwilioAccount, Settings.TwilioToken);
            var sms = twilio.SendMessage(Settings.TwilioPhoneNumber, phone, message);

            ViewBag.Message = "Message " + sms.Status;
            return View("Index");
        }
    }
}