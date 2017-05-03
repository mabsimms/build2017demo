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
            return ConnectionMultiplexer.Connect("contoso5.redis.cache.windows.net,abortConnect=false,ssl=true,password=...");
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
