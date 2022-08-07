using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;

namespace General.ErrorLogging.Threading
{
    public class BackgroundWorker
    {
        private static Hashtable _objThreadData;

        #region RunInSeparateThread
        public static void RunInSeparateThread(WaitCallback Callback)
        {
            string strSessionID = "";
            //if (System.Web.HttpContext.Current != null && System.Web.HttpContext.Current.Session != null)
            //    strSessionID = System.Web.HttpContext.Current.Session.SessionID; //This line is intentionally written in a way that loads the Session object in this thread, so it is available in the new thread.
            if(_objThreadData == null)
                _objThreadData = new Hashtable();
            if(_objThreadData.Contains(strSessionID))
                _objThreadData[strSessionID] = new Job(Callback, strSessionID);
            else
                _objThreadData.Add(strSessionID, new Job(Callback, strSessionID));
            Thread objThread = new Thread( new ThreadStart(SeparateThreadCallback) );
            objThread.Name = strSessionID;
            objThread.Start();
        }
        private static void SeparateThreadCallback()
        {
            try
            {
                Job objJob = (Job) _objThreadData[Thread.CurrentThread.Name];
                objJob.Callback(Thread.CurrentThread.Name); //SessionID
            }
            catch(Exception ex)
            {
                ErrorReporter.ReportError(ex);
            }
            finally
            {
                _objThreadData.Remove(Thread.CurrentThread.Name);
                Thread.CurrentThread.Abort();
            }
        }
        #endregion

        #region Job Class (RunInSeparateThread)
        /// <summary>
        /// Summary description for Job.
        /// </summary>
        private class Job
        {
            public WaitCallback Callback;
            public string SessionID;
            public Job(WaitCallback objCallback, string strSessionID)
            {
                Callback = objCallback;
                SessionID = strSessionID;
            }
        }
        #endregion

    }
}
