using System.Web;
using System.Web.Mvc;
using General.ErrorLogging.GUI.Filters;

namespace General.ErrorLogging.GUI
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }
    }
}

