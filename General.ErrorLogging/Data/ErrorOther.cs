using System;
using General;
using General.ErrorLogging.Model;
using General.Data;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Linq;

namespace General.ErrorLogging.Data
{

	/// <summary>
	/// General.ErrorLogging::ErrorOther
	/// </summary>
    public class ErrorOther
    {
        public static readonly string ConnectionStringName = "ErrorLog";

        #region Queuing
        private static System.Collections.Generic.List<SqlCommand> ErrorQueue = new System.Collections.Generic.List<SqlCommand>();

        public static void ClearQueue()
        {
            if (ErrorQueue.Count > 500)
                ErrorQueue.Clear(); //Safety mechanism

            while (ErrorQueue.Count > 0)
            {
                SqlCommand cmd = ErrorQueue[0];
                try
                {
                    SqlHelper.ExecuteNonQuery(cmd, ConnectionStringName);
                    ErrorQueue.RemoveAt(0);
                }
                catch
                {
                    return;
                }
            }
        }
        #endregion

        #region StoreEvent
        public static long StoreEvent(Model.ErrorOther objModel, FilterContext filterContext, EventHistoryContext historyContext)
		{
            try
            {
                if (historyContext != null && !String.IsNullOrWhiteSpace(historyContext.Last) && historyContext.Last.ToLower() != "unknown")
                {
                    string history = "";
                    history += "EVENT HISTORY: ";
                    history += "#" + historyContext.Last + " ";
                    foreach (string incidentCode in historyContext.History)
                    {
                        if (incidentCode != historyContext.Last && incidentCode.ToLower() != "unknown")
                            history += "#" + incidentCode + " ";
                    }
                    if (String.IsNullOrWhiteSpace(objModel.Custom3) && history.Length <= 200)
                        objModel.Custom3 = history;
                }
            }
            catch { }

            SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_ErrorOther_Insert]");
			cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", objModel.AppID);
            cmd.Parameters.AddWithValue("@EnvironmentID", (int)objModel.Environment);
            if (!StringFunctions.IsNullOrWhiteSpace(objModel.ClientID)) cmd.Parameters.AddWithValue("@ClientID", objModel.ClientID);
			cmd.Parameters.AddWithValue("@ErrorType", (int) objModel.EventType);
            if (objModel.Severity.HasValue) cmd.Parameters.AddWithValue("@Severity", (int) objModel.Severity);
            cmd.Parameters.AddWithValue("@ExceptionType", objModel.ExceptionType);
			cmd.Parameters.AddWithValue("@ErrorCode",SqlConvert.ToSql(objModel.ErrorCode));
            cmd.Parameters.AddWithValue("@CodeMethod", SqlConvert.ToSql(objModel.CodeMethod));
            cmd.Parameters.AddWithValue("@CodeFileName", SqlConvert.ToSql(objModel.CodeFileName));
            cmd.Parameters.AddWithValue("@CodeLineNumber", SqlConvert.ToSql(objModel.CodeLineNumber));
            cmd.Parameters.AddWithValue("@CodeColumnNumber", SqlConvert.ToSql(objModel.CodeColumnNumber, 0));
            cmd.Parameters.AddWithValue("@ErrorName", SqlConvert.ToSql(objModel.EventName));
            cmd.Parameters.AddWithValue("@ErrorDetail", SqlConvert.ToSql(objModel.EventDetail));
            cmd.Parameters.AddWithValue("@ErrorURL", SqlConvert.ToSql(objModel.EventURL));
            cmd.Parameters.AddWithValue("@UserAgent", SqlConvert.ToSql(objModel.UserAgent));
            if (!StringFunctions.IsNullOrWhiteSpace(objModel.UserType)) cmd.Parameters.AddWithValue("@UserType", objModel.UserType);
            if (!StringFunctions.IsNullOrWhiteSpace(objModel.UserID)) cmd.Parameters.AddWithValue("@UserID", objModel.UserID);
            if (objModel.CustomID.HasValue) cmd.Parameters.AddWithValue("@CustomID", objModel.CustomID.Value);
            cmd.Parameters.AddWithValue("@AppName", SqlConvert.ToSql(objModel.AppName));
            cmd.Parameters.AddWithValue("@MachineName", SqlConvert.ToSql(objModel.MachineName));
			cmd.Parameters.AddWithValue("@Custom1",SqlConvert.ToSql(objModel.Custom1));
			cmd.Parameters.AddWithValue("@Custom2",SqlConvert.ToSql(objModel.Custom2));
			cmd.Parameters.AddWithValue("@Custom3",SqlConvert.ToSql(objModel.Custom3));
            cmd.Parameters.AddWithValue("@Duration", SqlConvert.ToSql(objModel.Duration));

            #region Filter Context
            if (filterContext != null && filterContext.MatchedFilters != null && filterContext.MatchedFilters.Length > 0)
            {
                // Add filter context
                DataTable dtFilters = new DataTable("Filters");
                dtFilters.Columns.Add("ID", typeof(int));
                foreach (int intFilterID in filterContext.MatchedFilters)
                {
                    dtFilters.Rows.Add(intFilterID);
                }
                SqlParameter paramFilters = new SqlParameter("@FiltersMatched", SqlDbType.Structured);
                paramFilters.TypeName = "IDListType";
                paramFilters.Value = dtFilters;
                cmd.Parameters.Add(paramFilters);
            }
            #endregion

            try
            {
                long intIncidentID = SqlConvert.ToInt64(SqlHelper.ExecuteScalar(cmd, ConnectionStringName));
                try { ClearQueue(); }
                catch { }
                return intIncidentID;
            }
            catch
            {
                ErrorQueue.Add(cmd);
                throw;
            }
		}

