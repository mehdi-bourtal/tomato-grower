class WateringEvent {
  final String procId;
  final DateTime date;

  WateringEvent({
    required this.procId,
    required this.date,
  });

  factory WateringEvent.fromJson(Map<String, dynamic> json) {
    return WateringEvent(
      procId: json['proc_id'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'proc_id': procId,
        'date': date.toIso8601String(),
      };
}
