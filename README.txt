Bước 1: Chạy flutter pub get
Bước 2:Kiểm tra xem có Cài package NuGet bên API chưa nếu có:

Mở Tools → NuGet Package Manager → Package Manager Console rồi chạy:

Install-Package Microsoft.EntityFrameworkCore.SqlServer
Install-Package Microsoft.EntityFrameworkCore.Tools
Install-Package Microsoft.AspNetCore.Authentication.JwtBearer
Install-Package BCrypt.Net-Next
Bước 3: Mở sql chạy lệnh create data base
Bước 4:Qua API chạyy Package Manager Console chạy:
Add-Migration InitDb
Update-Database
Bước 5: Chạy hết lệnh còn lại của sql( chạy lần lượt không bị nhầm lệnh )
Bước 6: Chạy APi hiển thị web swang
Bước 7: Chạy flutter