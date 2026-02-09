import 'dart:ui';
import 'package:flutter/material.dart';
import '../logic.dart';
import '../styles.dart';
import '../components.dart';
import '../themes/season_data.dart';

class GlassSettingsMenu extends StatefulWidget {
  final AppData appData;
  const GlassSettingsMenu({super.key, required this.appData});

  @override
  State<GlassSettingsMenu> createState() => _GlassSettingsMenuState();
}

class _GlassSettingsMenuState extends State<GlassSettingsMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  void _closeMenu() {
    _controller.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _selectTheme(ThemeType type) {
    widget.appData.setThemeType(type);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appData,
      builder: (context, _) {
        final isDark = widget.appData.isDarkMode;
        final textColor = AppStyles.getText(isDark);
        final seasonTheme = getThemeData(widget.appData.currentTheme);
        final accentColor = seasonTheme.accentColor;
        final size = MediaQuery.of(context).size;

        return Stack(
          children: [
            GestureDetector(
              onTap: _closeMenu,
              child: Container(color: Colors.transparent),
            ),
            // CORREÇÃO 1: Usar Positioned ao invés de Center para alinhar ao topo direito
            Positioned(
              top: 80, // Abaixo do botão de configurações
              right: 20, // Alinhado à direita
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 300,
                    constraints: BoxConstraints(maxHeight: size.height * 0.8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: AppStyles.glassShadow(isDark),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          decoration: AppStyles.glassDecorationNoShadow(isDark),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.appData.t('settings'),
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _closeMenu,
                                      child: Icon(Icons.close_rounded,
                                          color:
                                              textColor.withValues(alpha: 0.5),
                                          size: 20),
                                    )
                                  ],
                                ),
                              ),


                              Flexible(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildMenuRow(
                                        icon: isDark
                                            ? Icons.dark_mode_rounded
                                            : Icons.light_mode_rounded,
                                        label: widget.appData.t('dark_mode'),
                                        trailing: Transform.scale(
                                          scale: 0.8,
                                          child: Switch(
                                            value: isDark,
                                            onChanged: (val) {
                                              widget.appData.toggleTheme(val
                                                  ? ThemeMode.dark
                                                  : ThemeMode.light);
                                            },
                                            activeTrackColor: accentColor,
                                            activeThumbColor: Colors.white,
                                            inactiveThumbColor: textColor
                                                .withValues(alpha: 0.8),
                                            inactiveTrackColor: textColor
                                                .withValues(alpha: 0.1),
                                            trackOutlineColor:
                                                WidgetStateProperty.all(
                                                    Colors.transparent),
                                          ),
                                        ),
                                        isDark: isDark,
                                        accentColor: accentColor,
                                        onTap: () => widget.appData.toggleTheme(
                                            isDark
                                                ? ThemeMode.light
                                                : ThemeMode.dark),
                                      ),

                                      const SizedBox(height: 10),

                                      _buildMenuRow(
                                        icon: Icons.translate_rounded,
                                        label: widget.appData.t('language'),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.1)
                                                : Colors.black
                                                    .withValues(alpha: 0.03),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: textColor.withValues(
                                                    alpha: 0.05)),
                                          ),
                                          child: Text(
                                            widget.appData.locale
                                                        .languageCode ==
                                                    'pt'
                                                ? '🇧🇷 PT'
                                                : '🇺🇸 EN',
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        isDark: isDark,
                                        accentColor: accentColor,
                                        onTap: widget.appData.toggleLanguage,
                                      ),

                                      const SizedBox(height: 15),
                                      _buildDivider(textColor),
                                      const SizedBox(height: 15),


                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, bottom: 10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.palette_rounded,
                                                size: 16,
                                                color: accentColor.withValues(
                                                    alpha: 0.8)),
                                            const SizedBox(width: 8),
                                            Text(
                                              widget.appData
                                                  .t('theme_menu')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: textColor.withValues(
                                                    alpha: 0.6),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // LISTA DE TEMAS
                                      ...ThemeType.values.map((type) {
                                        final themeData = getThemeData(type);
                                        final isSelected =
                                            widget.appData.currentTheme == type;

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: _buildThemeItem(
                                            label: widget.appData
                                                .t(themeData.nameKey),
                                            isSelected: isSelected,
                                            isDark: isDark,
                                            themeAccent: themeData.accentColor,
                                            onTap: () => _selectTheme(type),
                                          ),
                                        );
                                      }),

                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      height: 1,
      color: color.withValues(alpha: 0.05),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String label,
    required Widget trailing,
    required bool isDark,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final Color rowColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.5);

    return RubberBandButton(
      onTap: onTap,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: rowColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppStyles.getText(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // Widget específico para os itens da lista de temas
  Widget _buildThemeItem({
    required String label,
    required bool isSelected,
    required bool isDark,
    required Color themeAccent,
    required VoidCallback onTap,
  }) {
    final backgroundColor = isSelected
        ? themeAccent.withValues(alpha: isDark ? 0.2 : 0.15)
        : (isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.white.withValues(alpha: 0.3));

    final borderColor =
        isSelected ? themeAccent.withValues(alpha: 0.5) : Colors.transparent;

    final textColor = isSelected
        ? (isDark ? themeAccent : Color.lerp(themeAccent, Colors.black, 0.4)!)
        : AppStyles.getText(isDark).withValues(alpha: 0.7);

    return RubberBandButton(
      onTap: onTap,
      borderRadius: 14,
      // CORREÇÃO 2: Reduzi o padding externo para dar espaço ao Container interno
      padding: const EdgeInsets.all(4),
      color: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          // CORREÇÃO 3: Borda mais grossa (3.0) para ficar "maior" e visível
          border: Border.all(color: borderColor, width: 3.0),
          borderRadius: BorderRadius.circular(14),
        ),
        // CORREÇÃO 4: Padding interno para afastar a borda do texto
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: themeAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: themeAccent.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1)
                  ]),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: textColor, size: 18),
          ],
        ),
      ),
    );
  }
}

void showGlassSettingsMenu(BuildContext context, AppData appData) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return GlassSettingsMenu(appData: appData);
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );
}
