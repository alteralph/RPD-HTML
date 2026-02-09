import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../styles.dart';
import '../logic.dart';

class GlassContextMenu extends StatelessWidget {
  final EditableTextState editableTextState;
  final bool isDark;

  const GlassContextMenu({
    super.key,
    required this.editableTextState,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context, listen: false);

    final anchors = editableTextState.contextMenuAnchors;
    final textColor = AppStyles.getText(isDark);

    const double outerRadius = 20.0;
    const double padding = 8.0;
    const double itemRadius = 12.0;

    final List<Widget> items = [];
    final selection = editableTextState.textEditingValue.selection;
    final text = editableTextState.textEditingValue.text;

    Widget menuButton(String label, IconData icon, VoidCallback onTap) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap();
            editableTextState.hideToolbar();
          },
          borderRadius: BorderRadius.circular(itemRadius),
          hoverColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          splashColor: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    if (!editableTextState.widget.readOnly && !selection.isCollapsed) {
      // Usa appData.t('cut')
      items.add(menuButton(appData.t('cut'), Icons.content_cut_rounded,
          () => editableTextState.cutSelection(SelectionChangedCause.toolbar)));
    }
    if (!selection.isCollapsed) {
      // Usa appData.t('copy')
      items.add(menuButton(
          appData.t('copy'),
          Icons.content_copy_rounded,
          () =>
              editableTextState.copySelection(SelectionChangedCause.toolbar)));
    }
    if (!editableTextState.widget.readOnly) {
      // Usa appData.t('paste_action') para "Paste"/"Colar"
      items.add(menuButton(
          appData.t('paste_action'),
          Icons.content_paste_rounded,
          () => editableTextState.pasteText(SelectionChangedCause.toolbar)));
    }
    if (text.isNotEmpty && selection.end - selection.start != text.length) {
      // Usa appData.t('select_all')
      items.add(menuButton(appData.t('select_all'), Icons.select_all_rounded,
          () => editableTextState.selectAll(SelectionChangedCause.toolbar)));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    final List<Widget> dividedItems = [];
    for (int i = 0; i < items.length; i++) {
      dividedItems.add(items[i]);
      if (i < items.length - 1) {
        dividedItems.add(Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 1,
            height: 16,
            color: textColor.withValues(alpha: 0.1)));
      }
    }

    final screenSize = MediaQuery.of(context).size;
    final anchor = anchors.primaryAnchor;

    double estimatedWidth = items.length * 90.0;
    double leftPos = (anchor.dx - (estimatedWidth / 2)).roundToDouble();

    if (leftPos < 20) leftPos = 20;
    if (leftPos + estimatedWidth > screenSize.width - 20) {
      leftPos = screenSize.width - estimatedWidth - 20;
    }

    double topPos = (anchor.dy - 80).roundToDouble();
    if (topPos < 50) topPos = (anchor.dy + 40).roundToDouble();

    return Stack(
      children: [
        Positioned(
          top: topPos,
          left: leftPos,
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(outerRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: AppStyles.glassDecorationNoShadow(isDark),
                  padding: const EdgeInsets.all(padding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: dividedItems,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
