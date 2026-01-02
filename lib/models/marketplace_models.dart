class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final String category;
  final String sellerId;
  final String sellerName;
  final String? imageUrl;
  final int quantity;
  final bool isAvailable;
  final DateTime createdAt;
  final String location;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    this.imageUrl,
    required this.quantity,
    this.isAvailable = true,
    required this.createdAt,
    required this.location,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      imageUrl: json['imageUrl'] as String?,
      quantity: json['quantity'] as int,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'category': category,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'isAvailable': isAvailable,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'location': location,
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