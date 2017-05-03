using System;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

namespace SampleWebAppBaseline.Support
{
    internal class TraceProvider : ILoggerProvider
    {
        private IConfiguration config;
        private ILogger logger;

        public TraceProvider(IConfiguration config)
        {
            this.config = config;
            this.logger = new Tracer();
        }

        public ILogger CreateLogger(string categoryName)
        {
            return logger;
        }

        public void Dispose()
        {
           
        }
    }

    internal class Tracer : ILogger
    {
        private object _lockObj = new object();

        public IDisposable BeginScope<TState>(TState state)
        {
           return null;
        }

        public bool IsEnabled(LogLevel logLevel)
        {
            return true;
        }

        public void Log<TState>(LogLevel logLevel, EventId eventId, 
            TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            lock(_lockObj)
            {
                // Send the tracing information somewhere awesome
                System.Threading.Thread.Sleep(10);
            }
        }
    }
}