using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using MiniMart.Services;
using MiniMart.ViewModels;

namespace MiniMart.Views
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            this.Loaded += Window_Loaded;
        }

        private async void Window_Loaded(object sender, RoutedEventArgs e)
        {
            var shift = await ApiService.Instance.GetCurrentShiftAsync();
            if (shift == null)
            {
                var shiftWindow = new ShiftManagementWindow();
                shiftWindow.Owner = this;
                var result = shiftWindow.ShowDialog();
                if (result != true)
                {
                    Application.Current.Shutdown();
                }
                else
                {
                    if (DataContext is MainViewModel vm)
                        vm.CurrentShift = await ApiService.Instance.GetCurrentShiftAsync();
                }
            }
            else if (shift.EndTime.HasValue && System.DateTime.Now > shift.EndTime.Value)
            {
                var closeShiftWindow = new CloseShiftWindow(shift);
                closeShiftWindow.Owner = this;
                var result = closeShiftWindow.ShowDialog();
                
                if (result == true)
                {
                    var shiftWindow = new ShiftManagementWindow();
                    shiftWindow.Owner = this;
                    if (shiftWindow.ShowDialog() != true)
                    {
                        Application.Current.Shutdown();
                    }
                    else
                    {
                        if (DataContext is MainViewModel vm)
                            vm.CurrentShift = await ApiService.Instance.GetCurrentShiftAsync();
                    }
                }
                else
                {
                    Application.Current.Shutdown();
                }
            }
            else
            {
                if (DataContext is MainViewModel vm)
                {
                    vm.CurrentShift = shift;
                }
            }
        }
    }
}