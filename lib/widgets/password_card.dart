import 'package:flutter/material.dart';

import '../models/password.dart';

class PasswordCard extends StatelessWidget {
  final Password password;
  final VoidCallback onTap;

  const PasswordCard({
    super.key,
    required this.password,
    required this.onTap,
  });

  IconData _obtenerIcono() {
    switch (password.categoria) {
      case 'Trabajo':
        return Icons.work;

      case 'Estudio':
        return Icons.school;

      case 'Redes sociales':
        return Icons.people;

      case 'Bancos':
        return Icons.account_balance;

      case 'Personal':
        return Icons.person;

      default:
        return Icons.lock;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      elevation: 1,

      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [

              // ÍCONO
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Icon(
                  _obtenerIcono(),

                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer,

                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // INFORMACIÓN
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      password.servicio,

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      password.usuario,

                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),

                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,

                        borderRadius:
                            BorderRadius.circular(8),
                      ),

                      child: Text(
                        password.categoria,

                        style: TextStyle(
                          fontSize: 11,

                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}