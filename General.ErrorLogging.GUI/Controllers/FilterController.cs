using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace General.ErrorLogging.GUI.Controllers
{
    public class FilterController : Controller
    {
        // GET: Filter
        [Authorize]
        public ActionResult Manage()
        {
            return View();
        }

        // GET: Filter
        [Authorize]
        public ActionResult Edit(int? AppID = null, int? FilterID = null)
        {
            if (AppID.HasValue)
                ViewBag.AppID = AppID.Value;
            else
                ViewBag.AppID = "null";

            if (FilterID.HasValue)
                ViewBag.FilterID = FilterID.Value;
            else
                ViewBag.FilterID = "null";
            return View();
        }
    }
}