using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace MiniMart.Hubs
{
    [Authorize]
    public class NotificationHub : Hub
    {
        public override async Task OnConnectedAsync()
        {
            var employeeId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(employeeId))
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, $"Employee_{employeeId}");
            }

            var role = Context.User?.FindFirst(ClaimTypes.Role)?.Value;
            if (role == "Manager" || role == "Admin")
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, "Managers");
            }

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var employeeId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(employeeId))
            {
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"Employee_{employeeId}");
            }

            var role = Context.User?.FindFirst(ClaimTypes.Role)?.Value;
            if (role == "Manager" || role == "Admin")
            {
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, "Managers");
            }

            await base.OnDisconnectedAsync(exception);
        }
    }
}