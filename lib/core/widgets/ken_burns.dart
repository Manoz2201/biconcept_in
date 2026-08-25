import 'package:biconcept_in/core/theme/colors.dart';
import 'package:flutter/material.dart';

class KenBurnsImage extends StatefulWidget {
  const KenBurnsImage({
    super.key,
    required this.url,
    this.duration = const Duration(seconds: 22),
  });

  final String url;
  final Duration duration;

  @override
  State<KenBurnsImage> createState() => _KenBurnsImageState();
}

class _KenBurnsImageState extends State<KenBurnsImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween(begin: 1.0, end: 1.08).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
      child: NetworkCover(url: widget.url),
    );
  }
}

class NetworkCover extends StatelessWidget {
  const NetworkCover({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.high,
      alignment: Alignment.center,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(color: BcColors.charcoal);
      },
      errorBuilder: (context, error, stack) {
        return const ColoredBox(
          color: BcColors.charcoal,
          child: Center(
            child: Icon(Icons.landscape_outlined, color: BcColors.line, size: 48),
          ),
        );
      },
    );
  }
}
