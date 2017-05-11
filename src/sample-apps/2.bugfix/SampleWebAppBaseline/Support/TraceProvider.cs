using System;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Microsoft.ApplicationInsights;

namespace SampleWebAppBaseline.Support
{
    internal class TraceProvider : ILoggerProvider
    {
        private TelemetryClient client;
        private IConfiguration config;
        private ILogger logger;

        public TraceProvider(IConfiguration config)
        {
            this.config = config;

            // Create a shared AppInsights client
            this.client = new TelemetryClient();
            this.logger = new Tracer(client);
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
        private readonly TelemetryClient _client;

        public Tracer(TelemetryClient client)
        {
            this._client = client;
        }
         
        public IDisposable BeginScope<TState>(TState state)
        {
           return null;
        }

        public bool IsEnabled(LogLevel logLevel)
        {
            return true;
        }

        // Now a synchronous, non-blocking implementation (fire and forget)
        public void Log<TState>(LogLevel logLevel, EventId eventId, 
            TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            // This is clearly not an optimal implementation. Should be using
            // Microsoft.Extensions.ILogger rather than a home rolled interface
            var msg = formatter(state, null);
            _client.TrackTrace(msg); 
        }
    }
}