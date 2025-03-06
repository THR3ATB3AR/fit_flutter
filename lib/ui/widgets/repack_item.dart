import 'package:flutter/material.dart';
import 'package:fit_flutter/data_classes/repack.dart';

class RepackItem extends StatelessWidget {
  final Repack repack;

  const RepackItem({super.key, required this.repack});

  String _overflowText(String text, int maxLength) {
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        verticalOffset: 120,
        exitDuration: const Duration(milliseconds: 0),
        richMessage: TextSpan(
          text: '${_overflowText(repack.title, 30)}\n',
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: '${_overflowText('Genre: ${repack.genres},', 30)}\n',
            ),
            TextSpan(
              text: '${_overflowText('Company: ${repack.company}', 30)}\n',
            ),
            TextSpan(
              text: '${_overflowText('Language: ${repack.language}', 30)}\n',
            ),
            TextSpan(
              text:
                  '${_overflowText('Original Size: ${repack.originalSize}', 30)}\n',
            ),
            TextSpan(
                text: _overflowText('Repack Size: ${repack.repackSize}', 30)),
          ],
        ),
        child: Card(
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(repack.cover, fit: BoxFit.cover),
          ),
        ));
  }
}
