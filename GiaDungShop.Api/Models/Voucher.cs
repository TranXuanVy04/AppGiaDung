namespace GiaDungShop.Api.Models
{
    public class Voucher
    {
        public int Id { get; set; }
        public string Code { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string DiscountType { get; set; } = "Fixed";
        public decimal DiscountValue { get; set; }
        public decimal MinOrderValue { get; set; }
        public DateTime ExpiredAt { get; set; }
        public bool IsActive { get; set; } = true;
    }
}