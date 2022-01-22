import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/animated_grid_view/entities/animated_grid_view_entity.dart';

typedef OnCreatedFunction = AnimatedGridViewEntity? Function(
  int hashKey,
  GlobalKey key,
);

class AnimatedGridViewChild extends StatefulWidget {
  final AnimatedGridViewEntity animatedGridViewEntity;
  final double opacity;

  final OnCreatedFunction onCreated;
  final Function(AnimatedGridViewEntity animatedGridViewEntity)
      onEndAnimatedOpacity;

  const AnimatedGridViewChild({
    required this.animatedGridViewEntity,
    required this.opacity,
    required this.onCreated,
    required this.onEndAnimatedOpacity,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedGridViewChild> createState() => _AnimatedGridViewChildState();
}

class _AnimatedGridViewChildState extends State<AnimatedGridViewChild> {
  late AnimatedGridViewEntity _animatedGridViewEntity;

  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final hashKey = _animatedGridViewEntity.child.key.hashCode;
      _animatedGridViewEntity = widget.onCreated(hashKey, _globalKey)!;
    });

    _animatedGridViewEntity = widget.animatedGridViewEntity;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.opacity == 0.0
          ? const Duration(milliseconds: 300)
          : Duration.zero,
      opacity: widget.opacity,
      onEnd: () => widget.onEndAnimatedOpacity(widget.animatedGridViewEntity),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(-dx, -dy, 0),
        key: _globalKey,
        child: widget.animatedGridViewEntity.child,
      ),
    );
  }

  double get dx {
    final originalOffset = _animatedGridViewEntity.originalOffset;
    final updatedOffset = _animatedGridViewEntity.updatedOffset;

    return originalOffset.dx - updatedOffset.dx;
  }

  double get dy {
    final originalOffset = _animatedGridViewEntity.originalOffset;
    final updatedOffset = _animatedGridViewEntity.updatedOffset;

    return originalOffset.dy - updatedOffset.dy;
  }
}
