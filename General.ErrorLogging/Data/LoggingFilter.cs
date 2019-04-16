using System;
using General;
using General.ErrorLogging.Model;
using General.Data;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using General.Model;
using System.Linq;

namespace General.ErrorLogging.Data
{

	/// <summary>
    /// General.ErrorLogging::LoggingFilter
	/// </summary>
    public class LoggingFilter
	{
        public static readonly string ConnectionStringName = "ErrorLog";

        #region CreateLoggingFilter
        public static ILoggingFilter CreateLoggingFilter(Model.LoggingFilter objModel)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_LoggingFilter_Insert]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@Name", SqlConvert.ToSql(objModel.Name));
            cmd.Parameters.AddWithValue("@AppID", objModel.AppID);
            cmd.Parameters.AddWithValue("@ClientFilter", objModel.ClientFilter.ToJson());
            cmd.Parameters.AddWithValue("@EnvironmentFilter", objModel.EnvironmentFilter.ToJson());
            cmd.Parameters.AddWithValue("@EventFilter", objModel.EventFilter.ToJson());
            cmd.Parameters.AddWithValue("@UserFilter", objModel.UserFilter.ToJson());
            cmd.Parameters.AddWithValue("@Enabled", SqlConvert.ToSql(objModel.Enabled));
            if (objModel.StartDate.HasValue) cmd.Parameters.AddWithValue("@StartDate", objModel.StartDate);
            if (objModel.EndDate.HasValue) cmd.Parameters.AddWithValue("@EndDate", objModel.EndDate);
            cmd.Parameters.AddWithValue("@PageEmail", SqlConvert.ToSql(objModel.PageEmail));
            cmd.Parameters.AddWithValue("@PageSMS", SqlConvert.ToSql(objModel.PageSMS));
            cmd.Parameters.AddWithValue("@CreatedBy", SqlConvert.ToSql(objModel.FingerPrint.CreatedBy));
            cmd.Parameters.AddWithValue("@Custom1", SqlConvert.ToSql(objModel.Custom1));
            cmd.Parameters.AddWithValue("@Custom2", SqlConvert.ToSql(objModel.Custom2));
            cmd.Parameters.AddWithValue("@Custom3", SqlConvert.ToSql(objModel.Custom3));

