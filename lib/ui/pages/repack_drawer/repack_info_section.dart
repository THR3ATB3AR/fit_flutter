import 'package:fit_flutter/data_classes/repack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text.rich(
          TextSpan(
              text:
                  '${AppLocalizations.of(context)!.genres}: ${selectedRepack?.genres}\n',
              children: [
                TextSpan(
                  text:
                      '${AppLocalizations.of(context)!.company}: ${selectedRepack?.company}\n',
                ),
                TextSpan(
                  text:
                      '${AppLocalizations.of(context)!.language}: ${selectedRepack?.language}\n',
                ),
                TextSpan(
                  text:
                      '${AppLocalizations.of(context)!.originalSize}: ${selectedRepack?.originalSize}\n',
                ),
                TextSpan(
                    text:
                        '${AppLocalizations.of(context)!.repackSize}: ${selectedRepack?.repackSize}'),
              ]),
        ),
      ),
    );
  }
}
