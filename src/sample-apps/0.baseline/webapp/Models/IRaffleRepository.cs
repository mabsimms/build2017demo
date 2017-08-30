using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SampleWebApp.Baseline.Models
{
    public interface IRaffleRepository
    {
        Task<IList<Raffle>> GetAllRaffles();
        Task<Raffle> GetRaffleById(long raffleId);
    }
}
