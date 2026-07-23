namespace MiniMart.Shared.Utils
{
    public static class HanoiTime
    {
        private static readonly TimeZoneInfo _timeZone;

        static HanoiTime()
        {
            _timeZone = TryGetTimeZone("SE Asia Standard Time")
                ?? TryGetTimeZone("Asia/Bangkok")
                ?? TimeZoneInfo.CreateCustomTimeZone("Hanoi", TimeSpan.FromHours(7), "Hanoi", "Hanoi");
        }

        public static DateTime Now => TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, _timeZone);

        public static DateOnly Today => DateOnly.FromDateTime(Now);

        private static TimeZoneInfo? TryGetTimeZone(string id)
        {
            try { return TimeZoneInfo.FindSystemTimeZoneById(id); }
            catch { return null; }
        }
    }
}
