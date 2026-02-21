class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String unit;
  final String category;
  final String subCategory;
  final String sellerId;
  final String sellerName;
  final List<String> imageUrls;
  final double quantity;
  final String unitSymbol;
  final String location;
  final String district;
  final bool isVerified;
  final String qualityGrade;
  final bool isOrganic;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.unit,
    required this.category,
    required this.subCategory,
    required this.sellerId,
    required this.sellerName,
    required this.imageUrls,
    required this.quantity,
    required this.unitSymbol,
    required this.location,
    required this.district,
    this.isVerified = false,
    this.qualityGrade = 'B',
    this.isOrganic = false,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  // Alias for backward compatibility if needed
  String get name => title;
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] ?? json['name'] as String? ?? 'Unnamed Product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'unit',
      category: json['category'] as String? ?? 'General',
      subCategory: json['subCategory'] ?? json['category'] ?? 'General',
      sellerId: json['sellerId'] as String? ?? '',
      sellerName: json['sellerName'] ?? 'Unknown Seller',
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : (json['imageUrl'] != null ? [json['imageUrl']] : []),
      quantity:
          (json['quantity'] ?? json['quantityAvailable'] ?? 0.0).toDouble(),
      unitSymbol: json['unitSymbol'] ?? json['unit'] ?? 'unit',
      location: json['location'] as String? ?? 'Unknown',
      district: json['district'] ?? 'Unknown',
      isVerified: json['isVerified'] as bool? ?? false,
      qualityGrade: json['qualityGrade'] ?? 'B',
      isOrganic: json['isOrganic'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'unit': unit,
      'category': category,
      'subCategory': subCategory,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'imageUrls': imageUrls,
      'quantity': quantity,
      'unitSymbol': unitSymbol,
      'location': location,
      'district': district,
      'isVerified': isVerified,
      'qualityGrade': qualityGrade,
      'isOrganic': isOrganic,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }
}

class Order {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String deliveryAddress;
  final String? notes;

  const Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.deliveryAddress,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
      deliveryAddress: json['deliveryAddress'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'deliveryAddress': deliveryAddress,
      'notes': notes,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

enum ProductCategory {
  crops,
  seeds,
  fertilizer,
  tools,
  livestock,
  dairy,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.crops:
        return 'Crops';
      case ProductCategory.seeds:
        return 'Seeds';
      case ProductCategory.fertilizer:
        return 'Fertilizer';
      case ProductCategory.tools:
        return 'Tools';
      case ProductCategory.livestock:
        return 'Livestock';
      case ProductCategory.dairy:
        return 'Dairy';
    }
  }
}
