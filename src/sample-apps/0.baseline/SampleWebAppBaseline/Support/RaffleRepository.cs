using Newtonsoft.Json;
using SampleWebApp.Baseline.Models;
using StackExchange.Redis;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace SampleWebApp.Baseline.Support
{
    public class RaffleRepository : IRaffleRepository
    {
        private readonly RaffleContext _context;

        public RaffleRepository(RaffleContext context)
        {
            _context = context;
        }

        private static readonly string KEY_REDIS_RAFFLE_LIST = "Meta_Raffles";

        // TODO - fill these in
        public async Task<IList<Raffle>> GetAllRaffles()
        {
            // Check redis for the raffle information
            var redisClient = RedisManager.Connection.GetDatabase();
            var redisStr = await redisClient.StringGetAsync(KEY_REDIS_RAFFLE_LIST);
            if (!String.IsNullOrEmpty(redisStr))
            {
                var redisRaffles = JsonConvert.DeserializeObject<Raffle[]>(redisStr);
                return redisRaffles;
            }

            // Get from the SQL database, and update redis (note; the same code that
            // updates the list of raffles will also update redis
            var raffles = await _context.Raffles.ToListAsync();
            await redisClient.StringSetAsync(KEY_REDIS_RAFFLE_LIST,
                JsonConvert.SerializeObject(raffles.ToArray())); 
              
            return raffles;
        }

        // TODO - fill these in
        public async Task<Raffle> GetRaffleById(long raffleId)
        {

            // Check redis for the raffle information
            var redisClient = RedisManager.Connection.GetDatabase();
            var redisKey = "Raffle_" + raffleId.ToString();
            var redisStr = await redisClient.StringGetAsync(redisKey);
            if (!String.IsNullOrEmpty(redisStr))
            {
                var redisRaffle = JsonConvert.DeserializeObject<Raffle>(redisStr);
                return redisRaffle;
            }

            // Get from the SQL database, and update redis (note; the same code that
            // updates the list of raffles will also update redis
            var raffle = await _context.Raffles
                .Where(e => e.Key == raffleId).FirstOrDefaultAsync();
            await redisClient.StringSetAsync(redisKey,
                JsonConvert.SerializeObject(raffle));

            return raffle;
        }
    }
}
