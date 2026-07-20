using System.Threading.Tasks;
using System.Windows;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MiniMart.Services;

namespace MiniMart.ViewModels
{
    public partial class CloseShiftViewModel : ObservableObject
    {
        public int ShiftId { get; set; }

        [ObservableProperty]
        private string _shiftName = string.Empty;

        [ObservableProperty]
        private string _shiftDate = string.Empty;

        [ObservableProperty]
        private string _endCashString = string.Empty;

        [ObservableProperty]
        private bool _isLoading = false;

        [ObservableProperty]
        private string _errorMessage = string.Empty;

        [RelayCommand]
        private async Task CloseShiftAsync(Window window)
        {
            if (string.IsNullOrWhiteSpace(EndCashString))
            {
                ErrorMessage = "Vui lòng nhập số tiền cuối ca.";
                return;
            }

            if (!decimal.TryParse(EndCashString, out decimal endCash) || endCash < 0)
            {
                ErrorMessage = "Số tiền không hợp lệ.";
                return;
            }

            IsLoading = true;
            ErrorMessage = string.Empty;

            var (success, error) = await ApiService.Instance.CloseShiftAsync(ShiftId, endCash);

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
