namespace MiniMart.Models.Enums
{
    public enum ReturnClassify
    {
        ProductError = 1,      // Lỗi sản phẩm (Hủy trực tiếp, không hoàn kho)
        NoLongerNeeded = 2     // Không dùng nữa (Hoàn lại kho hàng)
    }
}