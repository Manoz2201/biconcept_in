import 'package:biconcept_in/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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

class _KenBurnsImageState extends State<KenBurnsImage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _scale = Tween(begin: 1.0, end: 1.08).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: NetworkCover(url: widget.url, eager: true),
      ),
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

/// Shrink Unsplash (and similar) URLs so first paint is not a 2000px JPEG.
String tunedPhotoUrl(String url, {required int width}) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return url;
  if (!uri.host.contains('unsplash.com') && !uri.host.contains('images.unsplash.com')) {
    return url;
  }
  final query = Map<String, String>.from(uri.queryParameters);
  query['auto'] = 'format';
  query['fit'] = 'crop';
  query['w'] = '$width';
  query['q'] = '68';
  return uri.replace(queryParameters: query).toString();
}

class NetworkCover extends StatefulWidget {
  const NetworkCover({
    super.key,
    required this.url,
    this.eager = false,
  });

  final String url;
  final bool eager;

  @override
  State<NetworkCover> createState() => _NetworkCoverState();
}

class _NetworkCoverState extends State<NetworkCover> {
  late bool _load = widget.eager;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context).width;
    final width = widget.eager
        ? (screen < 800 ? 1100 : 1400)
        : (screen < 800 ? 720 : 960);
    final src = tunedPhotoUrl(widget.url, width: width);

    if (!_load) {
      return VisibilityDetector(
        key: Key('cover-${widget.url.hashCode}'),
        onVisibilityChanged: (info) {
          if (!_load && info.visibleFraction > 0.02) {
            setState(() => _load = true);
          }
        },
        child: const SizedBox.expand(
          child: ColoredBox(color: BcColors.stone),
        ),
      );
    }

    return Image.network(
      src,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: width.round(),
      filterQuality: FilterQuality.medium,
      alignment: Alignment.center,
      gaplessPlayback: true,
      // Canvas decode keeps ClipRRect, Ken Burns, and taps working on web.
      webHtmlElementStrategy: WebHtmlElementStrategy.never,
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