        public static long StoreEvent(General.ErrorLogging.Client.RecordEventDataContext request)
        {
            try
            {
                var historyContext = request.EventHistory;
                if (historyContext != null && !String.IsNullOrWhiteSpace(historyContext.Last) && historyContext.Last.ToLower() != "unknown")
                {
                    string history = "";
                    history += "EVENT HISTORY: ";
                    history += "#" + historyContext.Last + " ";
                    foreach (string incidentCode in historyContext.History)
                    {
                        if (incidentCode != historyContext.Last && incidentCode.ToLower() != "unknown")
                            history += "#" + incidentCode + " ";
                    }
                    if (String.IsNullOrWhiteSpace(request.AppContext.Custom3) && history.Length <= 200)
                        request.AppContext.Custom3 = history;
                }
            }
            catch { }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_Insert]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", request.AppContext.AppID);
            cmd.Parameters.AddWithValue("@EnvironmentID", (int)ErrorReporter.GetEnvironment(request.AppContext));
            if (!StringFunctions.IsNullOrWhiteSpace(request.AppContext.ClientID)) cmd.Parameters.AddWithValue("@ClientID", request.AppContext.ClientID);
            cmd.Parameters.AddWithValue("@ErrorType", (int)request.EventContext.EventType);
            if (request.EventContext.Severity.HasValue) cmd.Parameters.AddWithValue("@Severity", (int)request.EventContext.Severity);
            cmd.Parameters.AddWithValue("@ExceptionType", request.EventContext.ExceptionType);
            cmd.Parameters.AddWithValue("@ErrorCode", SqlConvert.ToSql(request.EventContext.ErrorCode));
            cmd.Parameters.AddWithValue("@CodeMethod", SqlConvert.ToSql(request.EventContext.MethodName));
            cmd.Parameters.AddWithValue("@CodeFileName", SqlConvert.ToSql(request.EventContext.FileName));
            cmd.Parameters.AddWithValue("@CodeLineNumber", SqlConvert.ToSql(request.EventContext.LineNumber));
            cmd.Parameters.AddWithValue("@CodeColumnNumber", SqlConvert.ToSql(request.EventContext.ColumnNumber, 0));
            cmd.Parameters.AddWithValue("@ErrorName", SqlConvert.ToSql(request.EventContext.EventName));
            cmd.Parameters.AddWithValue("@ErrorDetail", SqlConvert.ToSql(request.EventContext.Details));
            cmd.Parameters.AddWithValue("@ErrorURL", SqlConvert.ToSql(request.EventContext.URL));
            cmd.Parameters.AddWithValue("@UserAgent", SqlConvert.ToSql(request.EventContext.UserAgent));
            if (!StringFunctions.IsNullOrWhiteSpace(request.AppContext.UserType)) cmd.Parameters.AddWithValue("@UserType", request.AppContext.UserType);
            if (!StringFunctions.IsNullOrWhiteSpace(request.AppContext.UserID)) cmd.Parameters.AddWithValue("@UserID", request.AppContext.UserID);
            if (request.AppContext.CustomID.HasValue) cmd.Parameters.AddWithValue("@CustomID", request.AppContext.CustomID.Value);
            cmd.Parameters.AddWithValue("@AppName", SqlConvert.ToSql(request.AppContext.AppName));
            cmd.Parameters.AddWithValue("@MachineName", SqlConvert.ToSql(request.AppContext.MachineName));
            cmd.Parameters.AddWithValue("@Custom1", SqlConvert.ToSql(request.AppContext.Custom1));
            cmd.Parameters.AddWithValue("@Custom2", SqlConvert.ToSql(request.AppContext.Custom2));
            cmd.Parameters.AddWithValue("@Custom3", SqlConvert.ToSql(request.AppContext.Custom3));
            cmd.Parameters.AddWithValue("@Duration", SqlConvert.ToSql(request.EventContext.Duration));

            #region Filter Context
            if (request.FilterContext != null && request.FilterContext.MatchedFilters != null && request.FilterContext.MatchedFilters.Length > 0)
            {
                // Add filter context
                DataTable dtFilters = new DataTable("Filters");
                dtFilters.Columns.Add("ID", typeof(int));
                foreach (int intFilterID in request.FilterContext.MatchedFilters)
                {
                    dtFilters.Rows.Add(intFilterID);
                }
                SqlParameter paramFilters = new SqlParameter("@FiltersMatched", SqlDbType.Structured);
                paramFilters.TypeName = "IDListType";
                paramFilters.Value = dtFilters;
                cmd.Parameters.Add(paramFilters);
            }
            #endregion

