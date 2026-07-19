using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading.Tasks;
using MiniMart.Models.DTOs;

namespace MiniMart.Services
{
    public class ApiService
    {
        private static ApiService? _instance;
        public static ApiService Instance => _instance ??= new ApiService();

        public EmployeeUserDto? CurrentUser { get; private set; }

        private readonly HttpClient _client;
        private readonly CookieContainer _cookieContainer;
        private readonly string _baseUrl = "http://localhost:5005";

        private ApiService()
        {
            _cookieContainer = new CookieContainer();
            var handler = new HttpClientHandler
            {
                CookieContainer = _cookieContainer,
                UseCookies = true,
                ServerCertificateCustomValidationCallback = (sender, cert, chain, sslPolicyErrors) => true // Bypass SSL for local dev
            };

            _client = new HttpClient(handler)
            {
                BaseAddress = new Uri(_baseUrl)
            };
            _client.DefaultRequestHeaders.Add("Accept", "application/json");
        }

        private async Task<string> FetchCsrfTokenAsync()
        {
            try
            {
                var response = await _client.GetAsync("/api/auth/csrf-token");
                if (response.IsSuccessStatusCode)
                {
                    var result = await response.Content.ReadFromJsonAsync<ApiResponse<JsonElement>>();
                    if (result != null && result.Data.ValueKind != JsonValueKind.Undefined && result.Data.ValueKind != JsonValueKind.Null)
                    {
                        var data = result.Data;
                        if (data.TryGetProperty("csrfToken", out var tokenProp) || data.TryGetProperty("CsrfToken", out tokenProp))
                        {
                            var token = tokenProp.GetString() ?? "";
                            _cookieContainer.Add(new Uri(_baseUrl), new Cookie("XSRF-TOKEN", token));
                            return token;
                        }
                    }
                }
            }
            catch { }
            return string.Empty;
        }

        public async Task<(bool Success, EmployeeUserDto? User, string ErrorMessage)> LoginAsync(string username, string password)
        {
            try
            {
                string csrfToken = await FetchCsrfTokenAsync();
                
                var request = new HttpRequestMessage(HttpMethod.Post, "/api/auth/login");
                request.Content = JsonContent.Create(new LoginRequest
                {
                    Username = username,
                    Password = password,
                    RememberMe = false
                });

                if (!string.IsNullOrEmpty(csrfToken))
                {
                    request.Headers.Add("X-XSRF-TOKEN", csrfToken);
                }

                var response = await _client.SendAsync(request);

                if (response.Headers.TryGetValues("Set-Cookie", out var setCookies))
                {
                    foreach (var cookieStr in setCookies)
                    {
                        var parts = cookieStr.Split(';');
                        var nameValue = parts[0].Split('=', 2);
                        if (nameValue.Length == 2)
                        {
                            var cookie = new Cookie(nameValue[0].Trim(), nameValue[1].Trim())
                            {
                                Domain = "localhost",
                                Path = "/"
                            };
                            _cookieContainer.Add(new Uri(_baseUrl), cookie);
                        }
                    }
                }

                var result = await response.Content.ReadFromJsonAsync<ApiResponse<AuthResponse>>();

                if (response.IsSuccessStatusCode && result != null && result.Data?.User != null)
                {
                    CurrentUser = result.Data.User;
                    return (true, result.Data.User, string.Empty);
                }

                return (false, null, result?.Message ?? "Đăng nhập thất bại.");
            }
            catch (Exception ex)
            {
                return (false, null, $"Lỗi kết nối: {ex.Message}");
            }
        }

        public async Task<ShiftDto?> GetCurrentShiftAsync()
        {
            try
            {
                var response = await _client.GetAsync("/api/shifts/current");
                if (response.IsSuccessStatusCode)
                {
                    return await response.Content.ReadFromJsonAsync<ShiftDto>();
                }
            }
            catch { }
            return null;
        }

