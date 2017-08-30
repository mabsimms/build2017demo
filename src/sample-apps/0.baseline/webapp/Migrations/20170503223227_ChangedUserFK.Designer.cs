using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using SampleWebApp.Baseline.Support;

namespace SampleWebAppBaseline.Migrations
{
    [DbContext(typeof(RaffleContext))]
    [Migration("20170503223227_ChangedUserFK")]
    partial class ChangedUserFK
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
            modelBuilder
                .HasAnnotation("ProductVersion", "1.1.1")
                .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

            modelBuilder.Entity("SampleWebApp.Baseline.Models.Raffle", b =>
                {
                    b.Property<long>("Key")
                        .ValueGeneratedOnAdd();

                    b.Property<DateTime>("Date");

                    b.Property<string>("Name");

                    b.HasKey("Key");

                    b.ToTable("Raffles");
                });

            modelBuilder.Entity("SampleWebApp.Baseline.Models.Ticket", b =>
                {
                    b.Property<long>("Key")
                        .ValueGeneratedOnAdd();

                    b.Property<long?>("AssignedToId");

                    b.Property<long>("RaffleId");

                    b.HasKey("Key");

                    b.HasIndex("AssignedToId");

                    b.HasIndex("RaffleId");

                    b.ToTable("Tickets");
                });

            modelBuilder.Entity("SampleWebApp.Baseline.Models.User", b =>
                {
                    b.Property<long>("Key")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("Name");

                    b.HasKey("Key");

                    b.ToTable("User");
                });

            modelBuilder.Entity("SampleWebApp.Baseline.Models.Ticket", b =>
                {
                    b.HasOne("SampleWebApp.Baseline.Models.User", "AssignedTo")
                        .WithMany()
                        .HasForeignKey("AssignedToId");

                    b.HasOne("SampleWebApp.Baseline.Models.Raffle", "Raffle")
                        .WithMany()
                        .HasForeignKey("RaffleId")
                        .OnDelete(DeleteBehavior.Cascade);
                });
        }
    }
}
