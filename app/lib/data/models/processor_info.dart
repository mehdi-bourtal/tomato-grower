class ProcessorInfo {
  final String procId;
  final String? name;
  final String? latitude;
  final String? longitude;
  final int? wateringVolume;
  final int? cultivationSize;

  ProcessorInfo({
    required this.procId,
    this.name,
    this.latitude,
    this.longitude,
    this.wateringVolume,
    this.cultivationSize,
  });

  factory ProcessorInfo.fromJson(Map<String, dynamic> json) {
    return ProcessorInfo(
      procId: json['proc_id'] as String,
      name: json['name'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      wateringVolume: (json['watering_volume'] as num?)?.toInt(),
      cultivationSize: (json['cultivation_size'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'proc_id': procId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'watering_volume': wateringVolume,
        'cultivation_size': cultivationSize,
      };

  String get displayName => name ?? 'Unnamed Processor';
}
