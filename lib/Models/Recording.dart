class Recording {
  final String id;
  final String userId;
  final String topic;
  final String fileLink;
  final DateTime? datetime;
  final String? transcript;
  final String? output;

  Recording({
    required this.id,
    required this.userId,
    required this.topic,
    required this.fileLink,
    this.datetime,
    this.transcript,
    this.output,
  });

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'],
      userId: json['user_id'],
      topic: json['topic'],
      fileLink: json['file_link'],
      datetime: json['datetime'] != null 
          ? DateTime.parse(json['datetime']) 
          : json['created_at'] != null 
              ? DateTime.parse(json['created_at'])
              : null,
      transcript: json['transcript'],
      output: json['output'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'topic': topic,
      'file_link': fileLink,
      'datetime': datetime?.toIso8601String(),
      'transcript': transcript,
      'output': output,
    };
  }
}
