import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/animated_grid_view_entity.dart';

typedef OnCreatedFunction = void Function(
  AnimatedGridViewEntity animatedGridViewEntity,
  GlobalKey key,
);

typedef OnMovingFinished = void Function(
  AnimatedGridViewEntity animatedGridViewEntity,
);

class AnimatedGridViewChild extends StatefulWidget {
  final AnimatedGridViewEntity animatedGridViewEntity;

  final OnCreatedFunction onCreated;
  final OnCreatedFunction onBuilding;
  final OnMovingFinished onMovingFinished;

  const AnimatedGridViewChild({
    required this.animatedGridViewEntity,
    required this.onCreated,
    required this.onBuilding,
    required this.onMovingFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedGridViewChild> createState() => _AnimatedGridViewChildState();
}

class _AnimatedGridViewChildState extends State<AnimatedGridViewChild>
    with SingleTickerProviderStateMixin {
  final _globalKey = GlobalKey();

  late AnimationController animationController;
  late Animation<double> _animationDx;
  late Animation<double> _animationDy;

  @override
  void initState() {
    super.initState();

    print(
        'AnimatedGridView: Created ${widget.animatedGridViewEntity.child.key}');

    animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animationDx = Tween<double>(begin: 0, end: 0).animate(animationController);
    _animationDy = Tween<double>(begin: 0, end: 0).animate(animationController);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      widget.onCreated(
        widget.animatedGridViewEntity,
        _globalKey,
      );
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedGridViewChild oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animatedGridViewEntity != widget.animatedGridViewEntity) {
      print(
          'AnimatedGridView: Updated ${widget.animatedGridViewEntity.child.key}');

      if (widget.animatedGridViewEntity.isBuilding) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          widget.onBuilding(
            widget.animatedGridViewEntity,
            _globalKey,
          );
        });
      }
      animationController.reset();
      _updateAnimationTranslation();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //    '${widget.animatedGridViewEntity.child.key}: _animationDx $_animationDx');
    return Container(
      key: _globalKey,
      transform: Matrix4.translationValues(
        _animationDx.value,
        _animationDy.value,
        0,
      ),
      child: widget.animatedGridViewEntity.child,
    );
  }

  void _updateAnimationTranslation() {
    final offsetDiff = _getOffsetDiff(widget.animatedGridViewEntity);
    _animationDx = _getAnimation(offsetDiff.dx * -1);
    _animationDy = _getAnimation(offsetDiff.dy * -1);

    if (offsetDiff.dx != 0 || offsetDiff.dy != 0) {
      animationController.forward();
    }
  }

  Offset _getOffsetDiff(AnimatedGridViewEntity animatedGridViewEntity) {
    final originalOffset = animatedGridViewEntity.originalOffset;
    final updatedOffset = animatedGridViewEntity.updatedOffset;
    return originalOffset - updatedOffset;
  }

  Animation<double> _getAnimation(double value) {
    return Tween<double>(
      begin: -value,
      end: 0,
    ).animate(animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onMovingFinished(widget.animatedGridViewEntity);
        }
      });
  }
}
