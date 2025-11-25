import 'package:flutter/material.dart';

class AuriSlimePlaceholder extends StatefulWidget {
  const AuriSlimePlaceholder({super.key});

  @override
  State<AuriSlimePlaceholder> createState() => _AuriSlimePlaceholderState();
}

class _AuriSlimePlaceholderState extends State<AuriSlimePlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.purpleAccent.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}
