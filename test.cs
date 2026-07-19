using System;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;

class Program
{
    static async Task Main()
    {
        var client = new HttpClient();
        var res = await client.GetAsync("http://localhost:5005/odata/Products");
        var str = await res.Content.ReadAsStringAsync();
        Console.WriteLine(str);
    }
}
