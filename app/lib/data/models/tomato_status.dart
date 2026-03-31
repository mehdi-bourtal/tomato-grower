class TomatoStatus {
  final DateTime date;
  final String procId;
  final int? ripeTomatos;
  final String? imgSupabaseUrl;

  TomatoStatus({
    required this.date,
    required this.procId,
    this.ripeTomatos,
    this.imgSupabaseUrl,
  });

  factory TomatoStatus.fromJson(Map<String, dynamic> json) {
    return TomatoStatus(
      date: DateTime.parse(json['date'] as String),
      procId: json['proc_id'] as String,
      ripeTomatos: (json['ripe_tomatos'] as num?)?.toInt(),
      imgSupabaseUrl: json['img_supabase_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'proc_id': procId,
        'ripe_tomatos': ripeTomatos,
        'img_supabase_url': imgSupabaseUrl,
      };
}
