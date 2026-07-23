using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using MiniMart.Data;

#nullable disable

namespace MiniMart.Migrations
{
    [DbContext(typeof(MiniMartDbContext))]
    [Migration("20260723071000_FixBatchesSyncStockTriggerRowCount")]
    partial class FixBatchesSyncStockTriggerRowCount
    {
    }
}
