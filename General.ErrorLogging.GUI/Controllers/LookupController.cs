using General.ErrorLogging.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace General.ErrorLogging.GUI.Controllers
{
    public class LookupController : Controller
    {

        [Authorize]
        public ActionResult Index(string IC = "")
        {
            ViewBag.IncidentCode = IC;
            return View();
        }

    }
}
