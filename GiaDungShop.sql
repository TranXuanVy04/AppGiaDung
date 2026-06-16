CREATE DATABASE GiaDungShopDB;
GO
USE GiaDungShopDB;
GO

---------------------------------------------------
-- 1. USERS
---------------------------------------------------
-- Mật khẩu hash bên dưới là ví dụ.
-- Cách chắc ăn hơn: dùng API register để tạo user thật rồi sửa role nếu cần.

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'customer@gmail.com')
BEGIN
    INSERT INTO Users
    (FullName, Email, Phone, PasswordHash, Address, Role, IsActive, CreatedAt)
    VALUES
    (N'Khách hàng A',
     'customer@gmail.com',
     '0900000002',
     '$2a$11$Q6GQx1mV9zj4x1eBvJH4uO8w1o6W4zM5zW2KxkY6Q9W0N6O9Y2k5S',
     N'Hồ Chí Minh',
     'Customer',
     1,
     GETDATE());
END
GO

IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'admin@gmail.com')
BEGIN
    INSERT INTO Users
    (FullName, Email, Phone, PasswordHash, Address, Role, IsActive, CreatedAt)
    VALUES
    (N'Quản trị viên',
     'admin@gmail.com',
     '0900000001',
     '$2a$11$Q6GQx1mV9zj4x1eBvJH4uO8w1o6W4zM5zW2KxkY6Q9W0N6O9Y2k5S',
     N'Hồ Chí Minh',
     'Admin',
     1,
     GETDATE());
END
GO
IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = 'admin1@gmail.com')
BEGIN
    INSERT INTO Users
    (FullName, Email, Phone, PasswordHash, Address, Role, IsActive, CreatedAt)
    VALUES
    (N'Quản trị viên',
     'admin1@gmail.com',
     '0900000005',
     '$2a$11$Q6GQx1mV9zj4x1eBvJH4uO8w1o6W4zM5zW2KxkY6Q9W0N6O9Y2k5S',
     N'Hồ Chí Minh',
     'Admin',
     1,
     GETDATE());
END
GO
INSERT INTO Users
(FullName, Email, Phone, PasswordHash, Address, Role, IsActive, CreatedAt)
VALUES
(N'Admin2',
 'admin2@gmail.com',
 '0900000007',
 '$2a$11$Q6GQx1mV9zj4x1eBvJH4uO8w1o6W4zM5zW2KxkY6Q9W0N6O9Y2k5S',
 N'Hồ Chí Minh',
 'Admin',
 1,
 GETDATE());


---------------------------------------------------
-- 2. CATEGORIES
---------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = N'Nhà bếp')
BEGIN
    INSERT INTO Categories (Name, Description, IsActive)
    VALUES
    (N'Nhà bếp', N'Đồ gia dụng nhà bếp', 1),
    (N'Điện gia dụng', N'Thiết bị điện gia đình', 1),
    (N'Vệ sinh nhà cửa', N'Dụng cụ vệ sinh', 1),
    (N'Phòng tắm', N'Đồ dùng phòng tắm', 1);
END
GO

---------------------------------------------------
-- 3. PRODUCTS
---------------------------------------------------
DECLARE @CatKitchen INT = (SELECT TOP 1 Id FROM Categories WHERE Name = N'Nhà bếp');
DECLARE @CatElectric INT = (SELECT TOP 1 Id FROM Categories WHERE Name = N'Điện gia dụng');
DECLARE @CatClean   INT = (SELECT TOP 1 Id FROM Categories WHERE Name = N'Vệ sinh nhà cửa');
DECLARE @CatBath    INT = (SELECT TOP 1 Id FROM Categories WHERE Name = N'Phòng tắm');

IF NOT EXISTS (SELECT 1 FROM Products WHERE Name = N'Nồi cơm điện Sharp 1.8L')
BEGIN
    INSERT INTO Products
    (Name, Description, Price, OldPrice, Stock, Brand, ImageUrl, CategoryId, Rating, IsFeatured, IsActive, CreatedAt)
    VALUES
    (N'Nồi cơm điện Sharp 1.8L', N'Nồi cơm điện dung tích lớn cho gia đình 4-6 người.', 890000, 990000, 20, N'Sharp', NULL, @CatKitchen, 4.5, 1, 1, GETDATE()),
    (N'Ấm siêu tốc Sunhouse', N'Đun nước nhanh, dung tích 1.7L.', 350000, 420000, 35, N'Sunhouse', NULL, @CatElectric, 4.2, 1, 1, GETDATE()),
    (N'Máy xay sinh tố Philips', N'Công suất mạnh, xay nhuyễn thực phẩm.', 1250000, 1450000, 12, N'Philips', NULL, @CatKitchen, 4.8, 1, 1, GETDATE()),
    (N'Máy hút bụi mini cầm tay', N'Thiết kế nhỏ gọn, hút bụi tiện lợi.', 650000, 750000, 15, N'Xiaomi', NULL, @CatClean, 4.4, 1, 1, GETDATE()),
    (N'Bộ lau nhà xoay 360', N'Lau sạch nhanh, dễ sử dụng.', 280000, 320000, 40, N'HomePro', NULL, @CatClean, 4.1, 0, 1, GETDATE()),
    (N'Kệ để đồ phòng tắm', N'Chất liệu nhựa cao cấp, chống nước.', 180000, 220000, 30, N'Lock&Lock', NULL, @CatBath, 4.0, 0, 1, GETDATE());
END
GO
-------------------------------------------
--4. VOUCHERS
-------------------------------------------
INSERT INTO Vouchers (Code, Title, Description, DiscountType, DiscountValue, MinOrderValue, ExpiredAt, IsActive)
VALUES
('GIAM50K', N'Giảm 50.000đ', N'Giảm trực tiếp 50.000đ cho đơn từ 500.000đ', 'Fixed', 50000, 500000, DATEADD(DAY, 30, GETDATE()), 1),
('SALE10', N'Giảm 10%', N'Giảm 10% cho đơn từ 700.000đ', 'Percent', 10, 700000, DATEADD(DAY, 30, GETDATE()), 1);

------------------------------------------------
--5. PAY
------------------------------------------------
CREATE TABLE PaymentMethods (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    Code NVARCHAR(50),
    LogoUrl NVARCHAR(500),
    IsActive BIT DEFAULT 1
)

INSERT INTO PaymentMethods (Name, Code, LogoUrl)
VALUES
(N'Thanh toán khi nhận hàng', 'COD', ''),
(N'MoMo', 'MOMO', ''),
(N'VNPay', 'VNPAY', ''),
(N'Ngân hàng Vietcombank', 'VCB', ''),
(N'Ngân hàng MB Bank', 'MBBANK', ''),
(N'Ngân hàng Techcombank', 'TCB', '')

----------------------------------------
--6. Product Reviews
----------------------------------------
CREATE TABLE ProductReviews (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    UserId INT NOT NULL,
    OrderId INT NOT NULL,
    Rating INT NOT NULL,
    Comment NVARCHAR(1000) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
);



ALTER TABLE Orders 
ADD PaymentStatus NVARCHAR(50) DEFAULT 'Pending',
    TransactionCode NVARCHAR(100);

    SELECT * FROM __EFMigrationsHistory;

    INSERT INTO __EFMigrationsHistory (MigrationId, ProductVersion)
VALUES ('20260515163738_AddPaymentMethod', '8.0.0');
