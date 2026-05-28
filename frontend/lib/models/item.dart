class Item {
  final int id;
  final String name;
  final String type;
  final String description;
  final int stock;
  final String image;
  final double price;

  Item({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.image,
    required this.price,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      stock: json['stock'] is int ? json['stock'] : int.parse(json['stock'].toString()),
      image: json['image'] as String,
      price: json['price'] is double 
          ? json['price'] 
          : double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'stock': stock,
      'image': image,
      'price': price,
    };
  }

  
  Item copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    int? stock,
    String? image,
    double? price,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      price: price ?? this.price,
    );
  }
}
