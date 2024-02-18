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
