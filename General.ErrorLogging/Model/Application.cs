using System;
using General;
using General.Model;
using System.Runtime.Serialization;

namespace General.ErrorLogging.Model
{
    [DataContract]
    public class Application : ObjectBase
    {

        #region Public Properties

        private string _strAppIDString;
        [DataMember]
        public string AppIDString
        {
            get {
                if (StringFunctions.IsNullOrWhiteSpace(_strAppIDString))
                    return ID.ToString();
                else
                    return _strAppIDString;
            }
            set
            {
                _strAppIDString = value;
            }
        }

        [DataMember]
		public string Name
		{
            get;
            set;
		}

        [DataMember]
        public string URL
        {
            get;
            set;
        }

        public int? SortOrder
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
        /// General.ErrorLogging::Application
        /// </summary>
        public Application()
        {

        }
        #endregion Constructors

        #region Fill Model
        protected void FillModel(Model.Application objModel)
        {
			this.ID = objModel.ID;
            this.Name = objModel.Name;
            this.URL = objModel.URL;
            this.SortOrder = objModel.SortOrder;
            this.CustomID = objModel.CustomID;
            this.Custom1 = objModel.Custom1;
            this.Custom2 = objModel.Custom2;
            this.Custom3 = objModel.Custom3;
        }
        #endregion

    } //End Class



} //End Namespace
