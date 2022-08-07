using System;
using General;
using General.Model;
using System.Runtime.Serialization;

namespace General.ErrorLogging.Model
{

    [DataContract]
    public class ErrorOtherOccurrence : ErrorOther, IErrorOther
    {

        #region Public Properties
        [DataMember]
        public string IncidentCode
        {
            get
            {
                return Convert.ToString(ID, 16);
            }
        }

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

        #endregion

        #region Constructors
        /// <summary>
        /// General.ErrorLogging::ErrorOtherOccurrence
        /// </summary>
        public ErrorOtherOccurrence()
        {

        }

        /// <summary>
        /// General.ErrorLogging::ErrorOtherOccurrence
        /// </summary>
        public ErrorOtherOccurrence(ErrorOther mdlError)
        {
            base.FillModel(mdlError);
        }
        #endregion Constructors

        #region Fill Model
        protected void FillModel(Model.ErrorOtherOccurrence objModel)
        {
			this.ID = objModel.ID;
            this.ErrorOtherID = objModel.ErrorOtherID;
            this.TimeStamp = objModel.TimeStamp;
            base.FillModel(objModel);
        }
        #endregion

    } //End Class



} //End Namespace
