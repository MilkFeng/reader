import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../managers/settings/models.dart';
import '../style_state.dart';

class StyleSheet extends StatefulWidget {
  const StyleSheet({super.key});

  @override
  State<StatefulWidget> createState() => _StyleSheetState();
}

class _StyleSheetState extends State<StyleSheet> {
  late StyleBundle styleBundleSnapShot;

  @override
  void initState() {
    super.initState();
    styleBundleSnapShot = context.read<StyleState>().styleBundle;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSectionSliderItem(
    String label,
    String valueLabel, {
    double min = 0,
    double max = 1,
    double value = 0.5,
    int? divisions,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          Expanded(
            child: Slider(
              label: valueLabel,
              divisions: divisions,
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSwitchItem(
    String label, {
    String? subLabel,
    bool value = false,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (subLabel != null)
                Text(
                  subLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionItemTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 32,
    );
  }

  List<Widget> _buildColorEditItems(
    Color color, {
    required Function(Color) onChanged,
  }) {
    final red = (color.r * 255).round();
    final green = (color.g * 255).round();
    final blue = (color.b * 255).round();
    final alpha = (color.a * 255).round();
    return [
      _buildSectionSliderItem(
        "红色",
        "$red",
        min: 0,
        max: 255,
        value: red.toDouble(),
        onChanged: (value) {
          onChanged(Color.fromARGB(alpha, value.round(), green, blue));
        },
      ),
      _buildSectionSliderItem(
        "绿色",
        "$green",
        min: 0,
        max: 255,
        value: green.toDouble(),
        onChanged: (value) {
          onChanged(Color.fromARGB(alpha, red, value.round(), blue));
        },
      ),
      _buildSectionSliderItem(
        "蓝色",
        "$blue",
        min: 0,
        max: 255,
        value: blue.toDouble(),
        onChanged: (value) {
          onChanged(Color.fromARGB(alpha, red, green, value.round()));
        },
      ),
      _buildSectionSliderItem(
        "不透明度",
        "$alpha",
        min: 0,
        max: 255,
        value: alpha.toDouble(),
        onChanged: (value) {
          onChanged(Color.fromARGB(value.round(), red, green, blue));
        },
      ),
    ];
  }

  List<Widget> _buildColorSchemaEditItems(
    ColorSchema schema, {
    required Function(ColorSchema) onChanged,
  }) {
    return [
      _buildSectionItemTitle("背景颜色"),
      ..._buildColorEditItems(
        schema.backgroundColor,
        onChanged: (color) {
          onChanged(schema.copyWith(backgroundColor: color));
        },
      ),
      const SizedBox(height: 8),
      _buildSectionItemTitle("字体颜色"),
      ..._buildColorEditItems(
        schema.textColor,
        onChanged: (color) {
          onChanged(schema.copyWith(textColor: color));
        },
      ),
    ];
  }

  Future<void> _setStyleBundle(StyleBundle styleBundle) async {
    StyleState styleState = context.read<StyleState>();
    styleBundleSnapShot = styleBundle;
    setState(() {});
    await styleState.setStyleBundle(styleBundle);
  }

  Future<void> _setUseCustomParagraphStyle(bool value) async {
    await _setStyleBundle(
      styleBundleSnapShot.copyWith(useCustomParagraphStyle: value),
    );
  }

  Future<void> _setFontSize(double fontSize) async {
    await _setStyleBundle(
      styleBundleSnapShot.copyWith(fontSize: fontSize),
    );
  }

  Future<void> _setLetterSpacing(double letterSpacing) async {
    await _setStyleBundle(
      styleBundleSnapShot.copyWith(letterSpacing: letterSpacing),
    );
  }

  Future<void> _setUseThemeColorSchema(bool value) async {
    await _setStyleBundle(
      styleBundleSnapShot.copyWith(useThemeColorSchema: value),
    );
  }

  Future<void> _deleteColorSchema() async {
    final newColorSchemas = styleBundleSnapShot.colorSchemas
        .whereIndexed(
            (i, _) => i != styleBundleSnapShot.selectedColorSchemaIndex)
        .toList();
    final newSelectedIndex =
        styleBundleSnapShot.selectedColorSchemaIndex >= newColorSchemas.length
            ? newColorSchemas.length - 1
            : styleBundleSnapShot.selectedColorSchemaIndex;
    await _setStyleBundle(
      styleBundleSnapShot.copyWith(
        colorSchemas: newColorSchemas,
        selectedColorSchemaIndex: newSelectedIndex,
      ),
    );
  }

  Future<void> _addColorSchema() async {
    final newColorSchemas = List.of(styleBundleSnapShot.colorSchemas)
      ..add(ColorSchema.defaultColorSchema);
    await _setStyleBundle(
      styleBundleSnapShot.copyWith(
        colorSchemas: newColorSchemas,
        selectedColorSchemaIndex: newColorSchemas.length - 1,
      ),
    );
  }

  Future<void> _setSelectedColorSchema(ColorSchema colorSchema) async {
    final newColorSchemas = List.of(styleBundleSnapShot.colorSchemas)
      ..[styleBundleSnapShot.selectedColorSchemaIndex] = colorSchema;
    await _setStyleBundle(
      styleBundleSnapShot.copyWith(colorSchemas: newColorSchemas),
    );
  }

  Future<void> _setSelectedColorSchemaIndex(int index) async {
    await _setStyleBundle(
      styleBundleSnapShot.copyWith(selectedColorSchemaIndex: index),
    );
  }

  Future<void> _setPadding(double padding) async {
    await _setStyleBundle(
      styleBundleSnapShot.copyWith(padding: padding),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return ListView(
      padding: EdgeInsets.only(top: 0, bottom: bottom, left: 0, right: 0),
      children: [
        _buildSectionTitle("字体和段落"),
        _buildSectionSwitchItem(
          "使用自定义格式",
          subLabel: "开启后将使用自定义字体及段落格式",
          value: styleBundleSnapShot.useCustomParagraphStyle,
          onChanged: _setUseCustomParagraphStyle,
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: styleBundleSnapShot.useCustomParagraphStyle ? null : 0,
            child: Column(
              children: [
                // 字体大小：10 - 40
                _buildSectionSliderItem(
                  "字大小",
                  "${styleBundleSnapShot.fontSize.round()}px",
                  min: 10,
                  max: 40,
                  divisions: 40 - 10,
                  value: styleBundleSnapShot.fontSize,
                  onChanged: _setFontSize,
                ),
                _buildSectionSliderItem(
                  "字间距",
                  "${styleBundleSnapShot.letterSpacing.toStringAsFixed(1)}em",
                  value: styleBundleSnapShot.letterSpacing,
                  min: -1.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: _setLetterSpacing,
                ),
              ],
            ),
          ),
        ),
        _buildDivider(),
        _buildSectionTitle("背景和颜色"),
        _buildSectionSwitchItem(
          "使用主题颜色",
          subLabel: "开启后将使用所选主题颜色",
          value: styleBundleSnapShot.useThemeColorSchema,
          onChanged: _setUseThemeColorSchema,
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: !styleBundleSnapShot.useThemeColorSchema ? null : 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Wrap(
                    spacing: 8,
                    children: styleBundleSnapShot.colorSchemas
                        .mapIndexed(
                          (i, schema) => ChoiceChip(
                            label: Text("主题 ${i + 1}"),
                            shape: StadiumBorder(),
                            onSelected: (selected) {
                              if (selected) {
                                _setSelectedColorSchemaIndex(i);
                              }
                            },
                            selected:
                                styleBundleSnapShot.selectedColorSchemaIndex ==
                                    i,
                            backgroundColor: schema.backgroundColor,
                            labelStyle: TextStyle(
                              color: schema.textColor,
                            ),
                            selectedColor: schema.backgroundColor,
                            iconTheme: IconThemeData(
                              color: schema.textColor,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              // child: TextField(
                              //   style: Theme.of(context).textTheme.titleLarge,
                              //   decoration: InputDecoration(
                              //     hintText: "命名预设",
                              //     border: InputBorder.none,
                              //     contentPadding:
                              //         EdgeInsets.only(left: 16, right: 16),
                              //   ),
                              // ),
                              child: Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Text(
                                  "主题 ${styleBundleSnapShot.selectedColorSchemaIndex + 1}",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            ),
                            if (styleBundleSnapShot.colorSchemas.length > 1)
                              IconButton(
                                onPressed: _deleteColorSchema,
                                icon: Icon(Icons.delete),
                              ),
                            IconButton(
                              onPressed: _addColorSchema,
                              icon: Icon(Icons.add),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._buildColorSchemaEditItems(
                          styleBundleSnapShot.colorSchemas[
                              styleBundleSnapShot.selectedColorSchemaIndex],
                          onChanged: _setSelectedColorSchema,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildDivider(),
        _buildSectionTitle("页面"),
        _buildSectionSliderItem(
          "页边距",
          "${styleBundleSnapShot.padding.round()}",
          min: 0,
          max: 100,
          divisions: 100,
          value: styleBundleSnapShot.padding,
          onChanged: _setPadding,
        ),
      ],
    );
  }
}
