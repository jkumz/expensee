import 'package:flutter/material.dart';

final standardMenuOptionStyle = ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold));

final standardMenuOptionStyleWithIcon = ElevatedButton.styleFrom(
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
  alignment: Alignment.centerLeft,
  textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
);