        public async Task<(bool Success, ShiftDto? Shift, string ErrorMessage)> StartShiftAsync(decimal startCash)
        {
            try
            {
                if (CurrentUser == null) return (false, null, "Vui lòng đăng nhập lại.");

                string csrfToken = await FetchCsrfTokenAsync();

                var now = DateTime.Now;
                bool isMorning = now.Hour >= 6 && now.Hour < 14;
                string expectedShiftCode = (isMorning ? "SA-" : "CH-") + now.Date.ToString("yyyyMMdd") + "-" + CurrentUser.EmployeeId;

                int? shiftIdToOpen = null;

                // 1. Tìm xem có ca Pending nào chưa mở không
                var getReq = new HttpRequestMessage(HttpMethod.Get, $"/api/shifts?$filter=ShiftCode eq '{expectedShiftCode}'");
                if (!string.IsNullOrEmpty(csrfToken))
                {
                    getReq.Headers.Add("X-XSRF-TOKEN", csrfToken);
                }
                var getRes = await _client.SendAsync(getReq);
                if (getRes.IsSuccessStatusCode)
                {
                    var getStr = await getRes.Content.ReadAsStringAsync();
                    try
                    {
                        using var doc = JsonDocument.Parse(getStr);
                        if (doc.RootElement.ValueKind == JsonValueKind.Array)
                        {
                            foreach (var el in doc.RootElement.EnumerateArray())
                            {
                                if (el.TryGetProperty("status", out var st) && st.GetInt32() == 1) // 1 = Pending
                                {
                                    shiftIdToOpen = el.GetProperty("shiftId").GetInt32();
                                    break;
                                }
                            }
                        }
                        else if (doc.RootElement.TryGetProperty("value", out var val) && val.ValueKind == JsonValueKind.Array)
                        {
                            foreach (var el in val.EnumerateArray())
                            {
                                if (el.TryGetProperty("status", out var st) && st.GetInt32() == 1)
                                {
                                    shiftIdToOpen = el.GetProperty("shiftId").GetInt32();
                                    break;
                                }
                            }
                        }
                    }
                    catch { }
                }

                // 2. Nếu không có ca Pending, tạo ca mới
                if (shiftIdToOpen == null)
                {
                    var createPayload = new
                    {
                        shiftCode = "",
                        shiftName = isMorning ? "Ca sáng" : "Ca chiều",
                        employeeId = CurrentUser.EmployeeId,
                        cashierId = CurrentUser.EmployeeId,
                        startTime = now,
                        endTime = now.AddHours(8),
                        workDate = now.Date,
                        startCash = startCash,
                        endCash = 0m,
                        revenue = 0m,
                        status = 1, // 1 = Pending
                        note = ""
                    };

                    var createReq = new HttpRequestMessage(HttpMethod.Post, "/api/shifts");
                    createReq.Content = JsonContent.Create(createPayload);
                    if (!string.IsNullOrEmpty(csrfToken))
                    {
                        createReq.Headers.Add("X-XSRF-TOKEN", csrfToken);
    
                    }

                    var createRes = await _client.SendAsync(createReq);
                    if (!createRes.IsSuccessStatusCode)
                    {
                        var errStr = await createRes.Content.ReadAsStringAsync();
                        try {
                            using var doc = JsonDocument.Parse(errStr);
                            if (doc.RootElement.TryGetProperty("message", out var msg)) errStr = msg.GetString();
                        } catch { }
                        return (false, null, $"Lỗi tạo ca ({createRes.StatusCode}): {errStr}");
                    }

                    var createdShift = await createRes.Content.ReadFromJsonAsync<ShiftDto>();
                    if (createdShift == null) return (false, null, "Lỗi tạo ca: Dữ liệu trả về rỗng.");
                    shiftIdToOpen = createdShift.ShiftId;
                }

                // 3. Mở ca
                var openPayload = new
                {
                    shiftId = shiftIdToOpen.Value,
                    cashierId = CurrentUser.EmployeeId,
                    startCash = startCash,
                    note = ""
                };

                var openReq = new HttpRequestMessage(HttpMethod.Post, "/api/shifts/open");
                openReq.Content = JsonContent.Create(openPayload);
                if (!string.IsNullOrEmpty(csrfToken))
                {
                    openReq.Headers.Add("X-XSRF-TOKEN", csrfToken);
                }

                var openRes = await _client.SendAsync(openReq);
                if (!openRes.IsSuccessStatusCode)
                {
                    var errStr = await openRes.Content.ReadAsStringAsync();
                    try {
                        using var doc = JsonDocument.Parse(errStr);
                        if (doc.RootElement.TryGetProperty("message", out var msg)) errStr = msg.GetString();
                    } catch { }
                    return (false, null, $"Lỗi mở ca ({openRes.StatusCode}): {errStr}");
                }

                var openedShift = await openRes.Content.ReadFromJsonAsync<ShiftDto>();
                return (true, openedShift, string.Empty);
            }
            catch (Exception ex)
            {
                return (false, null, $"Lỗi kết nối: {ex.Message}");
            }
        }

