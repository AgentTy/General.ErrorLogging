using System;
using General;
using General.Model;
using General.Reflection;
using System.ComponentModel;
using System.Runtime.Serialization;

namespace General.ErrorLogging.Model
{
    public enum ErrorOtherTypes
    {
        [EnumDisplayAttribute("Uncategorized Event", false, false)]
        [Description("Events with no type specified")]
        Unknown = 0,
        [EnumDisplayAttribute("Server Side Error", true, true)]
        [Description("Managed code errors and other server side exceptions")]
        Server = 1,
        [EnumDisplayAttribute("SQL Error", false, true)]
        [Description("SQL Server errors")]
        SQL = 2,
        [EnumDisplayAttribute("SQL Connectivity", false, true)]
        [Description("SQL Server connectivity errors")]
        SQLConnectivity = 3,
        [EnumDisplayAttribute("SQL Timeout", false, true)]
        [Description("SQL Server timeouts")]
        SQLTimeout = 4,
        [EnumDisplayAttribute("Javascript Error", false, true)]
        [Description("Client side javascript errors")]
        Javascript = 6,
        [EnumDisplayAttribute("Warning", false, true)]
        [Description("A warning level trace record")]
        Warning = 10,
        [EnumDisplayAttribute("Audit", false, true)]
        [Description("An audit level trace record")]
        Audit = 11,
        [EnumDisplayAttribute("Trace", false, true)]
        [Description("A trace record")]
        Trace = 12,
        [EnumDisplayAttribute("Auth", false, true)]
        [Description("An authentication event")]
        Auth = 13
    }

    [DataContract]
    public class ErrorOther : ObjectBase, IErrorOther
    {

        #region Public Properties

        [DataMember]
		public int AppID
		{
            get;
            set;
		}

        [DataMember]
        public General.Environment.EnvironmentContext Environment
        {
            get;
            set;
        }

        [DataMember]
        public string EnvironmentName
        {
            get
            {
                return Environment.ToString();
            }
        }

        [DataMember]
		public String ClientID
		{
            get;
            set;
		}

        [DataMember]
        public DateTimeOffset FirstTime
        {
            get;
            set;
        }

        [DataMember]
        public string FirstTimeString
        {
            get
            {
                if (FirstTime == null || FirstTime == DateTime.MinValue)
                    return "";

                string s =  FirstTime.ToString("g") + " GMT";
                if (FirstTime.Offset.Ticks != 0)
                    s += FirstTime.ToString("zzz");
                return s;

            }
        }

        [DataMember]
        public DateTimeOffset LastTime
        {
            get;
            set;
        }

        [DataMember]
        public string LastTimeString
        {
            get
            {
                if (LastTime == null || LastTime == DateTime.MinValue)
                    return "";

                string s = LastTime.ToString("g") + " GMT";
                if (LastTime.Offset.Ticks != 0)
                    s += LastTime.ToString("zzz");
                return s;
            }
        }

        [DataMember]
        public string LastIncidentCode
        {
            get
            {
                if (LastIncidentID.HasValue)
                    return Convert.ToString(LastIncidentID.Value, 16);
                return "unknown";
            }
        }

        [DataMember]
        public int? LastIncidentID
        {
            get;
            set;
        }

        [DataMember]
        public int Count
        {
            get;
            set;
        }

        [DataMember]
        public ErrorOtherTypes EventType
        {
            get;
            set;
        }

        [DataMember]
        public int EventTypeID
        {
            get
            {
                return (int)EventType;
            }
        }

        [DataMember]
        public String EventTypeName
        {
            get
            {
                return General.Reflection.EnumSerializer.GetDisplayName<ErrorOtherTypes>(EventType);
            }
        }

        [DataMember]
        public int? Severity
        {
            get;
            set;
        }

        [DataMember]
		public String ErrorCode
		{
            get;
            set;
		}

        [DataMember]
        public string CodeMethod
        {
            get;
            set;
        }

        [DataMember]
        public String CodeFileName
        {
            get;
            set;
        }

        [DataMember]
        public int CodeLineNumber
        {
            get;
            set;
        }

        [DataMember]
        public int CodeColumnNumber
        {
            get;
            set;
        }

        [DataMember]
        public String ExceptionType
        {
            get;
            set;
        }

        [DataMember]
        public String EventName
        {
            get;
            set;
        }

        [DataMember]
		public String EventDetail
		{
            get;
            set;
		}

        [DataMember]
        public bool EventDetailLoaded
        {
            get;
            set;
        }

        [DataMember]
        public String EventURL
		{
            get;
            set;
		}

