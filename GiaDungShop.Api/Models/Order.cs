namespace GiaDungShop.Api.Models
{
    public class Order
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string ReceiverName { get; set; } = string.Empty;
        public string ReceiverPhone { get; set; } = string.Empty;
        public string ShippingAddress { get; set; } = string.Empty;
        public string PaymentMethod { get; set; } = "COD";
        public decimal SubTotal { get; set; }
        public decimal ShippingFee { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public string? VoucherCode { get; set; }
        public string Status { get; set; } = "Chờ xác nhận";
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public User? User { get; set; }
        public ICollection<OrderItem>? OrderItems { get; set; }
    }
}