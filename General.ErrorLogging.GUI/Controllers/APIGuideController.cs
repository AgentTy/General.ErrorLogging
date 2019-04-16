using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace General.ErrorLogging.GUI.Controllers
{
    public class APIGuideController : Controller
    {
        public ActionResult Index()
        {
            ViewBag.Message = "";
            ViewBag.HostedURI = Settings.HostedURI;
            return View();
        }

        public ActionResult ImplementationGuide()
        {
            ViewBag.Message = "";
            ViewBag.HostedURI = Settings.HostedURI;
            return View();
        }

        public ActionResult ErrorLog()
        {
            ViewBag.Message = "";
            ViewBag.HostedURI = Settings.HostedURI;
            return View();
        }

        public ActionResult LoggingFilters()
        {
            ViewBag.Message = "";
            ViewBag.HostedURI = Settings.HostedURI;
            return View();
        }

        public ActionResult Error404()
        {
            ViewBag.Message = "";
            ViewBag.HostedURI = Settings.HostedURI;
            return View();
        }

        public ActionResult Error404Redirect()
        {
            ViewBag.Message = "";
            ViewBag.HostedURI = Settings.HostedURI;
            return View();
        }

        public ActionResult Misc()
        {
            ViewBag.Message = "";
            ViewBag.HostedURI = Settings.HostedURI;
            return View();
        }
    }
}
