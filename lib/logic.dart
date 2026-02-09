import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'themes/season_data.dart';

class AppData with ChangeNotifier {
  List<Entry> entries = [];
  ThemeMode themeMode = ThemeMode.system;
  Locale locale = const Locale('pt', 'BR');

  ThemeType currentTheme = ThemeType.defaultTheme;

  TextEditingController dateCtrl = TextEditingController();
  TextEditingController situationCtrl = TextEditingController();

  List<TextEditingController> thoughtCtrls = [TextEditingController()];
  List<TextEditingController> thoughtPercCtrls = [TextEditingController()];
  List<TextEditingController> emotionCtrls = [TextEditingController()];
  List<TextEditingController> emotionPercCtrls = [TextEditingController()];
  List<TextEditingController> conclusionCtrls = [TextEditingController()];
  List<TextEditingController> conclusionPercCtrls = [TextEditingController()];
  List<TextEditingController> resultCtrls = [TextEditingController()];
  List<TextEditingController> resultPercCtrls = [TextEditingController()];
  List<TextEditingController> newEmotionCtrls = [TextEditingController()];
  List<TextEditingController> newEmotionPercCtrls = [TextEditingController()];

  TextEditingController actionCtrl = TextEditingController();
  Entry? currentEditingEntry;

  bool get isHighPerformance {
    if (kIsWeb) return false;
    return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  double get stormIntensity {
    int totalChars = situationCtrl.text.length;
    for (var c in thoughtCtrls) {
      totalChars += c.text.length;
    }
    for (var c in emotionCtrls) {
      totalChars += c.text.length;
    }
    return (totalChars / 800).clamp(0.0, 1.0);
  }

  AppData() {
    _loadPreferences();
    dateCtrl.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
  }

  void refreshUI() {
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString('entries');
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      entries = decoded.map((e) => Entry.fromJson(e)).toList();
    }
    final String? themePref = prefs.getString('theme_mode');
    if (themePref == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (themePref == 'light') themeMode = ThemeMode.light;

    final String? langPref = prefs.getString('language_code');
    if (langPref != null) locale = Locale(langPref);

    final int? themeTypeIndex = prefs.getInt('theme_type_index');
    if (themeTypeIndex != null &&
        themeTypeIndex >= 0 &&
        themeTypeIndex < ThemeType.values.length) {
      currentTheme = ThemeType.values[themeTypeIndex];
    }

    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String entriesJson =
        jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString('entries', entriesJson);
    String themeStr = 'system';
    if (themeMode == ThemeMode.dark) themeStr = 'dark';
    if (themeMode == ThemeMode.light) themeStr = 'light';
    await prefs.setString('theme_mode', themeStr);
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setInt('theme_type_index', currentTheme.index);
  }

  void toggleTheme(ThemeMode mode) {
    themeMode = mode;
    _savePreferences();
    notifyListeners();
  }

  void setLocale(Locale loc) {
    locale = loc;
    _savePreferences();
    notifyListeners();
  }

  void toggleLanguage() {
    if (locale.languageCode == 'pt') {
      locale = const Locale('en', 'US');
    } else {
      locale = const Locale('pt', 'BR');
    }
    _savePreferences();
    notifyListeners();
  }

  void setThemeType(ThemeType type) {
    currentTheme = type;
    _savePreferences();
    notifyListeners();
  }

  String t(String key) {
    Map<String, String> pt = {
      'app_title': 'RPD Sky',
      'how_to_use': 'COMO USAR',
      'how_to_use_desc':
          'Quando você perceber o seu humor alterando, pergunte a si mesmo "O que está passando pela minha cabeça agora?" e, assim que possível, anote o pensamento ou imagem mental abaixo.',
      'helper_questions': 'PERGUNTAS AUXILIARES',
      'q1': 'Qual a evidência de que isso é verdade? E falso?',
      'q2': 'Existe uma explicação alternativa?',
      'q3': 'O que é o pior que pode acontecer? Eu aguentaria?',
      'q4': 'O que eu diria a um amigo nessa situação?',
      'situation': 'Situação',
      'date_time': 'Data e Hora',
      'what_happened': 'O que aconteceu?',
      'describe_moment': 'Descreva o momento...',
      'auto_thoughts': 'Pensamentos Automáticos',
      'thought_hint': 'O que passou pela cabeça?',
      'add_thought': '+ Adicionar Pensamento',
      'initial_emotions': 'Emoções Iniciais',
      'emotion_hint': 'Tristeza, Raiva, Ansiedade...',
      'add_emotion': '+ Adicionar Emoção',
      'rational_response': 'Resposta Racional',
      'response_hint': 'Resposta racional...',
      'reevaluation': 'Reavaliação',
      'original_thought': 'PENSAMENTO ORIGINAL',
      'new_belief': 'Nova crença...',
      'how_feel_now': 'Como se sente agora?',
      'initial_emotion': 'EMOÇÃO INICIAL',
      'new_intensity': 'Nova intensidade',
      'action_plan': 'Plano de Ação',
      'next_steps': 'Próximos passos...',
      'save_record': 'Salvar Registro',
      'update_record': 'Atualizar Registro',
      'export_all': 'Exportar',
      'clear': 'Limpar',
      'history': 'Histórico',
      'backup': 'Backup',
      'restore': 'Restaurar',
      'empty_sky': 'Seu céu está limpo.',
      'edited_on': 'Editado em',
      'thought': 'PENSAMENTO',
      'emotion': 'EMOÇÃO',
      'settings': 'Configurações',
      'dark_mode': 'Modo Escuro',
      'language': 'Idioma',
      'theme_menu': 'Tema Visual',
      'alert_saved_title': 'Salvo!',
      'alert_saved_msg': 'Seu pensamento foi registrado! ☁️',
      'alert_updated_title': 'Atualizado!',
      'alert_updated_msg': 'Registro atualizado com sucesso! 🔄',
      'alert_error_title': 'Atenção',
      'alert_error_msg': 'Preencha TODOS os campos principais para salvar.',
      'alert_empty_title': 'Vazio',
      'alert_empty_msg': 'Não há dados para exportar.',
      'alert_backup_empty': 'Sem dados para backup.',
      'confirm_clear_title': 'Limpar',
      'confirm_clear_msg': 'Deseja apagar o formulário atual?',
      'confirm_delete_title': 'Excluir Registro',
      'confirm_delete_msg': 'Deseja remover este item do histórico?',
      'alert_restore_title': 'Restaurado!',
      'alert_restore_msg': 'Backup carregado com sucesso. 📂',
      'alert_restore_error_title': 'Erro',
      'alert_restore_error_msg': 'Não foi possível ler o arquivo de backup.',
      'cancel': 'CANCELAR',
      'confirm': 'CONFIRMAR',
      'close': 'FECHAR',
      'ok': 'OK',
      'theme_default': 'Padrão',
      'season_summer': 'Verão',
      'season_spring': 'Primavera',
      'season_autumn': 'Outono',
      'season_winter': 'Inverno',
      'season_halloween': 'Halloween',
      'season_christmas': 'Natal',
      'cut': 'Recortar',
      'copy': 'Copiar',
      'paste_action': 'Colar',
      'select_all': 'Tudo',
      'time_picker_help': 'HORÁRIO',
      'date_picker_help': 'DATA',
    };
    Map<String, String> en = {
      'app_title': 'RPD Sky',
      'how_to_use': 'HOW TO USE',
      'how_to_use_desc':
          'When you notice your mood changing, ask yourself "What is going through my mind right now?" and note the thought or mental image below as soon as possible.',
      'helper_questions': 'HELP',
      'q1': 'What is the evidence that this is true? And false?',
      'q2': 'Is there an alternative explanation?',
      'q3': 'What is the worst that could happen? Could I handle it?',
      'q4': 'What would I tell a friend in this situation?',
      'situation': 'Situation',
      'date_time': 'Date and Time',
      'what_happened': 'What happened?',
      'describe_moment': 'Describe the moment...',
      'auto_thoughts': 'Automatic Thoughts',
      'thought_hint': 'What went through your mind?',
      'add_thought': '+ Add Thought',
      'initial_emotions': 'Initial Emotions',
      'emotion_hint': 'Sadness, Anger, Anxiety...',
      'add_emotion': '+ Add Emotion',
      'rational_response': 'Rational Response',
      'response_hint': 'Rational response...',
      'reevaluation': 'Re-evaluation',
      'original_thought': 'ORIGINAL THOUGHT',
      'new_belief': 'New belief...',
      'how_feel_now': 'How do you feel now?',
      'initial_emotion': 'INITIAL EMOTION',
      'new_intensity': 'New intensity',
      'action_plan': 'Action Plan',
      'next_steps': 'Next steps...',
      'save_record': 'Save Record',
      'update_record': 'Update Record',
      'export_all': 'Export All',
      'clear': 'Clear',
      'history': 'History',
      'backup': 'Backup',
      'restore': 'Restore',
      'empty_sky': 'Your sky is clear.',
      'edited_on': 'Edited on',
      'thought': 'THOUGHT',
      'emotion': 'EMOÇÃO',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'theme_menu': 'Visual Theme',
      'alert_saved_title': 'Saved!',
      'alert_saved_msg': 'Your thought has been recorded! ☁️',
      'alert_updated_title': 'Updated!',
      'alert_updated_msg': 'Record updated successfully! 🔄',
      'alert_error_title': 'Attention',
      'alert_error_msg': 'Fill in ALL main fields to save.',
      'alert_empty_title': 'Empty',
      'alert_empty_msg': 'No data to export.',
      'alert_backup_empty': 'No data to backup.',
      'confirm_clear_title': 'Clear',
      'confirm_clear_msg': 'Do you want to clear the current form?',
      'confirm_delete_title': 'Delete Record',
      'confirm_delete_msg': 'Do you want to remove this item from history?',
      'alert_restore_title': 'Restored!',
      'alert_restore_msg': 'Backup loaded successfully. 📂',
      'alert_restore_error_title': 'Error',
      'alert_restore_error_msg': 'Could not read backup file.',
      'cancel': 'CANCEL',
      'confirm': 'CONFIRM',
      'close': 'CLOSE',
      'ok': 'OK',
      'theme_default': 'Default',
      'season_summer': 'Summer',
      'season_spring': 'Spring',
      'season_autumn': 'Autumn',
      'season_winter': 'Winter',
      'season_halloween': 'Halloween',
      'season_christmas': 'Christmas',
      'cut': 'Cut',
      'copy': 'Copy',
      'paste_action': 'Paste',
      'select_all': 'Select All',
      'time_picker_help': 'TIME',
      'date_picker_help': 'DATE',
    };
    return locale.languageCode == 'pt' ? (pt[key] ?? key) : (en[key] ?? key);
  }

  void addThought() {
    thoughtCtrls.add(TextEditingController());
    thoughtPercCtrls.add(TextEditingController());
    conclusionCtrls.add(TextEditingController());
    conclusionPercCtrls.add(TextEditingController());
    resultCtrls.add(TextEditingController());
    resultPercCtrls.add(TextEditingController());
    notifyListeners();
  }

  void removeThought(int index) {
    if (thoughtCtrls.length > 1) {
      thoughtCtrls.removeAt(index);
      thoughtPercCtrls.removeAt(index);
      conclusionCtrls.removeAt(index);
      conclusionPercCtrls.removeAt(index);
      resultCtrls.removeAt(index);
      resultPercCtrls.removeAt(index);
      notifyListeners();
    }
  }

  void addEmotion() {
    emotionCtrls.add(TextEditingController());
    emotionPercCtrls.add(TextEditingController());
    newEmotionCtrls.add(TextEditingController());
    newEmotionPercCtrls.add(TextEditingController());
    notifyListeners();
  }

  void removeEmotion(int index) {
    if (emotionCtrls.length > 1) {
      emotionCtrls.removeAt(index);
      emotionPercCtrls.removeAt(index);
      newEmotionCtrls.removeAt(index);
      newEmotionPercCtrls.removeAt(index);
      notifyListeners();
    }
  }

  void clearForm() {
    currentEditingEntry = null;
    dateCtrl.text = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    situationCtrl.clear();
    _resetControllers(thoughtCtrls);
    _resetControllers(thoughtPercCtrls);
    _resetControllers(emotionCtrls);
    _resetControllers(emotionPercCtrls);
    _resetControllers(conclusionCtrls);
    _resetControllers(conclusionPercCtrls);
    _resetControllers(resultCtrls);
    _resetControllers(resultPercCtrls);
    _resetControllers(newEmotionCtrls);
    _resetControllers(newEmotionPercCtrls);
    actionCtrl.clear();
    notifyListeners();
  }

  void _resetControllers(List<TextEditingController> ctrls) {
    for (var c in ctrls) {
      c.dispose();
    }
    ctrls.clear();
    ctrls.add(TextEditingController());
  }

  void loadEntryToEdit(Entry entry) {
    currentEditingEntry = entry;
    dateCtrl.text = entry.dateTime;
    situationCtrl.text = entry.situation;
    _loadList(thoughtCtrls, thoughtPercCtrls, entry.thoughts);
    _loadList(emotionCtrls, emotionPercCtrls, entry.emotions);
    _loadList(conclusionCtrls, conclusionPercCtrls, entry.conclusions);
    _loadList(resultCtrls, resultPercCtrls, entry.results);
    _loadList(newEmotionCtrls, newEmotionPercCtrls, entry.newEmotions);
    actionCtrl.text = entry.action;
    notifyListeners();
  }

  void _loadList(List<TextEditingController> txtCtrls,
      List<TextEditingController> percCtrls, List<dynamic> items) {
    for (var c in txtCtrls) {
      c.dispose();
    }
    txtCtrls.clear();
    for (var c in percCtrls) {
      c.dispose();
    }
    percCtrls.clear();
    for (int i = 0; i < items.length; i++) {
      txtCtrls.add(TextEditingController(text: items[i].text));
      percCtrls.add(TextEditingController(text: items[i].percentage));
    }
    if (txtCtrls.isEmpty) {
      txtCtrls.add(TextEditingController());
      percCtrls.add(TextEditingController());
    }
  }

  bool saveEntry() {
    if (situationCtrl.text.isEmpty ||
        thoughtCtrls[0].text.isEmpty ||
        emotionCtrls[0].text.isEmpty) {
      return false;
    }
    final newEntry = Entry(
        id: currentEditingEntry?.id ?? const Uuid().v4(),
        date: DateTime.now(),
        dateTime: dateCtrl.text,
        situation: situationCtrl.text,
        thoughts: _collectThoughts(thoughtCtrls, thoughtPercCtrls),
        emotions: _collectEmotions(emotionCtrls, emotionPercCtrls),
        conclusions: _collectThoughts(conclusionCtrls, conclusionPercCtrls),
        results: _collectThoughts(resultCtrls, resultPercCtrls),
        newEmotions: _collectEmotions(newEmotionCtrls, newEmotionPercCtrls),
        action: actionCtrl.text,
        lastEdited: currentEditingEntry != null
            ? DateTime.now().toIso8601String()
            : null);
    if (currentEditingEntry != null) {
      int index = entries.indexWhere((e) => e.id == currentEditingEntry!.id);
      if (index != -1) entries[index] = newEntry;
    } else {
      entries.insert(0, newEntry);
    }
    _savePreferences();
    clearForm();
    return true;
  }

  List<ThoughtItem> _collectThoughts(
      List<TextEditingController> txt, List<TextEditingController> perc) {
    List<ThoughtItem> list = [];
    for (int i = 0; i < txt.length; i++) {
      list.add(ThoughtItem(txt[i].text, perc[i].text));
    }
    return list;
  }

  List<EmotionItem> _collectEmotions(
      List<TextEditingController> txt, List<TextEditingController> perc) {
    List<EmotionItem> list = [];
    for (int i = 0; i < txt.length; i++) {
      list.add(EmotionItem(txt[i].text, perc[i].text));
    }
    return list;
  }

  void deleteEntry(String id) {
    entries.removeWhere((e) => e.id == id);
    _savePreferences();
    if (currentEditingEntry?.id == id) clearForm();
    notifyListeners();
  }

  Future<void> exportAllTxt() async {
    String content = entries
        .map((e) => _formatEntryForTxt(e))
        .join('\n====================\n\n');
    await _shareText(content, 'rpd_completo.txt');
  }

  Future<void> exportSingleTxt(Entry entry) async {
    await _shareText(_formatEntryForTxt(entry), 'rpd_registro.txt');
  }

  String _formatEntryForTxt(Entry e) {
    StringBuffer sb = StringBuffer();
    sb.writeln("DATA/HORA: ${e.dateTime}");
    if (e.lastEdited != null) {
      sb.writeln(
          "(Editado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(e.lastEdited!))})");
    }
    sb.writeln("\nSITUAÇÃO:\n${e.situation}");
    sb.writeln("\nPENSAMENTOS AUTOMÁTICOS:");
    for (var t in e.thoughts) {
      sb.writeln("- ${t.text} (${t.percentage}%)");
    }
    sb.writeln("\nEMOÇÕES INICIAIS:");
    for (var em in e.emotions) {
      sb.writeln("- ${em.text} (${em.percentage}%)");
    }
    sb.writeln("\nRESPOSTA RACIONAL:");
    for (var c in e.conclusions) {
      if (c.text.isNotEmpty) sb.writeln("- ${c.text} (${c.percentage}%)");
    }
    sb.writeln("\nREAVALIAÇÃO:");
    for (var r in e.results) {
      if (r.text.isNotEmpty) {
        sb.writeln("- Pensamento: ${r.text} (${r.percentage}%)");
    }
      }
    for (var ne in e.newEmotions) {
      if (ne.percentage.isNotEmpty) {
        sb.writeln("- Emoção: ${ne.text} (${ne.percentage}%)");
    }
      }
    sb.writeln("\nPLANO DE AÇÃO:\n${e.action}");
    return sb.toString();
  }

  Future<void> exportBackup() async {
    final String jsonStr = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _shareText(jsonStr, "backup.json");
  }

  Future<bool> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        entries = jsonList.map((e) => Entry.fromJson(e)).toList();
        _savePreferences();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _shareText(String content, String fileName) async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        String? outputFile = await FilePicker.platform
            .saveFile(dialogTitle: 'Salvar Arquivo', fileName: fileName);
        if (outputFile != null) {
          await File(outputFile).writeAsString(content);
        }
      } catch (e) {
        print("Erro ao salvar: $e");
      }
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      await Share.shareXFiles([XFile(file.path)], text: 'Registro');
    }
  }
}