using System;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace General.ErrorLogging.Client.Tests
{
    [TestClass]
    public class ErrorReporterTest
    {
        [TestMethod]
        public void TestGetFilters()
        {
            var filters = General.ErrorLogging.Data.LoggingFilter.GetFiltersForRemoteServer(18);
            Assert.IsNotNull(filters);
        }

        [TestMethod]
        public async Task TestError()
        {
            
            var response1 = await ErrorReporter.ReportError("error");
            Assert.IsNotNull(response1);
            Assert.IsTrue(response1.Success);
            Assert.IsFalse(String.IsNullOrWhiteSpace(response1.IncidentCode) || response1.IncidentCode == "0");


            try
            {
                long intTest = 42424242242423342;
                short test = Convert.ToInt16(intTest);
            }
            catch (Exception ex)
            {
                ApplicationContext context = new ApplicationContext();
                context.ClientID = "client4";
                context.Custom1 = "cus1";
                context.Custom2 = "cus2";
                context.Custom3 = "cus3";
                context.CustomID = 9876;
                context.UserID = "user4";
                context.UserType = "utype4";

                var response2 = await ErrorReporter.ReportError(ex, "My Error Name", context: context, intSeverity: 99, strDetails: "these are more details");
                Assert.IsNotNull(response2);
                Assert.IsTrue(response2.Success);
                Assert.IsFalse(String.IsNullOrWhiteSpace(response2.IncidentCode) || response2.IncidentCode == "0");
            }

        }

        [TestMethod]
        public void TestErrorSynchronous()
        {

            var response1 = ErrorReporter.ReportError("error").Result;
            Assert.IsNotNull(response1);
            Assert.IsTrue(response1.Success);
            Assert.IsFalse(String.IsNullOrWhiteSpace(response1.IncidentCode) || response1.IncidentCode == "0");

            /*
            try
            {
                long intTest = 42424242242423342;
                short test = Convert.ToInt16(intTest);
            }
            catch (Exception ex)
            {
                ApplicationContext context = new ApplicationContext();
                context.ClientID = "client4";
                context.Custom1 = "cus1";
                context.Custom2 = "cus2";
                context.Custom3 = "cus3";
                context.CustomID = 9876;
                context.UserID = "user4";
                context.UserType = "utype4";

                var response2 = ErrorReporter.ReportError(ex, "My Error Name", context: context, intSeverity: 99, strDetails: "these are more details").Result;
                Assert.IsNotNull(response2);
                Assert.IsTrue(response2.Success);
                Assert.IsFalse(String.IsNullOrWhiteSpace(response2.IncidentCode) || response2.IncidentCode == "0");
            }
            */
        }


        [TestMethod]
        public async Task TestAudit()
        {
            ApplicationContext context = new ApplicationContext();
            context.ClientID = "client4";
            context.Custom1 = "cus1";
            context.Custom2 = "cus2";
            context.Custom3 = "cus3";
            context.CustomID = 9876;
            context.UserID = "user4";
            context.UserType = "utype4";

            var response = await ErrorReporter.ReportAudit("audit unit test", context);
            Assert.IsNotNull(response);
            Assert.IsTrue(response.Success);
            Assert.IsFalse((String.IsNullOrWhiteSpace(response.IncidentCode) || response.IncidentCode == "0") && !response.Message.Contains("unknown"));

            var response2 = await ErrorReporter.ReportAudit("audit unit test 2", context, intSeverity: 97, strDetails: "audit detail text", strMethodName: "MyMethod", strFileName: "MyFile.test");
            Assert.IsNotNull(response2);
            Assert.IsTrue(response2.Success);
            Assert.IsFalse((String.IsNullOrWhiteSpace(response2.IncidentCode) || response2.IncidentCode == "0") && !response2.Message.Contains("unknown"));

        }
        

        [TestMethod]
        public async Task TestCode()
        {
            var context = new ApplicationContext(strClientID: "Organization ID/Name", strUserType: "UserType", strUserID: "UserID");

            await ErrorReporter.ReportError("Error 1", context, intSeverity: 8, intDuration: 1234);
            await ErrorReporter.ReportError("Error 2");

            await ErrorReporter.ReportAudit("Audit 1", context, strDetails: "This is what happened in detail", intDuration: 3333);
            await ErrorReporter.ReportAudit("Audit 2");

            await ErrorReporter.ReportTrace("Trace 1", context, strDetails: "Details", strMethodName: System.Reflection.MethodBase.GetCurrentMethod().Name, intDuration: 2222);
            await ErrorReporter.ReportTrace("Trace 2");

            await ErrorReporter.ReportWarning("Warning 1", context, strDetails: "A file couldn't be loaded, restoring from cache", strFileName: "File.jpg", intDuration: 1111);
            await ErrorReporter.ReportWarning("Warning 2");
        }
    }
}
