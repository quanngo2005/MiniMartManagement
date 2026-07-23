using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MiniMart.Models;
using MiniMart.Models.DTOs;
using MiniMart.Services;
using QRCoder;
using System.IO;
using System.Windows.Media.Imaging;
using System.Threading;
using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;

namespace MiniMart.ViewModels
{
    public partial class MainViewModel : ObservableObject
    {
        [ObservableProperty]
        private ObservableCollection<OrderTabViewModel> _orderTabs = new();

        private OrderTabViewModel? _activeTab;
        public OrderTabViewModel? ActiveTab
        {
            get => _activeTab;
            set
            {
                if (SetProperty(ref _activeTab, value))
                {
                    foreach (var tab in OrderTabs)
                    {
                        tab.IsActive = (tab == value);
                    }
                }
            }
        }

        private int _nextTabId = 1;

        [ObservableProperty]
        private bool _isShiftTabActive = false;

        [ObservableProperty]
        [NotifyPropertyChangedFor(nameof(CurrentCash))]
        private ShiftDto? _currentShift;

        [ObservableProperty]
        private int _totalOrders = 0;

        public decimal CurrentCash => (CurrentShift?.StartCash ?? 0) + (CurrentShift?.Revenue ?? 0);

        [ObservableProperty]
        private bool _isCheckoutPopupOpen;

        [ObservableProperty]
        private bool _isVietQRPopupOpen;

        [ObservableProperty]
        private BitmapImage? _vietQRCodeImage;

        [ObservableProperty]
        private int _selectedPaymentMethod = 0;

        private long _currentPayosOrderCode = 0;
        private int _currentOrderId = 0;

        [ObservableProperty]
        private bool _isEditCustomerPopupOpen;

        [ObservableProperty]
        private string _tempCustomerName = string.Empty;

        [ObservableProperty]
        private string _tempCustomerPhone = string.Empty;

        [ObservableProperty]
        private string _customerSearchQuery = string.Empty;

        [ObservableProperty]
        private ObservableCollection<CustomerDto> _customerSearchResults = new();

        partial void OnCustomerSearchQueryChanged(string value)
        {
            if (string.IsNullOrWhiteSpace(value) || value.Length != 10) 
            {
                CustomerSearchResults.Clear();
                return;
            }
            _ = SearchCustomerAsync(value);
        }

        [RelayCommand]
        private void ClearCustomer()
        {
            if (ActiveTab != null)
            {
                ActiveTab.CustomerName = string.Empty;
                ActiveTab.CustomerPhone = string.Empty;
                ActiveTab.CustomerPoints = 0;
                ActiveTab.CustomerId = null;
                ActiveTab.LoyaltyPointsToUse = 0;
            }
            CustomerSearchQuery = "";
        }

        [ObservableProperty]
        private string _shiftStartCashStr = string.Empty;

        [ObservableProperty]
        private string _searchQuery = string.Empty;

        [ObservableProperty]
        private ObservableCollection<ProductDto> _searchResults = new();

        // For tracking the delay in debounce
        private string _lastSearchQuery = string.Empty;

        public MainViewModel()
        {
            AddNewTab();
        }

        [RelayCommand]
        private void AddNewTab()
        {
            var tab = new OrderTabViewModel
            {
                Id = _nextTabId,
                TabName = $"Order {_nextTabId}"
            };
            OrderTabs.Add(tab);
            ActiveTab = tab;
            IsShiftTabActive = false;
            _nextTabId++;
        }

        [RelayCommand]
        private void CloseTab(OrderTabViewModel tab)
        {
            if (tab != null && OrderTabs.Contains(tab))
            {
                OrderTabs.Remove(tab);
                if (OrderTabs.Count == 0)
                {
                    _nextTabId = 1;
                    AddNewTab();
                }
                else
                {
                    ActiveTab = OrderTabs.Last();
                }
            }
        }

        [RelayCommand]
        private void ShowShiftTab()
        {
            IsShiftTabActive = true;
            ActiveTab = null;
        }

        [RelayCommand]
        private void ShowOrderTab(OrderTabViewModel tab)
        {
            IsShiftTabActive = false;
            ActiveTab = tab;
        }

        [RelayCommand]
        private void RemoveItem(CartItem? item)
        {
            if (item != null && ActiveTab != null)
            {
                ActiveTab.RemoveItem(item);
            }
        }

        [RelayCommand]
        private void OpenEditCustomer()
        {
            if (ActiveTab != null)
            {
                TempCustomerName = ActiveTab.CustomerName;
                TempCustomerPhone = ActiveTab.CustomerPhone;
                IsEditCustomerPopupOpen = true;
            }
        }

