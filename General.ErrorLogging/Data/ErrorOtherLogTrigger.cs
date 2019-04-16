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
    public class ErrorOtherLogTrigger
    {
        public static readonly string ConnectionStringName = "ErrorLog";

        #region GetPendingTriggers
        public static List<Model.ErrorOtherLogTrigger> GetPendingTriggers(int? intAppID = null)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOther_SelectPendingTriggers]");
            cmd.CommandType = CommandType.StoredProcedure;
            if (intAppID.HasValue)
                cmd.Parameters.AddWithValue("@AppID", intAppID.Value);
            DataTable objTable = SqlHelper.ExecuteDataset(cmd, ConnectionStringName).Tables[0];
            List<Model.ErrorOtherLogTrigger> aryModels = new List<Model.ErrorOtherLogTrigger>();
            foreach (DataRow objRow in objTable.Rows)
            {
                Model.ErrorOtherLogTrigger trigger = new Model.ErrorOtherLogTrigger();
                trigger.ID = (int)objRow["ErrorOtherLogTriggerID"];
                trigger.Event = ErrorOther.GetErrorOtherOccurrenceModel(objRow);
                trigger.Filter = (Model.LoggingFilter)LoggingFilter.GetFilterModel(objRow, LoggingFilterViewType.Full);
                aryModels.Add(trigger);
            }
            return aryModels;
        }
        #endregion

        #region MarkAsProcessed
        public static void MarkAsProcessed(int intErrorOtherLogTriggerID, bool blnProcessingSuccessful, bool blnSMSSent, bool blnEmailSent, string strDetails = null)
        {
            SqlCommand cmd;
            cmd = new SqlCommand("[dbo].[pr_ErrorOtherLogTrigger_MarkAsProcessed]");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@ErrorOtherLogTriggerID", intErrorOtherLogTriggerID);
            cmd.Parameters.AddWithValue("@ProcessingSuccessful", blnProcessingSuccessful);
            cmd.Parameters.AddWithValue("@SMSSent", blnSMSSent);
            cmd.Parameters.AddWithValue("@EmailSent", blnEmailSent);
            if (!General.StringFunctions.IsNullOrWhiteSpace(strDetails))
                cmd.Parameters.AddWithValue("@Details", strDetails);
            SqlHelper.ExecuteNonQuery(cmd, ConnectionStringName);
        }
        #endregion

    }

}
