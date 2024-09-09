import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'dart:ui' as ui;

import 'package:flutter_shaders/flutter_shaders.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({
    Key? key,
    required this.child,
    required this.onDelete,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDelete;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with TickerProviderStateMixin {
  double _previousScrollPosition = 0.0;
  double _scrollDirection = 1.0; // Default to left-to-right
  final double cornerRadius = 16.0;

  late final AnimationController _animation;
  late double _width;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController.unbounded(
      vsync: this,
      duration: ProjectCardConstants.animationDuration,
    );
    _animation.value = 0.0;
  }

  Future<void> _handleCancel() async {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    await _animation.animateTo(
      0,
      duration: ProjectCardConstants.pauseAnimationDuration,
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _previousScrollPosition = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _width = context.size!.width;
      final double delta = details.globalPosition.dx - _previousScrollPosition;
      final double normalizedDelta = delta / _width;

      // Update scroll direction
      if (delta > 0) {
        _scrollDirection = 1.0; // Left to right
      } else if (delta < 0) {
        _scrollDirection = -1.0; // Right to left
      }

      // Update animation value
      double newValue = _animation.value + normalizedDelta;
      _animation.value = newValue.clamp(-1.0, 1.0);

      _previousScrollPosition = details.globalPosition.dx;

      print(
          "Drag Update: delta=$delta, newPointer=${_animation.value}, scrollDirection=$_scrollDirection");
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    final double animationValue = _animation.value;

    if (animationValue.abs() > ProjectCardConstants.completionThreshold ||
        velocity.abs() > ProjectCardConstants.velocityThreshold) {
      // Complete the animation in the current direction
      final double targetValue = _scrollDirection > 0 ? 1.5 : -1.5;
      _completeAnimation(targetValue);
    } else {
      // Reset the animation
      _resetAnimation();
    }
  }

  void _completeAnimation(double targetValue) {
    _animation
        .animateTo(
      targetValue,
      duration: ProjectCardConstants.completeAnimationDuration,
      curve: Curves.easeOut,
    )
        .then((_) {
      if (targetValue.abs() == 1.0) {
        // Trigger action based on direction (e.g., delete or other action)
        if (targetValue > 0) {
          // Action for right swipe
        } else {
          widget.onDelete();
        }
      }
    });
  }

  void _resetAnimation() {
    _animation
        .animateTo(
          0,
          duration: ProjectCardConstants.resetAnimationDuration,
          curve: Curves.easeOut,
        )
        .then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragCancel: _resetAnimation,
      child: AnimatedBuilder(
        animation: _animation,
        builder: _buildAnimatedCard,
      ),
    );
  }

  Widget _buildAnimatedCard(BuildContext context, Widget? child) {
    return ShaderBuilder(
      (context, shader, _) {
        return AnimatedSampler(
          (image, size, canvas) {
            // double clampedPointer = _animation.value.clamp(-1.0, 1.0);
            ShaderHelper.configureShader(
                shader, size, image, _animation.value, _scrollDirection);
            ShaderHelper.drawShaderRect(shader, size, canvas);

            print(
                "Shader configured: pointer=$_animation.value, scrollDirection=$_scrollDirection");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ProjectCardConstants.cornerRadius,
            ),
            child: widget.child,
          ),
        );
      },
      assetKey: ProjectCardConstants.shaderAssetKey,
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }
}

class ProjectCardConstants {
  static const double cornerRadius = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Duration pauseAnimationDuration = Duration(milliseconds: 1000);
  static const Duration completeAnimationDuration =
      Duration(milliseconds: 1000);
  static const Duration resetAnimationDuration = Duration(milliseconds: 200);
  static const String shaderAssetKey = 'shaders/page_curl.frag';
  static const double completionThreshold = 0.5;
  static const double velocityThreshold = 1000.0;
}

class ShaderHelper {
  static void configureShader(
    ui.FragmentShader shader,
    ui.Size size,
    ui.Image image,
    double pointer,
    double scrollDirection,
  ) {
    print(
        "Configure shader : pointer = $pointer, scrollDirection = $scrollDirection");
    shader
      ..setFloat(0, size.width) // resolution
      ..setFloat(1, size.height) // resolution
      ..setFloat(2, pointer) // pointer
      ..setFloat(3, 0) // inner container
      ..setFloat(4, 0) // inner container
      ..setFloat(5, size.width) // inner container
      ..setFloat(6, size.height) // inner container
      ..setFloat(7, ProjectCardConstants.cornerRadius) // cornerRadius
      ..setFloat(8, scrollDirection) // New: scroll direction
      ..setImageSampler(0, image); // image
  }

  static void drawShaderRect(
      ui.FragmentShader shader, ui.Size size, ui.Canvas canvas) {
    canvas.drawRect(
      ui.Rect.fromCenter(
        center: ui.Offset(size.width / 2, size.height / 2),
        width: size.width,
        height: size.height,
      ),
      ui.Paint()..shader = shader,
    );
  }
}
