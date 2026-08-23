import 'package:flutter/material.dart';

/// Thin indeterminate progress bar pinned to the top of the content area.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.listStyle = false});

  /// Kept for call-site compatibility; ignored (top bar replaces skeletons).
  final bool listStyle;

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LinearProgressIndicator(minHeight: 2),
        Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
