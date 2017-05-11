using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SampleWebApp.Baseline.Models;
using Microsoft.Extensions.Logging;

namespace SampleWebAppBaseline.Controllers
{
    [Produces("application/json")]
    [Route("api/raffle")]
    public class RaffleController : Controller
    {
        private readonly IRaffleRepository _raffleRepository;
        private readonly ILogger _logger;

        public RaffleController(IRaffleRepository raffleRepository, 
            ILoggerFactory loggerFactory)
        {
            _raffleRepository = raffleRepository;
            _logger = loggerFactory.CreateLogger("Audit");
        }

        // GET: api/raffle
        [HttpGet]
        public async Task<IEnumerable<Raffle>> Get()
        {
            var raffles = await _raffleRepository.GetAllRaffles();
            _logger.LogInformation("Request for all raffle information received");
            return raffles;
        }

        // GET: api/Raffle/5
        [HttpGet("{id}", Name = "GetRaffle")]
        public async Task<Raffle> Get(int id)
        {
            return await _raffleRepository.GetRaffleById((long)id);
        }         
    }
}
