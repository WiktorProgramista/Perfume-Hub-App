class SavedProduct {
  final String productUrl;
  final String productBrand;
  final String productLine;
  final String subTitle;
  final String imageUrl;
  bool isLiked;

  SavedProduct({
    required this.productUrl,
    required this.productBrand,
    required this.productLine,
    required this.subTitle,
    required this.imageUrl,
    required this.isLiked,
  });

  Map<String, dynamic> toJson() {
    return {
      'productUrl': productUrl,
      'productBrand': productBrand,
      'productLine': productLine,
      'subTitle': subTitle,
      'imageUrl': imageUrl,
      'isLiked': isLiked,
    };
  }

  factory SavedProduct.fromJson(Map<String, dynamic> json) {
    return SavedProduct(
      productUrl: json['productUrl'],
      productBrand: json['productBrand'],
      productLine: json['productLine'],
      subTitle: json['subTitle'],
      imageUrl: json['imageUrl'],
      isLiked: json['isLiked'],
    );
  }
}
