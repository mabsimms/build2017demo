using SampleWebApp.Baseline.Models;
using SampleWebApp.Baseline.Support;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SampleWebAppBaseline.DAta
{
    public static class DatabaseInitializer
    {
        public static void Initialize(RaffleContext context)
        {
            Console.WriteLine("Ensuring databases are created..");
            context.Database.EnsureDeleted();
            context.Database.EnsureCreated();
            if (!context.Raffles.Any())
            {
                var raffle = new Raffle[]
                {
                    new Raffle() { Name = "Test Raffle", Date = DateTime.UtcNow.AddDays(5) }
                };
                context.Raffles.AddRange(raffle);
                context.SaveChanges();
            }
        }
    }
}
