import 'package:flutter/gestures.dart';

/// Class that holds interactions for a layer item.
class LayerItemInteractions {
  /// Constructor for LayerItemInteractions.
  ///
  /// Requires all callbacks to be provided.
  LayerItemInteractions({
    required this.edit,
    required this.remove,
    required this.duplicated,
    required this.scaleRotateDown,
    required this.scaleRotateUp,
    required this.group,
    required this.ungroup,
  });

  /// Callback function for editing the layer.
  final Function() edit;

  /// Callback triggered when a layer should be copied.
  final Function() duplicated;

  /// Callback function for removing the layer.
  final Function() remove;

  /// Callback function triggered when a scale/rotate gesture starts.
  ///
  /// This function is required to initiate the scaling and rotation
  /// operations on the layer.
  final Function(PointerDownEvent event) scaleRotateDown;

  /// Callback function triggered when a scale/rotate gesture ends.
  ///
  /// This function is required to finalize the scaling and rotation
  /// operations on the layer, applying the changes.
  final Function(PointerUpEvent event) scaleRotateUp;

  /// Callback function for grouping layers.
  ///
  /// This function groups the currently selected layers together by assigning
  /// them the same groupId. When any layer in the group is selected, all
  /// layers in the group will be selected automatically.
  final Function() group;

  /// Callback function for ungrouping layers.
  ///
  /// This function ungroups the layer by removing its groupId, allowing it
  /// to be selected independently from other layers.
  final Function() ungroup;
}
