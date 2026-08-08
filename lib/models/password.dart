class Password {
  final int? id;
  final String servicio;
  final String usuario;
  final String password;
  final String clave;
  final String categoria;
  final String notas;
  final String? icono;
  final DateTime fechaCreacion;

  Password({
    this.id,
    required this.servicio,
    required this.usuario,
    required this.password,
    required this.clave,
    required this.categoria,
    required this.notas,
    this.icono,
    required this.fechaCreacion,
  });

  // Convertir objeto a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'servicio': servicio,
      'usuario': usuario,
      'password': password,
      'clave': clave,
      'categoria': categoria,
      'notas': notas,
      'icono': icono,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  // Crear objeto Password desde SQLite
  factory Password.fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'],
      servicio: map['servicio'],
      usuario: map['usuario'],
      password: map['password'],
      clave: map['clave'],
      categoria: map['categoria'],
      notas: map['notas'],
      icono: map['icono'],
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
    );
  }
}