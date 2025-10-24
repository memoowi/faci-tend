import 'package:flutter/material.dart';

class Helper {
  static onTapOutside(event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
