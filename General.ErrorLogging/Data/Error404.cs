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
	/// General.ErrorLogging::Error404
	/// </summary>
    public class Error404
    {
        public static readonly string ConnectionStringName = "ErrorLog";

        #region RecordError404
        public static Model.Error404 RecordError404(int AppID, Environment.EnvironmentContext Environment, string ClientID, string URL, string UserAgent, string Detail)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_Error404_Insert]");
			cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", SqlConvert.ToSql(AppID));
            cmd.Parameters.AddWithValue("@EnvironmentID", (int)Environment);
            if (!StringFunctions.IsNullOrWhiteSpace(ClientID)) cmd.Parameters.AddWithValue("@ClientID", SqlConvert.ToSql(ClientID));
            cmd.Parameters.AddWithValue("@URL", SqlConvert.ToSql(URL));
            cmd.Parameters.AddWithValue("@UserAgent", SqlConvert.ToSql(UserAgent));
			cmd.Parameters.AddWithValue("@Detail", SqlConvert.ToSql(Detail));

            return GetError404Model(SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0].Rows[0]);
		}
        #endregion RecordError404

        #region UpdateError404
        public static Model.Error404 UpdateError404(Model.Error404 objModel)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_Error404_Update]");
			cmd.CommandType = CommandType.StoredProcedure;
			cmd.Parameters.AddWithValue("@Error404ID",SqlConvert.ToSql(objModel.ID));
			cmd.Parameters.AddWithValue("@URL",SqlConvert.ToSql(objModel.URL));
			cmd.Parameters.AddWithValue("@Count",SqlConvert.ToSql(objModel.Count));
            cmd.Parameters.AddWithValue("@Hide", SqlConvert.ToSql(objModel.Hide));
            cmd.Parameters.AddWithValue("@UserAgent", SqlConvert.ToSql(objModel.UserAgent));
			cmd.Parameters.AddWithValue("@Detail",SqlConvert.ToSql(objModel.Detail));

			return GetError404Model(SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0].Rows[0]);
		}
        #endregion UpdateError404

        #region UpdateError404Visibility
        public static void UpdateError404Visibility(Int32 intID, bool blnHide)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404_UpdateVisibility]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Error404ID", intID);
            cmd.Parameters.AddWithValue("@Hide", blnHide);
            SqlHelper.ExecuteNonQuery(cmd, null, ConnectionStringName);
        }
        #endregion UpdateError404Visibility

        #region DeleteError404
        public static void DeleteError404(Int32 intID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404_Delete]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Error404ID", SqlConvert.ToSql(intID));
            SqlHelper.ExecuteNonQuery(cmd, null, ConnectionStringName);
        }
        #endregion DeleteError404

        #region GetError404
        public static Model.Error404 GetError404(Int32 intID)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_Error404_Select]");
			cmd.CommandType = CommandType.StoredProcedure;
			cmd.Parameters.AddWithValue("@Error404ID",SqlConvert.ToSql(intID));

            var ds = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName);
            if (ds == null)
                return null;
            if (ds.Tables.Count == 0)
                return null;
            if (ds.Tables[0].Rows.Count == 0)
                return null;
            return GetError404Model(ds.Tables[0].Rows[0]);
		}
        #endregion GetError404

        #region GetError404s
        public static List<Model.Error404> GetError404s(int intAppID, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404_SelectAll]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", intAppID);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);

            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<Model.Error404> lstModels = new List<Model.Error404>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetError404Model(objRow));
            }
            return lstModels;
        }

        public static List<Model.Error404> GetError404s(int intAppID, string strClientID, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404_SelectAll]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", intAppID);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);

            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<Model.Error404> lstModels = new List<Model.Error404>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetError404Model(objRow));
            }
            return lstModels;
        }

        public static List<Model.Error404> GetError404s(int intAppID, General.Environment.EnvironmentContext? enuEnvironment, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404_SelectAll]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", intAppID);
            if (enuEnvironment.HasValue)
                cmd.Parameters.AddWithValue("@EnvironmentID", (int)enuEnvironment.Value);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);

            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<Model.Error404> lstModels = new List<Model.Error404>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetError404Model(objRow));
            }
            return lstModels;
        }

        public static List<Model.Error404> GetError404s(int intAppID, string strClientID, General.Environment.EnvironmentContext? enuEnvironment, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404_SelectAll]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", intAppID);
            if (enuEnvironment.HasValue)
                cmd.Parameters.AddWithValue("@EnvironmentID", (int)enuEnvironment.Value);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);

            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<Model.Error404> lstModels = new List<Model.Error404>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetError404Model(objRow));
            }
            return lstModels;
        }

        public static List<Model.Error404> GetError404s_CommonOnly(int intAppID, string strClientID, General.Environment.EnvironmentContext? enuEnvironment, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404_SelectAll]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", intAppID);
            if (enuEnvironment.HasValue)
                cmd.Parameters.AddWithValue("@EnvironmentID", (int)enuEnvironment.Value);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);
            cmd.Parameters.AddWithValue("@ReturnCommonOnly", 1);

            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<Model.Error404> lstModels = new List<Model.Error404>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetError404Model(objRow));
            }
            return lstModels;
        }

        public static List<Model.Error404> GetError404s_Hidden(int intAppID, string strClientID, General.Environment.EnvironmentContext? enuEnvironment, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404_SelectAll]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", intAppID);
            if (enuEnvironment.HasValue)
                cmd.Parameters.AddWithValue("@EnvironmentID", (int)enuEnvironment.Value);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);
            cmd.Parameters.AddWithValue("@ReturnHidden", 1);

            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<Model.Error404> lstModels = new List<Model.Error404>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetError404Model(objRow));
            }
            return lstModels;
        }
        #endregion

        #region GetError404Model
        public static Model.Error404 GetError404Model(DataRow row)
        {
            Model.Error404 objModel = new General.ErrorLogging.Model.Error404();
			objModel.ID = SqlConvert.ToInt32(row["Error404ID"]);
            objModel.AppID = SqlConvert.ToInt32(row["Error404AppID"]);
            objModel.Environment = (Environment.EnvironmentContext)SqlConvert.ToInt16(row["Error404EnvironmentID"]);
            if (row["Error404ClientID"] != DBNull.Value)
                objModel.ClientID = SqlConvert.ToString(row["Error404ClientID"]);
            if (row["Error404FirstTime"] != DBNull.Value)
			    objModel.FirstTime = (DateTimeOffset) row["Error404FirstTime"];
            if (row["Error404LastTime"] != DBNull.Value)
			    objModel.LastTime = (DateTimeOffset) row["Error404LastTime"];
			objModel.URL = SqlConvert.ToString(row["Error404URL"]);
			objModel.Count = SqlConvert.ToInt16(row["Error404Count"]);
            objModel.Hide = SqlConvert.ToBoolean(row["Error404Hide"]);
            objModel.UserAgent = SqlConvert.ToString(row["Error404UserAgent"]);
			objModel.Detail = SqlConvert.ToString(row["Error404Detail"]);

            if(row.Table.Columns.Contains("AppURL"))
            {
                objModel.AppName = SqlConvert.ToString(row["AppName"]);
                objModel.AppURL = SqlConvert.ToString(row["AppURL"]);
            }

            return objModel;
        }
        #endregion GetError404Model

    } //End Class


} //End Namespace
