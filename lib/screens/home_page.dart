import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../styles.dart';
import '../background.dart';
import '../components.dart';
import '../logic.dart';
import '../models.dart';
import '../widgets/glass_dialogs.dart';
import '../widgets/glass_settings_menu.dart';
import '../themes/season_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _pickGlassDateTime(BuildContext context, AppData appData) async {
    final now = DateTime.now();
    final isDark = appData.isDarkMode;
    final textColor = AppStyles.getText(isDark);

    final DateTime? pickedDate = await showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return GlassDatePickerDialog(
            initialDate: now,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            isDark: isDark,
            textColor: textColor,
            helpText: appData.t('date_picker_help'),
            appData: appData);
      },
      transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child)),
    );

    if (pickedDate == null) return;
    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showGeneralDialog<TimeOfDay>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return GlassTimePickerDialog(
            initialTime: TimeOfDay.now(),
            isDark: isDark,
            textColor: textColor,
            helpText: appData.t('time_picker_help'),
            appData: appData);
      },
      transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child)),
    );

    if (pickedTime == null) return;

    final DateTime finalDateTime = DateTime(pickedDate.year, pickedDate.month,
        pickedDate.day, pickedTime.hour, pickedTime.minute);
    appData.dateCtrl.text =
        DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final isDark = appData.isDarkMode;
    final textColor = AppStyles.getText(isDark);

    final seasonTheme = getThemeData(appData.currentTheme);
    final accentColor = seasonTheme.accentColor;
    final intensity = appData.stormIntensity;

    final bool isEditing = appData.currentEditingEntry != null;
    final bool isHalloween = appData.currentTheme == ThemeType.halloween;
    final bool isChristmas = appData.currentTheme == ThemeType.christmas;

    final List<Widget> listItems = _buildListItems(
        context, appData, isDark, textColor, accentColor, intensity, isEditing);

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false, 
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CloudBackground(
                  isDarkMode: isDark,
                  stormIntensity: intensity,
                  currentTheme: seasonTheme,
                  isHighPerformance: appData.isHighPerformance,
                ),
              ),
            ),

            if (isHalloween)
              Positioned(
                bottom: 20,
                left: 20,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.9,
                    child: CustomPaint(
                      size: const Size(60, 60),
                      painter: _PumpkinPainter(),
                    ),
                  ),
                ),
              ),

            Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              extendBody: true,
              extendBodyBehindAppBar: true,
              
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: SafeArea(
                    bottom: false, 
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(
                              left: 20, 
                              right: 20, 
                              top: 10,
                              bottom: bottomPadding + 100 
                            ),
                            itemCount: listItems.length,
                            itemBuilder: (context, index) {
                              return RepaintBoundary(
                                child: listItems[index],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 30,
              right: 20,
              child: SafeArea(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30), 
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: isDark 
                          ? Colors.black.withValues(alpha: 0.2) 
                          : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.0
                        )
                      ),
                      child: RubberBandButton(
                        onTap: () => showGlassSettingsMenu(context, appData),
                        borderRadius: 30,
                        padding: EdgeInsets.zero,
                        color: Colors.transparent, 
                        child: Icon(Icons.settings_rounded, color: textColor, size: 22),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildListItems(
    BuildContext context,
    AppData appData,
    bool isDark,
    Color textColor,
    Color accentColor,
    double intensity,
    bool isEditing,
  ) {
    final bool isHalloween = appData.currentTheme == ThemeType.halloween;
    final bool isChristmas = appData.currentTheme == ThemeType.christmas;

    return [
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 25),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: AppStyles.glassShadow(isDark),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          decoration:
                              AppStyles.glassDecorationNoShadow(isDark),
                          child: Text(
                            appData.t('app_title'),
                            style: AppStyles.titleStyle.copyWith(
                                color: textColor, fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
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
                                painter: ChristmasLightsPainter(borderRadius: 50),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isChristmas)
                Positioned(
                  right: -15,
                  top: -10,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: _HollyBranchPainter(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      GlassCard(
          stormIntensity: intensity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.lightbulb_rounded,
                      color: accentColor, size: 24),
                  const SizedBox(width: 10),
                  Text(appData.t('how_to_use'),
                      style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0))
                ]),
                const SizedBox(height: 10),
                Text(appData.t('how_to_use_desc'),
                    style: TextStyle(
                        color: textColor,
                        height: 1.5,
                        fontSize: 15))
              ])),

      GlassCard(
          stormIntensity: intensity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.help_outline_rounded,
                      color: accentColor, size: 24),
                  const SizedBox(width: 10),
                  Text(appData.t('helper_questions'),
                      style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0))
                ]),
                const SizedBox(height: 15),
                _buildQuestionItem(appData.t('q1'), textColor),
                _buildQuestionItem(appData.t('q2'), textColor),
                _buildQuestionItem(appData.t('q3'), textColor),
                _buildQuestionItem(appData.t('q4'), textColor)
              ])),


      GlassCard(
          stormIntensity: intensity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📅 ${appData.t('situation')}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor)),
                const SizedBox(height: 15),
                Text(appData.t('date_time')),
                const SizedBox(height: 5),
                AeroTextField(
                    controller: appData.dateCtrl,
                    readOnly: true,
                    onTap: () => _pickGlassDateTime(context, appData),
                    prefixIcon: Icon(
                        Icons.calendar_month_rounded,
                        color: textColor.withValues(alpha: 0.5))),
                const SizedBox(height: 15),
                Text(appData.t('what_happened')),
                const SizedBox(height: 5),
                AeroTextField(
                    controller: appData.situationCtrl,
                    maxLines: 3,
                    hint: appData.t('describe_moment'))
              ])),


      GlassCard(
          stormIntensity: intensity,
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("💭 ${appData.t('auto_thoughts')}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: accentColor))
                ]),
            const SizedBox(height: 15),
            ...List.generate(
                appData.thoughtCtrls.length,
                (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: AeroTextField(
                                  controller: appData.thoughtCtrls[i],
                                  hint: appData.t('thought_hint'),
                                  maxLines: 2,
                                  onChanged: (_) => appData.refreshUI())),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: 75,
                              child: AeroTextField(
                                  controller: appData.thoughtPercCtrls[i],
                                  isPercentage: true)),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: 45,
                              height: 45,
                              child: RubberBandButton(
                                  onTap: () => appData.removeThought(i),
                                  color: Colors.redAccent
                                      .withValues(alpha: 0.15),
                                  borderRadius: 12,
                                  padding: EdgeInsets.zero,
                                  child: const Icon(Icons.close_rounded,
                                      color: Colors.redAccent, size: 22)))
                        ]))),
            RubberBandButton(
                isDashed: true,
                onTap: appData.addThought,
                child: Text(appData.t('add_thought')))
          ])),


      GlassCard(
          stormIntensity: intensity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("😢 ${appData.t('initial_emotions')}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor)),
                const SizedBox(height: 15),
                ...List.generate(
                    appData.emotionCtrls.length,
                    (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(children: [
                          Expanded(
                              child: AeroTextField(
                                  controller: appData.emotionCtrls[i],
                                  hint: appData.t('emotion_hint'),
                                  onChanged: (val) => appData.refreshUI())),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: 75,
                              child: AeroTextField(
                                  controller: appData.emotionPercCtrls[i],
                                  isPercentage: true)),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: 45,
                              height: 45,
                              child: RubberBandButton(
                                  onTap: () => appData.removeEmotion(i),
                                  color: Colors.redAccent
                                      .withValues(alpha: 0.15),
                                  borderRadius: 12,
                                  padding: EdgeInsets.zero,
                                  child: const Icon(Icons.close_rounded,
                                      color: Colors.redAccent, size: 22)))
                        ]))),
                RubberBandButton(
                    isDashed: true,
                    onTap: appData.addEmotion,
                    child: Text(appData.t('add_emotion')))
              ])),


      GlassCard(
          stormIntensity: intensity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("💡 ${appData.t('rational_response')}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor)),
                const SizedBox(height: 20),
                ...List.generate(appData.thoughtCtrls.length, (i) {
                  if (appData.thoughtCtrls[i].text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final perc = appData.thoughtPercCtrls[i].text.isEmpty
                      ? '?'
                      : appData.thoughtPercCtrls[i].text;
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CloudBubble(
                            label:
                                "${appData.t('thought').toUpperCase()} #${i + 1} ($perc%)",
                            text: appData.thoughtCtrls[i].text),
                        Padding(
                            padding: const EdgeInsets.only(left: 40, bottom: 5),
                            child: Column(children: [
                              _buildDot(12, isDark),
                              _buildDot(8, isDark),
                              _buildDot(5, isDark)
                            ])),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: AeroTextField(
                                      controller: appData.conclusionCtrls[i],
                                      hint: appData.t('response_hint'),
                                      maxLines: 3)),
                              const SizedBox(width: 10),
                              Container(
                                  width: 80,
                                  height: 80,
                                  alignment: Alignment.topCenter,
                                  child: AeroTextField(
                                      controller:
                                          appData.conclusionPercCtrls[i],
                                      isPercentage: true))
                            ]),
                        const Divider(height: 40, color: Colors.transparent)
                      ]);
                })
              ])),


      GlassCard(
          stormIntensity: intensity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("✅ ${appData.t('reevaluation')}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor)),
                const SizedBox(height: 20),
                ...List.generate(appData.thoughtCtrls.length, (i) {
                  if (appData.thoughtCtrls[i].text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final perc = appData.thoughtPercCtrls[i].text.isEmpty
                      ? '?'
                      : appData.thoughtPercCtrls[i].text;
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CloudBubble(
                            label:
                                "${appData.t('original_thought')} #${i + 1} ($perc%)",
                            text: appData.thoughtCtrls[i].text),
                        Padding(
                            padding: const EdgeInsets.only(left: 40, bottom: 5),
                            child: Column(children: [
                              _buildDot(10, isDark),
                              _buildDot(6, isDark)
                            ])),
                        Row(children: [
                          Expanded(
                              flex: 2,
                              child: AeroTextField(
                                  controller: appData.resultCtrls[i],
                                  hint: appData.t('new_belief'))),
                          const SizedBox(width: 10),
                          SizedBox(
                              width: 70,
                              child: AeroTextField(
                                  controller: appData.resultPercCtrls[i],
                                  isPercentage: true))
                        ]),
                        const SizedBox(height: 30)
                      ]);
                }),
                const Divider(height: 30, thickness: 1),
                if (appData.emotionCtrls.any((c) => c.text.isNotEmpty))
                  Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(appData.t('how_feel_now'),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor.withValues(alpha: 0.9)))),
                ...List.generate(appData.emotionCtrls.length, (i) {
                  if (appData.emotionCtrls[i].text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final oldEmotion = appData.emotionCtrls[i].text;
                  final oldPerc = appData.emotionPercCtrls[i].text.isEmpty
                      ? '?'
                      : appData.emotionPercCtrls[i].text;
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CloudBubble(
                                label:
                                    "${appData.t('initial_emotion')} ($oldPerc%)",
                                text: oldEmotion),
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, bottom: 5),
                                child: Column(children: [
                                  _buildDot(10, isDark),
                                  _buildDot(6, isDark)
                                ])),
                            Row(children: [
                              Expanded(
                                  child: AeroTextField(
                                      controller: appData.newEmotionCtrls[i],
                                      hint: appData.t('new_intensity'))),
                              const SizedBox(width: 10),
                              SizedBox(
                                  width: 70,
                                  child: AeroTextField(
                                      controller:
                                          appData.newEmotionPercCtrls[i],
                                      isPercentage: true))
                            ]),
                          ]));
                }),
                const SizedBox(height: 20),
                Text(appData.t('action_plan')),
                const SizedBox(height: 5),
                AeroTextField(
                    controller: appData.actionCtrl,
                    maxLines: 2,
                    hint: appData.t('next_steps'))
              ])),


      Column(children: [
        SizedBox(
            width: double.infinity,
            child: RubberBandButton(
                color: const Color(0xFF10B981).withValues(alpha: 0.8),
                onTap: () {
                  if (appData.saveEntry()) {
                    showGlassAlert(
                        context,
                        isEditing
                            ? appData.t('alert_updated_title')
                            : appData.t('alert_saved_title'),
                        isEditing
                            ? appData.t('alert_updated_msg')
                            : appData.t('alert_saved_msg'),
                        isDark,
                        appData);
                  } else {
                    showGlassAlert(context, appData.t('alert_error_title'),
                        appData.t('alert_error_msg'), isDark, appData,
                        isError: true);
                  }
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(isEditing
                          ? appData.t('update_record')
                          : appData.t('save_record'))
                    ]))),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(
              child: RubberBandButton(
                  color: const Color(0xFFD97706).withValues(alpha: 0.8),
                  onTap: () {
                    if (appData.entries.isEmpty) {
                      showGlassAlert(
                          context,
                          appData.t('alert_empty_title'),
                          appData.t('alert_empty_msg'),
                          isDark,
                          appData);
                    } else {
                      appData.exportAllTxt();
                    }
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_open_rounded,
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Text(appData.t('export_all'))
                      ]))),
          const SizedBox(width: 15),
          Expanded(
              child: RubberBandButton(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                  onTap: () async {
                    if (await showGlassConfirm(
                        context,
                        appData.t('confirm_clear_title'),
                        appData.t('confirm_clear_msg'),
                        isDark,
                        appData)) {
                      appData.clearForm();
                    }
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_outline_rounded,
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Text(appData.t('clear'))
                      ]))),
        ])
      ]),

      const SizedBox(height: 40),


      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(appData.t('history'),
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor)),
        Row(children: [
          SizedBox(
              width: 110,
              height: 40,
              child: RubberBandButton(
                  onTap: () {
                    if (appData.entries.isEmpty) {
                      showGlassAlert(context, appData.t('alert_empty_title'),
                          appData.t('alert_backup_empty'), isDark, appData);
                    } else {
                      appData.exportBackup();
                    }
                  },
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  borderRadius: 12,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_rounded, size: 16),
                        const SizedBox(width: 5),
                        Text(appData.t('backup'),
                            style: const TextStyle(fontSize: 13))
                      ]))),
          const SizedBox(width: 10),
          SizedBox(
              width: 120,
              height: 40,
              child: RubberBandButton(
                  onTap: () async {
                    bool success = await appData.importBackup();
                    if (context.mounted) {
                      if (success) {
                        showGlassAlert(
                            context,
                            appData.t('alert_restore_title'),
                            appData.t('alert_restore_msg'),
                            isDark,
                            appData);
                      }
                    }
                  },
                  color: Colors.orangeAccent.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  borderRadius: 12,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restore_rounded, size: 16),
                        const SizedBox(width: 5),
                        Text(appData.t('restore'),
                            style: const TextStyle(fontSize: 13))
                      ]))),
        ])
      ]),
      const Divider(),

      if (appData.entries.isEmpty)
        Center(
            child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(appData.t('empty_sky'),
                    style: TextStyle(
                        color: textColor.withValues(alpha: 0.5),
                        fontSize: 16)))),

      ...appData.entries.map((entry) => HistoryEntryCard(
            entry: entry, 
            appData: appData
          )),
      
      const SizedBox(height: 80),
    ];
  }

  Widget _buildQuestionItem(String text, Color textColor) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("• ",
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
              child: Text(text,
                  style:
                      TextStyle(color: textColor, fontSize: 14, height: 1.4)))
        ]));
  }

  Widget _buildDot(double size, bool isDark) {
    return Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(bottom: 4, left: 4),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.4),
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.3), width: 1)));
  }
}

