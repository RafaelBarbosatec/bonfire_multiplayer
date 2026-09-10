import 'package:flutter/material.dart';

/// Ragnarok-inspired design tokens shared by the menu screens (login,
/// character select, ...). Screens consume these instead of hard-coding
/// colours, so the whole front-end stays visually consistent.
class RoColors {
  static const bgTop = Color(0xFF070E1C);
  static const bgBottom = Color(0xFF14294A);
  static const panelBg = Color(0xE6122036);
  static const border = Color(0xFF8A6A2F);
  static const borderDark = Color(0xFF5A4726);
  static const gold = Color(0xFFE8C36A);
  static const goldBright = Color(0xFFFFE9A8);
  static const ivory = Color(0xFFF4EBD6);
  static const textSoft = Color(0xFFBAC5DB);
  static const textFaint = Color(0xFF8493AF);
  static const btnTop = Color(0xFF3D6CA0);
  static const btnBottom = Color(0xFF16304F);
  static const danger = Color(0xFFE08270);
}

/// Full-screen backdrop: vertical night-blue gradient, two soft radial glows
/// and a vignette that focuses the centre of the screen.
class RoBackground extends StatelessWidget {
  const RoBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [RoColors.bgTop, RoColors.bgBottom],
        ),
      ),
      child: Stack(
        children: [
          // Soft golden glow (upper area) + deep blue side glow.
          Positioned(
            top: -120,
            right: -80,
            child: RoGlow(
              size: 420,
              color: RoColors.gold.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -60,
            child: RoGlow(
              size: 460,
              color: const Color(0xFF2E6FA8).withValues(alpha: 0.10),
            ),
          ),
          // Vignette to focus the centre.
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.3,
                    colors: [Colors.transparent, Color(0x99020812)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular radial glow used to light up the [RoBackground].
class RoGlow extends StatelessWidget {
  const RoGlow({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

/// Ornamented framed panel with an optional gold title header.
///
/// The child is laid out inside an [Expanded], so callers must give the panel
/// a bounded height (via `Expanded`, `SizedBox` or `ConstrainedBox`).
class RoOrnatePanel extends StatelessWidget {
  const RoOrnatePanel({
    super.key,
    required this.child,
    this.title,
    this.titleIcon,
  });

  final Widget child;
  final String? title;
  final IconData? titleIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RoColors.borderDark, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xF21B2E4C), RoColors.panelBg],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (titleIcon != null) ...[
                        Icon(titleIcon, color: RoColors.gold, size: 16),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          title!,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: RoColors.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      if (titleIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(titleIcon, color: RoColors.gold, size: 16),
                      ],
                    ],
                  ),
                ),
              if (title != null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(color: RoColors.border, height: 1),
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill-shaped secondary action (icon + uppercase label).
class RoPillAction extends StatelessWidget {
  const RoPillAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0x1FFFFFFF),
              border: Border.all(
                color: enabled ? RoColors.border : RoColors.borderDark,
                width: 1.1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: RoColors.gold, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: RoColors.ivory,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Big primary action button (gradient + gold border) with an optional
/// inline loading spinner.
class RoPrimaryButton extends StatelessWidget {
  const RoPrimaryButton({
    super.key,
    required this.onTap,
    this.label = 'ENTRAR',
    this.icon = Icons.play_arrow_rounded,
    this.enabled = true,
    this.loading = false,
  });

  final VoidCallback? onTap;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onTap != null;
    return Opacity(
      opacity: active ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: active ? onTap : null,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [RoColors.btnTop, RoColors.btnBottom],
              ),
              border: Border.all(color: RoColors.gold, width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: RoColors.goldBright,
                    ),
                  )
                else
                  Icon(icon, color: RoColors.goldBright, size: 22),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: RoColors.goldBright,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Slim error strip used to surface failures to the player.
class RoErrorBar extends StatelessWidget {
  const RoErrorBar({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0x33E08270),
        border: Border.all(color: RoColors.danger, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: RoColors.danger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RoColors.ivory, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared decoration for the themed text fields (login, create character).
InputDecoration roInputDecoration({
  required String label,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: RoColors.textSoft),
    floatingLabelStyle: const TextStyle(color: RoColors.gold),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, color: RoColors.textFaint, size: 18),
    suffixIcon: suffixIcon,
    counterText: '',
    filled: true,
    fillColor: const Color(0x33000000),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: border(RoColors.borderDark, 1.2),
    focusedBorder: border(RoColors.gold, 1.4),
    errorBorder: border(RoColors.danger, 1.2),
    focusedErrorBorder: border(RoColors.danger, 1.4),
    errorStyle: const TextStyle(color: RoColors.danger, fontSize: 11),
  );
}
