import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AnimatedGradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final double width;
  final double height;
  final bool isLoading;

  const AnimatedGradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.width = double.infinity,
    this.height = 50,
    this.isLoading = false,
  });

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.fastAnimation,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _controller.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    _isHovered
                        ? [AppTheme.primaryLight, AppTheme.primaryColor]
                        : [AppTheme.primaryColor, AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(
                    _isHovered ? 0.4 : 0.2,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child:
                    widget.isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: Colors.white),
                              const SizedBox(width: 8),
                            ],
                            Text(widget.text, style: AppTheme.buttonMd),
                          ],
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const AnimatedCard({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = 200,
    this.onTap,
    this.color,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.mediumAnimation,
          curve: Curves.easeInOut,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color ?? AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
                blurRadius: _isHovered ? 10 : 5,
                offset: Offset(0, _isHovered ? 5 : 2),
              ),
            ],
            border: Border.all(
              color:
                  _isHovered
                      ? AppTheme.primaryLight.withOpacity(0.3)
                      : Colors.transparent,
              width: 1,
            ),
          ),
          transform:
              _isHovered
                  ? Matrix4.translationValues(0, -3, 0)
                  : Matrix4.translationValues(0, 0, 0),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool isAnimating;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.isAnimating = true,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isAnimating ? _animation.value : 1.0,
          child: widget.child,
        );
      },
    );
  }
}

class FadeSlideTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, 30),
  });

  @override
  State<FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
