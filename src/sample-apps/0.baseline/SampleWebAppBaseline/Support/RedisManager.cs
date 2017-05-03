using StackExchange.Redis;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SampleWebApp.Baseline
{
    public class RedisManager
    {
        // TODO - update this with a real value and pull direct from
        // environment
        private static Lazy<ConnectionMultiplexer> lazyConnection = 
            new Lazy<ConnectionMultiplexer>(() =>
        {
            var server = Environment.GetEnvironmentVariable("REDIS_SERVER");
            if (string.IsNullOrEmpty(server))
                server = "localhost";
            var password = Environment.GetEnvironmentVariable("REDIS_PASSWORD");
            if (string.IsNullOrEmpty(password))
                password = "12345";

            var connectionString = $"{server},abortConnect=false,ssl=true,password={password}";
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
