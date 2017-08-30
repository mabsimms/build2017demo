using StackExchange.Redis;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

namespace SampleWebApp.Baseline
{
    public class RedisManager
    {        
        private static Lazy<ConnectionMultiplexer> lazyConnection = 
            new Lazy<ConnectionMultiplexer>(() =>
        {
            var server = Environment.GetEnvironmentVariable("REDIS_SERVER");
            if (string.IsNullOrEmpty(server))
                server = "localhost";
            //var password = Environment.GetEnvironmentVariable("REDIS_PASSWORD");
            //if (string.IsNullOrEmpty(password))
            //    password = "12345";

            // .NET Core on Linux issue workaround - manually resolve the IP address
            // see https://github.com/dotnet/corefx/issues/8768 
            Console.WriteLine("Looking up IP address(es) for redis server {0}", server);
            var ipAddresses = Dns.GetHostAddressesAsync(server).GetAwaiter().GetResult();

            // Note - this avoids pulling in ::1 on Windows systems when calling loopback in test
            // scenarios
            var addr = ipAddresses.FirstOrDefault(e => 
                e.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork);

            if (addr == null)
                throw new ArgumentOutOfRangeException("REDIS_SERVER", "Could not look up dns information for redis server " + server);
            
            var connectionString = $"{addr},abortConnect=false,ssl=false";
            Console.WriteLine("Using redis connection string {0}", connectionString);
            return ConnectionMultiplexer.Connect(connectionString);
        });

        public static ConnectionMultiplexer Connection
        {
            get
            {
                return lazyConnection.Value;
            }
        }
    }
}