        [DataMember]
        public String UserAgent
        {
            get;
            set;
        }

        [DataMember]
        public String UserType
        {
            get;
            set;
        }

        [DataMember]
        public String UserID
        {
            get;
            set;
        }

        [DataMember]
        public int? CustomID
        {
            get;
            set;
        }

        [DataMember]
        public String AppName
        {
            get;
            set;
        }

        [DataMember]
        public String MachineName
        {
            get;
            set;
        }

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

        [DataMember]
        public Int32? Duration
        {
            get;
            set;
        }

        #endregion

        #region Constructors
        /// <summary>
        /// General.ErrorLogging::ErrorOther
        /// </summary>
        public ErrorOther()
        {
            this.AppID = ErrorReporter.AppID;
            this.AppName = ErrorReporter.DefaultAppNameForErrorLog;
            this.Environment = General.Environment.Current.WhereAmI();
            this.MachineName = System.Environment.MachineName;
        }
        #endregion Constructors

        #region Fill Model
        protected void FillModel(Model.ErrorOther objModel)
        {
			this.ID = objModel.ID;
            this.AppID = objModel.AppID;
            this.Environment = objModel.Environment;
			this.ClientID = objModel.ClientID;
			this.FirstTime = objModel.FirstTime;
            this.LastTime = objModel.LastTime;
            this.Count = objModel.Count;
            this.EventType = objModel.EventType;
            this.Severity = objModel.Severity;
            this.ErrorCode = objModel.ErrorCode;
            this.CodeMethod = objModel.CodeMethod;
            this.CodeFileName = objModel.CodeFileName;
            this.CodeLineNumber = objModel.CodeLineNumber;
            this.CodeColumnNumber = objModel.CodeColumnNumber;
            this.ExceptionType = objModel.ExceptionType;
            this.EventName = objModel.EventName;
            this.EventDetail = objModel.EventDetail;
            this.EventURL = objModel.EventURL;
            this.UserAgent = objModel.UserAgent;
            this.UserType = objModel.UserType;
            this.UserID = objModel.UserID;
            this.CustomID = objModel.CustomID;
            this.AppName = objModel.AppName;
            this.MachineName = objModel.MachineName;
			this.Custom1 = objModel.Custom1;
			this.Custom2 = objModel.Custom2;
			this.Custom3 = objModel.Custom3;
            this.Duration = objModel.Duration;
        }
        #endregion

        #region ToString
        public override string ToString()
        {
            return this.EventName + " (" + this.EventType.ToString() + "): " + this.CodeFileName + ":" + this.CodeLineNumber;
        }
        #endregion

    } //End Class

    public interface IErrorOther
    {
        int AppID
        {
            get;
            set;
        }

        General.Environment.EnvironmentContext Environment
        {
            get;
            set;
        }

        string EnvironmentName
        {
            get;
        }

        String ClientID
        {
            get;
            set;
        }

        DateTimeOffset FirstTime
        {
            get;
            set;
        }

        string FirstTimeString
        {
            get;
        }

        DateTimeOffset LastTime
        {
            get;
            set;
        }

        string LastTimeString
        {
            get;
        }

        string LastIncidentCode
        {
            get;
        }

        int? LastIncidentID
        {
            get;
            set;
        }

        int Count
        {
            get;
            set;
        }

        ErrorOtherTypes EventType
        {
            get;
            set;
        }

        int EventTypeID
        {
            get;
        }

        String EventTypeName
        {
            get;
        }

        int? Severity
        {
            get;
            set;
        }

        String ErrorCode
        {
            get;
            set;
        }

        string CodeMethod
        {
            get;
            set;
        }

        String CodeFileName
        {
            get;
            set;
        }

        int CodeLineNumber
        {
            get;
            set;
        }

        int CodeColumnNumber
        {
            get;
            set;
        }

        String ExceptionType
        {
            get;
            set;
        }

        String EventName
        {
            get;
            set;
        }

        String EventDetail
        {
            get;
            set;
        }

        bool EventDetailLoaded
        {
            get;
            set;
        }

        String EventURL
        {
            get;
            set;
        }

        String UserAgent
        {
            get;
            set;
        }

        String UserType
        {
            get;
            set;
        }

        String UserID
        {
            get;
            set;
        }

        int? CustomID
        {
            get;
            set;
        }

        String AppName
        {
            get;
            set;
        }

        String MachineName
        {
            get;
            set;
        }

        String Custom1
        {
            get;
            set;
        }

        String Custom2
        {
            get;
            set;
        }

        String Custom3
        {
            get;
            set;
        }

        Int32? Duration
        {
            get;
            set;
        }

    }

} //End Namespace
