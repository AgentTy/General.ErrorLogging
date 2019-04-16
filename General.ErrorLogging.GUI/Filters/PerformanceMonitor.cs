using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Diagnostics;

namespace General.ErrorLogging.GUI.Filters
{

    public class ActionPerformance
    {
        public ActionPerformance(string ControllerName, string ActionName, string AppID)
        {
            this.ControllerName = ControllerName;
            this.ActionName = ActionName;
            this.AppID = AppID;
        }

        public string ControllerName { get; set; }
        public string ActionName { get; set; }
        public string AppID { get; set; }

        private string _strAppName;
        public string AppName
        {
            get
            {
                if (!String.IsNullOrWhiteSpace(_strAppName))
                    return _strAppName;
                try
                {
                    int intAppID;
                    if (int.TryParse(AppID, out intAppID))
                    {
                        var app = General.ErrorLogging.Data.Application.GetApplication(intAppID);
                        if (app != null)
                            _strAppName = app.Name;
                        else
                            _strAppName = "";
                        return _strAppName;
                    }
                    else
                        return AppID;
                }
                catch { return AppID; }
            }
        }

        public System.Diagnostics.Stopwatch Stopwatch = new Stopwatch();
        public int RunCount_Lifetime { get; set; }
        public int RunCount_Today { get; set; }
        public int RunCount_Yesterday { get; set; }
        public int RunCount_ThisHour { get; set; }
        public int RunCount_LastHour { get; set; }
        public Queue<MinuteCount> RunCount_RecentMinutes = new Queue<MinuteCount>(120);
        public Queue<long> RunSpeed_RecentRuns = new Queue<long>(100);

        public class MinuteCount
        {
            public DateTime TimeStamp = DateTime.Now;
            public int Count = 1;

            public void DoCount()
            {
                Count++;
            }
        }
        
        public double AverageSpeed
        {
            get
            {
                return RunSpeed_RecentRuns.Average();
            }
        }

        public double AverageCallsPerMinute
        {
            get
            {
                return RunCount_RecentMinutes.Average(dr => dr.Count);
            }
        }

        public int RunCount_ThisMinute
        {
            get
            {
                foreach (var point in RunCount_RecentMinutes)
                {
                    if (point != null && point.TimeStamp.Date == DateTime.Today && point.TimeStamp.Hour == DateTime.Now.Hour && point.TimeStamp.Minute == DateTime.Now.Minute)
                    {
                        return point.Count;
                    }
                }
                return 0;
            }
        }

        public int RunCount_LastMinute
        {
            get
            {
                foreach(var point in RunCount_RecentMinutes)
                {
                    if (point != null && point.TimeStamp.Date == DateTime.Today && point.TimeStamp.Hour == DateTime.Now.Hour && point.TimeStamp.Minute == DateTime.Now.Minute - 1)
                    {
                        return point.Count;
                    }
                }
                return 0;
            }
        }


        public void Start()
        {
            Stopwatch.Restart();
        }

        public void Stop()
        {
            Stopwatch.Stop();
            RecordRun();
        }

        private DateTime TimeStamp = DateTime.Now;
        public DateTime TimeStampStart = DateTime.Now;
        private void RecordRun()
        {
            #region RunSpeed
            if (RunSpeed_RecentRuns.Count >= 100)
                RunSpeed_RecentRuns.Dequeue();
            RunSpeed_RecentRuns.Enqueue(Stopwatch.ElapsedMilliseconds);
            #endregion

            #region RunCount_Lifetime
            RunCount_Lifetime++;
            #endregion

            #region Yesterday and Today
            if (TimeStamp.Date < DateTime.Today)
            {
                RunCount_Yesterday = RunCount_Today;
                RunCount_Today = 0;
                TimeStamp = DateTime.Now;
            }
            RunCount_Today++;
            #endregion

            #region This Hour and Last Hour
            if (TimeStamp.Hour < DateTime.Now.Hour)
            {
                RunCount_LastHour = RunCount_ThisHour;
                RunCount_ThisHour = 0;
                TimeStamp = DateTime.Now;
            }
            RunCount_ThisHour++;
            #endregion

            #region RunCount_RecentMinutes
            if (RunCount_RecentMinutes.Count >= 120)
                RunCount_RecentMinutes.Dequeue();
            MinuteCount objMinute = null;
            foreach (var point in RunCount_RecentMinutes)
            {
                if (point != null && point.TimeStamp.Date == DateTime.Today && point.TimeStamp.Hour == DateTime.Now.Hour && point.TimeStamp.Minute == DateTime.Now.Minute)
                {
                    point.DoCount();
                    objMinute = point;
                }
            }
            if (objMinute == null)
            {
                RunCount_RecentMinutes.Enqueue(new MinuteCount());
            }
            #endregion
        }
        
    }

    public class APIPerformanceFilter : System.Web.Http.Filters.ActionFilterAttribute
    {
        private readonly Dictionary<string, ActionPerformance> _objMonitors;

        public Dictionary<string, ActionPerformance> Monitors
        {
            get
            {
                return _objMonitors;
            }
        }

        public APIPerformanceFilter()
        {
            if (_objMonitors == null)
                _objMonitors = new Dictionary<string, ActionPerformance>();
        }

