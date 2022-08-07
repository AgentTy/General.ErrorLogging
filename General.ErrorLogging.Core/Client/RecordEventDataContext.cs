using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace General.ErrorLogging.Client
{
    public class RecordEventDataContext
    {
        public string AccessCode { get; set; }
        public EventContext EventContext { get; set; }
        public ApplicationContext AppContext { get; set; }
        public FilterContext FilterContext { get; set; }
        public EventHistoryContext EventHistory { get; set; }
    }
}
