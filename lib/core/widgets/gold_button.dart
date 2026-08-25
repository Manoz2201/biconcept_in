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
        _hover ? BcColors.goldSoft : BcColors.gold,
      GoldButtonVariant.outline =>
        _hover ? BcColors.gold.withValues(alpha: 0.12) : Colors.transparent,
      GoldButtonVariant.ghost => Colors.transparent,
    };
    final fg = filled ? BcColors.ink : BcColors.gold;
    final border = ghost
        ? Border.all(color: Colors.transparent)
        : Border.all(color: BcColors.gold);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: enabled ? bg : BcColors.line,
            border: border,
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
