using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SampleWebApp.Baseline.Models
{
    public interface IUserRepository
    {
        Task<User> GetUserById(long id);
    }
}
