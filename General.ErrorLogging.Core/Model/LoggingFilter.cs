using System;
using General;
using General.Model;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Runtime.Serialization;

namespace General.ErrorLogging.Model
{


    #region Json Serializable Property Classes
    [DataContract]
    public class ClientFilterModel : JsonObject
    {
        private List<string> _lstClientID = new List<string>();
        [DataMember(Name = "clients")]
        public List<string> ClientIDList
        {
            get { return _lstClientID; }
            set { _lstClientID = value; }
        }

        [DataMember(Name = "all")]
        public bool WildcardAll
        {
            get
            {
                if (ClientIDList != null && ClientIDList.Count > 0)
                    return false;
                return true;
            }
            set
            {

            }
        }
    }

    [DataContract]
    public class UserFilterModel : JsonObject
    {
        private List<string> _lstUserID = new List<string>();
        [DataMember(Name = "users")]
        public List<string> UserIDList
        {
            get { return _lstUserID; }
            set { _lstUserID = value; }
        }

        [DataMember(Name = "all")]
        public bool WildcardAll
        {
            get
            {
                if (UserIDList != null && UserIDList.Count > 0)
                    return false;
                return true;
            }
            set
            {

            }
        }
    }

    [DataContract]
    public class EnvironmentFilterModel : JsonObject
    {
        private List<General.Environment.EnvironmentContext> _lstEnvironmentList = new List<General.Environment.EnvironmentContext>();
        [DataMember(Name = "environments")]
        public List<General.Environment.EnvironmentContext> EnvironmentList
        {
            get { return _lstEnvironmentList; }
            set { _lstEnvironmentList = value; }
        }

        [DataMember(Name = "all")]
        public bool WildcardAll
        {
            get
            {
                if (EnvironmentList != null && EnvironmentList.Count > 0)
                    return false;
                return true;
            }
            set
            {

            }
        }
    }

    [DataContract]
    public class EventFilterModel : JsonObject
    {
        private List<ErrorOtherTypes> _lstEventList = new List<ErrorOtherTypes>();
        [DataMember(Name = "events")]
        public List<ErrorOtherTypes> Events
        {
            get { return _lstEventList; }
            set { _lstEventList = value; }
        }

        [DataMember(Name = "all")]
        public bool WildcardAll
        {
            get
            {
                if (Events != null && Events.Count > 0)
                    return false;
                return true;
            }
            set
            {

            }
        }

        [DataMember(Name = "minseverity")]
        public int MinSeverity
        {
            get;
            set;
        }

    }
    #endregion

    public interface ILoggingFilter
    {
        LoggingFilterViewType FilterView { get; }
        int ID { get; set; }
        string Name { get; set; }
        int AppID { get; set; }
        ClientFilterModel ClientFilter { get; set; }
        UserFilterModel UserFilter { get; set; }
        EnvironmentFilterModel EnvironmentFilter { get; set; }
        EventFilterModel EventFilter { get; set; }
        bool Enabled { get; set; }
        DateTimeOffset? StartDate { get; set; }
        DateTimeOffset? EndDate { get; set; }
        EmailAddress PageEmail { get; set; }
        PhoneNumber PageSMS { get; set; }
        String Custom1 { get; set; }
        String Custom2 { get; set; }
        String Custom3 { get; set; }
        General.FingerPrint FingerPrint { get; set; }
    }

    [DataContract]
    public class LoggingFilterBrowserView : LoggingFilterGlobal, ILoggingFilter
    {
        [DataMember]
        public override LoggingFilterViewType FilterView { get { return LoggingFilterViewType.Browser; } }

        private ClientFilterModel _objClientFilter = new ClientFilterModel();
        [IgnoreDataMember]
        public override ClientFilterModel ClientFilter
        {
            get { return _objClientFilter; }
            set { _objClientFilter = value; }
        }

        private UserFilterModel _objUserFilter = new UserFilterModel();
        [IgnoreDataMember]
        public override UserFilterModel UserFilter
        {
            get { return _objUserFilter; }
            set { _objUserFilter = value; }
        }

        private EnvironmentFilterModel _objEnvironmentFilter = new EnvironmentFilterModel();
        [IgnoreDataMember]
        public override EnvironmentFilterModel EnvironmentFilter
        {
            get { return _objEnvironmentFilter; }
            set { _objEnvironmentFilter = value; }
        }

        [IgnoreDataMember]
        public override EmailAddress PageEmail
        {
            get;
            set;
        }

        [IgnoreDataMember]
        public override PhoneNumber PageSMS
        {
            get;
            set;
        }

        private General.FingerPrint _objFingerPrint;
        [IgnoreDataMember]
        public override General.FingerPrint FingerPrint
        {
            get
            {
                return _objFingerPrint;
            }
            set
            {
                _objFingerPrint = value;
            }
        }

    }

    [DataContract]
    public class LoggingFilterRemoteServerView : LoggingFilterGlobal, ILoggingFilter
    {
        [DataMember]
        public override LoggingFilterViewType FilterView { get { return LoggingFilterViewType.RemoteServer; } }

        private ClientFilterModel _objClientFilter = new ClientFilterModel();
        [DataMember]
        public override ClientFilterModel ClientFilter
        {
            get { return _objClientFilter; }
            set { _objClientFilter = value; }
        }

