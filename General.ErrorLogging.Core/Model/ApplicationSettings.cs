using System;
using General;
using General.Model;

namespace General.ErrorLogging.Model
{

    public class ApplicationSettings : Application
    {

        #region Public Properties



        #endregion

        #region Constructors
        /// <summary>
        /// General.ErrorLogging::ApplicationSettings
        /// </summary>
        public ApplicationSettings()
        {

        }
        #endregion Constructors

        #region Fill Model
        protected new void FillModel(Model.Application objModel)
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
