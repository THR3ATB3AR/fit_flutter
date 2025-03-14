import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/left_info_section.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/right_info_section.dart';
import 'package:flutter/material.dart';

class RepackPage extends StatefulWidget {
  const RepackPage(
      {super.key, required this.selectedRepack, required this.goHome});
  final Repack? selectedRepack;
  final Function goHome;

  @override
  State<RepackPage> createState() => _RepackPageState();
}

class _RepackPageState extends State<RepackPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.black.withValues(alpha: 0.2),
      ),
      child: widget.selectedRepack == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: 200, minWidth: 100),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            widget.goHome('home');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0),
                                          ),
                                          child: const Icon(
                                              Icons.arrow_back_outlined)),
                                    ),
                                  ),
                                  LeftInfoSection(
                                    selectedRepack: widget.selectedRepack,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: RightInfoSection(
                                  constraints: constraints,
                                  selectedRepack: widget.selectedRepack,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
