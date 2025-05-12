// models/user_model.dart
class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? direccion;
  final String? avatar;
  final String rol;
  final DateTime createdAt;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.direccion,
    this.avatar,
    required this.rol,
    required this.createdAt,
  });

  // Constructor desde JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'],
      direccion: json['direccion'],
      avatar: json['avatar'],
      // Por defecto, asignamos "cliente" si no hay un rol específico
      rol: json['rol'] ?? 'cliente',
      // Convertir la fecha de creación
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'avatar': avatar,
      'rol': rol,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Método para actualizar datos de usuario
  Usuario copyWith({
    String? nombre,
    String? telefono,
    String? direccion,
    String? avatar,
  }) {
    return Usuario(
      id: this.id,
      nombre: nombre ?? this.nombre,
      email: this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      avatar: avatar ?? this.avatar,
      rol: this.rol,
      createdAt: this.createdAt,
    );
  }
}