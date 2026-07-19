using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PRN231_SU25_SE_HE186460.api.Models
{
    [Table("LeopardAccount")]
    public class LeopardAccount
    {
        [Key, DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int AccountID { get; set; }

        [Required, StringLength(50)]
        public string UserName { get; set; }

        [StringLength(100)]
        public string Password { get; set; }

        [Required, StringLength(100)]
        public string FullName { get; set; }

        [Required, StringLength(150)]
        public string Email { get; set; }

        [Required, StringLength(50)]
        public string Phone { get; set; }

        [Required]
        public int RoleId { get; set; }
    }
}
