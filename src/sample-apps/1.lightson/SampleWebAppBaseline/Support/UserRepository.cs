using Newtonsoft.Json;
using SampleWebApp.Baseline.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace SampleWebApp.Baseline.Support
{
    public class UserRepository : IUserRepository
    {
        private readonly RaffleContext _context;

        public UserRepository(RaffleContext context)
        {
            _context = context;
        }

        public async Task<User> GetUserById(long userId)
        {
            // Check redis for the raffle information
            var redisClient = RedisManager.Connection.GetDatabase();
            var redisKey = "User_" + userId.ToString();
            var redisStr = await redisClient.StringGetAsync(redisKey);
            if (!String.IsNullOrEmpty(redisStr))
            {
                var redisUser = JsonConvert.DeserializeObject<User>(redisStr);
                return redisUser;
            }

            // Get from the SQL database, and update redis (note; the same code that
            // updates the list of raffles will also update redis
            var user = await _context.User
                .Where(e => e.Key == userId).FirstOrDefaultAsync();
            await redisClient.StringSetAsync(redisKey,
                JsonConvert.SerializeObject(user));

            return user;
        }
    }
}
