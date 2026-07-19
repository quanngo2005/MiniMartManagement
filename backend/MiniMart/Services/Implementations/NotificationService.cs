using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using MiniMart.Hubs;
using MiniMart.Services.Interfaces;

namespace MiniMart.Services.Implementations
{
    public class NotificationService : INotificationService
    {
        private readonly IHubContext<NotificationHub> _hubContext;

        public NotificationService(IHubContext<NotificationHub> hubContext)
        {
            _hubContext = hubContext;
        }

        public async Task SendToUserAsync(int employeeId, string title, string body, Dictionary<string, string>? data = null)
        {
            await _hubContext.Clients.Group($"Employee_{employeeId}").SendAsync("ReceiveNotification", new
            {
                title,
                body,
                data
            });
        }

        public async Task SendToRoleAsync(string roleName, string title, string body, Dictionary<string, string>? data = null)
        {
            if (roleName == "Manager" || roleName == "Admin")
            {
                await _hubContext.Clients.Group("Managers").SendAsync("ReceiveNotification", new
                {
                    title,
                    body,
                    data
                });
            }
        }
    }
}
