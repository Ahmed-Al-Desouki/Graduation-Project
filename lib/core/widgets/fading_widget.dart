import 'package:flutter/material.dart';

class FadingWidget extends StatefulWidget {
  const FadingWidget({super.key, required this.child});
  final Widget child;

  @override
  State<FadingWidget> createState() => _FadingWidgetState();
}

class _FadingWidgetState extends State<FadingWidget>
    with SingleTickerProviderStateMixin {
  late Animation animation;
  late AnimationController animationController;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    animation = Tween<double>(begin: .2, end: .8).animate(animationController);
    animationController.repeat(reverse: true);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: animation.value, child: widget.child);
  }
}
