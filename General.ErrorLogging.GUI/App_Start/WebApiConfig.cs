using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Http;

namespace General.ErrorLogging.GUI
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            config.EnableCors();

            #region AppID Based API Calls
            config.Routes.MapHttpRoute(
                name: "AppBasedApi",
                routeTemplate: "api/{appid}/{controller}",
                defaults: null,
                constraints: new { appid = @"^\d+$|any$" } // AppID must be all digits
            );

            config.Routes.MapHttpRoute(
                name: "AppBasedApiWithAction",
                routeTemplate: "api/{appid}/{controller}/{action}",
                defaults: null,
                constraints: new { appid = @"^\d+$|any$" } // AppID must be all digits
            );
            
            config.Routes.MapHttpRoute(
                name: "AppBasedApiWithID",
                routeTemplate: "api/{appid}/{controller}id={id}",
                defaults: null,
                constraints: new { appid = @"^\d+$|any$", id = @"^\d+$" } // AppID and ID must be all digits
            );

            config.Routes.MapHttpRoute(
                 name: "AppBasedApiWithActionAndID",
                 routeTemplate: "api/{appid}/{controller}/{action}id={id}",
                 defaults: null,
                 constraints: new { appid = @"^\d+$|any$", id = @"^\d+$" } // AppID and ID must be all digits
           );

            /*
            config.Routes.MapHttpRoute(
              name: "AppBasedImplicit",
              routeTemplate: "api/{appid}/{controller}/{id}",
              defaults: null,
              constraints: new { appid = @"^\d+$|any$", id = @"^\d+$" } // AppID and ID must be all digits
            );
            */
            
  
            
            #endregion

            #region Default API
            
            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );

            config.Routes.MapHttpRoute(
              name: "DefaultApiImplicit",
              routeTemplate: "api/{controller}/{id}",
              defaults: null,
              constraints: new { id = @"^\d+$" } // id must be all digits
            );

            config.Routes.MapHttpRoute(
               name: "DefaultApiExplicit",
               routeTemplate: "api/{controller}/{action}/{id}",
               defaults: null,
               constraints: new { id = @"^\d+$" } // id must be all digits
             );

            #endregion

            #region Filters
            //config.Filters.Add(new General.ErrorLogging.GUI.Filters.APIPerformanceFilter());
            #endregion

            #region MessageHandlers
            //Add support for chunked transfer encoding
            config.MessageHandlers.Add(new ChunkedTransferHandler());
            #endregion

            // Uncomment the following line of code to enable query support for actions with an IQueryable or IQueryable<T> return type.
            // To avoid processing unexpected or malicious queries, use the validation settings on QueryableAttribute to validate incoming queries.
            // For more information, visit http://go.microsoft.com/fwlink/?LinkId=279712.
            //config.EnableQuerySupport();
        }

        public class ChunkedTransferHandler : DelegatingHandler
        {
            protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request,
                CancellationToken cancellationToken)
            {
                var response = base.SendAsync(request, cancellationToken);

                response.Result.Headers.TransferEncodingChunked = true; // Here!

                return response;
            }
        }
    }
}