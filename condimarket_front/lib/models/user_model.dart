class Usuario {
  final String id;
  final String nombre;
  final String email;
  // final String? telefono;    // Se habilitará cuando el backend lo implemente
  // final String? direccion;  // Se habilitará cuando el backend lo implemente
  final DateTime createdAt;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    // this.telefono,
    // this.direccion,
    required this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString() ?? '',
      nombre: json['name'] ?? json['nombre'] ?? '',
      email: json['email'] ?? '',
      // telefono: json['telefono'],
      // direccion: json['direccion'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nombre,
      'email': email,
      // 'telefono': telefono,
      // 'direccion': direccion,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Usuario copyWith({
    String? nombre,
    // String? telefono,
    // String? direccion,
  }) {
    return Usuario(
      id: id,
      nombre: nombre ?? this.nombre,
      email: email,
      // telefono: telefono ?? this.telefono,
      // direccion: direccion ?? this.direccion,
      createdAt: createdAt,
    );
  }
}
