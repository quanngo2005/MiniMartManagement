namespace MiniMart.Shared.Authorization
{
    public static class AppPermissions
    {
        public const string StaffView   = "staffs.view";
        public const string StaffCreate = "staffs.create";
        public const string StaffEdit   = "staffs.edit";
        public const string StaffDelete = "staffs.delete";

        public const string ShiftView   = "shifts.view";
        public const string ShiftCreate = "shifts.create";
        public const string ShiftEdit   = "shifts.edit";
        public const string ShiftDelete = "shifts.delete";
        public const string ShiftOpen   = "shifts.open";
        public const string ShiftClose  = "shifts.close";

        public const string ProductView   = "products.view";
        public const string ProductCreate = "products.create";
        public const string ProductEdit   = "products.edit";
        public const string ProductDelete = "products.delete";

        public const string CategoryView   = "categories.view";
        public const string CategoryCreate = "categories.create";
        public const string CategoryEdit   = "categories.edit";
        public const string CategoryDelete = "categories.delete";

        public const string SupplierView   = "suppliers.view";
        public const string SupplierCreate = "suppliers.create";
        public const string SupplierEdit   = "suppliers.edit";

        public const string OrderView   = "orders.view";
        public const string OrderCreate = "orders.create";
        public const string OrderEdit   = "orders.edit";
        public const string OrderDelete = "orders.delete";

        public const string ReceiptView   = "receipts.view";
        public const string ReceiptCreate = "receipts.create";
        public const string ReceiptEdit   = "receipts.edit";

        public const string InventoryView   = "inventory.view";
        public const string InventoryCreate = "inventory.create";
        public const string InventoryEdit   = "inventory.edit";

        public const string CustomerView   = "customers.view";
        public const string CustomerCreate = "customers.create";
        public const string CustomerEdit   = "customers.edit";

        public const string RoleView   = "roles.view";
        public const string RoleCreate = "roles.create";
        public const string RoleEdit   = "roles.edit";
        public const string RoleDelete = "roles.delete";

        public const string DashboardView = "dashboard.view";
        public const string ReportsView   = "reports.view";

        public static readonly IReadOnlyDictionary<int, string[]> ByRole = new Dictionary<int, string[]>
        {
            [1] = new[] { StaffView, StaffCreate, StaffEdit, StaffDelete,
                           ShiftView, ShiftCreate, ShiftEdit, ShiftDelete, ShiftOpen, ShiftClose,
                           ProductView, ProductCreate, ProductEdit, ProductDelete,
                           CategoryView, CategoryCreate, CategoryEdit, CategoryDelete,
                           SupplierView, SupplierCreate, SupplierEdit,
                           OrderView, OrderCreate, OrderEdit, OrderDelete,
                           ReceiptView, ReceiptCreate, ReceiptEdit,
                           InventoryView, InventoryCreate, InventoryEdit,
                           CustomerView, CustomerCreate, CustomerEdit,
                           RoleView, RoleCreate, RoleEdit, RoleDelete,
                           DashboardView, ReportsView },

            [2] = new[] { ShiftView, ShiftOpen, ShiftClose,
                           OrderView, OrderCreate,
                           CustomerView, CustomerCreate,
                           ProductView,
                           DashboardView },

            [3] = new[] { ProductView, ProductCreate, ProductEdit,
                           CategoryView,
                           SupplierView,
                           ReceiptView, ReceiptCreate, ReceiptEdit,
                           InventoryView, InventoryCreate, InventoryEdit,
                           DashboardView },

            [4] = new[] { StaffView, StaffCreate, StaffEdit, StaffDelete,
                           ShiftView, ShiftCreate, ShiftEdit, ShiftDelete, ShiftOpen, ShiftClose,
                           ProductView, ProductCreate, ProductEdit, ProductDelete,
                           CategoryView, CategoryCreate, CategoryEdit, CategoryDelete,
                           SupplierView, SupplierCreate, SupplierEdit,
                           OrderView, OrderCreate, OrderEdit, OrderDelete,
                           ReceiptView, ReceiptCreate, ReceiptEdit,
                           InventoryView, InventoryCreate, InventoryEdit,
                           CustomerView, CustomerCreate, CustomerEdit,
                           RoleView, RoleCreate, RoleEdit, RoleDelete,
                           DashboardView, ReportsView },
        };
    }
}