// Painter para a Abóbora (Jack-o'-lantern Redondinha)
class _PumpkinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBody = Paint()..color = const Color(0xFFE65100);
    final paintStem = Paint()..color = const Color(0xFF2E7D32);
    final paintFace = Paint()..color = const Color(0xFF3E2723).withValues(alpha: 0.8);
    
    Rect bodyRect = Rect.fromLTWH(0, size.height * 0.15, size.width, size.height * 0.85);
    canvas.drawOval(bodyRect, paintBody);
    canvas.drawOval(bodyRect.deflate(size.width * 0.15), paintBody..color = const Color(0xFFF57C00));
    canvas.drawOval(bodyRect.deflate(size.width * 0.35), paintBody..color = const Color(0xFFFF9800));
    
    canvas.drawRect(Rect.fromLTWH(size.width * 0.45, 0, size.width * 0.1, size.height * 0.25), paintStem);

    Path leftEye = Path()
      ..moveTo(size.width * 0.3, size.height * 0.45)
      ..lineTo(size.width * 0.4, size.height * 0.55)
      ..lineTo(size.width * 0.2, size.height * 0.55)
      ..close();
    canvas.drawPath(leftEye, paintFace);

    Path rightEye = Path()
      ..moveTo(size.width * 0.7, size.height * 0.45)
      ..lineTo(size.width * 0.8, size.height * 0.55)
      ..lineTo(size.width * 0.6, size.height * 0.55)
      ..close();
    canvas.drawPath(rightEye, paintFace);

    Path smile = Path()
      ..moveTo(size.width * 0.2, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width * 0.8, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.8, size.width * 0.2, size.height * 0.7)
      ..close();
    canvas.drawPath(smile, paintFace);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter para o Galho de Natal (Static - Header)
class _HollyBranchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLeaf = Paint()..color = const Color(0xFF2E7D32);
    final paintBerry = Paint()..color = const Color(0xFFC62828);
    
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width*0.3, size.height*0.3), width: 20, height: 10), paintLeaf);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width*0.7, size.height*0.3), width: 20, height: 10), paintLeaf);
    
    canvas.drawCircle(Offset(size.width*0.5, size.height*0.5), 4, paintBerry);
    canvas.drawCircle(Offset(size.width*0.4, size.height*0.6), 4, paintBerry);
    canvas.drawCircle(Offset(size.width*0.6, size.height*0.6), 4, paintBerry);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}