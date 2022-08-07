using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace General.ErrorLogging.Model
{
    public class ErrorOtherLogTrigger
    {
        public int ID { get; set; }
        public ErrorOtherOccurrence Event { get; set; }
        public LoggingFilter Filter { get; set; }
    }
}
