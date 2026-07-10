using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MiniMart.Models;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace MiniMart.ViewModels
{
    //Ke thua ObservableObject la dk bat buoc de UI tu dong cap nhat khi du lieu thay doi
    public partial class MainViewModel : ObservableObject
    {
        //Thuộc tính [ObservableProperty] tu dong sinh ra bien public 'title' co kha nang tbao cho giao dien
        [ObservableProperty]
        private ObservableCollection<CartItem> _cartItems;

        //Biến tiền
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
                if(value < 0) value = 0;

                if (value > 500) value = 500;

                if(SetProperty(ref _loyaltyPointsToUse, value))
                {
                    Discount = _loyaltyPointsToUse * 1000;
                }
            }
        }

        // --- THÔNG TIN KHÁCH HÀNG ---
        [ObservableProperty]
        private string _customerName = "Jane Doe";

        [ObservableProperty]
        private string _customerPhone = "0123 456 789";

        [ObservableProperty]
        private int _customerPoints = 1500;

        [ObservableProperty]
        private string _tempCustomerName;

        [ObservableProperty]
        private string _tempCustomerPhone;

        [ObservableProperty]
        private bool _isEditCustomerPopupOpen;

        [RelayCommand]
        private void OpenEditCustomer()
        {
            TempCustomerName = CustomerName;
            TempCustomerPhone = CustomerPhone;
            IsEditCustomerPopupOpen = true;
        }

        [RelayCommand]
        private void SaveEditCustomer()
        {
            CustomerName = TempCustomerName;
            CustomerPhone = TempCustomerPhone;
            IsEditCustomerPopupOpen = false;
        }

        [RelayCommand]
        private void CloseEditCustomer()
        {
            IsEditCustomerPopupOpen = false;
        }

        [ObservableProperty]
        private bool _isCheckoutPopupOpen;



        [RelayCommand]
        private void Checkout()
        {
            IsCheckoutPopupOpen = true;
        }

        [RelayCommand]
        private void ClosePopup()
        {
            IsCheckoutPopupOpen = false;
        }

        public decimal FinalAmount => SubTotal - Discount;
        public MainViewModel()
        {
            //
            CartItems = new ObservableCollection<CartItem>
            {
                new CartItem("Nước giải khát Coca Cola 330ml", 10000, 2),
                new CartItem("Mì tôm Hảo Hảo chua cay", 3500, 5),
                new CartItem("Bánh mì que Pate cay", 15000, 1),
                new CartItem("Sữa tươi Vinamilk có đường 180ml", 8000, 3)
            };

            foreach(var item in CartItems)
            {
                item.PropertyChanged += Item_PropertyChanged;
            }

            CalculateTotal();
        }

        //Ham tu dong chay moi khi 1 CartItem bi thay doi du lieu
        private void Item_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == nameof(CartItem.Total)) 
            {
                CalculateTotal();
            }
        }

        private void CalculateTotal()
        {
            SubTotal = CartItems.Sum(item => item.Total);
        }
    }
}
