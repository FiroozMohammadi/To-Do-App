import 'package:flutter/material.dart';

TextFormField myDialogTextField(String label, IconData sufixIcon,
    TextEditingController userControl, VoidCallback onTap) {
  return TextFormField(
    onTap: onTap,
    controller: userControl,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: Icon(
        sufixIcon,
        color: Colors.red,
        size: 13,
      ),
      labelStyle: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    ),
  );
}

SizedBox myIcon(IconData icon, Color color, VoidCallback onTap) {
  return SizedBox(
    width: 40,
    child: GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 24,
        color: color,
      ),
    ),
  );
}
