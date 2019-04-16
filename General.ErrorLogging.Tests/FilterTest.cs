using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace General.ErrorLogging.Tests
{
    [TestClass]
    public class FilterTest
    {
        [TestMethod]
        public async Task ActiveFiltersInContext()
        {
            var filters = await General.ErrorLogging.Client.EventLogClient.FilterCache.Active();
            var filter = filters.FirstOrDefault();

            filters = await General.ErrorLogging.Client.EventLogClient.FilterCache.Active();
            filter = filters.FirstOrDefault();

            filters = await General.ErrorLogging.Client.EventLogClient.FilterCache.Active();
            filter = filters.FirstOrDefault();

            filters = await General.ErrorLogging.Client.EventLogClient.FilterCache.Active();
            filter = filters.FirstOrDefault();

            filters = await General.ErrorLogging.Client.EventLogClient.FilterCache.Active();
            filter = filters.FirstOrDefault();
        }
    }
}
