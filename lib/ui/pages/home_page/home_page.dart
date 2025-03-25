import 'package:fit_flutter/data/repack_list_type.dart';
import 'package:fit_flutter/services/repack_service.dart';
import 'package:fit_flutter/ui/widgets/repack_item.dart';
import 'package:fit_flutter/ui/widgets/repack_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.openRepackPage});
  final Function openRepackPage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  BoxConstraints constraints = const BoxConstraints.expand();
  final RepackService _repackService = RepackService.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            RepackSlider(
                repackListType: RepackListType.newest,
                title: AppLocalizations.of(context)!.newRepacks,
                onRepackTap: (repack) {
                  widget.openRepackPage(repack: repack);
                }),
            RepackSlider(
                repackListType: RepackListType.popular,
                title: AppLocalizations.of(context)!.popularRepacks,
                onRepackTap: (repack) {
                  widget.openRepackPage(repack: repack);
                }),
            const Padding(
              padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "All Repacks",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            StreamBuilder<void>(
              stream: _repackService.repacksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  cacheExtent: 50,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _repackService.everyRepack.length,
                  itemBuilder: (context, index) {
                    final repack = _repackService.everyRepack[index];
                    return GestureDetector(
                      onTap: () {
                        widget.openRepackPage(repack: repack);
                      },
                      child: RepackItem(repack: repack),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
