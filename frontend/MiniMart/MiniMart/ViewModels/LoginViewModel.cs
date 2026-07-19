using System.Threading.Tasks;
using System.Windows;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using MiniMart.Services;

namespace MiniMart.ViewModels
{
    public partial class LoginViewModel : ObservableObject
    {
        [ObservableProperty]
        private string _username = string.Empty;

        [ObservableProperty]
        private string _password = string.Empty;

        [ObservableProperty]
        private bool _isLoading = false;

        [ObservableProperty]
        private string _errorMessage = string.Empty;

        [RelayCommand]
        private async Task LoginAsync(Window currentWindow)
        {
            if (string.IsNullOrWhiteSpace(Username) || string.IsNullOrWhiteSpace(Password))
            {
                ErrorMessage = "Vui lòng nhập tên đăng nhập và mật khẩu.";
                return;
            }

            IsLoading = true;
            ErrorMessage = string.Empty;

            var (success, user, error) = await ApiService.Instance.LoginAsync(Username, Password);

            IsLoading = false;

            if (success && user != null)
            {
                if (user.RoleId == 2 || user.RoleId == 6 || user.RoleName.ToLower() == "cashier" || user.RoleName.ToLower() == "thu ngân")
                {
                    // Open PosView (MainWindow for now)
                    var posWindow = new MiniMart.Views.MainWindow();
                    posWindow.Show();
                    currentWindow.Close();
                }
                else
                {
                    ErrorMessage = "Chỉ Thu ngân (Cashier) mới được phép sử dụng POS.";
                }
            }
            else
            {
                ErrorMessage = string.IsNullOrEmpty(error) ? "Tên đăng nhập hoặc mật khẩu không đúng." : error;
            }
        }
    }
}
