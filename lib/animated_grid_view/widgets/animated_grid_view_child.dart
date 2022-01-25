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

class _AnimatedGridViewChildState extends State<AnimatedGridViewChild>
    with SingleTickerProviderStateMixin {
  late AnimatedGridViewEntity _animatedGridViewEntity;
  late AnimationController animationController;
  late Animation animation;

  final _globalKey = GlobalKey();

  var offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = Tween<double>(
      begin: widget.animatedGridViewEntity.originalOffset.dx,
      end: _dx,
    ).animate(animationController)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
    animationController.forward();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final hashKey = _animatedGridViewEntity.child.key.hashCode;
      _animatedGridViewEntity = widget.onCreated(hashKey, _globalKey)!;
      setState(() {});
    });

    _animatedGridViewEntity = widget.animatedGridViewEntity;
  }

  @override
  void didUpdateWidget(covariant AnimatedGridViewChild oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animatedGridViewEntity.updatedOffset !=
        widget.animatedGridViewEntity.updatedOffset) {
      final updatedAnimatedGridViewEntity = widget.animatedGridViewEntity;
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        setState(() {
          offset = _getOffset(
            animatedGridViewEntity: updatedAnimatedGridViewEntity,
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('----');
    print('${widget.animatedGridViewEntity.child.key} offset $offset');
    print('dx $_dx dy $_dy');
    print('----');
    print('animation.value ${animation.value}');

    return AnimatedOpacity(
      key: _globalKey,
      duration: widget.opacity == 0.0
          ? const Duration(milliseconds: 300)
          : Duration.zero,
      opacity: widget.opacity,
      onEnd: () => widget.onEndAnimatedOpacity(widget.animatedGridViewEntity),
      child: Container(
        transform: Matrix4.translationValues(
          animation.value,
          _dy,
          0,
        ),
        child: CustomSingleChildLayout(
          delegate: AnimatedGridViewSingleChildLayoutDelegate(
            offset: Offset(-_dx, -_dy),
          ),
          child: widget.animatedGridViewEntity.child,
        ),
      ),
    );
  }

  Offset _getOffset({
    required AnimatedGridViewEntity animatedGridViewEntity,
  }) {
    final originalOffset = animatedGridViewEntity.originalOffset;
    final updatedOffset = animatedGridViewEntity.updatedOffset;

    final dx = originalOffset.dx - updatedOffset.dx;
    final dy = originalOffset.dy - updatedOffset.dy;

    return Offset(dx, dy);
  }

  double get _dx {
    final animatedGridViewEntity = widget.animatedGridViewEntity;
    final originalOffset = animatedGridViewEntity.originalOffset;
    final updatedOffset = animatedGridViewEntity.updatedOffset;

    return originalOffset.dx - updatedOffset.dx;
  }

  double get _dy {
    final animatedGridViewEntity = widget.animatedGridViewEntity;
    final originalOffset = animatedGridViewEntity.originalOffset;
    final updatedOffset = animatedGridViewEntity.updatedOffset;

    return originalOffset.dy - updatedOffset.dy;
  }
}

class AnimatedGridViewSingleChildLayoutDelegate
    extends SingleChildLayoutDelegate {
  final Offset offset;

  AnimatedGridViewSingleChildLayoutDelegate({required this.offset});

  @override
  bool shouldRelayout(
      covariant AnimatedGridViewSingleChildLayoutDelegate oldDelegate) {
    return true; // oldDelegate.offset != offset;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return offset;
  }
}
