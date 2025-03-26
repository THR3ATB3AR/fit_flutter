import 'package:fit_flutter/services/repack_service.dart';
import 'package:fit_flutter/ui/pages/left_drawer/menu_section.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer(
      {super.key,
      //  required this.constraints,
        required this.changeWidget});
  // final BoxConstraints constraints;
  final Function(String) changeWidget;

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  final RepackService _repackService = RepackService.instance;
  late StreamSubscription _repackSubscription;

  @override
  void initState() {
    super.initState();
    _repackSubscription = _repackService.repacksStream.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _repackSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return constraints.maxHeight < 400
                ? SingleChildScrollView(
                    child: SideBar(widget: widget),
                  )
                : SideBar(widget: widget);
          },
        ),
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  const SideBar({
    super.key,
    required this.widget,
  });

  final LeftDrawer widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 4.0, left: 8.0, right: 8.0, top: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.changeWidget('home');
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 21.0),
                ),
                child: const Icon(Icons.home_outlined, size: 30.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 4.0, left: 8.0, right: 8.0, top: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.changeWidget('allRepacks');
                },
                style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 21.0),
                ),
                child: const Icon(Icons.video_library_outlined, size: 30.0),
              ),
            ),
          ],
        ),
        MenuSection(changeWidget: widget.changeWidget),
      ],
    );
  }
}