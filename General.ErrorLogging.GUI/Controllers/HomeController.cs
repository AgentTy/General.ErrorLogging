using General.ErrorLogging.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace General.ErrorLogging.GUI.Controllers
{
    public class HomeController : Controller
    {
        [Authorize]
        public ActionResult Index()
        {
            //LoggingFilter filter = General.ErrorLogging.Data.LoggingFilter.GetFilters(true)[0];

            //filter.EventFilter.Test = "wowsers";

           // General.ErrorLogging.Data.LoggingFilter.UpdateLoggingFilter(filter);

            //ViewBag.Message = filter.Name;
            /*
            LoggingFilter.ApplicationFilterModel filter = new LoggingFilter.ApplicationFilterModel();
            filter.AppIDList.Add(4);
            string json = filter.ToJson();

            LoggingFilter.ApplicationFilterModel back = LoggingFilter.ApplicationFilterModel.FromJson<LoggingFilter.ApplicationFilterModel>(json);
            string s = back.WildcardAll.ToString();

            LoggingFilter.ClientFilterModel filterClient = new LoggingFilter.ClientFilterModel();
            filterClient.ClientIDList.Add("LAS");
            filterClient.ClientIDList.Add("PHX");
            json += "<br/>" + filterClient.ToJson();

            LoggingFilter.EnvironmentFilterModel filterEnv = new LoggingFilter.EnvironmentFilterModel();
            filterEnv.EnvironmentList.Add(Environment.EnvironmentContext.Live);
            filterEnv.EnvironmentList.Add(Environment.EnvironmentContext.Stage);
            json += "<br/>" + filterEnv.ToJson();

            LoggingFilter.EventFilterModel filterEvents = new LoggingFilter.EventFilterModel();
            filterEvents.Events.Add(ErrorOtherTypes.Javascript);
            filterEvents.Events.Add(ErrorOtherTypes.General);
            json += "<br/>" + filterEvents.ToJson();

            ViewBag.Message = json;
            */
            ViewBag.Message = "";
            return View();
        }

        public ActionResult Stats()
        {
            ViewBag.Message = "";

            //ViewBag.StatData = new Dictionary<string, General.ErrorLogging.GUI.Filters.ActionPerformance>();
            foreach (var filter in System.Web.Http.GlobalConfiguration.Configuration.Filters)
            {
                if (filter.Instance is General.ErrorLogging.GUI.Filters.APIPerformanceFilter)
                {
                    General.ErrorLogging.GUI.Filters.APIPerformanceFilter perfMon = (General.ErrorLogging.GUI.Filters.APIPerformanceFilter) filter.Instance;
                    ViewBag.Count = perfMon.Monitors.Count;
                    ViewBag.Data = perfMon.Monitors.OrderBy(dr => dr.Value.AppName).ThenByDescending(x => x.Value.AverageCallsPerMinute);
                    break;
                }
            }
            return View();
        }

        [Authorize]
        public ActionResult ErrorLog()
        {
            ViewBag.Message = "";
            return View();
        }

        [Authorize]
        public ActionResult Lookup(string IC = "")
        {
            return RedirectPermanent("/Lookup?IC=" + IC);
        }

        [Authorize]
        public ActionResult Error404()
        {
            ViewBag.Message = "";
            return View();
        }

        [Authorize]
        public ActionResult Error404Redirect()
        {
            ViewBag.Message = "";
            return View();
        }

        public ActionResult WhoAmI()
        {
            ViewBag.Message = "";
            ViewBag.MachineName = System.Environment.MachineName;
            return View();
        }
    }
}
