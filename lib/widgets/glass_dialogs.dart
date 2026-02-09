import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../logic.dart';
import '../styles.dart';
import '../components.dart';

class GlassDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool isDark;
  final Color textColor;
  final AppData appData;
  final String? helpText;

  const GlassDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.isDark,
    required this.textColor,
    required this.appData,
    this.helpText,
  });

  @override
  State<GlassDatePickerDialog> createState() => _GlassDatePickerDialogState();
}

class _GlassDatePickerDialogState extends State<GlassDatePickerDialog> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.isDark ? Colors.cyanAccent : Colors.blue;
    return Center(
      child: Container(
        width: 320,
        height: 480,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: AppStyles.glassShadow(widget.isDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: AppStyles.glassDecorationNoShadow(widget.isDark),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (widget.helpText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        widget.helpText!.toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: widget.isDark
                            ? const ColorScheme.dark().copyWith(
                                primary: accent, onPrimary: Colors.black)
                            : const ColorScheme.light().copyWith(
                                primary: accent, onPrimary: Colors.white),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                              foregroundColor: widget.textColor),
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: _selectedDate,
                        firstDate: widget.firstDate,
                        lastDate: widget.lastDate,
                        onDateChanged: (date) =>
                            setState(() => _selectedDate = date),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RubberBandButton(
                          onTap: () => Navigator.pop(context),
                          color: Colors.red.withValues(alpha: 0.1),
                          textColor: Colors.redAccent,
                          borderRadius: 15,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(widget.appData.t('cancel').toUpperCase()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RubberBandButton(
                          onTap: () => Navigator.pop(context, _selectedDate),
                          color: accent.withValues(alpha: 0.8),
                          textColor:
                              widget.isDark ? Colors.black : Colors.white,
                          borderRadius: 15,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(widget.appData.t('ok').toUpperCase()),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final bool isDark;
  final Color textColor;
  final AppData appData;
  final String? helpText;

  const GlassTimePickerDialog({
    super.key,
    required this.initialTime,
    required this.isDark,
    required this.textColor,
    required this.appData,
    this.helpText,
  });

  @override
  State<GlassTimePickerDialog> createState() => _GlassTimePickerDialogState();
}

class _GlassTimePickerDialogState extends State<GlassTimePickerDialog> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.isDark ? Colors.cyanAccent : Colors.blue;
    return Center(
      child: Container(
        width: 320,
        height: 380,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: AppStyles.glassShadow(widget.isDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: AppStyles.glassDecorationNoShadow(widget.isDark),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (widget.helpText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 5),
                      child: Text(
                        widget.helpText!.toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  Expanded(
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness:
                            widget.isDark ? Brightness.dark : Brightness.light,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: widget.textColor,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime(2020, 1, 1,
                            _selectedTime.hour, _selectedTime.minute),
                        onDateTimeChanged: (DateTime newDate) {
                          setState(() {
                            _selectedTime = TimeOfDay.fromDateTime(newDate);
                          });
                        },
                        use24hFormat: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: RubberBandButton(
                          onTap: () => Navigator.pop(context),
                          color: Colors.red.withValues(alpha: 0.1),
                          textColor: Colors.redAccent,
                          borderRadius: 15,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(widget.appData.t('cancel').toUpperCase()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RubberBandButton(
                          onTap: () => Navigator.pop(context, _selectedTime),
                          color: accent.withValues(alpha: 0.8),
                          textColor:
                              widget.isDark ? Colors.black : Colors.white,
                          borderRadius: 15,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(widget.appData.t('ok').toUpperCase()),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showGlassAlert(BuildContext context, String title, String msg,
    bool isDark, AppData appData,
    {bool isError = false}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black.withValues(alpha: 0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      final accent = isError
          ? Colors.redAccent
          : (isDark ? Colors.cyanAccent : Colors.blue);
      final textColor = AppStyles.getText(isDark);

      return Center(
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: AppStyles.glassShadow(isDark),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: AppStyles.glassDecorationNoShadow(isDark),
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        isError
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 50,
                        color: accent),
                    const SizedBox(height: 15),
                    Text(title,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(msg,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: textColor.withValues(alpha: 0.8))),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: RubberBandButton(
                        onTap: () => Navigator.pop(context),
                        color: accent.withValues(alpha: 0.2),
                        textColor: accent,
                        borderRadius: 15,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(appData.t('ok').toUpperCase()),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
      scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
      child: FadeTransition(opacity: anim1, child: child),
    ),
  );
}

Future<bool> showGlassConfirm(BuildContext context, String title, String msg,
    bool isDark, AppData appData) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black.withValues(alpha: 0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      final accent = isDark ? Colors.cyanAccent : Colors.blue;
      final textColor = AppStyles.getText(isDark);

      return Center(
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: AppStyles.glassShadow(isDark),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: AppStyles.glassDecorationNoShadow(isDark),
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.help_outline_rounded, size: 50, color: accent),
                    const SizedBox(height: 15),
                    Text(title,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(msg,
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: textColor.withValues(alpha: 0.8))),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: RubberBandButton(
                            onTap: () => Navigator.pop(context, false),
                            color: Colors.red.withValues(alpha: 0.15),
                            textColor: Colors.redAccent,
                            borderRadius: 15,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(appData.t('cancel').toUpperCase()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RubberBandButton(
                            onTap: () => Navigator.pop(context, true),
                            color: accent.withValues(alpha: 0.2),
                            textColor: accent,
                            borderRadius: 15,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(appData.t('confirm').toUpperCase()),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
      scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
      child: FadeTransition(opacity: anim1, child: child),
    ),
  );
  return result ?? false;
}
