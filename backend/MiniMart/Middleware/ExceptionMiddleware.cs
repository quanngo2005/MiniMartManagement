using MiniMart.DTOs;
using MiniMart.Shared.Exceptions;
using System.Text.Json;

namespace MiniMart.Middleware
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;

        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        }

        private async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            var statusCode = exception is DomainException domainException
                ? domainException.StatusCode
                : StatusCodes.Status500InternalServerError;

            if (statusCode == StatusCodes.Status500InternalServerError)
            {
                _logger.LogError(exception, "Unhandled exception.");
            }

            context.Response.ContentType = "application/json";
            context.Response.StatusCode = statusCode;

            var response = new ApiResponse<object>
            {
                Success = false,
                Message = exception.Message,
                Data = exception switch
                {
                    StockCountLineConcurrencyException lineConflict => new { lineIds = lineConflict.LineIds },
                    StockCountStockDriftException stockDrift => new
                    {
                        lines = stockDrift.Lines.Select(line => new
                        {
                            lineId = line.StockCountLineId,
                            productId = line.ProductId,
                            snapshotQuantity = line.SnapshotQuantity,
                            currentQuantity = line.CurrentQuantity
                        })
                    },
                    _ => null
                }
            };
            await context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    }
}