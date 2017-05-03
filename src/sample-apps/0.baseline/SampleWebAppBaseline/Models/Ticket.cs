using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SampleWebApp.Baseline.Models
{
    public class Ticket
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Key { get; set; }
        
        public long RaffleId { get; set; }

        [ForeignKey("RaffleId")]
        public Raffle Raffle { get; set; }

        public long AssignedToId { get; set; }

        [ForeignKey("AssignedToId")]
        public User AssignedTo { get; set; }
    }
}
