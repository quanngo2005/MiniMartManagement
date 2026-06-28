namespace MiniMart.DTOs
{
    public class OpenShiftRequest
    {
        public int ShiftId { get; set; }
        public int CashierId { get; set; }
        public decimal StartCash { get; set; }
        public string? Note { get; set; }
    }

    public class CloseShiftRequest
    {
        public decimal EndCash { get; set; }
        public string? Note { get; set; }
    }
}
