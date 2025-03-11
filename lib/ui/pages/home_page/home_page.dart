import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/ui/widgets/repack_slider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage(
      {super.key,
      required this.scaffoldContext,
      required this.newRepacks,
      required this.popularRepacks,
      required this.updatedRepacks,
      required this.openRepackPage});
  BuildContext scaffoldContext;
  final List<Repack> newRepacks;
  final List<Repack> popularRepacks;
  final List<Repack> updatedRepacks;
  final Function openRepackPage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BoxConstraints constraints =const BoxConstraints.expand();
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.black.withOpacity(0.2),
      ),
      child: Builder(
        builder: (BuildContext context) {
          widget.scaffoldContext = context;
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:24),
                  child: RepackSlider(
                      repacksList: widget.newRepacks,
                      title: 'New Repacks',
                      onRepackTap: (repack) {
                        widget.openRepackPage(repack: repack);
                      }),
                ),
                RepackSlider(
                    repacksList: widget.popularRepacks,
                    title: 'Popular Repacks',
                    onRepackTap: (repack) {
                      widget.openRepackPage(repack: repack);
                    }),
                // RepackSlider(
                //     repacksList: widget.updatedRepacks,
                //     title: 'Updated Repacks',
                //     onRepackTap: (repack) {
                //       widget.openRepackPage(repack: repack);
                //     }),
              ],
            ),
          );
        },
      ),
    );
  }
}
