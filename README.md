# SafePass

SafePass es una aplicación móvil personal para guardar y consultar credenciales en una bóveda local. Está desarrollada con Flutter y actualmente no usa cuentas, servidores ni sincronización en la nube.

## Funciones

- Guarda el servicio, usuario, contraseña, categoría, una clave adicional opcional y notas.
- Permite buscar por servicio, usuario o categoría.
- Permite ver, editar, copiar y eliminar credenciales.
- Solicita autenticación del dispositivo al iniciar: biometría cuando está disponible o el PIN, patrón o código de desbloqueo del teléfono.
- Bloquea la bóveda al pasar la aplicación a segundo plano y solicita autenticación al volver.
- Incluye modo claro y oscuro, que cambia según la hora local del dispositivo.

## Cómo ejecutar

Necesitas Flutter instalado y un dispositivo Android o emulador conectado. El proyecto requiere una versión de Dart compatible con `^3.11.5` (incluida en una versión compatible de Flutter).

Desde esta carpeta, ejecuta:

```bash
flutter pub get
flutter run
```

En Android, configura un método de bloqueo de pantalla en el dispositivo. SafePass lo necesita para permitir el acceso a la bóveda. Si usas un dispositivo iOS, la primera compilación requiere macOS y Xcode.

## Almacenamiento y seguridad actual

- Las credenciales se guardan localmente en SQLite (`password_vault.db`). No se envían a un servidor.
- El servicio, el usuario, la contraseña, la clave adicional y las notas se cifran con AES. La clave de cifrado se guarda mediante `flutter_secure_storage`.
- La categoría, el icono y la fecha de creación permanecen sin cifrar para mostrar y filtrar la bóveda.
- Al actualizar desde la versión anterior, SQLite cifra el servicio, el usuario y las notas de los registros existentes durante la migración.
- La bóveda no tiene todavía una función de exportación o respaldo cifrado. Reinstalar la aplicación o perder los datos y la clave del dispositivo podría hacer que las credenciales no se puedan recuperar.
- La contraseña copiada queda en el portapapeles del sistema; SafePass todavía no la borra automáticamente.

La autenticación protege la entrada a la interfaz, pero no sustituye un respaldo seguro ni una revisión de seguridad. El proyecto es una aplicación personal en desarrollo y no ha pasado por una auditoría de seguridad.

## Estructura del proyecto

```text
lib/
  database/    Acceso a SQLite
  models/      Modelo de credenciales
  providers/   Estado y operaciones de la aplicación
  screens/     Pantallas de la bóveda
  services/    Cifrado, autenticación y contexto horario
  widgets/     Componentes reutilizables
test/          Pruebas existentes
```

## Tecnologías principales

- Flutter y Dart
- Provider para el estado
- SQLite mediante `sqflite`
- `encrypt` y `flutter_secure_storage` para el cifrado y almacenamiento de la clave
- `local_auth` para la autenticación del dispositivo

## Plataformas

La aplicación está orientada actualmente a Android e iOS. Aunque el repositorio contiene carpetas generadas para otras plataformas, el almacenamiento y la autenticación requieren adaptación y validación antes de considerar compatibles la web o las aplicaciones de escritorio.
