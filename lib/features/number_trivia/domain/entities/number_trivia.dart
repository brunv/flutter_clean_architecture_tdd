import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// EQUATABLE:
/// By default dart only supports referencial equality, which means that even
/// if two objects are completely identical (same properties, same data) they
/// won't be treated as equal unless they are referencing the same object in
/// memory.
/// With equatable when two object contain the the same values they will be
/// equal, so we don't need to override equal operator.

class NumberTrivia extends Equatable {
  final String text;
  final int number;

  NumberTrivia({
    @required this.text,
    @required this.number,
  });

  @override
  List<Object> get props => [text, number];
}
