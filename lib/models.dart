class ThoughtItem {
  String text;
  String percentage;
  ThoughtItem(this.text, this.percentage);

  Map<String, dynamic> toJson() => {'text': text, 'percentage': percentage};
  factory ThoughtItem.fromJson(Map<String, dynamic> json) =>
      ThoughtItem(json['text'] ?? '', json['percentage'] ?? '');
}

class EmotionItem {
  String text;
  String percentage;
  EmotionItem(this.text, this.percentage);

  Map<String, dynamic> toJson() => {'text': text, 'percentage': percentage};
  factory EmotionItem.fromJson(Map<String, dynamic> json) =>
      EmotionItem(json['text'] ?? '', json['percentage'] ?? '');
}

class Entry {
  String id;
  DateTime date;
  String dateTime;
  String situation;
  List<ThoughtItem> thoughts;
  List<EmotionItem> emotions;
  List<ThoughtItem> conclusions;
  List<ThoughtItem> results;
  List<EmotionItem> newEmotions;
  String action;
  String? lastEdited;

  Entry({
    required this.id,
    required this.date,
    required this.dateTime,
    required this.situation,
    required this.thoughts,
    required this.emotions,
    required this.conclusions,
    required this.results,
    required this.newEmotions,
    required this.action,
    this.lastEdited,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'dateTime': dateTime,
        'situation': situation,
        'thoughts': thoughts.map((e) => e.toJson()).toList(),
        'emotions': emotions.map((e) => e.toJson()).toList(),
        'conclusions': conclusions.map((e) => e.toJson()).toList(),
        'results': results.map((e) => e.toJson()).toList(),
        'newEmotions': newEmotions.map((e) => e.toJson()).toList(),
        'action': action,
        'lastEdited': lastEdited,
      };

  factory Entry.fromJson(Map<String, dynamic> json) {
    var thoughtsList = json['thoughts'] as List? ?? [];
    var emotionsList = json['emotions'] as List? ?? [];
    var conclusionsList = json['conclusions'] as List? ?? [];
    var resultsList = json['results'] as List? ?? [];
    var newEmotionsList = json['newEmotions'] as List? ?? [];

    return Entry(
      id: json['id'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      dateTime: json['dateTime'] ?? '',
      situation: json['situation'] ?? '',
      thoughts: thoughtsList.map((i) => ThoughtItem.fromJson(i)).toList(),
      emotions: emotionsList.map((i) => EmotionItem.fromJson(i)).toList(),
      conclusions: conclusionsList.map((i) => ThoughtItem.fromJson(i)).toList(),
      results: resultsList.map((i) => ThoughtItem.fromJson(i)).toList(),
      newEmotions: newEmotionsList.map((i) => EmotionItem.fromJson(i)).toList(),
      action: json['action'] ?? '',
      lastEdited: json['lastEdited'],
    );
  }
}
