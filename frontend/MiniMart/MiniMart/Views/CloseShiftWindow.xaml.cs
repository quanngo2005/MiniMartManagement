using System.Windows;
using MiniMart.ViewModels;

namespace MiniMart.Views
{
    public partial class CloseShiftWindow : Window
    {
        public CloseShiftWindow(MiniMart.Models.DTOs.ShiftDto shift)
        {
            InitializeComponent();
            if (DataContext is CloseShiftViewModel viewModel)
            {
                viewModel.ShiftId = shift.ShiftId;
                viewModel.ShiftName = shift.ShiftName;
                viewModel.ShiftDate = shift.StartTime.ToString("dd/MM/yyyy");
            }
        }
    }
}
