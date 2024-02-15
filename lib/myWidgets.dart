import 'package:flutter/material.dart';

TextFormField myDialogTextField(String label, IconData sufixIcon,
    TextEditingController userControl, TextInputType keyBoardType) {
  return TextFormField(
    keyboardType: keyBoardType,
    controller: userControl,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: Icon(
        sufixIcon,
        color: Colors.red,
        size: 13,
      ),
      labelStyle: const TextStyle(
        color: Colors.blue,
        fontSize: 16,
      ),
    ),
  );
}