        public override void OnActionExecuting(System.Web.Http.Controllers.HttpActionContext actionContext)
        {
            string appID = "any";
            if (actionContext.RequestContext.RouteData.Values.ContainsKey("AppID"))
                appID = actionContext.RequestContext.RouteData.Values["AppID"].ToString();
            string key = String.Format("App{0}-{1}-{2}", appID, actionContext.ControllerContext.ControllerDescriptor.ControllerName, actionContext.ActionDescriptor.ActionName);

            if (!_objMonitors.ContainsKey(key))
                _objMonitors.Add(key, new ActionPerformance(actionContext.ControllerContext.ControllerDescriptor.ControllerName, actionContext.ActionDescriptor.ActionName, appID));

            _objMonitors[key].Start();
            base.OnActionExecuting(actionContext);
        }

        public override void OnActionExecuted(System.Web.Http.Filters.HttpActionExecutedContext actionExecutedContext)
        {
            string appID = "any";
            if (actionExecutedContext.ActionContext.RequestContext.RouteData.Values.ContainsKey("AppID"))
                appID = actionExecutedContext.ActionContext.RequestContext.RouteData.Values["AppID"].ToString();
            string key = String.Format("App{0}-{1}-{2}", appID, actionExecutedContext.ActionContext.ControllerContext.ControllerDescriptor.ControllerName, actionExecutedContext.ActionContext.ActionDescriptor.ActionName);

            if (_objMonitors.ContainsKey(key))
            {
                _objMonitors[key].Stop();
                try
                {
                    if (actionExecutedContext.Response != null)
                        actionExecutedContext.Response.Headers.Add("PM-" + key, _objMonitors[key].Stopwatch.ElapsedMilliseconds.ToString() + "ms");
                }
                catch { }
            }
            base.OnActionExecuted(actionExecutedContext);
        }

    }


    #region Other Examples

    public class StopwatchActionFilter : System.Web.Mvc.ActionFilterAttribute
    {
        private readonly Dictionary<string, Stopwatch> _stopWatches;

        public StopwatchActionFilter()
        {
            if (_stopWatches == null)
                _stopWatches = new Dictionary<string, Stopwatch>();
        }

        public override void OnActionExecuting(System.Web.Mvc.ActionExecutingContext filterContext)
        {
            //Gets currently executing action and controller
            string actionName = filterContext.RequestContext.RouteData.Values["Action"].ToString();
            string controllerName = filterContext.RequestContext.RouteData.Values["Controller"].ToString();

            string key = String.Format("NC-{0}-{1}", controllerName, actionName);
            if (_stopWatches.ContainsKey(key))
                _stopWatches[key].Reset();
            else
                _stopWatches.Add(key, new Stopwatch());
            _stopWatches[key].Start();
            base.OnActionExecuting(filterContext);
        }

        public override void OnActionExecuted(System.Web.Mvc.ActionExecutedContext filterContext)
        {
            string actionName = filterContext.RequestContext.RouteData.Values["Action"].ToString();
            string controllerName = filterContext.RequestContext.RouteData.Values["Controller"].ToString();

            string key = String.Format("NC-{0}-{1}", controllerName, actionName);
            if (_stopWatches.ContainsKey(key))
            {
                _stopWatches[key].Stop();
                try
                {
                    filterContext.HttpContext.Response.AddHeader("MVC-ActionTime", _stopWatches[key].ElapsedMilliseconds.ToString() + "ms");
                }
                catch { }
            }
            base.OnActionExecuted(filterContext);
        }

    }

    public class APIStopwatchActionFilter : System.Web.Http.Filters.ActionFilterAttribute
    {
        private readonly Dictionary<string, Stopwatch> _stopWatches;

        public APIStopwatchActionFilter()
        {
            if (_stopWatches == null)
                _stopWatches = new Dictionary<string, Stopwatch>();
        }

        public override void OnActionExecuting(System.Web.Http.Controllers.HttpActionContext actionContext)
        {
            //Gets currently executing action and controller
            string actionName = actionContext.RequestContext.RouteData.Values["Action"].ToString();
            string controllerName = actionContext.RequestContext.RouteData.Values["Controller"].ToString();

            string key = String.Format("NC-{0}-{1}", controllerName, actionName);
            if (_stopWatches.ContainsKey(key))
                _stopWatches[key].Reset();
            else
                _stopWatches.Add(key, new Stopwatch());
            _stopWatches[key].Start();
            base.OnActionExecuting(actionContext);
        }

        public override void OnActionExecuted(System.Web.Http.Filters.HttpActionExecutedContext actionExecutedContext)
        {
            string actionName = actionExecutedContext.ActionContext.RequestContext.RouteData.Values["Action"].ToString();
            string controllerName = actionExecutedContext.ActionContext.RequestContext.RouteData.Values["Controller"].ToString();

            string key = String.Format("NC-{0}-{1}", controllerName, actionName);
            if (_stopWatches.ContainsKey(key))
            {
                _stopWatches[key].Stop();
                try
                {
                    actionExecutedContext.Response.Headers.Add("MVC-API-ActionTime", _stopWatches[key].ElapsedMilliseconds.ToString() + "ms");
                }
                catch { }
            }
            base.OnActionExecuted(actionExecutedContext);
        }

    }
    #endregion

}