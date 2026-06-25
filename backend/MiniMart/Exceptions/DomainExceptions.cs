namespace MiniMart.Exceptions
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
}
