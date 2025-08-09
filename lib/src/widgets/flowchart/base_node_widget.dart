// =============================================================================
// BASE NODE WIDGET
// =============================================================================

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'painter/node_painter.dart';
import 'styles/node_styles.dart';

export 'painter/node_painter.dart';
export 'styles/node_styles.dart';

class BaseNodeWidget extends StatelessWidget {
  const BaseNodeWidget({
    super.key,
    required this.text,
    required this.painter,
    this.style = const NodeStyle(),
    this.scaleFactor = 1.0,
    this.initialSize = const Size(140, 70), // Updated size for two-line text
    this.onTap,
  });

  final String text;
  final NodePainter painter;
  final NodeStyle style;
  final double scaleFactor; // 1.0 - 2.0
  final Size initialSize;
  final VoidCallback? onTap;

  static const double _textPadding = 12.0;

  @override
  Widget build(BuildContext context) {
    // Calculate scaled size
    final scaledSize = Size(
      initialSize.width * scaleFactor,
      initialSize.height * scaleFactor,
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: scaledSize.width,
        height: scaledSize.height,
        child: Stack(
          children: [
            // Shape background
            CustomPaint(painter: painter, size: scaledSize),
            // Text content with inline icons
            Center(
              child: Padding(
                padding: const EdgeInsets.all(_textPadding),
                child: _buildRichText(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build RichText with inline FontAwesome icons
  Widget _buildRichText() {
    final segments = _parseTextWithIcons(text);
    final fontSize = _calculateFontSize(scaleFactor);

    return RichText(
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: segments.map((segment) {
          if (segment is TextSegmentText) {
            return TextSpan(
              text: segment.text,
              style: TextStyle(
                color: style.textColor,
                fontSize: fontSize,
                decoration: style.hasLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            );
          } else if (segment is TextSegmentIcon) {
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: FaIcon(
                segment.iconData,
                size: fontSize,
                color: style.textColor,
              ),
            );
          }
          return const TextSpan(text: '');
        }).toList(),
      ),
    );
  }

  /// Calculate appropriate font size based on scale factor
  double _calculateFontSize(double scale) {
    const baseFontSize = 14.0;
    return baseFontSize + (scale - 1.0) * 4.0; // Grows from 14 to 18
  }

  /// Parse text into segments of text and FontAwesome icons
  List<TextSegment> _parseTextWithIcons(String input) {
    final segments = <TextSegment>[];
    final regex = RegExp(r'fa:fa-([a-zA-Z0-9-]+)');
    int lastEnd = 0;

    for (final match in regex.allMatches(input)) {
      // Add text before icon
      if (match.start > lastEnd) {
        final textBefore = input.substring(lastEnd, match.start);
        if (textBefore.isNotEmpty) {
          segments.add(TextSegmentText(textBefore));
        }
      }

      // Add icon
      final iconName = match.group(1)!;
      final iconData = _mapFontAwesomeIcon(iconName);
      if (iconData != null) {
        segments.add(TextSegmentIcon(iconData));
      } else {
        // Fallback: keep original text if icon not found
        segments.add(TextSegmentText(match.group(0)!));
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < input.length) {
      final remainingText = input.substring(lastEnd);
      if (remainingText.isNotEmpty) {
        segments.add(TextSegmentText(remainingText));
      }
    }

    // If no icons found, just return the original text as one segment
    if (segments.isEmpty && input.isNotEmpty) {
      segments.add(TextSegmentText(input));
    }

    return segments;
  }

  /// Map FontAwesome icon names to IconData
  IconData? _mapFontAwesomeIcon(String iconName) {
    // Common FontAwesome Free icons mapping
    const iconMap = {
      // Arrows
      'arrow': FontAwesomeIcons.arrowLeft,
      'arrow-right': FontAwesomeIcons.arrowRight,
      'arrow-left': FontAwesomeIcons.arrowLeft,
      'arrow-up': FontAwesomeIcons.arrowUp,
      'arrow-down': FontAwesomeIcons.arrowDown,
      'chevron-right': FontAwesomeIcons.chevronRight,
      'chevron-left': FontAwesomeIcons.chevronLeft,

      // UI Elements
      'check': FontAwesomeIcons.check,
      'times': FontAwesomeIcons.xmark,
      'plus': FontAwesomeIcons.plus,
      'minus': FontAwesomeIcons.minus,
      'edit': FontAwesomeIcons.penToSquare,
      'trash': FontAwesomeIcons.trash,
      'save': FontAwesomeIcons.floppyDisk,
      'copy': FontAwesomeIcons.copy,

      // Objects & Symbols
      'user': FontAwesomeIcons.user,
      'users': FontAwesomeIcons.users,
      'database': FontAwesomeIcons.database,
      'server': FontAwesomeIcons.server,
      'cog': FontAwesomeIcons.gear,
      'wrench': FontAwesomeIcons.wrench,
      'home': FontAwesomeIcons.house,
      'folder': FontAwesomeIcons.folder,
      'file': FontAwesomeIcons.file,
      'envelope': FontAwesomeIcons.envelope,
      'phone': FontAwesomeIcons.phone,
      'calendar': FontAwesomeIcons.calendar,
      'clock': FontAwesomeIcons.clock,
      'star': FontAwesomeIcons.star,
      'heart': FontAwesomeIcons.heart,
      'bookmark': FontAwesomeIcons.bookmark,
      'flag': FontAwesomeIcons.flag,
      'tag': FontAwesomeIcons.tag,

      // Technology
      'cloud': FontAwesomeIcons.cloud,
      'download': FontAwesomeIcons.download,
      'upload': FontAwesomeIcons.upload,
      'wifi': FontAwesomeIcons.wifi,
      'link': FontAwesomeIcons.link,
      'globe': FontAwesomeIcons.globe,
      'code': FontAwesomeIcons.code,
      'terminal': FontAwesomeIcons.terminal,
      'laptop': FontAwesomeIcons.laptop,
      'mobile': FontAwesomeIcons.mobile,

      // Business & Finance
      'chart-bar': FontAwesomeIcons.chartBar,
      'chart-line': FontAwesomeIcons.chartLine,
      'chart-pie': FontAwesomeIcons.chartPie,
      'dollar-sign': FontAwesomeIcons.dollarSign,
      'euro-sign': FontAwesomeIcons.euroSign,
      'credit-card': FontAwesomeIcons.creditCard,
      'shopping-cart': FontAwesomeIcons.cartShopping,
      'briefcase': FontAwesomeIcons.briefcase,
      'building': FontAwesomeIcons.building,

      // Media & Communication
      'play': FontAwesomeIcons.play,
      'pause': FontAwesomeIcons.pause,
      'stop': FontAwesomeIcons.stop,
      'volume-up': FontAwesomeIcons.volumeHigh,
      'volume-down': FontAwesomeIcons.volumeLow,
      'microphone': FontAwesomeIcons.microphone,
      'video': FontAwesomeIcons.video,
      'camera': FontAwesomeIcons.camera,
      'image': FontAwesomeIcons.image,

      // Status & Alerts
      'info': FontAwesomeIcons.info,
      'warning': FontAwesomeIcons.triangleExclamation,
      'exclamation': FontAwesomeIcons.exclamation,
      'question': FontAwesomeIcons.question,
      'bell': FontAwesomeIcons.bell,
      'shield': FontAwesomeIcons.shield,
      'lock': FontAwesomeIcons.lock,
      'unlock': FontAwesomeIcons.unlock,
      'key': FontAwesomeIcons.key,

      // Directions & Navigation
      'map': FontAwesomeIcons.map,
      'compass': FontAwesomeIcons.compass,
      'location': FontAwesomeIcons.locationArrow,
      'search': FontAwesomeIcons.magnifyingGlass,
      'filter': FontAwesomeIcons.filter,
      'sort': FontAwesomeIcons.sort,

      // Social & Sharing
      'share': FontAwesomeIcons.share,
      'thumbs-up': FontAwesomeIcons.thumbsUp,
      'thumbs-down': FontAwesomeIcons.thumbsDown,
      'comment': FontAwesomeIcons.comment,
      'comments': FontAwesomeIcons.comments,
    };

    return iconMap[iconName];
  }
}
