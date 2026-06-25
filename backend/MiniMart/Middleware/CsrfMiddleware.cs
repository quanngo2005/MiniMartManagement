using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using MiniMart.DTOs;

namespace MiniMart.Middleware
{
    public class CsrfMiddleware
    {
        public const string CookieName = "XSRF-TOKEN";
        public const string HeaderName = "X-XSRF-TOKEN";

        private static readonly HashSet<string> SafeMethods = new(StringComparer.OrdinalIgnoreCase)
        {
            HttpMethods.Get,
            HttpMethods.Head,
            HttpMethods.Options,
            HttpMethods.Trace
        };

        private readonly RequestDelegate _next;

        public CsrfMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            if (!SafeMethods.Contains(context.Request.Method))
            {
                var cookieToken = context.Request.Cookies[CookieName];
                var headerToken = context.Request.Headers[HeaderName].FirstOrDefault();

                if (string.IsNullOrWhiteSpace(cookieToken) ||
                    string.IsNullOrWhiteSpace(headerToken) ||
                    !CryptographicOperations.FixedTimeEquals(
                        Encoding.UTF8.GetBytes(cookieToken),
                        Encoding.UTF8.GetBytes(headerToken)))
                {
                    context.Response.StatusCode = StatusCodes.Status400BadRequest;
                    context.Response.ContentType = "application/json";
                    await context.Response.WriteAsync(JsonSerializer.Serialize(ApiResponse<object>.Fail("Invalid CSRF token.")));
                    return;
                }
            }

            await _next(context);
        }
    }
}