        public async Task<(bool Success, string ErrorMessage)> CloseShiftAsync(int shiftId, decimal endCash)
        {
            try
            {
                string csrfToken = await FetchCsrfTokenAsync();
                var request = new HttpRequestMessage(HttpMethod.Post, $"/api/shifts/{shiftId}/close");
                request.Content = JsonContent.Create(new { endCash = endCash });

                if (!string.IsNullOrEmpty(csrfToken))
                {
                    request.Headers.Add("X-XSRF-TOKEN", csrfToken);
                }

                var response = await _client.SendAsync(request);

                if (!response.IsSuccessStatusCode)
                {
                    var errStr = await response.Content.ReadAsStringAsync();
                    try {
                        using var doc = JsonDocument.Parse(errStr);
                        if (doc.RootElement.TryGetProperty("message", out var msg)) errStr = msg.GetString();
                    } catch { }
                    return (false, $"Đóng ca thất bại ({response.StatusCode}): {errStr}");
                }

                var result = await response.Content.ReadFromJsonAsync<ShiftDto>();
                if (result != null)
                {
                    return (true, string.Empty);
                }

                return (false, "Đóng ca thất bại: Không đọc được dữ liệu trả về.");
            }
            catch (Exception ex)
            {
                return (false, $"Lỗi kết nối: {ex.Message}");
            }
        }

        public async Task<List<ProductDto>> SearchProductsAsync(string query)
        {
            try
            {
                var odataFilter = $"contains(tolower(ProductName), '{query.ToLower().Replace("'", "''")}') or contains(Barcode, '{query.Replace("'", "''")}')";
                var response = await _client.GetAsync($"/odata/Products?$filter={Uri.EscapeDataString(odataFilter)}");
                if (response.IsSuccessStatusCode)
                {
                    var result = await response.Content.ReadFromJsonAsync<List<ProductDto>>();
                    if (result != null)
                    {
                        return result;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SearchProductsAsync Error: {ex.Message}");
            }
            return new List<ProductDto>();
        }

        public async Task<CustomerDto?> GetCustomerByPhoneAsync(string phone)
        {
            try
            {
                var response = await _client.GetAsync($"/odata/Customers?$filter=PhoneNumber eq '{phone}'");
                if (response.IsSuccessStatusCode)
                {
                    var result = await response.Content.ReadFromJsonAsync<List<CustomerDto>>();
                    if (result != null && result.Count > 0)
                    {
                        return result[0];
                    }
                }
            }
            catch { }
            return null;
        }

        public async Task<(bool Success, CheckoutResponseDto? Data, string ErrorMessage)> CheckoutCashAsync(CheckoutRequestDto requestDto)
        {
            try
            {
                string csrfToken = await FetchCsrfTokenAsync();
                var request = new HttpRequestMessage(HttpMethod.Post, "/api/orders/checkout");
                request.Content = JsonContent.Create(requestDto);

                if (!string.IsNullOrEmpty(csrfToken))
                {
                    request.Headers.Add("X-XSRF-TOKEN", csrfToken);

                }

                var response = await _client.SendAsync(request);
                var result = await response.Content.ReadFromJsonAsync<ApiResponse<CheckoutResponseDto>>();

                if (response.IsSuccessStatusCode && result != null && result.Data != null)
                {
                    return (true, result.Data, string.Empty);
                }

                return (false, null, result?.Message ?? "Thanh toán thất bại.");
            }
            catch (Exception ex)
            {
                return (false, null, $"Lỗi kết nối: {ex.Message}");
            }
        }
    }
}
