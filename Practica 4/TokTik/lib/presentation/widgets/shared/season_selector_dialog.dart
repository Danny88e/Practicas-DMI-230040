import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/presentation/providers/theme_provider.dart';
import 'package:toktik/presentation/screens/splash/splash_screen.dart';

/// Modal para seleccionar y probar temas estacionales (mecanismo de prueba requerido).
class SeasonSelectorDialog extends StatelessWidget {
  const SeasonSelectorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const SeasonSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentSeason = themeProvider.currentSeason;
    final isAutomatic = themeProvider.isAutomatic;

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.palette_outlined, color: Colors.amber),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mecanismo de Prueba: Temporadas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige una temporada para forzarla en LocalStorage o usa la fecha del sistema:',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 12),
            _SeasonOption(
              title: 'Automático (Fecha del dispositivo)',
              subtitle: 'Oct=Halloween, Dic=Navidad, Feb=San Valentín',
              icon: Icons.calendar_today,
              selected: isAutomatic,
              onTap: () => themeProvider.setSeason(null),
            ),
            const Divider(color: Colors.white12),
            _SeasonOption(
              title: '🎃 Halloween (Octubre)',
              subtitle: 'Naranja calabaza, morado oscuro, audio espeluznante',
              icon: Icons.pest_control_rodent,
              selected: !isAutomatic && currentSeason == AppSeason.halloween,
              onTap: () => themeProvider.setSeason(AppSeason.halloween),
            ),
            _SeasonOption(
              title: '🎄 Navidad (Diciembre)',
              subtitle: 'Rojo navideño, verde pino, audio navideño',
              icon: Icons.ac_unit,
              selected: !isAutomatic && currentSeason == AppSeason.christmas,
              onTap: () => themeProvider.setSeason(AppSeason.christmas),
            ),
            _SeasonOption(
              title: '💝 San Valentín (Febrero)',
              subtitle: 'Rosa vibrante, carmesí y amor',
              icon: Icons.favorite,
              selected: !isAutomatic && currentSeason == AppSeason.valentines,
              onTap: () => themeProvider.setSeason(AppSeason.valentines),
            ),
            _SeasonOption(
              title: '📱 Normal (Todo el año)',
              subtitle: 'Tema oscuro estándar con detalles verdes',
              icon: Icons.phone_android,
              selected: !isAutomatic && currentSeason == AppSeason.normal,
              onTap: () => themeProvider.setSeason(AppSeason.normal),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_circle_fill, size: 20),
                label: const Text('Probar Splash Screen (3s)'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}

class _SeasonOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SeasonOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
          leading: Icon(
            icon,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.white60,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
          trailing: selected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
