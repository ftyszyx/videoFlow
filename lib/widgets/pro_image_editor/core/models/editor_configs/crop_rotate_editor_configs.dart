import 'package:flutter/material.dart';

import '/features/crop_rotate_editor/enums/crop_mode.enum.dart';
import '/features/crop_rotate_editor/models/aspect_ratio_item.dart';
import '/features/crop_rotate_editor/models/rotate_direction.dart';
import '../custom_widgets/crop_rotate_editor_widgets.dart';
import '../icons/crop_rotate_editor_icons.dart';
import '../styles/crop_rotate_editor_style.dart';
import 'utils/editor_safe_area.dart';
export '/features/crop_rotate_editor/models/rotate_direction.dart';
export '/features/crop_rotate_editor/models/transform_configs.dart';
export '../custom_widgets/crop_rotate_editor_widgets.dart';
export '../icons/crop_rotate_editor_icons.dart';
export '../styles/crop_rotate_editor_style.dart';

/// Configuration options for a crop and rotate editor.
///
/// `CropRotateEditorConfigs` allows you to define various settings for a
/// crop and rotate editor. You can enable or disable specific features like
/// cropping, rotating, and maintaining aspect ratio. Additionally, you can
/// specify an initial aspect ratio for cropping.
///
/// Example usage:
/// ```dart
/// CropRotateEditorConfigs(
///   enabled: true,
///   enabledRotate: true,
///   enabledAspectRatio: true,
///   initAspectRatio: CropAspectRatios.custom,
/// );
/// ```
class CropRotateEditorConfigs {
  /// Creates an instance of CropRotateEditorConfigs with optional settings.
  ///
  /// By default, all options are enabled, and the initial aspect ratio is set
  /// to `CropAspectRatios.custom`.
  const CropRotateEditorConfigs({
    this.desktopCornerDragArea = 7,
    this.mobileCornerDragArea = kMinInteractiveDimension,
    this.enabled = true,
    this.showRotateButton = true,
    this.showFlipButton = true,
    this.showAspectRatioButton = true,
    this.showResetButton = true,
    this.invertMouseScroll = false,
    this.invertDragDirection = false,
    this.initialCropMode = CropMode.rectangular,
    this.enableTransformLayers = true,
    this.enableProvideImageInfos = false,
    this.enableDoubleTap = true,
    this.enableFlipAnimation = true,
    this.showLayers = true,
    this.initAspectRatio,
    this.rotateAnimationCurve = Curves.decelerate,
    this.scaleAnimationCurve = Curves.decelerate,
    this.cropDragAnimationCurve = Curves.decelerate,
    this.flipAnimationCurve = Curves.decelerate,
    this.fadeInOutsideCropAreaAnimationCurve = Curves.decelerate,
    this.rotateDirection = RotateDirection.left,
    this.opacityOutsideCropAreaDuration = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 250),
    this.fadeInOutsideCropAreaAnimationDuration =
        const Duration(milliseconds: 350),
    this.cropDragAnimationDuration = const Duration(milliseconds: 400),
    this.maxScale = 7,
    this.mouseScaleFactor = 0.1,
    this.doubleTapScaleFactor = 2,
    this.aspectRatios = const [
      AspectRatioItem(text: 'Free', value: -1),
      AspectRatioItem(text: 'Original', value: 0.0),
      AspectRatioItem(text: '1*1', value: 1.0 / 1.0),
      AspectRatioItem(text: '4*3', value: 4.0 / 3.0),
      AspectRatioItem(text: '3*4', value: 3.0 / 4.0),
      AspectRatioItem(text: '16*9', value: 16.0 / 9.0),
      AspectRatioItem(text: '9*16', value: 9.0 / 16.0)
    ],
    this.safeArea = const EditorSafeArea(),
    this.style = const CropRotateEditorStyle(),
    this.icons = const CropRotateEditorIcons(),
    this.widgets = const CropRotateEditorWidgets(),
    this.maxWidthFactor,
  })  : assert(maxScale >= 1, 'maxScale must be greater than or equal to 1'),
        assert(desktopCornerDragArea > 0,
            'desktopCornerDragArea must be positive'),
        assert(
            mobileCornerDragArea > 0, 'mobileCornerDragArea must be positive'),
        assert(
            maxWidthFactor == null ||
                (maxWidthFactor > 0 && maxWidthFactor <= 1),
            'maxWidthFactor must be greater than 0 and less than 1'),
        assert(doubleTapScaleFactor > 1,
            'doubleTapScaleFactor must be greater than 1');

  /// Indicates whether the editor is enabled.
  final bool enabled;

  /// Whether to show a button to rotate the image.
  final bool showRotateButton;

  /// Whether to show a button to flip the image.
  final bool showFlipButton;

  /// Whether to show a button to change the aspect ratio.
  final bool showAspectRatioButton;

  /// Whether to show a button to reset all transformations.
  final bool showResetButton;

  /// Show the layers from the main-editor.
  final bool showLayers;

  /// Layers will also be transformed like the crop-rotate image.
  final bool enableTransformLayers;

  /// Enables double-tap zoom functionality when set to true.
  final bool enableDoubleTap;

  /// Enables flip-animation when set to true.
  final bool enableFlipAnimation;

  /// Determines if the mouse scroll direction should be inverted.
  final bool invertMouseScroll;

  /// Determines if the drag direction should be inverted.
  final bool invertDragDirection;

  /// The initial crop mode to be used when the crop/rotate editor is opened.
  ///
  /// This determines the default cropping behavior or aspect ratio that will be
  /// presented to the user before any manual adjustments are made.
  final CropMode initialCropMode;

  /// A boolean flag that determines whether the `imageInfos` parameter
  /// should be included in the `onDone` callback.
  ///
  /// When set to `true`, the `imageInfos` parameter will be provided in the
  /// `onDone` callback of the crop editor, containing detailed information
  /// about the edited image. If set to `false`, `imageInfos` will be `null`.
  final bool enableProvideImageInfos;

  /// The initial aspect ratio for cropping.
  ///
  /// For free aspect ratio use `-1` and for original aspect ratio use `0.0`.
  final double? initAspectRatio;

  /// The maximum scale allowed for the view.
  final double maxScale;

  /// The scaling factor applied to mouse scrolling.
  final double mouseScaleFactor;

  /// The scaling factor applied when double-tapping.
  final double doubleTapScaleFactor;

  /// Specifies the maximum width factor for scaling the content.
  ///
  /// - **Android**: The default value is `0.9`. This setting resolves an issue
  ///  related to the back button functionality, as outlined in
  ///  [GitHub Issue #303](https://github.com/hm21/pro_image_editor/issues/303).
  ///
  /// - **Other Platforms**: The default value is `1.0`, which allows the
  ///  content to utilize the full available width without any scaling
  ///  adjustment.
  ///
  /// This property can be customized to fine-tune the scaling behavior based
  /// on the specific requirements of the platform or application context.
  final double? maxWidthFactor;

  /// The allowed aspect ratios for cropping.
  ///
  /// For free aspect ratio use `-1` and for original aspect ratio use `0.0`.
  final List<AspectRatioItem> aspectRatios;

  /// The duration for the animation controller that handles rotation and
  /// scale animations.
  final Duration animationDuration;

  /// The duration of drag-crop animations.
  final Duration cropDragAnimationDuration;

  /// Fade in animation from content outside the crop area.
  final Duration fadeInOutsideCropAreaAnimationDuration;

  /// The duration of the outside crop area opacity.
  final Duration opacityOutsideCropAreaDuration;

  /// The curve used for the rotation animation.
  final Curve rotateAnimationCurve;

  /// The curve used for the flip animation.
  final Curve flipAnimationCurve;

  /// The curve used for the scale animation, which is triggered when the
  /// image needs to resize due to rotation.
  final Curve scaleAnimationCurve;

  /// The animation curve used for crop animations.
  final Curve cropDragAnimationCurve;

  /// The animation curve used for the fade in animation from content outside
  /// the crop area.
  final Curve fadeInOutsideCropAreaAnimationCurve;

  /// The direction in which the image will be rotated.
  final RotateDirection rotateDirection;

  /// Defines the size of the draggable area on corners of the crop rectangle
  /// for desktop devices.
  final double desktopCornerDragArea;

  /// Defines the size of the draggable area on corners of the crop rectangle
  /// for mobile devices.
  final double mobileCornerDragArea;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;

  /// Style configuration for the crop and rotate editor.
  final CropRotateEditorStyle style;

  /// Icons used in the crop and rotate editor.
  final CropRotateEditorIcons icons;

  /// Widgets associated with the crop and rotate editor.
  final CropRotateEditorWidgets widgets;

  /// Creates a copy of this `CropRotateEditorConfigs` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [CropRotateEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  CropRotateEditorConfigs copyWith({
    bool? enabled,
    bool? showRotateButton,
    bool? showFlipButton,
    bool? showAspectRatioButton,
    bool? showResetButton,
    bool? showLayers,
    bool? enableTransformLayers,
    bool? enableDoubleTap,
    bool? enableFlipAnimation,
    bool? invertMouseScroll,
    bool? invertDragDirection,
    CropMode? initialCropMode,
    bool? enableProvideImageInfos,
    double? initAspectRatio,
    double? maxScale,
    double? mouseScaleFactor,
    double? doubleTapScaleFactor,
    double? maxWidthFactor,
    List<AspectRatioItem>? aspectRatios,
    Duration? animationDuration,
    Duration? cropDragAnimationDuration,
    Duration? fadeInOutsideCropAreaAnimationDuration,
    Duration? opacityOutsideCropAreaDuration,
    Curve? rotateAnimationCurve,
    Curve? flipAnimationCurve,
    Curve? scaleAnimationCurve,
    Curve? cropDragAnimationCurve,
    Curve? fadeInOutsideCropAreaAnimationCurve,
    RotateDirection? rotateDirection,
    double? desktopCornerDragArea,
    double? mobileCornerDragArea,
    EditorSafeArea? safeArea,
    CropRotateEditorStyle? style,
    CropRotateEditorIcons? icons,
    CropRotateEditorWidgets? widgets,
  }) {
    return CropRotateEditorConfigs(
      enabled: enabled ?? this.enabled,
      showRotateButton: showRotateButton ?? this.showRotateButton,
      showFlipButton: showFlipButton ?? this.showFlipButton,
      showAspectRatioButton:
          showAspectRatioButton ?? this.showAspectRatioButton,
      showResetButton: showResetButton ?? this.showResetButton,
      showLayers: showLayers ?? this.showLayers,
      enableTransformLayers:
          enableTransformLayers ?? this.enableTransformLayers,
      enableDoubleTap: enableDoubleTap ?? this.enableDoubleTap,
      enableFlipAnimation: enableFlipAnimation ?? this.enableFlipAnimation,
      invertMouseScroll: invertMouseScroll ?? this.invertMouseScroll,
      invertDragDirection: invertDragDirection ?? this.invertDragDirection,
      initialCropMode: initialCropMode ?? this.initialCropMode,
      enableProvideImageInfos:
          enableProvideImageInfos ?? this.enableProvideImageInfos,
      initAspectRatio: initAspectRatio ?? this.initAspectRatio,
      maxScale: maxScale ?? this.maxScale,
      mouseScaleFactor: mouseScaleFactor ?? this.mouseScaleFactor,
      doubleTapScaleFactor: doubleTapScaleFactor ?? this.doubleTapScaleFactor,
      maxWidthFactor: maxWidthFactor ?? this.maxWidthFactor,
      aspectRatios: aspectRatios ?? this.aspectRatios,
      animationDuration: animationDuration ?? this.animationDuration,
      cropDragAnimationDuration:
          cropDragAnimationDuration ?? this.cropDragAnimationDuration,
      fadeInOutsideCropAreaAnimationDuration:
          fadeInOutsideCropAreaAnimationDuration ??
              this.fadeInOutsideCropAreaAnimationDuration,
      opacityOutsideCropAreaDuration:
          opacityOutsideCropAreaDuration ?? this.opacityOutsideCropAreaDuration,
      rotateAnimationCurve: rotateAnimationCurve ?? this.rotateAnimationCurve,
      flipAnimationCurve: flipAnimationCurve ?? this.flipAnimationCurve,
      scaleAnimationCurve: scaleAnimationCurve ?? this.scaleAnimationCurve,
      cropDragAnimationCurve:
          cropDragAnimationCurve ?? this.cropDragAnimationCurve,
      fadeInOutsideCropAreaAnimationCurve:
          fadeInOutsideCropAreaAnimationCurve ??
              this.fadeInOutsideCropAreaAnimationCurve,
      rotateDirection: rotateDirection ?? this.rotateDirection,
      desktopCornerDragArea:
          desktopCornerDragArea ?? this.desktopCornerDragArea,
      mobileCornerDragArea: mobileCornerDragArea ?? this.mobileCornerDragArea,
      safeArea: safeArea ?? this.safeArea,
      style: style ?? this.style,
      icons: icons ?? this.icons,
      widgets: widgets ?? this.widgets,
    );
  }
}
