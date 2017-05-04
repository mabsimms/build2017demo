using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using SampleWebApp.Baseline.Support;
using Microsoft.EntityFrameworkCore;
using Swashbuckle.AspNetCore.Swagger;
using SampleWebApp.Baseline.Models;
using System.Data.SqlClient;
using SampleWebAppBaseline.DAta;

namespace SampleWebAppBaseline
{
    public class Startup
    {
        public Startup(IHostingEnvironment env)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();
            Configuration = builder.Build();
        }

        public IConfigurationRoot Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // Add framework services.
            services.AddMvc();

            // Add data store          
            var connBuilder = new SqlConnectionStringBuilder();
            connBuilder.DataSource = Environment.GetEnvironmentVariable("SQL_DATASOURCE");
            connBuilder.PersistSecurityInfo = false;
            connBuilder.UserID = Environment.GetEnvironmentVariable("SQL_USER");
            connBuilder.Password = Environment.GetEnvironmentVariable("SQL_PASSWORD");
            connBuilder.MultipleActiveResultSets = false;
            connBuilder.Encrypt = true;
            connBuilder.TrustServerCertificate = false;
            connBuilder.ConnectTimeout = 30;
           
            services.AddEntityFrameworkSqlServer()
                .AddDbContext<RaffleContext>(options => 
                    options.UseSqlServer(connBuilder.ToString()));
            
            // Add repositories
            services.AddScoped<IRaffleRepository, RaffleRepository>();
            services.AddScoped<IUserRepository, UserRepository>();

            // Register the Swagger generator, defining one or more Swagger documents
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new Info { Title = "My API", Version = "v1" });
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, 
            ILoggerFactory loggerFactory, RaffleContext raffleContext)
        {
            loggerFactory.AddConsole(Configuration.GetSection("Logging"));
            loggerFactory.AddDebug();

            app.UseMvc();

            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger();

            // Enable middleware to serve swagger-ui (HTML, JS, CSS etc.), specifying the Swagger JSON endpoint.
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
            });
        }
    }
}