            return GetFilterModel(SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0].Rows[0]);
        }
        #endregion CreateLoggingFilter

        #region UpdateLoggingFilter
        public static ILoggingFilter UpdateLoggingFilter(Model.LoggingFilter objModel)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_LoggingFilter_Update]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@LoggingFilterID", SqlConvert.ToSql(objModel.ID));
            cmd.Parameters.AddWithValue("@Name", SqlConvert.ToSql(objModel.Name));
            cmd.Parameters.AddWithValue("@AppID", objModel.AppID);
            cmd.Parameters.AddWithValue("@ClientFilter", objModel.ClientFilter.ToJson());
            cmd.Parameters.AddWithValue("@EnvironmentFilter", objModel.EnvironmentFilter.ToJson());
            cmd.Parameters.AddWithValue("@EventFilter", objModel.EventFilter.ToJson());
            cmd.Parameters.AddWithValue("@UserFilter", objModel.UserFilter.ToJson());
            cmd.Parameters.AddWithValue("@Enabled", SqlConvert.ToSql(objModel.Enabled));
            if (objModel.StartDate.HasValue) cmd.Parameters.AddWithValue("@StartDate", objModel.StartDate);
            if (objModel.EndDate.HasValue) cmd.Parameters.AddWithValue("@EndDate", objModel.EndDate);
            cmd.Parameters.AddWithValue("@PageEmail", SqlConvert.ToSql(objModel.PageEmail));
            cmd.Parameters.AddWithValue("@PageSMS", SqlConvert.ToSql(objModel.PageSMS));
            cmd.Parameters.AddWithValue("@Custom1", SqlConvert.ToSql(objModel.Custom1));
            cmd.Parameters.AddWithValue("@Custom2", SqlConvert.ToSql(objModel.Custom2));
            cmd.Parameters.AddWithValue("@Custom3", SqlConvert.ToSql(objModel.Custom3));

            return GetFilterModel(SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0].Rows[0]);
        }
        #endregion UpdateLoggingFilter

        #region UpdateLoggingFilterStatus
        public static void UpdateLoggingFilterStatus(Int32 intID, bool blnEnabled)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_LoggingFilter_UpdateStatus]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@LoggingFilterID", SqlConvert.ToSql(intID));
            cmd.Parameters.AddWithValue("@Enabled", SqlConvert.ToSql(blnEnabled));
            SqlHelper.ExecuteNonQuery(cmd, ConnectionStringName);
        }
        #endregion UpdateLoggingFilterStatus

        #region DeleteLoggingFilter
        public static void DeleteLoggingFilter(Int32 intID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_LoggingFilter_Delete]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@LoggingFilterID", SqlConvert.ToSql(intID));
            SqlHelper.ExecuteNonQuery(cmd, ConnectionStringName);
        }
        #endregion DeleteLoggingFilter

        #region GetFilter
        public static ILoggingFilter GetFilter(Int32 intID)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_LoggingFilter_Select]");
			cmd.CommandType = CommandType.StoredProcedure;
			cmd.Parameters.AddWithValue("@FilterID",SqlConvert.ToSql(intID));

            var ds = SqlHelper.ExecuteDataset(cmd, ConnectionStringName);
            if (ds == null)
                return null;
            if (ds.Tables.Count == 0)
                return null;
            if (ds.Tables[0].Rows.Count == 0)
                return null;
            return GetFilterModel(ds.Tables[0].Rows[0]);

		}
        #endregion GetApplication

        #region GetFilters

        public class GetActiveFiltersDataContext
        {
            public string AccessCode { get; set; }
            public LoggingFilterRequestContext AppContext { get; set; }
        }

        public class LoggingFilterRequestContext
        {
            public int? AppID;
            public string AccessCode { get; set; }
            public string ClientID { get; set; }
            public string UserID { get; set; }
            public General.Environment.EnvironmentContext? Environment { get; set; }
        }

        public static DataSet GetFilters_DataSet(int? intAppID, LoggingFilterRequestContext objAppContext = null, bool blnActiveOnly = true)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_LoggingFilter_SelectAll]");
            cmd.CommandType = CommandType.StoredProcedure;
            if (intAppID.HasValue)
                cmd.Parameters.AddWithValue("@AppID", intAppID.Value);
            cmd.Parameters.AddWithValue("@ActiveOnly", blnActiveOnly);
            return SqlHelper.ExecuteDataset(cmd, ConnectionStringName);
        }

        public static List<ILoggingFilter> GetFilters(int? intAppID, LoggingFilterRequestContext objAppContext = null, bool blnActiveOnly = true)
        {
            DataTable objTable = GetFilters_DataSet(intAppID, objAppContext, blnActiveOnly).Tables[0];
            List<ILoggingFilter> lstModels = new List<ILoggingFilter>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetFilterModel(objRow));
            }

            if (objAppContext != null)
                return QueryFiltersByAppContext(lstModels, objAppContext, LoggingFilterViewType.Full);
            return lstModels;
        }

        public static List<ILoggingFilter> GetFiltersCustomView(LoggingFilterViewType viewType, int? intAppID, LoggingFilterRequestContext objAppContext = null, bool blnActiveOnly = true)
        {
            DataTable objTable = GetFilters_DataSet(intAppID, objAppContext, blnActiveOnly).Tables[0];
            List<ILoggingFilter> lstModels = new List<Model.ILoggingFilter>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add(GetFilterModel(objRow, viewType: viewType));
            }

            if (objAppContext != null)
                return QueryFiltersByAppContext(lstModels, objAppContext, viewType);
            return lstModels;
        }

        public static List<LoggingFilterRemoteServerView> GetFiltersForRemoteServer(int? intAppID, LoggingFilterRequestContext objAppContext = null, bool blnActiveOnly = true)
        {
            DataTable objTable = GetFilters_DataSet(intAppID, objAppContext, blnActiveOnly).Tables[0];
            List<LoggingFilterRemoteServerView> lstModels = new List<Model.LoggingFilterRemoteServerView>();
            foreach (DataRow objRow in objTable.Rows)
            {
                lstModels.Add((LoggingFilterRemoteServerView) GetFilterModel(objRow, viewType: LoggingFilterViewType.RemoteServer));
            }

            if (objAppContext != null)
                return QueryFiltersByAppContext(lstModels, objAppContext, viewType: LoggingFilterViewType.RemoteServer);
            return lstModels;
        }

        public static List<ILoggingFilter> QueryFiltersByAppContext(List<ILoggingFilter> lstModels, LoggingFilterRequestContext objAppContext, LoggingFilterViewType viewType)
        {
            IEnumerable<ILoggingFilter> data = lstModels;
            data = data.Where(row => row.EnvironmentFilter.WildcardAll || (objAppContext.Environment.HasValue && row.EnvironmentFilter.EnvironmentList.Contains(objAppContext.Environment.Value)));
            if (viewType != LoggingFilterViewType.RemoteServer)
            {
                data = data.Where(row => row.ClientFilter.WildcardAll || row.ClientFilter.ClientIDList.Contains<string>(objAppContext.ClientID, new CaseInsensitiveComparer()));
                data = data.Where(row => row.UserFilter.WildcardAll || row.UserFilter.UserIDList.Contains<string>(objAppContext.UserID, new CaseInsensitiveComparer()));
            }
            return data.ToList();
        }

        public static List<LoggingFilterRemoteServerView> QueryFiltersByAppContext(List<LoggingFilterRemoteServerView> lstModels, LoggingFilterRequestContext objAppContext, LoggingFilterViewType viewType)
        {
            IEnumerable<LoggingFilterRemoteServerView> data = lstModels;
            data = data.Where(row => row.EnvironmentFilter.WildcardAll || (objAppContext.Environment.HasValue && row.EnvironmentFilter.EnvironmentList.Contains(objAppContext.Environment.Value)));
            return data.ToList();
        }

        #region CaseInsensitiveComparer
        internal class CaseInsensitiveComparer : IEqualityComparer<string>
        {
            public bool Equals(string x, string y)
            {
                return String.Equals(x, y, StringComparison.OrdinalIgnoreCase);
            }

            public int GetHashCode(string obj)
            {
                return obj.GetHashCode();
            }
        }
        #endregion

        #endregion

        #region GetFilterModel

        public static ILoggingFilter GetFilterModel(DataRow row, LoggingFilterViewType viewType = LoggingFilterViewType.Full)
        {
            ILoggingFilter objModel;
            if (viewType == LoggingFilterViewType.Browser)
                objModel = new General.ErrorLogging.Model.LoggingFilterBrowserView();
            else if (viewType == LoggingFilterViewType.RemoteServer)
                objModel = new General.ErrorLogging.Model.LoggingFilterRemoteServerView();
            else
                objModel = new General.ErrorLogging.Model.LoggingFilter();
			objModel.ID = SqlConvert.ToInt32(row["FilterID"]);
            objModel.Name = SqlConvert.ToString(row["FilterName"]);
            objModel.AppID = SqlConvert.ToInt32(row["FilterAppID"]);
            //if (row["AppFilter"] != DBNull.Value && !StringFunctions.IsNullOrWhiteSpace(row["AppFilter"].ToString()))
            //    objModel.AppFilter = Model.ApplicationFilterModel.FromJson<Model.ApplicationFilterModel>(row["AppFilter"].ToString());
            if (row["ClientFilter"] != DBNull.Value && !StringFunctions.IsNullOrWhiteSpace(row["ClientFilter"].ToString()))
                objModel.ClientFilter = Model.ClientFilterModel.FromJson<Model.ClientFilterModel>(row["ClientFilter"].ToString());
            if (row["UserFilter"] != DBNull.Value && !StringFunctions.IsNullOrWhiteSpace(row["UserFilter"].ToString()))
                objModel.UserFilter = Model.UserFilterModel.FromJson<Model.UserFilterModel>(row["UserFilter"].ToString());
            if (row["EnvironmentFilter"] != DBNull.Value && !StringFunctions.IsNullOrWhiteSpace(row["EnvironmentFilter"].ToString()))
                objModel.EnvironmentFilter = Model.EnvironmentFilterModel.FromJson<Model.EnvironmentFilterModel>(row["EnvironmentFilter"].ToString());
            if (row["EventFilter"] != DBNull.Value && !StringFunctions.IsNullOrWhiteSpace(row["EventFilter"].ToString()))
                objModel.EventFilter = Model.EventFilterModel.FromJson<Model.EventFilterModel>(row["EventFilter"].ToString());

            objModel.Enabled = SqlConvert.ToBoolean(row["FilterEnabled"]);
            if (row["FilterStartDate"] != DBNull.Value)
                objModel.StartDate = (DateTimeOffset) row["FilterStartDate"];
            if (row["FilterEndDate"] != DBNull.Value)
                objModel.EndDate = (DateTimeOffset) row["FilterEndDate"];
            if (row["FilterPageEmail"] != DBNull.Value)
                objModel.PageEmail = (EmailAddress)row["FilterPageEmail"].ToString();
            if (row["FilterPageSMS"] != DBNull.Value)
                objModel.PageSMS = (PhoneNumber)row["FilterPageSMS"].ToString();

            General.FingerPrint objFingerPrint = new General.FingerPrint();
            objFingerPrint.CreatedBy = SqlConvert.ToInt32(row["FilterCreatedBy"]);
            if (row["FilterCreateDate"] != DBNull.Value)
                objFingerPrint.CreatedOn = ((DateTimeOffset) row["FilterCreateDate"]).LocalDateTime;
            if (row["FilterModifyDate"] != DBNull.Value)
                objFingerPrint.ModifiedOn = ((DateTimeOffset) row["FilterModifyDate"]).LocalDateTime;
            objModel.FingerPrint = objFingerPrint;

            objModel.Custom1 = SqlConvert.ToString(row["FilterCustom1"]);
            objModel.Custom2 = SqlConvert.ToString(row["FilterCustom2"]);
            objModel.Custom3 = SqlConvert.ToString(row["FilterCustom3"]);

            return objModel;
        }
        #endregion GetFilterModel

    } //End Class


} //End Namespace
