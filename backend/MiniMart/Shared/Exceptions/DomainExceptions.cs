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
        public UnauthorizedDomainException(string message = "Không được phép truy cập")
            : base(message, StatusCodes.Status401Unauthorized)
        {
        }
    }

    public class ForbiddenDomainException : DomainException
    {
        public ForbiddenDomainException(string message = "Không có quyền truy cập")
            : base(message, StatusCodes.Status403Forbidden)
        {
        }
    }

    public class StockCountLineConcurrencyException : DomainException
    {
        public IReadOnlyList<int> LineIds { get; }

        public StockCountLineConcurrencyException(IReadOnlyList<int> lineIds)
            : base("Một hoặc nhiều dòng kiểm kê đã bị thay đổi bởi người dùng khác. Vui lòng tải lại và thử lại.", StatusCodes.Status409Conflict)
        {
            LineIds = lineIds;
        }
    }

    public class StockCountStockDriftException : DomainException
    {
        public IReadOnlyList<StockCountStockDriftDto> Lines { get; }

        public StockCountStockDriftException(IReadOnlyList<StockCountStockDriftDto> lines)
            : base("Tồn kho thực tế đã thay đổi từ khi tạo phiếu kiểm kê này. Vui lòng tải lại và kiểm đếm lại các dòng bị ảnh hưởng.", StatusCodes.Status409Conflict)
        {
            Lines = lines;
        }
    }
}