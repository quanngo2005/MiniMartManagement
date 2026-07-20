using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PRN231_SU25_SE_HE186460.api.Models
{
    [Table("LeopardProfile")]
    public class LeopardProfile
    {
        [Key, DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int LeopardProfileId { get; set; }

        [Required]
        public int LeopardTypeId { get; set; }

        [Required, StringLength(150)]
        public string LeopardName { get; set; }

        [Required]
        public double Weight { get; set; }

        [Required, StringLength(2000)]
        public string Characteristics { get; set; }

        [Required, StringLength(1500)]
        public string CareNeeds { get; set; }

        [Required]
        public DateTime ModifiedDate { get; set; }

        [ForeignKey("LeopardTypeId")]
        public virtual LeopardType? LeopardType { get; set; }
    }
}
