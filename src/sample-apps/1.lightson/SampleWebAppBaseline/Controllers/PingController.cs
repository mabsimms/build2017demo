
using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace SampleWebAppBaseline.Controllers
{
    [Produces("application/json")]
    [Route("api/ping")]
    public class PingController : Controller
    {
            // GET: api/raffle
        [HttpGet]
        public async Task<string> Get()
        {
            await Task.Delay(0);
            _logger.LogInformation("Request for all ping information received");     
            return DateTime.UtcNow.ToString();
        }

    }
}