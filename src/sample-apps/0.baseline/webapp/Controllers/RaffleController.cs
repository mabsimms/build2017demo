using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SampleWebApp.Baseline.Models;

namespace SampleWebAppBaseline.Controllers
{
    [Produces("application/json")]
    [Route("api/raffle")]
    public class RaffleController : Controller
    {
        private readonly IRaffleRepository _raffleRepository;

        public RaffleController(IRaffleRepository raffleRepository)
        {
            _raffleRepository = raffleRepository;
        }

        // GET: api/raffle
        [HttpGet]
        public async Task<IEnumerable<Raffle>> Get()
        {
            return await _raffleRepository.GetAllRaffles(); 
        }

        // GET: api/Raffle/5
        [HttpGet("{id}", Name = "GetRaffle")]
        public async Task<Raffle> Get(int id)
        {
            return await _raffleRepository.GetRaffleById((long)id);
        }         
    }
}
