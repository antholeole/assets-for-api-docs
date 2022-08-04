// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:diagrams/diagrams.dart';
import 'package:diagrams/src/text_editing_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class CupertinoTextMagnifierDiagram extends StatelessWidget
    implements DiagramMetadata {
  const CupertinoTextMagnifierDiagram(this.name, {Key? key}) : super(key: key);

  static final GlobalKey textFieldKey = GlobalKey();
  static final TextEditingController textEditingController =
      TextEditingController(text: 'hello world!');
  static const Duration duratonBetweenTaps = Duration(milliseconds: 30);
  static const Size exampleScreenshotSize = Size(300.0, 144.0);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return buildWithTextFieldBoilerplate(
      appSize: exampleScreenshotSize,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 30.0),
        child: Center(
          child: TextField(
            key: textFieldKey,
            selectionControls: CupertinoTextSelectionControls(),
            controller: TextEditingController(text: textEditingController.text),
          ),
        ),
      ),
    );
  }
}

class CupertinoTextMagnifierDiagramStep
    extends DiagramStep<CupertinoTextMagnifierDiagram> {
  CupertinoTextMagnifierDiagramStep(DiagramController controller)
      : super(controller);

  @override
  final String category = 'cupertino';

  @override
  Future<List<CupertinoTextMagnifierDiagram>> get diagrams async =>
      <CupertinoTextMagnifierDiagram>[
        const CupertinoTextMagnifierDiagram('cupertino_text_magnifier'),
      ];

  @override
  Future<File> generateDiagram(CupertinoTextMagnifierDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    // Double tap the 'e' to select 'hello'.
    final Offset tapOffset = textOffsetToPosition(
      CupertinoTextMagnifierDiagram.textFieldKey,
      CupertinoTextMagnifierDiagram.textEditingController.text.indexOf('e'),
    );

    final TestGesture testGesture = await controller.startGesture(tapOffset);
    await controller
        .advanceTime(CupertinoTextMagnifierDiagram.duratonBetweenTaps);
    await testGesture.up();
    await controller
        .advanceTime(CupertinoTextMagnifierDiagram.duratonBetweenTaps);
    await testGesture.down(tapOffset);
    await controller
        .advanceTime(CupertinoTextMagnifierDiagram.duratonBetweenTaps);
    await testGesture.up();
    await controller
        .advanceTime(CupertinoTextMagnifierDiagram.duratonBetweenTaps);

    // Get the position of the right selection handle.
    final RenderEditable renderEditable =
        findRenderEditable(CupertinoTextMagnifierDiagram.textFieldKey);
    final List<TextSelectionPoint> endpoints = globalizeTextSelectionPoints(
      renderEditable.getEndpointsForSelection(
          CupertinoTextMagnifierDiagram.textEditingController.selection),
      renderEditable,
    );

    final Offset handlePos = endpoints.last.point + const Offset(1.0, 1.0);

    // Create a drag gesture so the Magnifier shows.
    final TestGesture gesture = await controller.startGesture(handlePos);

    await gesture.moveTo(textOffsetToPosition(
      CupertinoTextMagnifierDiagram.textFieldKey,
      CupertinoTextMagnifierDiagram.textEditingController.text.indexOf('o'),
    ));

    // Give the magnifier time to show itself.
    controller.advanceTime(const Duration(seconds: 1));

    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}