            try
            {
                long intIncidentID = SqlConvert.ToInt64(SqlHelper.ExecuteScalar(cmd, ConnectionStringName));
                try { ClearQueue(); }
                catch { }
                return intIncidentID;
            }
            catch
            {
                ErrorQueue.Add(cmd);
                throw;
            }
        }

        public static long StoreEvent(int AppID, Environment.EnvironmentContext EnvironmentContext, string ClientID, ErrorOtherTypes EventType, int? intSeverity, string ExceptionType, string CodeMethod, string CodeFileName, int CodeLineNumber, int CodeColumnNumber, string ErrorCode, string EventName, string EventDetail, string EventURL, string UserAgent, string UserType, string UserID, int? CustomID, string AppName, string MachineName, string Custom1, string Custom2, string Custom3, int? Duration, FilterContext filterContext, EventHistoryContext historyContext)
        {

            try
            {
                if (historyContext != null && !String.IsNullOrWhiteSpace(historyContext.Last) && historyContext.Last.ToLower() != "unknown")
                {
                    string history = "";
                    history += "EVENT HISTORY: ";
                    history += "#" + historyContext.Last + " ";
                    foreach (string incidentCode in historyContext.History)
                    {
                        if (incidentCode != historyContext.Last && incidentCode.ToLower() != "unknown")
                            if ((history + "#" + incidentCode + " ").Length > 200)
                                break;
                            history += "#" + incidentCode + " ";
                    }
                    if (String.IsNullOrWhiteSpace(Custom3) && history.Length <= 200)
                        Custom3 = history;
                }
            }
            catch { }


            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_Insert]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@AppID", AppID);
            cmd.Parameters.AddWithValue("@EnvironmentID", (int) EnvironmentContext);
            if (!StringFunctions.IsNullOrWhiteSpace(ClientID)) cmd.Parameters.AddWithValue("@ClientID", ClientID);
            cmd.Parameters.AddWithValue("@ErrorType", (int) EventType);
            if (intSeverity.HasValue) cmd.Parameters.AddWithValue("@Severity", (int)intSeverity);
            cmd.Parameters.AddWithValue("@ExceptionType", ExceptionType);
            cmd.Parameters.AddWithValue("@CodeMethod", SqlConvert.ToSql(CodeMethod));
            cmd.Parameters.AddWithValue("@CodeFileName", SqlConvert.ToSql(CodeFileName));
            cmd.Parameters.AddWithValue("@CodeLineNumber", SqlConvert.ToSql(CodeLineNumber));
            cmd.Parameters.AddWithValue("@CodeColumnNumber", SqlConvert.ToSql(CodeColumnNumber, 0));
            cmd.Parameters.AddWithValue("@ErrorCode", SqlConvert.ToSql(ErrorCode));
            cmd.Parameters.AddWithValue("@ErrorName", SqlConvert.ToSql(EventName));
            cmd.Parameters.AddWithValue("@ErrorDetail", SqlConvert.ToSql(EventDetail));
            cmd.Parameters.AddWithValue("@ErrorURL", SqlConvert.ToSql(EventURL));
            cmd.Parameters.AddWithValue("@UserAgent", SqlConvert.ToSql(UserAgent));
            if (!StringFunctions.IsNullOrWhiteSpace(UserType)) cmd.Parameters.AddWithValue("@UserType", UserType);
            if (!StringFunctions.IsNullOrWhiteSpace(UserID)) cmd.Parameters.AddWithValue("@UserID", UserID);
            if (CustomID.HasValue) cmd.Parameters.AddWithValue("@CustomID", CustomID.Value);
            cmd.Parameters.AddWithValue("@AppName", SqlConvert.ToSql(AppName));
            cmd.Parameters.AddWithValue("@MachineName", SqlConvert.ToSql(MachineName));
            cmd.Parameters.AddWithValue("@Custom1", SqlConvert.ToSql(Custom1));
            cmd.Parameters.AddWithValue("@Custom2", SqlConvert.ToSql(Custom2));
            cmd.Parameters.AddWithValue("@Custom3", SqlConvert.ToSql(Custom3));
            if(Duration.HasValue) cmd.Parameters.AddWithValue("@Duration", SqlConvert.ToSql(Duration));

            #region Filter Context
            if (filterContext != null && filterContext.MatchedFilters != null && filterContext.MatchedFilters.Length > 0)
            {
                // Add filter context
                DataTable dtFilters = new DataTable("Filters");
                dtFilters.Columns.Add("ID", typeof(int));
                foreach (int intFilterID in filterContext.MatchedFilters)
                {
                    dtFilters.Rows.Add(intFilterID);
                }
                SqlParameter paramFilters = new SqlParameter("@FiltersMatched", SqlDbType.Structured);
                paramFilters.TypeName = "IDListType";
                paramFilters.Value = dtFilters;
                cmd.Parameters.Add(paramFilters);
            }
            #endregion

            try
            {
                long intIncidentID = SqlConvert.ToInt64(SqlHelper.ExecuteScalar(cmd, ConnectionStringName));
                try { ClearQueue(); }
                catch { }
                return intIncidentID;
            }
            catch
            {
                ErrorQueue.Add(cmd);
                throw;
            }
        }
        #endregion StoreEvent

        #region UpdateEvent
        public static Model.ErrorOther UpdateEvent(Model.ErrorOther objModel)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_ErrorOther_Update]");
			cmd.CommandType = CommandType.StoredProcedure;
			cmd.Parameters.AddWithValue("@ErrorOtherID", objModel.ID);
			cmd.Parameters.AddWithValue("@ErrorType", objModel.EventType);
            if (objModel.Severity.HasValue) cmd.Parameters.AddWithValue("@Severity", (int)objModel.Severity);
            cmd.Parameters.AddWithValue("@ExceptionType", objModel.ExceptionType);
			cmd.Parameters.AddWithValue("@ErrorCode",SqlConvert.ToSql(objModel.ErrorCode));
            cmd.Parameters.AddWithValue("@CodeMethod", SqlConvert.ToSql(objModel.CodeMethod));
            cmd.Parameters.AddWithValue("@CodeFileName", SqlConvert.ToSql(objModel.CodeFileName));
            cmd.Parameters.AddWithValue("@CodeLineNumber", SqlConvert.ToSql(objModel.CodeLineNumber));
            cmd.Parameters.AddWithValue("@CodeColumnNumber", SqlConvert.ToSql(objModel.CodeColumnNumber, 0));
			cmd.Parameters.AddWithValue("@ErrorName",SqlConvert.ToSql(objModel.EventName));
			cmd.Parameters.AddWithValue("@ErrorDetail",SqlConvert.ToSql(objModel.EventDetail));
			cmd.Parameters.AddWithValue("@ErrorURL",SqlConvert.ToSql(objModel.EventURL));
            cmd.Parameters.AddWithValue("@UserAgent", SqlConvert.ToSql(objModel.UserAgent));
            if (!StringFunctions.IsNullOrWhiteSpace(objModel.UserType)) cmd.Parameters.AddWithValue("@UserType", objModel.UserType);
            if (!StringFunctions.IsNullOrWhiteSpace(objModel.UserID)) cmd.Parameters.AddWithValue("@UserID", objModel.UserID);
            if (objModel.CustomID.HasValue) cmd.Parameters.AddWithValue("@CustomID", objModel.CustomID.Value);
            cmd.Parameters.AddWithValue("@AppName", SqlConvert.ToSql(objModel.AppName));
            cmd.Parameters.AddWithValue("@MachineName", SqlConvert.ToSql(objModel.MachineName));
			cmd.Parameters.AddWithValue("@Custom1",SqlConvert.ToSql(objModel.Custom1));
			cmd.Parameters.AddWithValue("@Custom2",SqlConvert.ToSql(objModel.Custom2));
			cmd.Parameters.AddWithValue("@Custom3",SqlConvert.ToSql(objModel.Custom3));
            cmd.Parameters.AddWithValue("@Duration", SqlConvert.ToSql(objModel.Duration));

			return GetErrorOtherModel(SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0].Rows[0]);
		}
        #endregion UpdateEventSummary

        #region DeleteEventSeries / DeleteEventOccurrence
        public static void DeleteEventSeries(Int32 intID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_Delete]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ErrorOtherID", SqlConvert.ToSql(intID));
            SqlHelper.ExecuteNonQuery(cmd, ConnectionStringName);
        }

        public static void DeleteEventOccurrence(Int64 intID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOtherLog_Delete]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ErrorOtherLogID", SqlConvert.ToSql(intID));
            SqlHelper.ExecuteNonQuery(cmd, ConnectionStringName);
        }
        #endregion DeleteEventSeries / DeleteEventOccurrence

        #region GetEventSummary
        public static Model.ErrorOther GetEventSummary(Int32 intID)
		{
			SqlCommand cmd;
			cmd = new SqlCommand("[dbo].[pr_ErrorOther_Select]");
			cmd.CommandType = CommandType.StoredProcedure;
			cmd.Parameters.AddWithValue("@ErrorOtherID",SqlConvert.ToSql(intID));

            var ds = SqlHelper.ExecuteDataset(cmd, ConnectionStringName);
            if (ds == null)
                return null;
            if (ds.Tables.Count == 0)
                return null;
            if (ds.Tables[0].Rows.Count == 0)
                return null;
            return GetErrorOtherModel(ds.Tables[0].Rows[0]);
		}
        #endregion GetEventSummary

        #region GetEventOccurrence
        public static Model.ErrorOtherOccurrence GetEventOccurrence(long intOccurrenceID)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_SelectOccurrence]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ErrorOtherLogID", SqlConvert.ToSql(intOccurrenceID));

            var ds = SqlHelper.ExecuteDataset(cmd, ConnectionStringName);
            if (ds == null)
                return null;
            if (ds.Tables.Count == 0)
                return null;
            if (ds.Tables[0].Rows.Count == 0)
                return null;
            return GetErrorOtherOccurrenceModel(ds.Tables[0].Rows[0]);
        }
        #endregion GetErrorOther

        #region GetEventSeries
        public static List<Model.ErrorOtherOccurrence> GetEventSeries(int intErrorOtherID, bool blnIncludeDetail = true)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_SelectSeries]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ErrorOtherID", intErrorOtherID);
            cmd.Parameters.AddWithValue("@IncludeDetail", blnIncludeDetail);
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0];
            List<Model.ErrorOtherOccurrence> aryModels = new List<Model.ErrorOtherOccurrence>();
            foreach (DataRow objRow in objTable.Rows)
            {
                aryModels.Add(GetErrorOtherOccurrenceModel(objRow));
            }
            return aryModels;
        }
        #endregion

        #region FindEventSummaries
        public static List<Model.ErrorOther> FindEventSummaries(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, List<int> lstAppIDs, bool? blnIncludeDetail)
        {
            return FindEventSummaries(dtStartDate, dtEndDate, lstAppIDs, null, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOther> FindEventSummaries(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, List<int> lstAppIDs, string strClientID, bool? blnIncludeDetail)
        {
            return FindEventSummaries(dtStartDate, dtEndDate, lstAppIDs, strClientID, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOther> FindEventSummaries(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, List<int> lstAppIDs, string strClientID, Environment.EnvironmentContext? enuEnvironment, bool? blnIncludeDetail)
        {
            return FindEventSummaries(dtStartDate, dtEndDate, lstAppIDs, strClientID, enuEnvironment, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOther> FindEventSummaries(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, List<int> lstAppIDs, string strClientID, Environment.EnvironmentContext? enuEnvironment, List<ErrorOtherTypes> lstEventTypes = null, int? intMinimumSeverity = null, bool? blnIncludeDetail = true)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_SelectSummaries_Multi]");
            cmd.CommandType = CommandType.StoredProcedure;
            if (lstAppIDs != null)
            {
                // Add app id's
                DataTable dtApps = new DataTable("Apps");
                dtApps.Columns.Add("ID", typeof(int));
                foreach (int intAppID in lstAppIDs)
                {
                    dtApps.Rows.Add(intAppID);
                }
                SqlParameter paramApps = new SqlParameter("@Apps", SqlDbType.Structured);
                paramApps.TypeName = "IDListType";
                paramApps.Value = dtApps;
                cmd.Parameters.Add(paramApps);
            }
            if (lstEventTypes != null)
            {
                // Add event types filters
                DataTable dtEvents = new DataTable("EventTypes");
                dtEvents.Columns.Add("ID", typeof(int));
                foreach (var enuEventType in lstEventTypes)
                {
                    dtEvents.Rows.Add((int)enuEventType);
                }
                SqlParameter paramEvents = new SqlParameter("@EventTypes", SqlDbType.Structured);
                paramEvents.TypeName = "IDListType";
                paramEvents.Value = dtEvents;
                cmd.Parameters.Add(paramEvents);
            }
            if (enuEnvironment.HasValue)
                cmd.Parameters.AddWithValue("@EnvironmentID", (int)enuEnvironment.Value);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            if (intMinimumSeverity.HasValue)
                cmd.Parameters.AddWithValue("@MinimumSeverity", intMinimumSeverity.Value);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);
            if (blnIncludeDetail.HasValue)
                cmd.Parameters.AddWithValue("@IncludeDetail", blnIncludeDetail.Value);
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0];
            List<Model.ErrorOther> aryModels = new List<Model.ErrorOther>();
            foreach (DataRow objRow in objTable.Rows)
            {
                aryModels.Add(GetErrorOtherModel(objRow));
            }
            return aryModels;
        }
        #endregion

        #region FindEventSummaries_Basic
        public static List<Model.ErrorOther> FindEventSummaries_Basic(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, int? intAppID, bool? blnIncludeDetail)
        {
            return FindEventSummaries_Basic(dtStartDate, dtEndDate, intAppID, null, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOther> FindEventSummaries_Basic(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, int? intAppID, string strClientID, bool? blnIncludeDetail)
        {
            return FindEventSummaries_Basic(dtStartDate, dtEndDate, intAppID, strClientID, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOther> FindEventSummaries_Basic(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, int? intAppID, string strClientID, Environment.EnvironmentContext? enuEnvironment, bool? blnIncludeDetail)
        {
            return FindEventSummaries_Basic(dtStartDate, dtEndDate, intAppID, strClientID, enuEnvironment, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOther> FindEventSummaries_Basic(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, int? intAppID, string strClientID, Environment.EnvironmentContext? enuEnvironment, ErrorOtherTypes? enuType = null, int? intMinimumSeverity = null, bool? blnIncludeDetail = true)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_SelectSummaries]");
            cmd.CommandType = CommandType.StoredProcedure;
            if(intAppID.HasValue)
                cmd.Parameters.AddWithValue("@AppID", intAppID.Value);
            if (enuEnvironment.HasValue)
                cmd.Parameters.AddWithValue("@EnvironmentID", (int) enuEnvironment.Value);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            if (enuType.HasValue)
                cmd.Parameters.AddWithValue("@ErrorType", (int)enuType.Value);
            if (intMinimumSeverity.HasValue)
                cmd.Parameters.AddWithValue("@MinimumSeverity", intMinimumSeverity.Value);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);
            if (blnIncludeDetail.HasValue)
                cmd.Parameters.AddWithValue("@IncludeDetail", blnIncludeDetail.Value);
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0];
            List<Model.ErrorOther> aryModels = new List<Model.ErrorOther>();
            foreach (DataRow objRow in objTable.Rows)
            {
                aryModels.Add(GetErrorOtherModel(objRow));
            }
            return aryModels;
        }
        #endregion

        #region FindEventLogs
        public static List<Model.ErrorOtherOccurrence> FindEventLogs(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, List<int> lstAppIDs, bool? blnIncludeDetail)
        {
            return FindEventLogs(dtStartDate, dtEndDate, lstAppIDs, null, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOtherOccurrence> FindEventLogs(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, List<int> lstAppIDs, string strClientID, bool? blnIncludeDetail)
        {
            return FindEventLogs(dtStartDate, dtEndDate, lstAppIDs, strClientID, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOtherOccurrence> FindEventLogs(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, List<int> lstAppIDs, string strClientID, Environment.EnvironmentContext? enuEnvironment, bool? blnIncludeDetail)
        {
            return FindEventLogs(dtStartDate, dtEndDate, lstAppIDs, strClientID, enuEnvironment, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOtherOccurrence> FindEventLogs(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, List<int> lstAppIDs, string strClientID, Environment.EnvironmentContext? enuEnvironment, List<ErrorOtherTypes> lstEventTypes = null, int? intMinimumSeverity = null, bool? blnIncludeDetail = true)
        {
            SqlCommand cmd = FindEventLogs_GetCommand(dtStartDate, dtEndDate, lstAppIDs, strClientID, enuEnvironment, lstEventTypes, intMinimumSeverity, blnIncludeDetail);

            List<Model.ErrorOtherOccurrence> aryModels = new List<Model.ErrorOtherOccurrence>();

            //DateTime dtStart1 = DateTime.Now;
            using (SqlConnection conn = DBConnection.GetOpenConnection(DBConnection.GetConnectionString(ConnectionStringName)))
            {
                cmd.Connection = conn;
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        aryModels.Add(GetErrorOtherOccurrenceModel(rdr));
                    }
                }
            }
            //TimeSpan ts1 = DateTime.Now - dtStart1;

            /*
            cmd.Connection = null;
            aryModels = new List<Model.ErrorOtherOccurrence>();
            DateTime dtStart2 = DateTime.Now;
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0];
            foreach (DataRow objRow in objTable.Rows)
            {
                aryModels.Add(GetErrorOtherOccurrenceModel(objRow));
            }
            TimeSpan ts2 = DateTime.Now - dtStart2;
            */

            /*
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0];
            System.Threading.Tasks.Parallel.ForEach(objTable.AsEnumerable(), drow =>
            {
                aryModels.Add(GetErrorOtherOccurrenceModel(drow));
            });
            */
            return aryModels;
        }

        public static SqlCommand FindEventLogs_GetCommand(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, List<int> lstAppIDs, string strClientID, Environment.EnvironmentContext? enuEnvironment, List<ErrorOtherTypes> lstEventTypes = null, int? intMinimumSeverity = null, bool? blnIncludeDetail = true)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_SelectLog_Multi]");
            cmd.CommandType = CommandType.StoredProcedure;
            if (lstAppIDs != null)
            {
                // Add app id's
                DataTable dtApps = new DataTable("Apps");
                dtApps.Columns.Add("ID", typeof(int));
                foreach (int intAppID in lstAppIDs)
                {
                    dtApps.Rows.Add(intAppID);
                }
                SqlParameter paramApps = new SqlParameter("@Apps", SqlDbType.Structured);
                paramApps.TypeName = "IDListType";
                paramApps.Value = dtApps;
                cmd.Parameters.Add(paramApps);
            }
            if (lstEventTypes != null)
            {
                // Add event types filters
                DataTable dtEvents = new DataTable("EventTypes");
                dtEvents.Columns.Add("ID", typeof(int));
                foreach (var enuEventType in lstEventTypes)
                {
                    dtEvents.Rows.Add((int)enuEventType);
                }
                SqlParameter paramEvents = new SqlParameter("@EventTypes", SqlDbType.Structured);
                paramEvents.TypeName = "IDListType";
                paramEvents.Value = dtEvents;
                cmd.Parameters.Add(paramEvents);
            }
            if (enuEnvironment.HasValue)
                cmd.Parameters.AddWithValue("@EnvironmentID", (int)enuEnvironment.Value);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            if (intMinimumSeverity.HasValue)
                cmd.Parameters.AddWithValue("@MinimumSeverity", intMinimumSeverity.Value);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);
            if (blnIncludeDetail.HasValue)
                cmd.Parameters.AddWithValue("@IncludeDetail", blnIncludeDetail.Value);

            return cmd;
        }
        #endregion

        #region FindEventLogs_Basic
        public static List<Model.ErrorOtherOccurrence> FindEventLogs_Basic(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, int? intAppID, bool? blnIncludeDetail)
        {
            return FindEventLogs_Basic(dtStartDate, dtEndDate, intAppID, null, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOtherOccurrence> FindEventLogs_Basic(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, int? intAppID, string strClientID, bool? blnIncludeDetail)
        {
            return FindEventLogs_Basic(dtStartDate, dtEndDate, intAppID, strClientID, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOtherOccurrence> FindEventLogs_Basic(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, int? intAppID, string strClientID, Environment.EnvironmentContext? enuEnvironment, bool? blnIncludeDetail)
        {
            return FindEventLogs_Basic(dtStartDate, dtEndDate, intAppID, strClientID, enuEnvironment, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOtherOccurrence> FindEventLogs_Basic(DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, int? intAppID, string strClientID, Environment.EnvironmentContext? enuEnvironment, ErrorOtherTypes? enuType = null, int? intMinimumSeverity = null, bool? blnIncludeDetail = true)
        {
            if (dtStartDate == dtEndDate)
            {
                dtEndDate = dtEndDate.Add(new TimeSpan(23, 59, 59));
            }

            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_SelectLog]");
            cmd.CommandType = CommandType.StoredProcedure;
            if (intAppID.HasValue)
                cmd.Parameters.AddWithValue("@AppID", intAppID.Value);
            if (enuEnvironment.HasValue)
                cmd.Parameters.AddWithValue("@EnvironmentID", (int)enuEnvironment.Value);
            if (!StringFunctions.IsNullOrWhiteSpace(strClientID))
                cmd.Parameters.AddWithValue("@ClientID", strClientID);
            if (enuType.HasValue)
                cmd.Parameters.AddWithValue("@ErrorType", (int)enuType.Value);
            if (intMinimumSeverity.HasValue)
                cmd.Parameters.AddWithValue("@MinimumSeverity", intMinimumSeverity.Value);
            cmd.Parameters.AddWithValue("@StartDate", dtStartDate);
            cmd.Parameters.AddWithValue("@EndDate", dtEndDate);
            if (blnIncludeDetail.HasValue)
                cmd.Parameters.AddWithValue("@IncludeDetail", blnIncludeDetail.Value);
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0];
            List<Model.ErrorOtherOccurrence> aryModels = new List<Model.ErrorOtherOccurrence>();
            foreach (DataRow objRow in objTable.Rows)
            {
                aryModels.Add(GetErrorOtherOccurrenceModel(objRow));
            }
            return aryModels;
        }
        #endregion

        #region FindEventSummariesByFilter
        public static List<Model.ErrorOther> FindEventSummariesByFilter(Model.ILoggingFilter objFilter, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, bool? blnIncludeDetail)
        {
            return FindEventSummariesByFilter(objFilter, dtStartDate, dtEndDate, null, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOther> FindEventSummariesByFilter(Model.ILoggingFilter objFilter, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, string strClientID, bool? blnIncludeDetail)
        {
            return FindEventSummariesByFilter(objFilter, dtStartDate, dtEndDate, strClientID, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOther> FindEventSummariesByFilter(Model.ILoggingFilter objFilter, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, string strClientID, Environment.EnvironmentContext? enuEnvironment, bool? blnIncludeDetail)
        {
            return FindEventSummariesByFilter(objFilter, dtStartDate, dtEndDate, strClientID, enuEnvironment, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOther> FindEventSummariesByFilter(Model.ILoggingFilter objFilter, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, string strClientID, Environment.EnvironmentContext? enuEnvironment, List<ErrorOtherTypes> lstEventTypes = null, int? intMinimumSeverity = null, bool? blnIncludeDetail = true)
        {
            List<int> lstApps = new List<int>();
            lstApps.Add(objFilter.AppID);
            //First, get unfiltered events from the database
            List<Model.ErrorOther> lstEvents = FindEventSummaries(dtStartDate, dtEndDate, lstApps, strClientID, enuEnvironment, lstEventTypes, intMinimumSeverity, blnIncludeDetail);
            //Next, apply the filter
            return QueryEventsByFilter(lstEvents, objFilter);
        }
        #endregion

        #region FindEventLogsByFilter
        public static List<Model.ErrorOtherOccurrence> FindEventLogsByFilter(Model.ILoggingFilter objFilter, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, bool? blnIncludeDetail)
        {
            return FindEventLogsByFilter(objFilter, dtStartDate, dtEndDate, null, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOtherOccurrence> FindEventLogsByFilter(Model.ILoggingFilter objFilter, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, string strClientID, bool? blnIncludeDetail)
        {
            return FindEventLogsByFilter(objFilter, dtStartDate, dtEndDate, strClientID, null, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOtherOccurrence> FindEventLogsByFilter(Model.ILoggingFilter objFilter, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, string strClientID, Environment.EnvironmentContext? enuEnvironment, bool? blnIncludeDetail)
        {
            return FindEventLogsByFilter(objFilter, dtStartDate, dtEndDate, strClientID, enuEnvironment, null, null, blnIncludeDetail);
        }

        public static List<Model.ErrorOtherOccurrence> FindEventLogsByFilter(Model.ILoggingFilter objFilter, DateTimeOffset dtStartDate, DateTimeOffset dtEndDate, string strClientID, Environment.EnvironmentContext? enuEnvironment, List<ErrorOtherTypes> lstEventTypes = null, int? intMinimumSeverity = null, bool? blnIncludeDetail = true)
        {
            List<int> lstApps = new List<int>();
            lstApps.Add(objFilter.AppID);
            //First, get unfiltered events from the database
            List<Model.ErrorOtherOccurrence> lstEvents = FindEventLogs(dtStartDate, dtEndDate, lstApps, strClientID, enuEnvironment, lstEventTypes, intMinimumSeverity, blnIncludeDetail);
            //Next, apply the filter
            return QueryOccurrencesByFilter(lstEvents, objFilter);
        }
        #endregion

        #region GetErrorOtherModel
        public static Model.ErrorOther GetErrorOtherModel(DataRow row)
        {
            Model.ErrorOther objModel = new General.ErrorLogging.Model.ErrorOther();
			objModel.ID = SqlConvert.ToInt32(row["ErrorOtherID"]);
            objModel.AppID = SqlConvert.ToInt32(row["ErrorOtherAppID"]);
            objModel.Environment = (Environment.EnvironmentContext)SqlConvert.ToInt16(row["ErrorOtherEnvironmentID"]);
            if (row["ErrorOtherClientID"] != DBNull.Value)
			    objModel.ClientID = SqlConvert.ToString(row["ErrorOtherClientID"]);

            if (row["ErrorOtherFirstTime"] != DBNull.Value)
			    objModel.FirstTime = (DateTimeOffset) row["ErrorOtherFirstTime"];
            if (row["ErrorOtherLastTime"] != DBNull.Value)
                objModel.LastTime = (DateTimeOffset) row["ErrorOtherLastTime"];
            if (row.Table.Columns.Contains("ErrorOtherLastLogID"))
                if (row["ErrorOtherLastLogID"] != DBNull.Value)
                    objModel.LastIncidentID = SqlConvert.ToInt32(row["ErrorOtherLastLogID"]);

            objModel.Count = SqlConvert.ToInt32(row["ErrorOtherCount"]);
			objModel.EventType = (ErrorOtherTypes) SqlConvert.ToInt16(row["ErrorOtherErrorType"]);
            if (row["ErrorOtherSeverity"] != DBNull.Value)
                objModel.Severity = Convert.ToInt16(row["ErrorOtherSeverity"]);
            objModel.ExceptionType = SqlConvert.ToString(row["ErrorOtherExceptionType"]);
            objModel.CodeMethod = SqlConvert.ToString(row["ErrorOtherCodeMethod"]);
            objModel.CodeFileName = SqlConvert.ToString(row["ErrorOtherCodeFileName"]);
            objModel.CodeLineNumber = SqlConvert.ToInt32(row["ErrorOtherCodeLineNumber"]);
            objModel.CodeColumnNumber = SqlConvert.ToInt32(row["ErrorOtherCodeColumnNumber"]);
			objModel.ErrorCode = SqlConvert.ToString(row["ErrorOtherErrorCode"]);
			objModel.EventName = SqlConvert.ToString(row["ErrorOtherErrorName"]);
			objModel.EventURL = SqlConvert.ToString(row["ErrorOtherErrorURL"]);
            objModel.UserAgent = SqlConvert.ToString(row["ErrorOtherUserAgent"]);
            if (row["ErrorOtherUserType"] != DBNull.Value)
                objModel.UserType = SqlConvert.ToString(row["ErrorOtherUserType"]);
            if (row["ErrorOtherUserID"] != DBNull.Value)
                objModel.UserID = SqlConvert.ToString(row["ErrorOtherUserID"]);
            if (row["ErrorOtherCustomID"] != DBNull.Value)
                objModel.CustomID = SqlConvert.ToInt32(row["ErrorOtherCustomID"]);
            objModel.AppName = SqlConvert.ToString(row["ErrorOtherAppName"]);
            objModel.MachineName = SqlConvert.ToString(row["ErrorOtherMachineName"]);
            if (row["ErrorOtherCustom1"] != DBNull.Value)
			    objModel.Custom1 = SqlConvert.ToString(row["ErrorOtherCustom1"]);
            if (row["ErrorOtherCustom2"] != DBNull.Value)
			    objModel.Custom2 = SqlConvert.ToString(row["ErrorOtherCustom2"]);
            if (row["ErrorOtherCustom3"] != DBNull.Value)
			    objModel.Custom3 = SqlConvert.ToString(row["ErrorOtherCustom3"]);
            if (row["ErrorOtherDuration"] != DBNull.Value)
                objModel.Duration = SqlConvert.ToInt32(row["ErrorOtherDuration"]);

            if (row.Table.Columns.Contains("ErrorOtherErrorDetail"))
            {
                objModel.EventDetail = SqlConvert.ToString(row["ErrorOtherErrorDetail"]);
                objModel.EventDetailLoaded = true;
            }

            return objModel;
        }

        public static Model.ErrorOther GetErrorOtherModel(SqlDataReader row)
        {
            Model.ErrorOther objModel = new General.ErrorLogging.Model.ErrorOther();
            objModel.ID = SqlConvert.ToInt32(row["ErrorOtherID"]);
            objModel.AppID = SqlConvert.ToInt32(row["ErrorOtherAppID"]);
            objModel.Environment = (Environment.EnvironmentContext)SqlConvert.ToInt16(row["ErrorOtherEnvironmentID"]);
            if (row["ErrorOtherClientID"] != DBNull.Value)
                objModel.ClientID = SqlConvert.ToString(row["ErrorOtherClientID"]);

            if (row["ErrorOtherFirstTime"] != DBNull.Value)
                objModel.FirstTime = (DateTimeOffset)row["ErrorOtherFirstTime"];
            if (row["ErrorOtherLastTime"] != DBNull.Value)
                objModel.LastTime = (DateTimeOffset)row["ErrorOtherLastTime"];
            if (row.HasColumn("ErrorOtherLastLogID"))
                if (row["ErrorOtherLastLogID"] != DBNull.Value)
                    objModel.LastIncidentID = SqlConvert.ToInt32(row["ErrorOtherLastLogID"]);

            objModel.Count = SqlConvert.ToInt32(row["ErrorOtherCount"]);
            objModel.EventType = (ErrorOtherTypes)SqlConvert.ToInt16(row["ErrorOtherErrorType"]);
            if (row["ErrorOtherSeverity"] != DBNull.Value)
                objModel.Severity = Convert.ToInt16(row["ErrorOtherSeverity"]);
            objModel.ExceptionType = SqlConvert.ToString(row["ErrorOtherExceptionType"]);
            objModel.CodeMethod = SqlConvert.ToString(row["ErrorOtherCodeMethod"]);
            objModel.CodeFileName = SqlConvert.ToString(row["ErrorOtherCodeFileName"]);
            objModel.CodeLineNumber = SqlConvert.ToInt32(row["ErrorOtherCodeLineNumber"]);
            objModel.CodeColumnNumber = SqlConvert.ToInt32(row["ErrorOtherCodeColumnNumber"]);
            objModel.ErrorCode = SqlConvert.ToString(row["ErrorOtherErrorCode"]);
            objModel.EventName = SqlConvert.ToString(row["ErrorOtherErrorName"]);
            objModel.EventURL = SqlConvert.ToString(row["ErrorOtherErrorURL"]);
            objModel.UserAgent = SqlConvert.ToString(row["ErrorOtherUserAgent"]);
            if (row["ErrorOtherUserType"] != DBNull.Value)
                objModel.UserType = SqlConvert.ToString(row["ErrorOtherUserType"]);
            if (row["ErrorOtherUserID"] != DBNull.Value)
                objModel.UserID = SqlConvert.ToString(row["ErrorOtherUserID"]);
            if (row["ErrorOtherCustomID"] != DBNull.Value)
                objModel.CustomID = SqlConvert.ToInt32(row["ErrorOtherCustomID"]);
            objModel.AppName = SqlConvert.ToString(row["ErrorOtherAppName"]);
            objModel.MachineName = SqlConvert.ToString(row["ErrorOtherMachineName"]);
            if (row["ErrorOtherCustom1"] != DBNull.Value)
                objModel.Custom1 = SqlConvert.ToString(row["ErrorOtherCustom1"]);
            if (row["ErrorOtherCustom2"] != DBNull.Value)
                objModel.Custom2 = SqlConvert.ToString(row["ErrorOtherCustom2"]);
            if (row["ErrorOtherCustom3"] != DBNull.Value)
                objModel.Custom3 = SqlConvert.ToString(row["ErrorOtherCustom3"]);
            if (row["ErrorOtherDuration"] != DBNull.Value)
                objModel.Duration = SqlConvert.ToInt32(row["ErrorOtherDuration"]);

            if (row.HasColumn("ErrorOtherErrorDetail"))
            {
                objModel.EventDetail = SqlConvert.ToString(row["ErrorOtherErrorDetail"]);
                objModel.EventDetailLoaded = true;
            }

            return objModel;
        }
        #endregion GetErrorOtherModel

        #region GetErrorOtherOccurrenceModel
        public static Model.ErrorOtherOccurrence GetErrorOtherOccurrenceModel(DataRow row)
        {
            Model.ErrorOtherOccurrence objModel = new ErrorOtherOccurrence(GetErrorOtherModel(row));
            
            objModel.ID = SqlConvert.ToInt32(row["ErrorOtherLogID"]);
            objModel.ErrorOtherID = SqlConvert.ToInt32(row["ErrorOtherID"]);
            if (row["ErrorOtherLogTimeStamp"] != DBNull.Value)
                objModel.TimeStamp = (DateTimeOffset) row["ErrorOtherLogTimeStamp"];
            return objModel;
        }

        public static Model.ErrorOtherOccurrence GetErrorOtherOccurrenceModel(SqlDataReader row)
        {
            Model.ErrorOtherOccurrence objModel = new ErrorOtherOccurrence(GetErrorOtherModel(row));

            objModel.ID = SqlConvert.ToInt32(row["ErrorOtherLogID"]);
            objModel.ErrorOtherID = SqlConvert.ToInt32(row["ErrorOtherID"]);
            if (row["ErrorOtherLogTimeStamp"] != DBNull.Value)
                objModel.TimeStamp = (DateTimeOffset)row["ErrorOtherLogTimeStamp"];
            return objModel;
        }
        #endregion GetErrorOtherOccurrenceModel


        #region QueryEventsByFilter
        public static List<Model.ErrorOther> QueryEventsByFilter(List<Model.ErrorOther> lstEvents, Model.ILoggingFilter objFilter)
        {
            IEnumerable<Model.ErrorOther> data = lstEvents;
            if (!objFilter.EnvironmentFilter.WildcardAll && objFilter.EnvironmentFilter.EnvironmentList.Count > 0)
            {
                data = data.Where(row => objFilter.EnvironmentFilter.EnvironmentList.Contains(row.Environment));
            }
            if (!objFilter.EventFilter.WildcardAll && objFilter.EventFilter.Events.Count > 0)
            {
                data = data.Where(row => objFilter.EventFilter.Events.Contains(row.EventType));
            }
            if (!objFilter.ClientFilter.WildcardAll && objFilter.ClientFilter.ClientIDList.Count > 0)
            {
                data = data.Where(row => objFilter.ClientFilter.ClientIDList.Contains<string>(row.ClientID, new CaseInsensitiveComparer()));
            }
            if (!objFilter.UserFilter.WildcardAll && objFilter.UserFilter.UserIDList.Count > 0)
            {
                data = data.Where(row => objFilter.UserFilter.UserIDList.Contains<string>(row.UserID, new CaseInsensitiveComparer()));
            }
            return data.ToList();
        }

        public static List<Model.ErrorOtherOccurrence> QueryOccurrencesByFilter(List<Model.ErrorOtherOccurrence> lstEvents, Model.ILoggingFilter objFilter)
        {
            IEnumerable<Model.ErrorOtherOccurrence> data = lstEvents;
            if (!objFilter.EnvironmentFilter.WildcardAll && objFilter.EnvironmentFilter.EnvironmentList.Count > 0)
            {
                data = data.Where(row => objFilter.EnvironmentFilter.EnvironmentList.Contains(row.Environment));
            }
            if (!objFilter.EventFilter.WildcardAll && objFilter.EventFilter.Events.Count > 0)
            {
                data = data.Where(row => objFilter.EventFilter.Events.Contains(row.EventType));
            }
            if (!objFilter.ClientFilter.WildcardAll && objFilter.ClientFilter.ClientIDList.Count > 0)
            {
                data = data.Where(row => objFilter.ClientFilter.ClientIDList.Contains<string>(row.ClientID, new CaseInsensitiveComparer()));
            }
            if (!objFilter.UserFilter.WildcardAll && objFilter.UserFilter.UserIDList.Count > 0)
            {
                data = data.Where(row => objFilter.UserFilter.UserIDList.Contains<string>(row.UserID, new CaseInsensitiveComparer()));
            }
            return data.ToList();
        }

        public static bool DataRowMatchesFilter(IDataReader reader, Model.ILoggingFilter objFilter)
        {
            if (!objFilter.EnvironmentFilter.WildcardAll && objFilter.EnvironmentFilter.EnvironmentList.Count > 0)
            {
                var tempEnvironment = (Environment.EnvironmentContext)SqlConvert.ToInt16(reader["ErrorOtherEnvironmentID"]);
                if (!objFilter.EnvironmentFilter.EnvironmentList.Contains(tempEnvironment))
                    return false;
            }
            if (!objFilter.EventFilter.WildcardAll && objFilter.EventFilter.Events.Count > 0)
            {
                var tempEventType = (ErrorOtherTypes)SqlConvert.ToInt16(reader["ErrorOtherErrorType"]);
                if (!objFilter.EventFilter.Events.Contains(tempEventType))
                    return false;
            }
            if (!objFilter.ClientFilter.WildcardAll && objFilter.ClientFilter.ClientIDList.Count > 0)
            {
                string tempClientID = "";
                if (reader["ErrorOtherClientID"] != DBNull.Value)
                    tempClientID = SqlConvert.ToString(reader["ErrorOtherClientID"]);
                if (!objFilter.ClientFilter.ClientIDList.Contains<string>(tempClientID, new CaseInsensitiveComparer()))
                    return false;
            }
            if (!objFilter.UserFilter.WildcardAll && objFilter.UserFilter.UserIDList.Count > 0)
            {
                string tempUserID = "";
                if (reader["ErrorOtherUserID"] != DBNull.Value)
                    tempUserID = SqlConvert.ToString(reader["ErrorOtherUserID"]);
                if (!objFilter.UserFilter.UserIDList.Contains<string>(tempUserID, new CaseInsensitiveComparer()))
                    return false;
            }
            return true;
        }
        #endregion

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

    } //End Class

    public static class DataRecordExtensions
    {
        public static bool HasColumn(this IDataRecord dr, string columnName)
        {
            for (int i = 0; i < dr.FieldCount; i++)
            {
                if (dr.GetName(i).Equals(columnName, StringComparison.InvariantCultureIgnoreCase))
                    return true;
            }
            return false;
        }
    }
} //End Namespace
