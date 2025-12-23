import 'package:flutter/material.dart';

/// Widget para animaciones de entrada (Fade + Slide)
class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedEntrance({
    Key? key,
    required this.child,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget para animación de escala
class AnimatedScale extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedScale({
    Key? key,
    required this.child,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.elasticOut,
  }) : super(key: key);

  @override
  State<AnimatedScale> createState() => _AnimatedScaleState();
}

class _AnimatedScaleState extends State<AnimatedScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Transición personalizada para cambio de pantalla (Compartir elemento)
class SharedAxisTransition extends PageRouteBuilder {
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
  ) pageBuilder;
  final SharedAxisTransitionType transitionType;

  SharedAxisTransition({
    required this.pageBuilder,
    this.transitionType = SharedAxisTransitionType.horizontal,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) =>
        pageBuilder(context, animation, secondaryAnimation),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _buildTransition(
        context,
        animation,
        secondaryAnimation,
        child,
        transitionType,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    SharedAxisTransitionType type,
  ) {
    final tween = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOutCubic));

    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: type == SharedAxisTransitionType.horizontal
              ? const Offset(1.0, 0.0)
              : const Offset(0.0, 1.0),
          end: Offset.zero,
        ),
      ),
      child: FadeTransition(
        opacity: tween.animate(animation),
        child: child,
      ),
    );
  }
}

enum SharedAxisTransitionType { horizontal, vertical }

/// Stagger animation para listas
class StaggerAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration delayBetween;
  final Duration duration;

  const StaggerAnimation({
    Key? key,
    required this.children,
    this.delayBetween = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  State<StaggerAnimation> createState() => _StaggerAnimationState();
}

class _StaggerAnimationState extends State<StaggerAnimation> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedEntrance(
          delay: Duration(
            milliseconds: index * widget.delayBetween.inMilliseconds,
          ),
          duration: widget.duration,
          child: widget.children[index],
        );
      },
    );
  }
}
