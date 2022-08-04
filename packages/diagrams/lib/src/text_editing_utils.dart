import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StubLocalizatonDelegate<T> extends LocalizationsDelegate<T> {
  const StubLocalizatonDelegate(this.loader);
  final Future<T> Function(Locale locale) loader;

  static List<LocalizationsDelegate<dynamic>> get requiredStubs =>
      <LocalizationsDelegate<dynamic>>[
        const StubLocalizatonDelegate<MaterialLocalizations>(
            DefaultMaterialLocalizations.load),
        const StubLocalizatonDelegate<WidgetsLocalizations>(
            DefaultWidgetsLocalizations.load),
        const StubLocalizatonDelegate<CupertinoLocalizations>(
            DefaultCupertinoLocalizations.load)
      ];

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<T> load(Locale locale) => loader(locale);

  @override
  bool shouldReload(LocalizationsDelegate<T> old) => false;
}

List<TextSelectionPoint> globalizeTextSelectionPoints(
    Iterable<TextSelectionPoint> points, RenderBox box) {
  return points.map<TextSelectionPoint>((TextSelectionPoint point) {
    return TextSelectionPoint(
      box.localToGlobal(point.point),
      point.direction,
    );
  }).toList();
}

Widget buildWithTextFieldBoilerplate(
    {required Widget child, required Size appSize}) {
  final OverlayEntry entry = OverlayEntry(
    builder: (BuildContext context) {
      return Align(
        alignment: Alignment.topLeft,
        child: Material(
          child: child,
        ),
      );
    },
  );

  return Localizations(
    locale: const Locale('en', 'US'),
    delegates: StubLocalizatonDelegate.requiredStubs,
    child: DefaultTextEditingShortcuts(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(size: appSize),
          child: Overlay(
            initialEntries: <OverlayEntry>[
              // This is intende
              entry,
            ],
          ),
        ),
      ),
    ),
  );
}

RenderEditable findRenderEditable<T extends State<StatefulWidget>>(
    GlobalKey<T> key) {
  final T state = key.currentState!;
  assert(state is TextSelectionGestureDetectorBuilderDelegate,
      'State of textFieldKey must conform to TextSelectionGestureDetectorBuilderDelegate');
  final EditableTextState editableTextState =
      (state as TextSelectionGestureDetectorBuilderDelegate)
          .editableTextKey
          .currentState!;
  return editableTextState.renderEditable;
}

Offset textOffsetToPosition<T extends State<StatefulWidget>>(
  // the global key's state must refer to a TextSelectionGestureDetectorBuilderDelegate.
  GlobalKey<T> textFieldKey,
  int offset,
) {
  final RenderEditable renderEditable = findRenderEditable(textFieldKey);

  final List<TextSelectionPoint> endpoints = renderEditable
      .getEndpointsForSelection(
        TextSelection.collapsed(offset: offset),
      )
      .map<TextSelectionPoint>((TextSelectionPoint point) => TextSelectionPoint(
            renderEditable.localToGlobal(point.point),
            point.direction,
          ))
      .toList();

  return endpoints[0].point + const Offset(0.0, -2.0);
}
