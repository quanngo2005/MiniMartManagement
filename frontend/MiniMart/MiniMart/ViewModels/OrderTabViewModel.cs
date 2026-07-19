using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MiniMart.Models;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;

namespace MiniMart.ViewModels
{
    public partial class OrderTabViewModel : ObservableObject
    {
        public int Id { get; set; }

        [ObservableProperty]
        private string _tabName = string.Empty;

        [ObservableProperty]
        private bool _isActive;

        [ObservableProperty]
        private ObservableCollection<CartItem> _cartItems = new();

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(FinalAmount))]
        private decimal _subTotal;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(FinalAmount))]
        private decimal _discount;

        private int _loyaltyPointsToUse;
        public int LoyaltyPointsToUse
        {
            get => _loyaltyPointsToUse;
            set
            {
                if (value < 0) value = 0;
                if (value > 500) value = 500;
                if (SetProperty(ref _loyaltyPointsToUse, value))
                {
                    Discount = _loyaltyPointsToUse * 1000;
                }
            }
        }

        public decimal FinalAmount => SubTotal - Discount;

        [ObservableProperty]
        private string _customerName = "Khách vãng lai";

        [ObservableProperty]
        private string _customerPhone = "";

        [ObservableProperty]
        private int _customerPoints = 0;

        [ObservableProperty]
        private int? _customerId;

        public void CalculateTotal()
        {
            SubTotal = CartItems.Sum(item => item.Total);
        }

        public void AddItem(CartItem item)
        {
            item.PropertyChanged += Item_PropertyChanged;
            CartItems.Add(item);
            CalculateTotal();
        }

        private void Item_PropertyChanged(object? sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == nameof(CartItem.Total))
            {
                CalculateTotal();
            }
        }
    }
}
