import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'styles.dart';
import 'logic.dart';
import 'models.dart';
import 'widgets/glass_context_menu.dart';
import 'widgets/glass_dialogs.dart';
import 'themes/season_data.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool isEditing;
  final double stormIntensity;
  const GlassCard(
      {super.key,
      required this.child,
      this.isEditing = false,
      this.stormIntensity = 0.0});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final isDark = appData.isDarkMode;
    final seasonTheme = getThemeData(appData.currentTheme);
    final seasonAccent = seasonTheme.accentColor;

    double baseBlur = appData.isHighPerformance ? 25.0 : 2.0;
    double maxBlur = appData.isHighPerformance ? 40.0 : 5.0;
    
    double dynamicBlur = baseBlur + (stormIntensity * (maxBlur - baseBlur));

    Color reactiveBorderColor = isEditing
        ? seasonAccent
        : Color.lerp(Colors.white.withValues(alpha: 0.1),
            seasonAccent.withValues(alpha: 0.5), stormIntensity)!;

    double borderWidth = isEditing ? 2.0 : (1.0 + stormIntensity);
    
    bool isHalloween = appData.currentTheme == ThemeType.halloween;
    bool isChristmas = appData.currentTheme == ThemeType.christmas;

    BoxDecoration decoration = appData.isHighPerformance 
        ? AppStyles.glassDecorationNoShadow(isDark)
        : AppStyles.glassDecorationMobile(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: AppStyles.glassShadow(isDark),
        border: Border.all(color: reactiveBorderColor, width: borderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: dynamicBlur, sigmaY: dynamicBlur),
          child: Stack(
            children: [
              Container(
                decoration: decoration,
                padding: const EdgeInsets.all(30),
                child: child,
              ),
              if (isHalloween)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: SpiderWebPainter(),
                    ),
                  ),
                ),
              if (isChristmas)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: ChristmasLightsPainter(borderRadius: 35),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpiderWebPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _drawWeb(canvas, paint, Offset(size.width, 0), -1, 1);
    _drawWeb(canvas, paint, Offset(0, size.height), 1, -1);
  }

  void _drawWeb(Canvas canvas, Paint paint, Offset corner, double dirX, double dirY) {
    double size = 80; 
    
    canvas.drawLine(corner, corner + Offset(size * dirX, 0), paint);
    canvas.drawLine(corner, corner + Offset(0, size * dirY), paint);
    canvas.drawLine(corner, corner + Offset(size * 0.7 * dirX, size * 0.7 * dirY), paint);
    canvas.drawLine(corner, corner + Offset(size * 0.9 * dirX, size * 0.35 * dirY), paint);
    canvas.drawLine(corner, corner + Offset(size * 0.35 * dirX, size * 0.9 * dirY), paint);

    for (int i = 1; i <= 3; i++) {
      double f = i * 0.25; 
      Path web = Path();
      web.moveTo(corner.dx + (size * f * dirX), corner.dy);
      web.quadraticBezierTo(
          corner.dx + (size * f * 0.9 * dirX), corner.dy + (size * f * 0.1 * dirY), 
          corner.dx + (size * f * 0.9 * dirX), corner.dy + (size * f * 0.35 * dirY));
      web.quadraticBezierTo(
          corner.dx + (size * f * 0.8 * dirX), corner.dy + (size * f * 0.6 * dirY),
          corner.dx + (size * f * 0.7 * dirX), corner.dy + (size * f * 0.7 * dirY));
       web.quadraticBezierTo(
          corner.dx + (size * f * 0.5 * dirX), corner.dy + (size * f * 0.85 * dirY),
          corner.dx + (size * f * 0.35 * dirX), corner.dy + (size * f * 0.9 * dirY));
      web.quadraticBezierTo(
          corner.dx + (size * f * 0.1 * dirX), corner.dy + (size * f * 0.9 * dirY),
          corner.dx, corner.dy + (size * f * dirY));
      canvas.drawPath(web, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChristmasLightsPainter extends CustomPainter {
  final double borderRadius;
  ChristmasLightsPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFF5252), 
      const Color(0xFF69F0AE), 
      const Color(0xFFFFD740), 
      const Color(0xFF448AFF) 
    ];
    
    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(borderRadius)));

    double spacing = 25.0; 
    
    final wirePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, wirePaint);

    for (PathMetric metric in path.computeMetrics()) {
      for (double i = 0; i < metric.length; i += spacing) {
        Tangent? tangent = metric.getTangentForOffset(i);
        if (tangent != null) {
          int colorIndex = (i / spacing).round() % colors.length;
          Color lightColor = colors[colorIndex];

          final glowPaint = Paint()
            ..color = lightColor.withValues(alpha: 0.6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
          canvas.drawCircle(tangent.position, 6.0, glowPaint);

          final bulbPaint = Paint()..color = lightColor;
          canvas.drawCircle(tangent.position, 3.0, bulbPaint);
        }
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AeroTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool isPercentage;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const AeroTextField(
      {super.key,
      required this.controller,
      this.hint = '',
      this.maxLines = 1,
      this.isPercentage = false,
      this.readOnly = false,
      this.onTap,
      this.prefixIcon,
      this.onChanged});

  @override
  State<AeroTextField> createState() => _AeroTextFieldState();
}

class _AeroTextFieldState extends State<AeroTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _shadowSpreadAnim;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutBack));
    _shadowSpreadAnim = Tween<double>(begin: 0.0, end: 6.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final isDark = appData.isDarkMode;
    final seasonAccent = getThemeData(appData.currentTheme).accentColor;
    final glowColor = seasonAccent.withValues(alpha: 0.5);
    final borderColor = _focusNode.hasFocus
        ? seasonAccent
        : Colors.white.withValues(alpha: isDark ? 0.2 : 0.6);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: borderColor, width: _focusNode.hasFocus ? 2.0 : 1.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
                if (_shadowSpreadAnim.value > 0 && appData.isHighPerformance)
                  BoxShadow(
                      color: glowColor,
                      blurRadius: 16,
                      spreadRadius: _shadowSpreadAnim.value)
              ],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.1 : 0.7),
                  Colors.white.withValues(alpha: isDark ? 0.0 : 0.1)
                ],
                stops: const [0.0, 0.5],
              ),
            ),
            padding: EdgeInsets.symmetric(
                horizontal: 16, vertical: widget.maxLines > 1 ? 16 : 4),
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              cursorColor: seasonAccent,
              contextMenuBuilder: (context, editableTextState) {
                return GlassContextMenu(
                  editableTextState: editableTextState,
                  isDark: isDark,
                );
              },
              style: TextStyle(color: AppStyles.getText(isDark)),
              keyboardType: widget.isPercentage
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.multiline,
              inputFormatters: widget.isPercentage
                  ? [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+[\.,]?\d{0,2}')),
                      LengthLimitingTextInputFormatter(5)
                    ]
                  : [],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hint,
                prefixIcon: widget.prefixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                            color: _focusNode.hasFocus
                                ? seasonAccent
                                : AppStyles.getText(isDark)
                                    .withValues(alpha: 0.5)),
                        child: widget.prefixIcon!)
                    : null,
                hintStyle: TextStyle(
                    color: AppStyles.getText(isDark).withValues(alpha: 0.6)),
                suffixText: widget.isPercentage ? '%' : null,
                contentPadding: widget.maxLines == 1
                    ? const EdgeInsets.symmetric(vertical: 12)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class RubberBandButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color? color;
  final Color? textColor;
  final bool isDashed;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const RubberBandButton(
      {super.key,
      required this.onTap,
      required this.child,
      this.color,
      this.textColor,
      this.isDashed = false,
      this.borderRadius = 20,
      this.padding});

  @override
  State<RubberBandButton> createState() => _RubberBandButtonState();
}

