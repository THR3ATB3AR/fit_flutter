import 'package:fit_flutter/data_classes/repack.dart';
import 'package:flutter/material.dart';

class RepackInfoSection extends StatelessWidget {
  const RepackInfoSection({
    super.key,
    required this.selectedRepack,
  });

  final Repack? selectedRepack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.black.withOpacity(0.2),
      ),
      child: Padding(
        padding:
            const EdgeInsets
                .all(8.0),
        child: Text.rich(
          TextSpan(
              text:
                  'Genres: ${selectedRepack?.genres}\n',
              children: [
                TextSpan(
                  text:
                      'Company: ${selectedRepack?.company}\n',
                ),
                TextSpan(
                  text:
                      'Language: ${selectedRepack?.language}\n',
                ),
                TextSpan(
                  text:
                      'Original Size: ${selectedRepack?.originalSize}\n',
                ),
                TextSpan(
                    text:
                        'Repack Size: ${selectedRepack?.repackSize}'),
              ]),
        ),
      ),
    );
  }
}

