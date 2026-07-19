using System.Threading.Tasks;
using System.Windows;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MiniMart.Services;

namespace MiniMart.ViewModels
{
    public partial class ShiftManagementViewModel : ObservableObject
    {
        [ObservableProperty]
        private string _startCashString = string.Empty;

        [ObservableProperty]
        private bool _isLoading = false;

        [ObservableProperty]
        private string _errorMessage = string.Empty;

        [RelayCommand]
        private async Task StartShiftAsync(Window window)
        {
            if (string.IsNullOrWhiteSpace(StartCashString))
            {
                ErrorMessage = "Vui lòng nhập số tiền đầu ca.";
                return;
            }

            if (!decimal.TryParse(StartCashString, out decimal startCash) || startCash < 0)
            {
                ErrorMessage = "Số tiền không hợp lệ.";
                return;
            }

            IsLoading = true;
            ErrorMessage = string.Empty;

            var (success, shift, error) = await ApiService.Instance.StartShiftAsync(startCash);

            IsLoading = false;

            if (success)
            {
                window.DialogResult = true;
                window.Close();
            }
            else
            {
                ErrorMessage = error;
            }
        }
    }
}
