import 'package:hive/hive.dart';

part 'cover_style.g.dart';

@HiveType(typeId: 3)
class CoverStyle {
  CoverStyle({
    required this.id,
    required this.name,
    this.backgroundImagePath,
    this.cropLeft,
    this.cropTop,
    this.cropWidth,
    this.cropHeight,
    this.titleX = 0,
    this.titleY = 0,
    this.titleFontSize = 32,
    this.titleColor = 0xFFFFFFFF,
    this.titleAlign = 0,
    this.titleFontFamily,
    this.subX = 0,
    this.subY = 0,
    this.subFontSize = 24,
    this.subColor = 0xFFCCCCCC,
    this.subAlign = 0,
    this.subFontFamily,
  });

  @HiveField(0)
  String id;

  @HiveField(10)
  String name;

  @HiveField(20)
  String? backgroundImagePath;

  // crop rect (relative 0-1 or pixels - consumer decides)
  @HiveField(30)
  double? cropLeft;

  @HiveField(31)
  double? cropTop;

  @HiveField(32)
  double? cropWidth;

  @HiveField(33)
  double? cropHeight;

  // title style
  @HiveField(40)
  double titleX;

  @HiveField(41)
  double titleY;

  @HiveField(42)
  double titleFontSize;

  @HiveField(43)
  int titleColor; // ARGB

  @HiveField(44)
  int titleAlign; // 0: left, 1: center, 2: right

  @HiveField(45)
  String? titleFontFamily;

  // subtitle style
  @HiveField(50)
  double subX;

  @HiveField(51)
  double subY;

  @HiveField(52)
  double subFontSize;

  @HiveField(53)
  int subColor; // ARGB

  @HiveField(54)
  int subAlign;

  @HiveField(55)
  String? subFontFamily;
}
