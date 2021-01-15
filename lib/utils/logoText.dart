import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class LogoText extends StatelessWidget {
  const LogoText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Text(
        "Tic Tac Go",
        style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = ui.Gradient.linear(
                const Offset(0, 20),
                const Offset(150, 200),
                <Color>[
                  Color(0xFF6F35A5),
                  Color(0xFFF1E6FF),
                ],
              )
        ),
      ),
    );
  }
}