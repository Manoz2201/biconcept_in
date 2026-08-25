import 'package:biconcept_in/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 28,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? Key('reveal-${identityHashCode(this)}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.12 && !_visible) {
          setState(() => _visible = true);
        }
      },
      child: widget.child
          .animate(target: _visible ? 1 : 0)
          .fadeIn(duration: 800.ms, delay: widget.delay, curve: Curves.easeOutCubic)
          .moveY(
            begin: widget.offset,
            end: 0,
            duration: 900.ms,
            delay: widget.delay,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color ?? BcColors.gold),
    );
  }
}
