namespace GiaDungShop.Api.Models
{
    public class Product
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public decimal? OldPrice { get; set; }
        public int Stock { get; set; }
        public string? Brand { get; set; }
        public string? ImageUrl { get; set; }
        public int CategoryId { get; set; }
        public double Rating { get; set; } = 0;
        public bool IsFeatured { get; set; } = false;
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public Category? Category { get; set; }
    }
}