        [RelayCommand]
        private async Task SaveEditCustomer()
        {
            if (ActiveTab != null && ActiveTab.CustomerId.HasValue)
            {
                var customer = await ApiService.Instance.GetCustomerByPhoneAsync(ActiveTab.CustomerPhone);
                if (customer != null)
                {
                    customer.FullName = TempCustomerName;
                    customer.PhoneNumber = TempCustomerPhone;
                    
                    var success = await ApiService.Instance.UpdateCustomerAsync(customer.CustomerId, customer);
                    if (success)
                    {
                        ActiveTab.CustomerName = TempCustomerName;
                        ActiveTab.CustomerPhone = TempCustomerPhone;
                        System.Windows.MessageBox.Show("Cập nhật thông tin khách hàng thành công!", "Thành công", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
                    }
                    else
                    {
                        System.Windows.MessageBox.Show("Cập nhật thông tin khách hàng thất bại!", "Lỗi", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                        return;
                    }
                }
            }
            IsEditCustomerPopupOpen = false;
        }

        [RelayCommand]
        private void CloseEditCustomer()
        {
            IsEditCustomerPopupOpen = false;
        }

        private async Task SearchCustomerAsync(string phone)
        {
            var customer = await ApiService.Instance.GetCustomerByPhoneAsync(phone);
            CustomerSearchResults.Clear();
            if (customer != null)
            {
                CustomerSearchResults.Add(customer);
            }
        }

        [RelayCommand]
        private void SelectCustomer(CustomerDto customer)
        {
            if (customer != null && ActiveTab != null)
            {
                ActiveTab.CustomerName = customer.FullName;
                ActiveTab.CustomerPoints = customer.Point;
                ActiveTab.CustomerId = customer.CustomerId;
                ActiveTab.CustomerPhone = customer.PhoneNumber;
                
                CustomerSearchResults.Clear();
                CustomerSearchQuery = string.Empty;
            }
        }

        async partial void OnSearchQueryChanged(string value)
        {
            _lastSearchQuery = value;
            await Task.Delay(300); // debounce 300ms
            if (_lastSearchQuery != value) return; // Only execute if it's the latest

            if (string.IsNullOrWhiteSpace(value))
            {
                Application.Current.Dispatcher.Invoke(() =>
                {
                    SearchResults.Clear();
                });
                return;
            }
            
            var results = await ApiService.Instance.SearchProductsAsync(value);
            Application.Current.Dispatcher.Invoke(() =>
            {
                SearchResults.Clear();
                foreach (var item in results)
                {
                    SearchResults.Add(item);
                }
            });
        }

        [RelayCommand]
        private void AddProductToCart(ProductDto product)
        {
            if (ActiveTab == null) return;

            var existingItem = ActiveTab.CartItems.FirstOrDefault(x => x.ProductId == product.ProductId);
            if (existingItem != null)
            {
                existingItem.Quantity++;
            }
            else
            {
                ActiveTab.AddItem(new CartItem(product.ProductId, product.ProductName, product.SellingPrice, 1));
            }
            SearchQuery = string.Empty;
        }

        [RelayCommand]
        private async Task UnifiedCheckout()
        {
            if (SelectedPaymentMethod == 0) // Cash
            {
                await CheckoutCash();
            }
            else // VietQR
            {
                await CheckoutVietQR();
            }
        }

        private async Task CheckoutCash()
        {
            if (ActiveTab == null || ActiveTab.CartItems.Count == 0) return;

            if (CurrentShift == null)
            {
                CurrentShift = await ApiService.Instance.GetCurrentShiftAsync();
                if (CurrentShift == null)
                {
                    System.Windows.MessageBox.Show("Vui lòng mở ca làm việc trước khi thanh toán (Chưa có ca làm việc nào đang mở)!", "Lỗi", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                    return;
                }
            }

            var request = new CheckoutRequestDto
            {
                EmployeeId = ApiService.Instance.CurrentUser?.EmployeeId ?? 1,
                ShiftId = CurrentShift.ShiftId,
                CustomerId = ActiveTab.CustomerId,
                LoyaltyPointsToUse = ActiveTab.LoyaltyPointsToUse,
                PaymentMethod = 1, // 1 for Cash
                PaidAmount = ActiveTab.AmountGiven,
                Note = "Thanh toán POS"
            };

            foreach (var item in ActiveTab.CartItems)
            {
                request.Items.Add(new CheckoutItemDto
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity
                });
            }

            var result = await ApiService.Instance.CheckoutCashAsync(request);
            if (result.Success)
            {
                ActiveTab.CartItems.Clear();
                ActiveTab.AmountGiven = 0m;
                ClearCustomer();
                System.Windows.MessageBox.Show("Thanh toán hóa đơn thành công!", "Thành công", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
            }
            else
            {
                System.Windows.MessageBox.Show($"Thanh toán thất bại: {result.ErrorMessage}", "Lỗi", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
            }
        }

        [RelayCommand]
        private async Task CheckoutVietQR()
        {
            if (ActiveTab == null || ActiveTab.CartItems.Count == 0) return;

            if (CurrentShift == null)
            {
                CurrentShift = await ApiService.Instance.GetCurrentShiftAsync();
                if (CurrentShift == null)
                {
                    System.Windows.MessageBox.Show("Vui lòng mở ca làm việc trước khi thanh toán (Chưa có ca làm việc nào đang mở)!", "Lỗi", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                    return;
                }
            }

            var request = new CheckoutRequestDto
            {
                EmployeeId = ApiService.Instance.CurrentUser?.EmployeeId ?? 1,
                ShiftId = CurrentShift.ShiftId,
                CustomerId = ActiveTab.CustomerId,
                LoyaltyPointsToUse = ActiveTab.LoyaltyPointsToUse,
                PaymentMethod = 7, // 7 for VietQR (PayOS)
                PaidAmount = ActiveTab.AmountGiven,
                Note = "Thanh toán VietQR"
            };

            foreach (var item in ActiveTab.CartItems)
            {
                request.Items.Add(new CheckoutItemDto
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity
                });
            }

            var result = await ApiService.Instance.CheckoutCashAsync(request);
            if (result.Success && result.Data != null)
            {
                if (!string.IsNullOrEmpty(result.Data.QrCode))
                {
                    var parts = result.Data.QrCode.Split('_', 2);
                    if (parts.Length == 2)
                    {
                        _currentPayosOrderCode = long.Parse(parts[0]);
                        VietQRCodeImage = GenerateQrCodeBitmap(parts[1]);
                    }
                    else
                    {
                        // Fallback (shouldn't happen with updated backend)
                        VietQRCodeImage = GenerateQrCodeBitmap(result.Data.QrCode);
                    }
                    
                    _currentOrderId = result.Data.OrderId;
                    IsVietQRPopupOpen = true;

                    _pollingCts = new CancellationTokenSource();
                    _ = PollPayOSStatus(result.Data.OrderId, _pollingCts.Token);
                }
                else
                {
                    System.Windows.MessageBox.Show("Không lấy được mã QR từ máy chủ.", "Lỗi", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
                }
            }
            else
            {
                System.Windows.MessageBox.Show($"Tạo mã thanh toán thất bại: {result.ErrorMessage}", "Lỗi", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Error);
            }
        }

        private BitmapImage GenerateQrCodeBitmap(string text)
        {
            using QRCodeGenerator qrGenerator = new QRCodeGenerator();
            using QRCodeData qrCodeData = qrGenerator.CreateQrCode(text, QRCodeGenerator.ECCLevel.Q);
            using PngByteQRCode qrCode = new PngByteQRCode(qrCodeData);
            byte[] qrCodeBytes = qrCode.GetGraphic(20);
            
            using MemoryStream ms = new MemoryStream(qrCodeBytes);
            BitmapImage bitmapImage = new BitmapImage();
            bitmapImage.BeginInit();
            bitmapImage.StreamSource = ms;
            bitmapImage.CacheOption = BitmapCacheOption.OnLoad;
            bitmapImage.EndInit();
            bitmapImage.Freeze();
            return bitmapImage;
        }

        private CancellationTokenSource? _pollingCts;

        private async Task PollPayOSStatus(int orderId, CancellationToken token)
        {
            try
            {
                while (!token.IsCancellationRequested)
                {
                    var status = await ApiService.Instance.CheckPayOSStatusAsync(orderId, _currentPayosOrderCode);
                    if (status == "PAID")
                    {
                        System.Windows.Application.Current.Dispatcher.Invoke(() =>
                        {
                            IsVietQRPopupOpen = false;
                            ActiveTab!.CartItems.Clear();
                            ActiveTab.AmountGiven = 0m;
                            ClearCustomer();
                            System.Windows.MessageBox.Show("Thanh toán VietQR thành công!", "Thành công", System.Windows.MessageBoxButton.OK, System.Windows.MessageBoxImage.Information);
                        });
                        break;
                    }
                    else if (status == "EXPIRED" || status == "CANCELLED")
                    {
                        // Auto regenerate QR if not manually cancelled by user
                        if (!token.IsCancellationRequested)
                        {
                            System.Windows.Application.Current.Dispatcher.Invoke(() =>
                            {
                                // Restart checkout quietly
                                _ = CheckoutVietQR();
                            });
                        }
                        break;
                    }
                    await Task.Delay(3000, token);
                }
            }
            catch (TaskCanceledException) { }
        }

        [RelayCommand]
        private void HideQR()
        {
            IsVietQRPopupOpen = false;
            // Does not cancel the token, so polling continues in background
        }

        [RelayCommand]
        private async Task CancelQR()
        {
            _pollingCts?.Cancel();
            IsVietQRPopupOpen = false;
            
            if (_currentOrderId > 0 && _currentPayosOrderCode > 0)
            {
                await ApiService.Instance.CancelPayOSAsync(_currentOrderId, _currentPayosOrderCode);
            }
        }

        [RelayCommand]
        private void ClosePopup()
        {
            IsCheckoutPopupOpen = false;
        }
    }
}
