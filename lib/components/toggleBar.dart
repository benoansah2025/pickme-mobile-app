import 'dart:collection';

import 'package:flutter/material.dart';

/// A horizontal bar of toggle tabs with customisable colors and labels.
///
/// The provided list of labels are laid out as tabs in a horizontal manner. The states of the tabs
/// are handled internally and the index of the selected tab is updated via [onSelectionUpdated].
class ToggleBar extends StatefulWidget {
  /// TextStyle for the labels.
  final TextStyle labelTextStyle;

  /// Background color of the toggle bar.
  final Color backgroundColor;

  /// Background border of the toggle bar.
  final BoxBorder? backgroundBorder;

  /// Color of the selected tab.
  final Color selectedTabColor;

  /// Color of text in the selected tab. This will override [color] in [labelTextStyle].
  final Color selectedTextColor;

  /// Color of text in unselected tabs. If the tab is selected, text color will be overriden by [selectedTextColor].
  final Color textColor;

  /// Labels to be displayed as tabs in the toggle bar.
  final List<String>? labels;

  /// Callback function which returns the index of the currently selected tab.
  final Function(int)? onSelectionUpdated;

  /// Border radius of the bar and selected tab indicator.
  final double borderRadius;

  final double? widthDivider;

  final int selectedIndex;

  const ToggleBar({
    super.key,
    @required this.labels,
    this.backgroundColor = Colors.black,
    this.backgroundBorder,
    this.selectedTabColor = Colors.deepPurple,
    this.selectedTextColor = Colors.white,
    this.textColor = Colors.white,
    this.labelTextStyle = const TextStyle(),
    this.onSelectionUpdated,
    this.borderRadius = 50,
    this.widthDivider,
    this.selectedIndex = 0,
  });

  @override
  State<StatefulWidget> createState() {
    return _ToggleBarState();
  }
}

class _ToggleBarState extends State<ToggleBar> {
  LinkedHashMap<String, bool> _hashMap = LinkedHashMap();
  int _selectedIndex = 0;
  bool _isInitialSetup = true;

  @override
  void initState() {
    super.initState();
    _hashMap = LinkedHashMap.fromIterable(widget.labels!, value: (value) => value = false);
    _hashMap[widget.labels![0]] = true;
    _selectedIndex = widget.selectedIndex;
    _updateSelection(widget.selectedIndex);
    _isInitialSetup = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: widget.backgroundBorder,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: ListView.builder(
        itemCount: widget.labels!.length,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
              child: Container(
                width: (widget.widthDivider != null
                        ? ((MediaQuery.of(context).size.width * widget.widthDivider!) - 32)
                        : (MediaQuery.of(context).size.width - 32)) /
                    widget.labels!.length,
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: _hashMap.values.elementAt(index) ? widget.selectedTabColor : null,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Text(
                  _hashMap.keys.elementAt(index),
                  textAlign: TextAlign.center,
                  style: widget.labelTextStyle.apply(
                    color: _hashMap.values.elementAt(index) ? widget.selectedTextColor : widget.textColor,
                  ),
                ),
              ),
              onHorizontalDragUpdate: (dragUpdate) async {
                int calculatedIndex = ((widget.labels!.length *
                                (dragUpdate.globalPosition.dx /
                                    ((widget.widthDivider != null
                                        ? ((MediaQuery.of(context).size.width * widget.widthDivider!) - 32)
                                        : (MediaQuery.of(context).size.width - 32)))))
                            .round() -
                        1)
                    .clamp(0, widget.labels!.length - 1);

                if (calculatedIndex != _selectedIndex) {
                  _updateSelection(calculatedIndex);
                }
              },
              onTap: () async {
                if (index != _selectedIndex) {
                  _updateSelection(index);
                }
              });
        },
      ),
    );
  }

  _updateSelection(int index) {
    _selectedIndex = index;
    if (!_isInitialSetup) {
      widget.onSelectionUpdated!(_selectedIndex);
    }
    _hashMap.updateAll((label, selected) => selected = false);
    _hashMap[_hashMap.keys.elementAt(index)] = true;
    if (mounted) setState(() {});
  }
}
