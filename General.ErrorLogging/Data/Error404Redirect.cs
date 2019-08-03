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
	/// General.ErrorLogging::Error404Redirect
	/// </summary>
    public class Error404Redirect
	{
        public static readonly string ConnectionStringName = "ErrorLog";

		#region CreateError404Redirect
        public static Model.Error404Redirect CreateError404Redirect(Model.Error404Redirect objModel)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_Error404Redirect_Insert]");
			cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", SqlConvert.ToSql(objModel.AppID));
            if (!StringFunctions.IsNullOrWhiteSpace(objModel.ClientID))
			    cmd.Parameters.AddWithValue("@ClientID",SqlConvert.ToSql(objModel.ClientID));
			cmd.Parameters.AddWithValue("@RedirectType",SqlConvert.ToSql(objModel.RedirectType));
			cmd.Parameters.AddWithValue("@From",SqlConvert.ToSql(objModel.From));
			cmd.Parameters.AddWithValue("@To",SqlConvert.ToSql(objModel.To));

            return GetError404RedirectModel(SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0].Rows[0]);
		}
		#endregion CreateError404Redirect

		#region UpdateError404Redirect
		public static Model.Error404Redirect UpdateError404Redirect(Model.Error404Redirect objModel)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_Error404Redirect_Update]");
			cmd.CommandType = CommandType.StoredProcedure;
			cmd.Parameters.AddWithValue("@Error404RedirectID",SqlConvert.ToSql(objModel.ID));
			cmd.Parameters.AddWithValue("@RedirectType",SqlConvert.ToSql(objModel.RedirectType));
			cmd.Parameters.AddWithValue("@From",SqlConvert.ToSql(objModel.From));
			cmd.Parameters.AddWithValue("@To",SqlConvert.ToSql(objModel.To));
			cmd.Parameters.AddWithValue("@FirstTime",SqlConvert.ToSql(objModel.FirstTime));
			cmd.Parameters.AddWithValue("@LastTime",SqlConvert.ToSql(objModel.LastTime));
			cmd.Parameters.AddWithValue("@Count",SqlConvert.ToSql(objModel.Count));

			return GetError404RedirectModel(SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0].Rows[0]);
		}
        #endregion UpdateError404Redirect

        #region UpdateLog
        public static Model.Error404Redirect UpdateLog(Model.Error404Redirect objModel)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404Redirect_UpdateLog]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Error404RedirectID", SqlConvert.ToSql(objModel.ID));
            cmd.Parameters.AddWithValue("@FirstTime", SqlConvert.ToSql(objModel.FirstTime));
            cmd.Parameters.AddWithValue("@LastTime", SqlConvert.ToSql(objModel.LastTime));
            cmd.Parameters.AddWithValue("@Count", SqlConvert.ToSql(objModel.Count));

            return GetError404RedirectModel(SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0].Rows[0]);
        }
        #endregion UpdateError404Redirect

        #region DeleteError404Redirect
        public static void DeleteError404Redirect(Int32 intID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404Redirect_Delete]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Error404RedirectID", SqlConvert.ToSql(intID));
            SqlHelper.ExecuteNonQuery(cmd, null, ConnectionStringName);
        }
        #endregion DeleteError404Redirect

        #region GetError404Redirect
        public static Model.Error404Redirect GetError404Redirect(Int32 intID)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_Error404Redirect_Select]");
			cmd.CommandType = CommandType.StoredProcedure;
			cmd.Parameters.AddWithValue("@Error404RedirectID",SqlConvert.ToSql(intID));

            var ds = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName);
            if (ds == null)
                return null;
            if (ds.Tables.Count == 0)
                return null;
            if (ds.Tables[0].Rows.Count == 0)
                return null;
            return GetError404RedirectModel(ds.Tables[0].Rows[0]);

		}

        public static Model.Error404Redirect GetError404Redirect(int intAppID, string strClientID, string strFrom)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404Redirect_SelectByFrom]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", intAppID);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            cmd.Parameters.AddWithValue("@From", SqlConvert.ToSql(strFrom));

            var ds = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName);
            if (ds == null)
                return null;
            if (ds.Tables.Count == 0)
                return null;
            if (ds.Tables[0].Rows.Count == 0)
                return null;
            return GetError404RedirectModel(ds.Tables[0].Rows[0]);

        }
        #endregion GetError404Redirect

        #region GetError404Redirects
        public static List<Model.Error404Redirect> GetError404Redirects(int intAppID, string strClientID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_Error404Redirect_SelectAll]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", intAppID);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, null, ConnectionStringName).Tables[0];
            List<Model.Error404Redirect> lstModels = new List<Model.Error404Redirect>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetError404RedirectModel(objRow));
            }
            return lstModels;
        }
        #endregion

        #region GetError404RedirectModel
        public static Model.Error404Redirect GetError404RedirectModel(DataRow row)
        {
            Model.Error404Redirect objModel = new General.ErrorLogging.Model.Error404Redirect();
			objModel.ID = SqlConvert.ToInt32(row["Error404RedirectID"]);
            objModel.AppID = SqlConvert.ToInt32(row["Error404RedirectAppID"]);
            objModel.ClientID = SqlConvert.ToString(row["Error404RedirectClientID"]);
            if (row["Error404RedirectCreateDate"] != DBNull.Value)
			    objModel.CreateDate =  (DateTimeOffset) row["Error404RedirectCreateDate"];
            if (row["Error404RedirectModifyDate"] != DBNull.Value)
			    objModel.ModifyDate = (DateTimeOffset) row["Error404RedirectModifyDate"];
			objModel.RedirectType = SqlConvert.ToInt16(row["Error404RedirectRedirectType"]);
			objModel.From = SqlConvert.ToString(row["Error404RedirectFrom"]);
            objModel.To = SqlConvert.ToString(row["Error404RedirectTo"]);
            if (row["Error404RedirectFirstTime"] != DBNull.Value)
			    objModel.FirstTime = (DateTimeOffset) row["Error404RedirectFirstTime"];
            if (row["Error404RedirectLastTime"] != DBNull.Value)
			    objModel.LastTime = (DateTimeOffset) row["Error404RedirectLastTime"];
			objModel.Count = SqlConvert.ToInt32(row["Error404RedirectCount"]);

            if (row.Table.Columns.Contains("AppURL"))
            {
                objModel.AppName = SqlConvert.ToString(row["AppName"]);
                objModel.AppURL = SqlConvert.ToString(row["AppURL"]);
            }

            return objModel;
        }
        #endregion GetError404RedirectModel

    } //End Class


} //End Namespace
