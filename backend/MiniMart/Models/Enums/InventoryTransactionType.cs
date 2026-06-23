namespace MiniMart.Models.Enums
{
    public enum InventoryTransactionType
    {
        Import = 1, // nhập hàng
        Sale = 2, // bán hàng
        ReturnToSupplier = 3, //trả lại nhà cung cấp
        Damage = 4, // hư hỏng
        Adjustment = 5 // chỉnh sửa tồn kho (có thể là tăng hoặc giảm)
    }
}