        private UserFilterModel _objUserFilter = new UserFilterModel();
        [DataMember]
        public override UserFilterModel UserFilter
        {
            get { return _objUserFilter; }
            set { _objUserFilter = value; }
        }

        private EnvironmentFilterModel _objEnvironmentFilter = new EnvironmentFilterModel();
        [DataMember]
        public override EnvironmentFilterModel EnvironmentFilter
        {
            get { return _objEnvironmentFilter; }
            set { _objEnvironmentFilter = value; }
        }

        [IgnoreDataMember]
        public override EmailAddress PageEmail
        {
            get;
            set;
        }

        [IgnoreDataMember]
        public override PhoneNumber PageSMS
        {
            get;
            set;
        }

        private General.FingerPrint _objFingerPrint;
        [IgnoreDataMember]
        public override General.FingerPrint FingerPrint
        {
            get
            {
                return _objFingerPrint;
            }
            set
            {
                _objFingerPrint = value;
            }
        }

    }

    [DataContract]
    public class LoggingFilter : LoggingFilterGlobal, ILoggingFilter
    {
        [DataMember]
        public override LoggingFilterViewType FilterView { get { return LoggingFilterViewType.Full; } }

        private ClientFilterModel _objClientFilter = new ClientFilterModel();
        [DataMember]
        public override ClientFilterModel ClientFilter
        {
            get { return _objClientFilter; }
            set { _objClientFilter = value; }
        }

        private UserFilterModel _objUserFilter = new UserFilterModel();
        [DataMember]
        public override UserFilterModel UserFilter
        {
            get { return _objUserFilter; }
            set { _objUserFilter = value; }
        }

        private EnvironmentFilterModel _objEnvironmentFilter = new EnvironmentFilterModel();
        [DataMember]
        public override EnvironmentFilterModel EnvironmentFilter
        {
            get { return _objEnvironmentFilter; }
            set { _objEnvironmentFilter = value; }
        }

        [DataMember]
        public override EmailAddress PageEmail
        {
            get;
            set;
        }

        [DataMember]
        public override PhoneNumber PageSMS
        {
            get;
            set;
        }

        private General.FingerPrint _objFingerPrint;
        [DataMember]
        public override General.FingerPrint FingerPrint
        {
            get
            {
                return _objFingerPrint;
            }
            set
            {
                _objFingerPrint = value;
            }
        }

    }

    public enum LoggingFilterStatus
    {
        Active,
        Disabled,
        Expired,
        Queued
    }

    public enum LoggingFilterViewType
    {
        Full,
        RemoteServer,
        Browser
    }

    [DataContract]
    public abstract class LoggingFilterGlobal: ILoggingFilter
    {
        
        #region Public Properties

        public abstract LoggingFilterViewType FilterView { get; }

        [DataMember]
        public int ID
        {
            get;
            set;
        }

        public abstract FingerPrint FingerPrint { get; set; }

        [DataMember]
		public string Name
		{
            get;
            set;
		}

        [DataMember]
        public int AppID
        {
            get;
            set;
        }

        public abstract ClientFilterModel ClientFilter { get; set; }

        public abstract UserFilterModel UserFilter { get; set; }

        public abstract EnvironmentFilterModel EnvironmentFilter { get; set; }
        
        private EventFilterModel _objEventFilter = new EventFilterModel();
        [DataMember]
        public EventFilterModel EventFilter
        {
            get { return _objEventFilter; }
            set { _objEventFilter = value; }
        }

        [DataMember]
        public bool Enabled
        {
            get;
            set;
        }

        [DataMember]
        public DateTimeOffset? StartDate
        {
            get;
            set;
        }

        [DataMember]
        public string StartDateString
        {
            get
            {
                if (StartDate == null || StartDate.Value == DateTime.MinValue)
                    return "";

                return StartDate.Value.ToString("d");
            }
        }

        [DataMember]
        public DateTimeOffset? EndDate
        {
            get;
            set;
        }

        [DataMember]
        public string EndDateString
        {
            get
            {
                if (EndDate == null || EndDate.Value == DateTime.MinValue)
                    return "";

                return EndDate.Value.ToString("d");
            }
        }

        [DataMember]
        public LoggingFilterStatus Status
        {
            get
            {
                if (!Enabled)
                    return LoggingFilterStatus.Disabled;
                else
                {
                    if (EndDate.HasValue && DateTimeOffset.Now > EndDate.Value)
                        return LoggingFilterStatus.Expired;
                    else if (StartDate.HasValue && DateTimeOffset.Now < StartDate.Value)
                        return LoggingFilterStatus.Queued;
                }
                return LoggingFilterStatus.Active;
            }
        }

        public abstract EmailAddress PageEmail { get; set; }
        public abstract PhoneNumber PageSMS { get; set; }

        [DataMember]
        public String Custom1
        {
            get;
            set;
        }

        [DataMember]
        public String Custom2
        {
            get;
            set;
        }

        [DataMember]
        public String Custom3
        {
            get;
            set;
        }

        #endregion

        #region Constructors
        /// <summary>
        /// General.ErrorLogging::LoggingFilter
        /// </summary>
        public LoggingFilterGlobal()
        {

        }
        #endregion Constructors

    } //End Class



} //End Namespace
