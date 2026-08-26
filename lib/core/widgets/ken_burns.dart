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

class PhotoScrim extends StatelessWidget {
  const PhotoScrim({super.key, this.soft = false});

  final bool soft;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: soft
              ? [
                  BcColors.espresso.withValues(alpha: 0.12),
                  BcColors.espresso.withValues(alpha: 0.72),
                ]
              : [
                  BcColors.espresso.withValues(alpha: 0.28),
                  BcColors.espresso.withValues(alpha: 0.52),
                  BcColors.espresso.withValues(alpha: 0.78),
                ],
        ),
      ),
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
        return const ColoredBox(color: BcColors.stone);
      },
      errorBuilder: (context, error, stack) {
        return const ColoredBox(
          color: BcColors.stone,
          child: Center(
            child: Icon(Icons.landscape_outlined, color: BcColors.muted, size: 48),
          ),
        );
      },
    );
  }
}
