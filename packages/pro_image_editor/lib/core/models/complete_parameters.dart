import 'package:flutter/foundation.dart';

import '../../features/filter_editor/utils/combine_color_matrix_utils.dart';
import 'layers/layer.dart';

/// A data class that contains all parameters needed for applying visual
/// transformations and filters to a video frame or image.
///
/// Includes cropping, rotation, flipping, blur, and color adjustments.
class CompleteParameters {
  /// Creates a [CompleteParameters] instance with all required values.
  CompleteParameters({
    required this.blur,
    required this.matrixFilterList,
    required this.matrixTuneAdjustmentsList,
    required this.startTime,
    required this.endTime,
    required this.cropWidth,
    required this.cropHeight,
    required this.rotateTurns,
    required this.cropX,
    required this.cropY,
    required this.flipX,
    required this.flipY,
    required this.image,
    required this.isTransformed,
    required this.layers,
  });

  /// The blur strength to apply (in logical pixels).
  final double blur;

  /// List of color filter matrices (e.g. sepia, noir).
  final List<List<double>> matrixFilterList;

  /// List of color tuning adjustment matrices (e.g. brightness, contrast).
  final List<List<double>> matrixTuneAdjustmentsList;

  /// All active color filters including both tuning and filter matrices.
  List<List<double>> get colorFilters => [
        ...matrixTuneAdjustmentsList,
        ...matrixFilterList,
      ];

  /// Combined color filter matrix from all filters and adjustments.
  List<double> get colorFiltersCombined {
    return mergeColorMatrices(
      filterList: matrixFilterList,
      tuneAdjustmentList: matrixTuneAdjustmentsList,
    );
  }

  /// The time where processing should start.
  final Duration? startTime;

  /// The time where processing should end.
  final Duration? endTime;

  /// The target crop width in pixels (optional).
  final int? cropWidth;

  /// The target crop height in pixels (optional).
  final int? cropHeight;

  /// Number of clockwise 90° rotations to apply.
  final int rotateTurns;

  /// The horizontal crop offset (optional).
  final int? cropX;

  /// The vertical crop offset (optional).
  final int? cropY;

  /// Whether to flip the image horizontally.
  final bool flipX;

  /// Whether to flip the image vertically.
  final bool flipY;

  /// The image data as a [Uint8List].
  final Uint8List image;

  /// Whether the video has any transformation (e.g. crop, scale, rotate, flip).
  /// This flag is typically used to optimize rendering or skip transformation
  /// logic when it's not needed.
  final bool isTransformed;

  /// A list of visual layers (e.g. text, stickers, overlays) that should be
  /// rendered on top of the video during export.
  final List<Layer> layers;

  /// Creates a copy of this [CompleteParameters] object with optional new
  /// values for specific fields.
  CompleteParameters copyWith({
    double? blur,
    List<List<double>>? matrixFilterList,
    List<List<double>>? matrixTuneAdjustmentsList,
    Duration? startTime,
    Duration? endTime,
    int? cropWidth,
    int? cropHeight,
    int? rotateTurns,
    int? cropX,
    int? cropY,
    bool? flipX,
    bool? flipY,
    Uint8List? image,
    bool? isTransformed,
    List<Layer>? layers,
  }) {
    return CompleteParameters(
      blur: blur ?? this.blur,
      matrixFilterList: matrixFilterList ?? this.matrixFilterList,
      matrixTuneAdjustmentsList:
          matrixTuneAdjustmentsList ?? this.matrixTuneAdjustmentsList,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cropWidth: cropWidth ?? this.cropWidth,
      cropHeight: cropHeight ?? this.cropHeight,
      rotateTurns: rotateTurns ?? this.rotateTurns,
      cropX: cropX ?? this.cropX,
      cropY: cropY ?? this.cropY,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      image: image ?? this.image,
      isTransformed: isTransformed ?? this.isTransformed,
      layers: layers ?? this.layers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CompleteParameters &&
        other.blur == blur &&
        listEquals(other.colorFilters, colorFilters) &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.cropWidth == cropWidth &&
        other.cropHeight == cropHeight &&
        other.rotateTurns == rotateTurns &&
        other.cropX == cropX &&
        other.cropY == cropY &&
        other.flipX == flipX &&
        other.flipY == flipY &&
        other.image == image &&
        other.isTransformed == isTransformed &&
        listEquals(other.layers, layers);
  }

  @override
  int get hashCode {
    return blur.hashCode ^
        colorFilters.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        cropWidth.hashCode ^
        cropHeight.hashCode ^
        rotateTurns.hashCode ^
        cropX.hashCode ^
        cropY.hashCode ^
        flipX.hashCode ^
        flipY.hashCode ^
        image.hashCode ^
        isTransformed.hashCode ^
        layers.hashCode;
  }
}
