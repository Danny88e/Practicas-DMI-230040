import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/config/constants/countries_config.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

/// Modal de selección de país para configurar el idioma de las películas
/// y el sistema de clasificación de edades.
class CountryConfigModal extends ConsumerWidget {
  const CountryConfigModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCountry = ref.watch(selectedCountryProvider);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de arrastre
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          // Título del modal
          Row(
            children: [
              Icon(Icons.public, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Configuración de País',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Selecciona un país para cambiar el idioma de las películas y el sistema de clasificación de edades.',
            style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Lista de países disponibles (5, uno por continente)
          ...CountriesConfig.availableCountries.map((country) {
            final isSelected = selectedCountry == country['code'];
            return _CountryTile(
              flag: country['flag']!,
              code: country['code']!,
              name: country['name']!,
              continent: country['continent']!,
              isSelected: isSelected,
              onTap: () {
                ref.read(selectedCountryProvider.notifier).state = country['code']!;
                Navigator.of(context).pop();
              },
            );
          }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


class _CountryTile extends StatelessWidget {
  final String flag;
  final String code;
  final String name;
  final String continent;
  final bool isSelected;
  final VoidCallback onTap;

  const _CountryTile({
    required this.flag,
    required this.code,
    required this.name,
    required this.continent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? colors.primaryContainer.withOpacity(0.4) : null,
        leading: Text(flag, style: const TextStyle(fontSize: 32)),
        title: Row(
          children: [
            Text(
              '$flag $code',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? colors.primary : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(name, style: textTheme.bodyMedium),
          ],
        ),
        subtitle: Text(
          continent,
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        trailing: isSelected ? Icon(Icons.check_circle, color: colors.primary) : null,
      ),
    );
  }
}


/// Función de utilidad para mostrar el modal de configuración de país
void showCountryConfigModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CountryConfigModal(),
  );
}
