using CommunityToolkit.Mvvm.ComponentModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CommunityToolkit.Mvvm.Input;

namespace MiniMart.Models
{
    //Ke thua ObservableObject de khi So luong tdoi, tong tien tu cap nhat
    public partial class CartItem : ObservableObject
    {
        [ObservableProperty]
        private string _name;
        [ObservableProperty]
        private decimal _price;
        //Khi quantity doi, tu dong bao XAML cap nhat lai Total
        private int _quantity;

        public int Quantity
        {
            get => _quantity;
            set
            {
                if (value <= 0)
                {
                    value = 1;
                }
                if (SetProperty(ref _quantity, value)) 
                {
                    OnPropertyChanged(nameof(Total));
                }
            }
        }

        [ObservableProperty]
        private int _productId;

        public decimal Total => Price * Quantity;
        public CartItem(int productId, string name, decimal price, int quantity)
        {
            ProductId = productId;
            Name = name;
            Price = price;
            Quantity = quantity;
        }

        //==Nut Tang Giam==
        [RelayCommand]
        private void Increase()
        {
            Quantity++; 
        }
        // 
        [RelayCommand]
        private void Decrease()
        {
                Quantity--; 
        }
    }
}
