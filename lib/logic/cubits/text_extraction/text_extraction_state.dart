import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class TextExtractionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TextExtractionInitial extends TextExtractionState {}

class TextExtractionLoading extends TextExtractionState {}

class TextExtractionImageSelected extends TextExtractionState {
  final File image;

  TextExtractionImageSelected(this.image);

  @override
  List<Object?> get props => [image];
}

class TextExtractionSuccess extends TextExtractionState {
  final String extractedText;
  final File image;
  final bool isOffline;

  TextExtractionSuccess(
    this.extractedText,
    this.image, {
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [extractedText, image, isOffline];
}

class TextExtractionError extends TextExtractionState {
  final String message;

  TextExtractionError(this.message);

  @override
  List<Object?> get props => [message];
}
