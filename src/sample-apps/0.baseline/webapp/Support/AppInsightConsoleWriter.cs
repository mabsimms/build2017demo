using Microsoft.ApplicationInsights.Extensibility;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights.Channel;

namespace SampleWebAppBaseline.Support
{
    public class AppInsightConsoleWriter : ITelemetryProcessor
    {
        private readonly ITelemetryProcessor _next;

        public AppInsightConsoleWriter(ITelemetryProcessor next)
        {
            _next = next;
        }

        public void Process(ITelemetry item)
        {
            Console.WriteLine(item?.ToString());
            _next.Process(item);
        }
    }
}
