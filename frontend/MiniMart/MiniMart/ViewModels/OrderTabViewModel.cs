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
                    CalculateTotal();
                }
            }
        }

        [ObservableProperty]
        private decimal _finalAmount;

        [ObservableProperty]
        private string _customerName = string.Empty;

        [ObservableProperty]
        private string _customerPhone = "";

        [ObservableProperty]
        private int _customerPoints = 0;

        [ObservableProperty]
        private int? _customerId;

        [ObservableProperty]
        private decimal _amountGiven;

        [ObservableProperty]
        private decimal _changeAmount;

        partial void OnAmountGivenChanged(decimal value)
        {
            CalculateTotal();
        }

        public void CalculateTotal()
        {
            SubTotal = CartItems.Sum(item => item.Total);
            FinalAmount = Math.Max(0, SubTotal - Discount);
            
            if (AmountGiven > 0)
            {
                ChangeAmount = AmountGiven - FinalAmount;
            }
            else
            {
                ChangeAmount = 0;
            }
        }

        public void AddItem(CartItem item)
        {
            item.PropertyChanged += Item_PropertyChanged;
            CartItems.Add(item);
            CalculateTotal();
        }

        public void RemoveItem(CartItem item)
        {
            item.PropertyChanged -= Item_PropertyChanged;
            CartItems.Remove(item);
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
