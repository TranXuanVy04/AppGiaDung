namespace GiaDungShop.Api.DTOs.Order
{
    public class CreateBuyNowOrderDto
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public string ReceiverName { get; set; } = string.Empty;
        public string ReceiverPhone { get; set; } = string.Empty;
        public string ShippingAddress { get; set; } = string.Empty;
        public string PaymentMethod { get; set; } = "COD";
        public decimal ShippingFee { get; set; } = 30000;
        public string? VoucherCode { get; set; }
    }
}