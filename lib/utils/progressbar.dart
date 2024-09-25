import 'package:flutter/material.dart';

class StyledCircularProgressIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color valueColor;

  const StyledCircularProgressIndicator({
    super.key,
    this.size = 50.0,
    this.strokeWidth = 5.0,
    this.backgroundColor = Colors.grey,
    this.valueColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: valueColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(strokeWidth * 2.5),
        child: Stack(
          children: [
            CircularProgressIndicator(
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