class _RubberBandButtonState extends State<RubberBandButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
  late AnimationController _flashController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
        reverseCurve: Curves.elasticOut));
    _flashController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
  }

  void _triggerFlash() {
    _flashController.reset();
    _flashController.forward();
  }

  @override
  void dispose() {
    _pressController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _triggerFlash();
      },
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          _triggerFlash();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnim, _flashController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Stack(
                children: [
                  widget.isDashed
                      ? _buildSolidAccentBackground()
                      : _buildSolidBackground(),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      child: CustomPaint(
                          painter: _FlashPainter(_flashController.value)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSolidBackground() {
    return Container(
      padding: widget.padding ??
          const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: widget.color ?? Colors.white.withValues(alpha: 0.2),
        border: Border.all(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.3),
            width: _isHovered ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
              color: (widget.color ?? Colors.black).withValues(alpha: 0.3),
              blurRadius: _isHovered ? 20 : 15,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 5)),
          if (_isHovered)
            BoxShadow(
                color: (widget.color ?? Colors.white).withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 2)
        ],
      ),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
              color: widget.textColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildSolidAccentBackground() {
    final appData = Provider.of<AppData>(context);
    final isDark = appData.isDarkMode;
    final seasonAccent = getThemeData(appData.currentTheme).accentColor;

    final textColor =
        isDark ? seasonAccent : Color.lerp(seasonAccent, Colors.black, 0.4)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          color: seasonAccent.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
              color: seasonAccent.withValues(alpha: _isHovered ? 1.0 : 0.8),
              width: 2.0),
          boxShadow: [
            BoxShadow(
                color: seasonAccent.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.5,
            shadows: _isHovered
                ? [Shadow(color: seasonAccent, blurRadius: 8)]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _FlashPainter extends CustomPainter {
  final double value;
  _FlashPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    if (value <= 0 || value >= 1) return;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0)
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(0.5),
      ).createShader(Rect.fromLTWH((size.width * 2 * value) - size.width,
          -size.height, size.width, size.height * 3));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_FlashPainter old) => old.value != value;
}

