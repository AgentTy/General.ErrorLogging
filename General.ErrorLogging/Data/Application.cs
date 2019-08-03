using System;
using General;
using General.ErrorLogging.Model;
using General.Data;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace General.ErrorLogging.Data
{

	/// <summary>
	/// General.ErrorLogging::Application
	/// </summary>
    public class Application
	{
        public static readonly string ConnectionStringName = "ErrorLog";

        #region ConnectionString
        public static string ConnectionString
        {
            get
            {
                return DBConnection.GetConnectionString(ConnectionStringName);
            }
        }

        public static bool HasErrorLogConnectionString
        {
            get
            {
                try
                {
                    return !String.IsNullOrWhiteSpace(ConnectionString);
                }
                catch
                {
                    return false;
                }
            }
        }
        #endregion

        #region GetApplication
        public static Model.Application GetApplication(Int32 intID)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_Application_Select]");
			cmd.CommandType = CommandType.StoredProcedure;
			cmd.Parameters.AddWithValue("@AppID",SqlConvert.ToSql(intID));

            var ds = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName);
            if (ds == null)
                return null;
            if (ds.Tables.Count == 0)
                return null;
            if (ds.Tables[0].Rows.Count == 0)
                return null;
            return GetApplicationModel(ds.Tables[0].Rows[0]);

		}
        #endregion GetApplication

        #region GetApplicationSettings
        public static Model.Application GetApplicationSettings(Int32 intID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Application_Select]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", SqlConvert.ToSql(intID));

            var ds = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName);
            if (ds == null)
                return null;
            if (ds.Tables.Count == 0)
                return null;
            if (ds.Tables[0].Rows.Count == 0)
                return null;
            return GetApplicationModel(ds.Tables[0].Rows[0]);

        }
        #endregion GetApplication

        #region GetApplications
        public static List<Model.Application> GetApplications()
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Application_SelectAll]");
            cmd.CommandType = CommandType.StoredProcedure;
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<Model.Application> lstModels = new List<Model.Application>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetApplicationModel(objRow));
            }
            return lstModels;
        }
        #endregion

        #region GetApplicationModel
        public static Model.Application GetApplicationModel(DataRow row)
        {
            Model.Application objModel = new General.ErrorLogging.Model.Application();
			objModel.ID = SqlConvert.ToInt32(row["AppID"]);
            objModel.Name = SqlConvert.ToString(row["AppName"]);
            objModel.URL = SqlConvert.ToString(row["AppURL"]);
            if (row["AppSortOrder"] != DBNull.Value)
                objModel.SortOrder = SqlConvert.ToInt32(row["AppSortOrder"]);
            if (row["AppCustomID"] != DBNull.Value)
                objModel.CustomID = SqlConvert.ToInt32(row["AppCustomID"]);
            objModel.Custom1 = SqlConvert.ToString(row["AppCustom1"]);
            objModel.Custom2 = SqlConvert.ToString(row["AppCustom2"]);
            objModel.Custom3 = SqlConvert.ToString(row["AppCustom3"]);

            return objModel;
        }
        #endregion GetApplicationModel

        #region GetApplicationSettingsModel
        public static Model.Application GetApplicationSettingsModel(DataRow row)
        {
            Model.Application objModel = new General.ErrorLogging.Model.Application();
            objModel.ID = SqlConvert.ToInt32(row["AppID"]);
            objModel.Name = SqlConvert.ToString(row["AppName"]);
            objModel.URL = SqlConvert.ToString(row["AppURL"]);
            if (row["AppSortOrder"] != DBNull.Value)
                objModel.SortOrder = SqlConvert.ToInt32(row["AppSortOrder"]);
            if (row["AppCustomID"] != DBNull.Value)
                objModel.CustomID = SqlConvert.ToInt32(row["AppCustomID"]);
            objModel.Custom1 = SqlConvert.ToString(row["AppCustom1"]);
            objModel.Custom2 = SqlConvert.ToString(row["AppCustom2"]);
            objModel.Custom3 = SqlConvert.ToString(row["AppCustom3"]);

            return objModel;
        }
        #endregion GetApplicationModel

        #region GetClients
        public static List<string> GetClients(int intAppID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Application_SelectClients]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", SqlConvert.ToSql(intAppID));
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<string> lstModels = new List<string>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(objRow["ClientID"].ToString());
            }
            return lstModels;
        }
        #endregion

        #region GetUsers
        public static List<string> GetUsers(int intAppID)
        {
            return GetUsers(intAppID, null);
        }

        public static List<string> GetUsers(int intAppID, string strClientID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Application_SelectUsers]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", SqlConvert.ToSql(intAppID));
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", SqlConvert.ToSql(strClientID));
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<string> lstModels = new List<string>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(objRow["UserID"].ToString());
            }
            return lstModels;
        }
        #endregion

    } //End Class


} //End Namespace
