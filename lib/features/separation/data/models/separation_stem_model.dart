import 'package:equatable/equatable.dart';

class SeparationStemModel extends Equatable {
  final String name;
  final String url;

  const SeparationStemModel({
    required this.name,
    required this.url,
  });

  factory SeparationStemModel.fromJson(Map<String, dynamic> json) {
    return SeparationStemModel(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [name, url];
}


