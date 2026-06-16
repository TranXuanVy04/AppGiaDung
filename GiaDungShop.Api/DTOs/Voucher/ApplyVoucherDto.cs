namespace GiaDungShop.Api.DTOs.Voucher
{
    public class ApplyVoucherDto
    {
        public string Code { get; set; } = string.Empty;
        public decimal OrderAmount { get; set; }
    }
}