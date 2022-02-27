import 'package:equatable/equatable.dart';

class OrderUpdateEntity extends Equatable {
  final int oldIndex;
  final int newIndex;

  const OrderUpdateEntity({
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
