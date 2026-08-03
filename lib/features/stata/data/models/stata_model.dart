class StataDatasetModel {
  final String path;
  final String name;
  final int size;
  final String summary;
  final List<String> variables;
  final String preview;

  StataDatasetModel({
    required this.path,
    required this.name,
    required this.size,
    required this.summary,
    required this.variables,
    required this.preview,
  });

  factory StataDatasetModel.fromJson(Map<String, dynamic> json) {
    return StataDatasetModel(
      path: json['path'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      summary: json['summary'] ?? '',
      variables: (json['variables'] as List?)?.map((e) => e.toString()).toList() ?? [],
      preview: json['preview'] ?? '',
    );
  }
}

class StataOutputModel {
  final String command;
  final String? html;
  final String? text;

  StataOutputModel({
    required this.command,
    this.html,
    this.text,
  });

  factory StataOutputModel.fromJson(Map<String, dynamic> json) {
    return StataOutputModel(
      command: json['command'] ?? '',
      html: json['html'],
      text: json['text'],
    );
  }
}
