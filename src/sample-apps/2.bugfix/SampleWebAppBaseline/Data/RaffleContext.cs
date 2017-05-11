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
        public RaffleContext(DbContextOptions<RaffleContext> options)
            : base(options)
        {
                            
        }

        public DbSet<Raffle> Raffles { get; set; }
        
        public DbSet<Ticket> Tickets { get; set; }

        public DbSet<User> User { get; set; }
    }
}
