using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SampleWebAppBaseline.Support
{
    public class LoggingManager
    {
        public static ILoggerFactory GetLoggerFactory(IConfiguration config)
        {
            var provider = new TraceProvider(config);
            var lf = new LoggerFactory();
            lf.AddProvider(provider);
             
            return lf;
        }
    }
}
