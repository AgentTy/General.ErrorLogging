using System;
using General;
using General.Model;
using System.Runtime.Serialization;

namespace General.ErrorLogging.Model
{

    [DataContract]
    public class Error404Redirect : ObjectBase
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
		public String ClientID
		{
            get;
            set;
		}

        [DataMember]
		public DateTimeOffset CreateDate
		{
            get;
            set;
		}

        [DataMember]
		public DateTimeOffset ModifyDate
		{
            get;
            set;
		}

        [DataMember]
		public Int16 RedirectType
		{
            get;
            set;
		}

        [DataMember]
		public String From
		{
            get;
            set;
		}

        [DataMember]
		public String To
		{
            get;
            set;
		}

        [DataMember]
		public DateTimeOffset? FirstTime
		{
            get;
            set;
		}

        [DataMember]
        public string FirstTimeString
        {
            get
            {
                if (!FirstTime.HasValue)
                    return "";
                return FirstTime.Value.ToString("d");
            }
        }

        [DataMember]
		public DateTimeOffset? LastTime
		{
            get;
            set;
		}

        [DataMember]
        public string LastTimeString
        {
            get
            {
                if (!LastTime.HasValue)
                    return "";
                return LastTime.Value.ToString("d");
            }
        }

        [DataMember]
		public Int32 Count
		{
            get;
            set;
		}

        [DataMember]
        public bool Changed 
        { 
            get; 
            set; 
        }
        #endregion

        #region RecordUse
        public void RecordUse()
        {
            Count++;
            if (!FirstTime.HasValue)
                FirstTime = DateTime.Now;
            LastTime = DateTime.Now;
            Changed = true; 
        }
        #endregion

        #region Constructors
        /// <summary>
        /// General.ErrorLogging::Error404Redirect
        /// </summary>
        public Error404Redirect()
        {
            this.AppID = ErrorReporter.AppID;
        }

        /// <summary>
        /// General.ErrorLogging::Error404Redirect
        /// </summary>
        public Error404Redirect(Int32 intID, Int32 intAppID, String strClientID, DateTimeOffset dtCreateDate, DateTimeOffset dtModifyDate, Int16 intRedirectType, URL objFrom, URL objTo )
        {
			this.ID = intID;
            this.AppID = intAppID;
            this.ClientID = strClientID;
			this.CreateDate = dtCreateDate;
			this.ModifyDate = dtModifyDate;
			this.RedirectType = intRedirectType;
			this.From = objFrom;
			this.To = objTo;
        }

        /// <summary>
        /// General.ErrorLogging::Error404Redirect
        /// </summary>
        public Error404Redirect(Int32 intAppID, String strClientID, Int16 intRedirectType, URL objFrom, URL objTo)
        {
            this.AppID = intAppID;
            this.ClientID = strClientID;
			this.RedirectType = intRedirectType;
			this.From = objFrom;
			this.To = objTo;

        }
        #endregion Constructors

        #region Fill Model
        protected void FillModel(Model.Error404Redirect objModel)
        {
			this.ID = objModel.ID;
            this.AppID = objModel.AppID;
            this.ClientID = objModel.ClientID;
			this.CreateDate = objModel.CreateDate;
			this.ModifyDate = objModel.ModifyDate;
			this.RedirectType = objModel.RedirectType;
			this.From = objModel.From;
			this.To = objModel.To;
			this.FirstTime = objModel.FirstTime;
			this.LastTime = objModel.LastTime;
			this.Count = objModel.Count;
            this.Changed = objModel.Changed;
        }
        #endregion

        #region ToString
        public override string ToString()
        {
            return this.From + " redirecting to " + this.To;
        }
        #endregion

    } //End Class



} //End Namespace
