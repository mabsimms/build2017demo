using Microsoft.EntityFrameworkCore;
using SampleWebApp.Baseline.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SampleWebApp.Baseline.Support
{
    public class RaffleContext : DbContext
    {
        public RaffleContext() 
        {

        }

        public RaffleContext(DbContextOptions<RaffleContext> options)
            : base(options)
        {
                            
        }
        
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            var connString = "Server=tcp:mastest1.database.windows.net,1433;Initial Catalog=mastest1;Persist Security Info=False;User ID=masimms;Password={password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
            optionsBuilder.UseSqlServer(connString);
        }

        public DbSet<Raffle> Raffles { get; set; }
        
        public DbSet<Ticket> Tickets { get; set; }

        public DbSet<User> User { get; set; }
    }
}
