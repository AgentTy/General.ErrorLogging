using System;
using General;
using General.Model;
using System.Runtime.Serialization;

namespace General.ErrorLogging.Model
{

    [DataContract]
    public class ErrorOtherOccurrenceSimple : ObjectBase
    {

        #region Public Properties

        [DataMember]
		public int ErrorOtherID
		{
            get;
            set;
		}

        [DataMember]
        public DateTimeOffset TimeStamp
        {
            get;
            set;
        }

        [DataMember]
        public string TimeStampString
        {
            get
            {
                if (TimeStamp == null || TimeStamp == DateTime.MinValue)
                    return "";

                string s = TimeStamp.ToString("g") + " GMT";
                if (TimeStamp.Offset.Ticks != 0)
                    s += TimeStamp.ToString("zzz");
                return s;
            }
        }

        [DataMember]
        public String ClientID
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

        #endregion

        #region Constructors
        /// <summary>
        /// General.ErrorLogging::ErrorOtherOccurrenceSimple
        /// </summary>
        public ErrorOtherOccurrenceSimple()
        {

        }
        #endregion Constructors

        #region Fill Model
        protected void FillModel(Model.ErrorOtherOccurrenceSimple objModel)
        {
			this.ID = objModel.ID;
            this.ErrorOtherID = objModel.ErrorOtherID;
            this.TimeStamp = objModel.TimeStamp;
            this.ClientID = objModel.ClientID;
            this.UserType = objModel.UserType;
            this.UserID = objModel.UserID;
            this.CustomID = objModel.CustomID;
        }
        #endregion

    } //End Class



} //End Namespace
