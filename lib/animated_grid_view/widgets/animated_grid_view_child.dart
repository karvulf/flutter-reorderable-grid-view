import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/animated_grid_view/entities/animated_grid_view_entity.dart';

typedef OnCreatedFunction = AnimatedGridViewEntity? Function(
  AnimatedGridViewEntity animatedGridViewEntity,
  GlobalKey key,
);

typedef OnMovingFinished = void Function(
  AnimatedGridViewEntity animatedGridViewEntity,
);

class AnimatedGridViewChild extends StatefulWidget {
  final AnimatedGridViewEntity animatedGridViewEntity;

  final OnCreatedFunction onCreated;
  final OnMovingFinished onMovingFinished;

  const AnimatedGridViewChild({
    required this.animatedGridViewEntity,
    required this.onCreated,
    required this.onMovingFinished,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedGridViewChild> createState() => _AnimatedGridViewChildState();
}

class _AnimatedGridViewChildState extends State<AnimatedGridViewChild>
    with SingleTickerProviderStateMixin {
  final _globalKey = GlobalKey();

  Offset _delegateOffset = Offset.zero;

  bool isCreated = false;

  late AnimationController animationController;
  late Animation _animationDx;
  late Animation _animationDy;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _updateAnimationTranslation(startAnimation: false);

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final gridViewEntity = widget.onCreated(
        widget.animatedGridViewEntity,
        _globalKey,
      );
      if (gridViewEntity != null) {
        _delegateOffset = _getDelegateOffset(gridViewEntity);
        _updateAnimationTranslation();

        setState(() {
          isCreated = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedGridViewChild oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldUpdatedOrderId = oldWidget.animatedGridViewEntity.updatedOrderId;
    final newUpdatedOrderId = widget.animatedGridViewEntity.updatedOrderId;
    if (oldUpdatedOrderId != newUpdatedOrderId) {
      final originalOffset = widget.animatedGridViewEntity.originalOffset;
      final newUpdatedOffset = widget.animatedGridViewEntity.updatedOffset;
      print(
          'Original offset originalOffset $originalOffset, Update in offset $newUpdatedOffset for child ${widget.animatedGridViewEntity.child.key}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !widget.animatedGridViewEntity.isBuilding,
      maintainAnimation: true,
      maintainSize: true,
      maintainState: true,
      child: Container(
        key: _globalKey,
        transform: Matrix4.translationValues(
          _animationDx.value,
          _animationDy.value,
          0,
        ),
        child: CustomSingleChildLayout(
          delegate: AnimatedGridViewSingleChildLayoutDelegate(
            offset: _delegateOffset,
          ),
          child: widget.animatedGridViewEntity.child,
        ),
      ),
    );
  }

  Offset _getDelegateOffset(AnimatedGridViewEntity animatedGridViewEntity) {
    final key = animatedGridViewEntity.child.key;
    final originalOffset = animatedGridViewEntity.originalOffset;
    final updatedOffset = animatedGridViewEntity.updatedOffset;
    final difference = originalOffset - updatedOffset;
    print('**** key $key with diff $difference ****');
    return difference;
  }

  void _updateAnimationTranslation({
    bool startAnimation = true,
  }) {
    _animationDx = _getAnimation(_delegateOffset.dx * -1);
    _animationDy = _getAnimation(_delegateOffset.dy * -1);

    if (startAnimation) {
      animationController.forward();
    }
  }

  Animation<double> _getAnimation(double value) {
    return Tween<double>(
      begin: 0,
      end: value,
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
