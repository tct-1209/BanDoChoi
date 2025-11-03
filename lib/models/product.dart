class Product {
  final int id;
  final String name;
  final String? img;
  final double price;
  final int catId;
  final String status;
  final String? description;
  final DateTime createdAt;
  final Category? category;

  Product({
    required this.id,
    required this.name,
    this.img,
    required this.price,
    required this.catId,
    required this.status,
    this.description,
    required this.createdAt,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      img: json['img'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      catId: json['cat_Id'] ?? 0,
      status: json['status'] ?? 'available',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      category: json['Category'] != null
          ? Category.fromJson(json['Category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'img': img,
      'price': price,
      'cat_Id': catId,
      'status': status,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'Category': category?.toJson(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? img,
    double? price,
    int? catId,
    String? status,
    String? description,
    DateTime? createdAt,
    Category? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      img: img ?? this.img,
      price: price ?? this.price,
      catId: catId ?? this.catId,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }

  // Helper methods
  bool get isActive => status == 'available';
  bool get isInactive => status == 'inactive';
  
  String get formattedPrice => '${price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]},'
  )} VNĐ';
}

class Category {
  final int id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
