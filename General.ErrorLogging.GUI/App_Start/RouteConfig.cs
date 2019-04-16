using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace General.ErrorLogging.GUI
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
            );

            /*
            // ex: api/lookups/all
            // ex: api/lookups/rooms
            routes.MapRoute(
                        name: "ControllerAction",
                        url: "api/{controller}/{action}"
                    );
            */
        }
    }
}