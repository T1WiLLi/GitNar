import 'package:flutter/cupertino.dart';

class GithubLabel {
  final String name;
  final String color;
  final String? description;

  GithubLabel({required this.name, required this.color, this.description});

  Color getColor() {
    // Assuming color is a hex string like 'ff0000'
    return Color(int.parse('ff$color', radix: 16));
  }
}
