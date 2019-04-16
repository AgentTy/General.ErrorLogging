using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace General.ErrorLogging.GUI
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            //This line adds support for cross-domain JSONP
            GlobalConfiguration.Configuration.Formatters.Insert(0, new JsonpFormatter());

            AreaRegistration.RegisterAllAreas();

            WebApiConfig.Register(GlobalConfiguration.Configuration);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
            AuthConfig.RegisterAuth();
            WebBackgrounderConfig.Start();
        }

        protected void Application_End()
        {
            WebBackgrounderConfig.Shutdown();
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            try
            {
                var context = ErrorLogging.GetApplicationContext(User);
                Exception ex = HttpContext.Current.Server.GetLastError();
                try
                {
                    if (ex is HttpException)
                        if (((HttpException)ex).GetHttpCode() == 404)
                        {
                            //Here I can handle a 404 Error with redirects, using Error404Handner.StaticHandler or a managed pool of handlers for different ClientID's.
                            bool blnRedirected = Error404Handler.StaticHandler.Handle404(HttpContext.Current);
                            return; //Don't continue to process like a normal error
                        }
                }
                catch (Exception ex404)
                {
                    ErrorReporter.ReportError(ex404, context);
                }

                //if (General.Environment.Current.AmILive()) //I can optionally put a condition here to only record the error in specific environments using the General.Environment library.
                ErrorReporter.ReportError(ex, context);
            }
            catch { }
        }

    }
}