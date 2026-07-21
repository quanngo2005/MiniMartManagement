using MiniMart.DTOs;

namespace MiniMart.Shared.Exceptions
{
    public class DomainException : Exception
    {
        public int StatusCode { get; }

        public DomainException(string message, int statusCode = StatusCodes.Status400BadRequest)
            : base(message)
        {
            StatusCode = statusCode;
        }
    }

    public class UnauthorizedDomainException : DomainException
    {
        public UnauthorizedDomainException(string message = "Unauthorized")
            : base(message, StatusCodes.Status401Unauthorized)
        {
        }
    }

    public class ForbiddenDomainException : DomainException
    {
        public ForbiddenDomainException(string message = "Forbidden")
            : base(message, StatusCodes.Status403Forbidden)
        {
        }
    }

    public class StockCountLineConcurrencyException : DomainException
    {
        public IReadOnlyList<int> LineIds { get; }

        public StockCountLineConcurrencyException(IReadOnlyList<int> lineIds)
            : base("One or more stock-count lines were changed by another user. Reload and retry.", StatusCodes.Status409Conflict)
        {
            LineIds = lineIds;
        }
    }

    public class StockCountStockDriftException : DomainException
    {
        public IReadOnlyList<StockCountStockDriftDto> Lines { get; }

        public StockCountStockDriftException(IReadOnlyList<StockCountStockDriftDto> lines)
            : base("Live stock has changed since this count was created. Reload and recount the affected lines.", StatusCodes.Status409Conflict)
        {
            Lines = lines;
        }
    }
}