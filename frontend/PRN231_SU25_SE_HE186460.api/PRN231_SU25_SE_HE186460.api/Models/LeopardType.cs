using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PRN231_SU25_SE_HE186460.api.Models
{
    [Table("LeopardType")]
    public class LeopardType
    {
        [Key, DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int LeopardTypeId { get; set; }

        [StringLength(250)]
        public string? LeopardTypeName { get; set; }

        [StringLength(250)]
        public string? Origin { get; set; }

        [StringLength(1000)]
        public string? Description { get; set; }

        public virtual ICollection<LeopardProfile> LeopardProfiles { get; set; } = new List<LeopardProfile>();
    }
}
