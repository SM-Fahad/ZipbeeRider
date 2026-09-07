import 'package:flutter/material.dart';

class HelpCenterOption {
  final String title;
  final String description;
  final IconData icon;
  final Function()? onTap;

  HelpCenterOption({
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
  });
}
