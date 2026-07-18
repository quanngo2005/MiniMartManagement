using System.Collections.Generic;
using System.Threading.Tasks;

namespace MiniMart.Services.Interfaces
{
    public interface INotificationService
    {
        Task SendToUserAsync(int employeeId, string title, string body, Dictionary<string, string>? data = null);
        Task SendToRoleAsync(string roleName, string title, string body, Dictionary<string, string>? data = null);
    }
}
