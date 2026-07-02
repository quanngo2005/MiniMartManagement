using System;
using Microsoft.Data.SqlClient;

class Program
{
    static void Main()
    {
        var connectionString = "Server=localhost;Database=MiniMartDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true";
        using (var connection = new SqlConnection(connectionString))
        {
            connection.Open();
            var command = new SqlCommand("SELECT Username, FullName FROM Employees WHERE RoleId = 6", connection);
            using var reader = command.ExecuteReader();
            Console.WriteLine("Cashiers:");
            while (reader.Read()) {
                Console.WriteLine(reader["Username"] + " -> " + reader["FullName"]);
            }
        }
    }
}
