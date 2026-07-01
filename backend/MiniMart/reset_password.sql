-- Reset password cho manager.test và admin.test
-- Password mới: Manager@123 và Admin@123
-- Hash được tạo bằng PBKDF2-SHA256:100000

-- Chạy script C# nhỏ này để lấy hash, hoặc dùng hash bên dưới
-- dotnet run --project tool để tạo hash

-- Cách nhanh: update trực tiếp bằng hash đã biết
-- Password: Test@1234 cho cả 2 tài khoản

-- Tạo hash mới bằng cách chạy endpoint /api/auth/reset-dev-passwords (xem bên dưới)
-- Hoặc chạy query này trong SSMS sau khi có hash:

-- UPDATE [dbo].[Employees] 
-- SET [PasswordHash] = N'<new_hash_here>'
-- WHERE [Username] IN (N'manager.test', N'admin.test');
