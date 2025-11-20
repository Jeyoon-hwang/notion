class AppSettings {
  bool palmRejection;
  bool isDarkMode;
  bool autoShapeEnabled;
  bool showGridLines;
  double defaultLineWidth;
  double defaultOpacity;

  AppSettings({
    this.palmRejection = false,
    this.isDarkMode = false,
    this.autoShapeEnabled = false,
    this.showGridLines = false,
    this.defaultLineWidth = 3.0,
    this.defaultOpacity = 1.0,
  });

  AppSettings copyWith({
    bool? palmRejection,
    bool? isDarkMode,
    bool? autoShapeEnabled,
    bool? showGridLines,
    double? defaultLineWidth,
    double? defaultOpacity,
  }) {
    return AppSettings(
      palmRejection: palmRejection ?? this.palmRejection,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoShapeEnabled: autoShapeEnabled ?? this.autoShapeEnabled,
      showGridLines: showGridLines ?? this.showGridLines,
      defaultLineWidth: defaultLineWidth ?? this.defaultLineWidth,
      defaultOpacity: defaultOpacity ?? this.defaultOpacity,
    );
  }
}
