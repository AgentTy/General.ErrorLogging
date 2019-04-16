using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace General.ErrorLogging.Tests
{
    [TestClass]
    public class QueryPerformanceTest
    {
        private string AppID = "any";

        [TestMethod]
        public void SelectDBErrors()
        {
            var controller = new ErrorLogging.GUI.Controllers.ErrorLogController();
            var results = controller.Expanded(AppID, DateTimeOffset.Now.AddDays(-90), DateTimeOffset.Now, Type: "2,3,4");
            Assert.IsNotNull(results);
            //Assert.IsTrue(results.Count > 0);
        }
    }
}
