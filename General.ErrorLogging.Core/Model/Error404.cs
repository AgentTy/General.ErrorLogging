using System;
using General;
using System.Runtime.Serialization;

namespace General.ErrorLogging.Model
{

    [DataContract]
    public class Error404 : ObjectBase
    {

        #region Public Properties

        [DataMember]
		public Int32 AppID
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
        public String AppURL
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

                return FirstTime.ToString("d");
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

                return LastTime.ToString("d");
            }
        }

        [DataMember]
        public string URL
        {
            get;
            set;
        }

        [DataMember]
        public string URLSafe
        {
            get
            {
                return System.Web.HttpUtility.HtmlEncode(URL);
            }
        }

        [DataMember]
		public Int16 Count
		{
            get;
            set;
		}

        [DataMember]
        public bool Hide
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
        public String UserAgentDisplay
        {
            get
            {
                if (String.IsNullOrWhiteSpace(UserAgent))
                    return String.Empty;
                return UserAgent.Replace("Mozilla/5.0 ", "");;
            }
        }
        /*
        public String UserAgentSample
        {
            get
            {
                string sample = UserAgent;
                sample = sample.Replace("Mozilla/5.0 ", "");
                if (sample.Length > 26)
                    return sample.Substring(0, 26) + "...";
                return sample;
            }
        }

        public String UserAgentIfLong
        {
            get
            {
                if (UserAgentSample == UserAgent)
                    return "";
                return UserAgent;
            }
        }
        */

        [DataMember]
		public String Detail
		{
            get;
            set;
		}

        #endregion

        #region Constructors
        /// <summary>
        /// General.ErrorLogging::Error404
        /// </summary>
        public Error404()
        {
            this.AppID = ErrorReporter.AppID;
        }
        #endregion Constructors

        #region Fill Model
        protected void FillModel(Model.Error404 objModel)
        {
			this.ID = objModel.ID;
            this.AppID = objModel.AppID;
            this.Environment = objModel.Environment;
            this.ClientID = objModel.ClientID;
			this.FirstTime = objModel.FirstTime;
			this.LastTime = objModel.LastTime;
			this.URL = objModel.URL;
			this.Count = objModel.Count;
            this.Hide = objModel.Hide;
            this.UserAgent = objModel.UserAgent;
			this.Detail = objModel.Detail;
        }
        #endregion

        #region ToString
        public override string ToString()
        {
            return this.URL;
        }
        #endregion

    } //End Class



} //End Namespace
