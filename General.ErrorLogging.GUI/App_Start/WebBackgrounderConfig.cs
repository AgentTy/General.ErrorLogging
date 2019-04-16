using System;
using WebBackgrounder;

namespace General.ErrorLogging.GUI
{

    public class WebBackgrounderConfig
    {
        static readonly JobManager _jobManager = CreateJobWorkersManager();

        public static void Start()
        {
            _jobManager.RestartSchedulerOnFailure = true;
            _jobManager.Start();
        }

        public static void Shutdown()
        {
            _jobManager.Dispose();
        }

        private static JobManager CreateJobWorkersManager()
        {
            var jobs = new IJob[]
            {
                new NotificationJob(TimeSpan.FromSeconds(15), TimeSpan.FromSeconds(14))
            };
            var manager = new JobManager(jobs, new JobHost());
            manager.Fail(ex => HandleJobError(ex));
            return manager;
        }

        private static void HandleJobError(Exception ex)
        {
            ErrorReporter.ReportError(ex, "Bkgnd Task");
        }

    }
}