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
    [Route("api/user")]
    public class UserController : Controller
    {
        private readonly IUserRepository _userRepository;

        public UserController(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }        

        // GET: api/User/5
        [HttpGet("{id}", Name = "GetUser")]
        public async Task<User> Get(int id)
        {
            return await _userRepository.GetUserById(id);
        }         
    }
}