class CloudBubble extends StatelessWidget {
  final String label;
  final String text;
  const CloudBubble({super.key, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final isDark = appData.isDarkMode;
    final seasonAccent = getThemeData(appData.currentTheme).accentColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12, left: 5, right: 5),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05)
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.8)
                ],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: seasonAccent.withValues(alpha: isDark ? 0.15 : 0.2),
            blurRadius: 15,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              spreadRadius: -2,
              offset: const Offset(-2, -2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: seasonAccent,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: AppStyles.getText(isDark).withValues(alpha: 0.95),
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryEntryCard extends StatelessWidget {
  final Entry entry;
  final AppData appData;
  const HistoryEntryCard(
      {super.key, required this.entry, required this.appData});

  @override
  Widget build(BuildContext context) {
    final isDark = appData.isDarkMode;
    final textColor = AppStyles.getText(isDark);
    final seasonAccent = getThemeData(appData.currentTheme).accentColor;
    final bool isBeingEdited = appData.currentEditingEntry?.id == entry.id;

    String? editedText;
    if ((entry.lastEdited ?? "").isNotEmpty) {
      try {
        final editedDate = DateTime.parse(entry.lastEdited!);
        editedText = DateFormat('dd/MM/yyyy HH:mm', appData.locale.toString())
            .format(editedDate);
      } catch (e) {}
    }

    // OTIMIZAÇÃO: Blur reduzido para histórico
    double blurAmount = appData.isHighPerformance ? 25.0 : 2.0;
    BoxDecoration decoration = appData.isHighPerformance 
        ? AppStyles.glassDecorationNoShadow(isDark)
        : AppStyles.glassDecorationMobile(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: AppStyles.glassShadow(isDark),
        border:
            isBeingEdited ? Border.all(color: seasonAccent, width: 2) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            decoration: decoration,
            padding: const EdgeInsets.all(30),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: seasonAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.calendar_today_rounded,
                              size: 16, color: seasonAccent),
                        ),
                        const SizedBox(width: 10),
                        Text(entry.dateTime,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: seasonAccent)),
                      ]),
                      if (editedText != null && editedText != entry.dateTime)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 42),
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 12,
                                  color: textColor.withValues(alpha: 0.5)),
                              const SizedBox(width: 4),
                              Text(
                                "${appData.t('edited_on')}: $editedText",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: textColor.withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      _buildSectionBox(
                          appData.t('situation').toUpperCase(),
                          Text(entry.situation,
                              style: TextStyle(color: textColor)),
                          isDark,
                          seasonAccent),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildSectionBox(
                                    appData.t('auto_thoughts').toUpperCase(),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: entry.thoughts
                                            .map((t) => Text(
                                                "• ${t.text} (${t.percentage}%)",
                                                style: TextStyle(
                                                    color: textColor,
                                                    height: 1.5)))
                                            .toList()),
                                    isDark,
                                    seasonAccent)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildSectionBox(
                                    appData.t('initial_emotions').toUpperCase(),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: entry.emotions
                                            .map((e) => Text(
                                                "${e.text} (${e.percentage}%)",
                                                style: TextStyle(
                                                    color: textColor,
                                                    height: 1.5)))
                                            .toList()),
                                    isDark,
                                    seasonAccent))
                          ]),
                      if (entry.conclusions.any((c) => c.text.isNotEmpty))
                        _buildSectionBox(
                            appData.t('rational_response').toUpperCase(),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: entry.conclusions
                                    .where((c) => c.text.isNotEmpty)
                                    .map((c) => Text(
                                        "• ${c.text} (${c.percentage}%)",
                                        style: TextStyle(
                                            color: textColor, height: 1.5)))
                                    .toList()),
                            isDark,
                            seasonAccent),
                      if (entry.results.any((r) => r.text.isNotEmpty) ||
                          entry.newEmotions.any((e) => e.percentage.isNotEmpty))
                        _buildSectionBox(
                            appData.t('reevaluation').toUpperCase(),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...entry.results.map((r) => Text(
                                      "• ${appData.t('thought')}: ${r.text} (${r.percentage}%)",
                                      style: TextStyle(
                                          color: textColor, height: 1.5))),
                                  const SizedBox(height: 5),
                                  ...entry.newEmotions.map((e) => Text(
                                      "• ${appData.t('emotion')}: ${e.text} (${e.percentage}%)",
                                      style: TextStyle(
                                          color: textColor, height: 1.5)))
                                ]),
                            isDark,
                            seasonAccent),
                      if (entry.action.isNotEmpty)
                        _buildSectionBox(
                            appData.t('action_plan').toUpperCase(),
                            Text(entry.action,
                                style: TextStyle(color: textColor)),
                            isDark,
                            seasonAccent),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Column(
                    children: [
                      _buildActionBtn(Icons.edit_rounded, Colors.amber,
                          () => appData.loadEntryToEdit(entry)),
                      const SizedBox(height: 10),
                      _buildActionBtn(Icons.description_rounded, Colors.blue,
                          () => appData.exportSingleTxt(entry)),
                      const SizedBox(height: 10),
                      _buildActionBtn(Icons.close_rounded, Colors.redAccent,
                          () async {
                        bool confirm = await showGlassConfirm(
                            context,
                            appData.t('confirm_delete_title'),
                            appData.t('confirm_delete_msg'),
                            isDark,
                            appData);
                        if (confirm) {
                          appData.deleteEntry(entry.id);
                        }
                      }),
                    ],
                  ),
                ),
                if (isBeingEdited)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.3),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: seasonAccent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text("Editando...",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionBox(
      String title, Widget content, bool isDark, Color accent) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? accent.withValues(alpha: 0.9)
                      : Color.lerp(accent, Colors.black, 0.3),
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 40,
      height: 40,
      child: RubberBandButton(
        onTap: onTap,
        color: color.withValues(alpha: 0.2),
        borderRadius: 50,
        padding: EdgeInsets.zero,
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}