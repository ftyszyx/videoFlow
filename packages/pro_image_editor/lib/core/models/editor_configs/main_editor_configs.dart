import 'package:flutter/widgets.dart';

import '/features/crop_rotate_editor/models/transform_configs.dart';
import '/shared/utils/decode_image.dart';
import '../custom_widgets/main_editor_widgets.dart';
import '../icons/main_editor_icons.dart';
import '../styles/main_editor_style.dart';
import 'utils/editor_safe_area.dart';
import 'utils/zoom_configs.dart';

export '../custom_widgets/main_editor_widgets.dart';
export '../icons/main_editor_icons.dart';
export '../styles/main_editor_style.dart';

/// Configuration options for a main editor.
class MainEditorConfigs extends ZoomConfigs {
  /// Creates an instance of MainEditorConfigs with optional settings.
  const MainEditorConfigs({
    super.enableZoom,
    super.editorMinScale,
    super.editorMaxScale,
    super.enableDoubleTapZoom,
    super.doubleTapZoomFactor,
    super.doubleTapZoomDuration,
    super.doubleTapZoomCurve,
    super.boundaryMargin,
    super.invertTrackpadDirection,
    this.transformSetup,
    this.enableCloseButton = true,
    this.enableEscapeButton = true,
    this.canZoomWhenLayerSelected = true,
    this.mobilePanInteraction = MobilePanInteraction.move,
    this.style = const MainEditorStyle(),
    this.icons = const MainEditorIcons(),
    this.widgets = const MainEditorWidgets(),
    this.safeArea = const EditorSafeArea(),
  });

  /// Determines whether the close button is displayed on the widget.
  final bool enableCloseButton;

  /// Defines the configuration for pan interactions on mobile devices.
  ///
  /// This property specifies how users can interact with the editor
  /// using pan gestures on mobile platforms. It allows customization
  /// of the behavior and sensitivity of panning actions.
  final MobilePanInteraction mobilePanInteraction;

  /// A boolean flag to enable or disable the escape button functionality.
  ///
  /// When set to `true`, the escape button will be enabled, allowing users
  /// to exit the editor or perform a specific action when the escape button
  /// is pressed. When set to `false`, the escape button will be disabled.
  ///
  /// This flag has no effect when the `onEscapeButton` callback is set.
  final bool enableEscapeButton;

  /// Determines whether zooming is allowed when a layer is selected in the
  /// editor.
  ///
  /// If set to `true`, users can zoom in or out while a layer is selected.
  /// If set to `false`, zooming is disabled when a layer is selected.
  final bool canZoomWhenLayerSelected;

  /// Initializes the editor with pre-configured transformations,
  /// such as cropping, based on the provided setup.
  final MainEditorTransformSetup? transformSetup;

  /// Style configuration for the main editor.
  final MainEditorStyle style;

  /// Icons used in the main editor.
  final MainEditorIcons icons;

  /// Widgets associated with the main editor.
  final MainEditorWidgets widgets;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;

  /// Creates a copy of this `MainEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [MainEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  MainEditorConfigs copyWith({
    bool? enableCloseButton,
    bool? enableEscapeButton,
    MainEditorTransformSetup? transformSetup,
    MainEditorStyle? style,
    MainEditorIcons? icons,
    MainEditorWidgets? widgets,
    bool? enableZoom,
    double? editorMinScale,
    double? editorMaxScale,
    EdgeInsets? boundaryMargin,
    bool? enableDoubleTapZoom,
    bool? canZoomWhenLayerSelected,
    MobilePanInteraction? mobilePanInteraction,
    bool? invertTrackpadDirection,
    double? doubleTapZoomFactor,
    Duration? doubleTapZoomDuration,
    Curve? doubleTapZoomCurve,
    EditorSafeArea? safeArea,
  }) {
    return MainEditorConfigs(
      enableCloseButton: enableCloseButton ?? this.enableCloseButton,
      enableEscapeButton: enableEscapeButton ?? this.enableEscapeButton,
      transformSetup: transformSetup ?? this.transformSetup,
      style: style ?? this.style,
      icons: icons ?? this.icons,
      widgets: widgets ?? this.widgets,
      enableZoom: enableZoom ?? this.enableZoom,
      editorMinScale: editorMinScale ?? this.editorMinScale,
      editorMaxScale: editorMaxScale ?? this.editorMaxScale,
      enableDoubleTapZoom: enableDoubleTapZoom ?? this.enableDoubleTapZoom,
      canZoomWhenLayerSelected:
          canZoomWhenLayerSelected ?? this.canZoomWhenLayerSelected,
      mobilePanInteraction: mobilePanInteraction ?? this.mobilePanInteraction,
      invertTrackpadDirection:
          invertTrackpadDirection ?? this.invertTrackpadDirection,
      doubleTapZoomFactor: doubleTapZoomFactor ?? this.doubleTapZoomFactor,
      doubleTapZoomDuration:
          doubleTapZoomDuration ?? this.doubleTapZoomDuration,
      doubleTapZoomCurve: doubleTapZoomCurve ?? this.doubleTapZoomCurve,
      boundaryMargin: boundaryMargin ?? this.boundaryMargin,
      safeArea: safeArea ?? this.safeArea,
    );
  }
}

/// A class that encapsulates the configuration and image information
/// required to set up the main editor's transform settings.
class MainEditorTransformSetup {
  /// Creates an instance of [MainEditorTransformSetup] with the required
  /// transformation configurations and image information.
  ///
  /// - [transformConfigs]: The configuration settings for the transformation.
  /// - [imageInfos]: The information about the image to be edited.
  MainEditorTransformSetup({
    required this.transformConfigs,
    this.imageInfos,
  });

  /// The configuration settings for the transformation applied in the main
  /// editor.
  final TransformConfigs transformConfigs;

  /// The information related to the image that will be edited in the main
  /// editor.
  final ImageInfos? imageInfos;

  /// Creates a copy of the current [MainEditorTransformSetup] instance
  /// with the option to override specific fields.
  ///
  /// - [transformConfigs]: Overrides the existing `transformConfigs` if
  /// provided.
  /// - [imageInfos]: Overrides the existing `imageInfos` if provided.
  ///
  /// Returns a new instance of [MainEditorTransformSetup] with the updated
  /// fields.
}

/// Enum representing the different types of pan interactions available
/// in a mobile editor context.
enum MobilePanInteraction {
  /// Allows the user to drag and select elements.
  dragSelect,

  /// Enables moving the canvas.
  move,

  /// Disables any pan interaction.
  none,
}
