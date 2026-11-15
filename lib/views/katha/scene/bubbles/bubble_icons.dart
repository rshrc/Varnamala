import 'dart:ui';

import 'package:words625/views/katha/scene/bubbles/bubble_icon_pen.dart';
import 'package:words625/views/katha/scene/bubbles/icons/home_icons.dart';
import 'package:words625/views/katha/scene/bubbles/icons/life_icons.dart';
import 'package:words625/views/katha/scene/bubbles/icons/signs_icons.dart';
import 'package:words625/views/katha/scene/bubbles/icons/work_icons.dart';

/// Every icon a picture bubble can show, by name.
const _icons = <String, BubbleIconPainter>{
  ...homeIcons,
  ...workIcons,
  ...lifeIcons,
  ...signsIcons,
};

/// Every icon a picture bubble can show.
final kathaBubbleIcons = _icons.keys.toList();

/// Draws [icon] to fill [box]. An unknown name draws nothing.
void drawBubbleIcon(Canvas canvas, String icon, Rect box) =>
    _icons[icon]?.call(BubbleIconPen(canvas, box));
