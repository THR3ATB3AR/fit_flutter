import 'package:fit_flutter/data_classes/repack.dart';
import 'package:flutter/material.dart';

class RepackInfoSection extends StatelessWidget {
  const RepackInfoSection({
    super.key,
    required this.selectedRepack,
    required this.constraints,
  });

  final Repack? selectedRepack;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets
              .only(top: 8.0),
      child: Card.filled(
        child: SizedBox(
          width: constraints
                  .maxWidth *
              0.15,
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
        ),
      ),
    );
  }
}

