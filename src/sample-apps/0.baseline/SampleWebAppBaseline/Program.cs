using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;

namespace SampleWebAppBaseline
{
    public class Program
    {
        public static void Main(string[] args)
        {
            // TEMP - don't check this stuff in
            Environment.SetEnvironmentVariable("REDIS_SERVER", "mastest1.redis.cache.windows.net:6380");
            Environment.SetEnvironmentVariable("REDIS_PASSWORD", "0FFTAgaeelDOb9UTLDoQXjdM+0pRzm7qUaC0imxcQjc=");
            Environment.SetEnvironmentVariable("SQL_USER", "masimms");
            Environment.SetEnvironmentVariable("SQL_PASS", "{password}");

            var host = new WebHostBuilder()
                .UseKestrel()
                .UseContentRoot(Directory.GetCurrentDirectory())
                .UseStartup<Startup>()
                .UseApplicationInsights()
                .Build();

            host.Run();
        }
    }
}
