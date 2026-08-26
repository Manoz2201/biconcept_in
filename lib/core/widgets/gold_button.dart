import 'package:biconcept_in/core/theme/colors.dart';
import 'package:flutter/material.dart';

enum GoldButtonVariant { filled, outline, ghost }

class GoldButton extends StatefulWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = GoldButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final GoldButtonVariant variant;

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.variant == GoldButtonVariant.filled;
    final ghost = widget.variant == GoldButtonVariant.ghost;
    final enabled = widget.onPressed != null;

    final bg = switch (widget.variant) {
      GoldButtonVariant.filled =>
        _hover ? BcColors.brassHover : BcColors.brass,
      GoldButtonVariant.outline =>
        _hover ? BcColors.brass.withValues(alpha: 0.1) : Colors.transparent,
      GoldButtonVariant.ghost => Colors.transparent,
    };
    final fg = filled ? BcColors.espresso : BcColors.brass;
    final border = ghost
        ? Border.all(color: Colors.transparent)
        : Border.all(color: BcColors.brass);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hover && enabled ? -2 : 0, 0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            color: enabled ? bg : BcColors.line,
            border: border,
            borderRadius: BorderRadius.circular(BcColors.radius),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: enabled ? fg : BcColors.muted,
                  letterSpacing: 2.2,
                  fontSize: 11,
                ),
          ),
        ),
      ),
    );
  }
}
