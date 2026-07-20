using System;
using System.Net.Http;
using System.Threading.Tasks;

var client = new HttpClient();
var res = await client.GetAsync("http://localhost:5005/odata/Products");
var str = await res.Content.ReadAsStringAsync();
Console.WriteLine(str);
