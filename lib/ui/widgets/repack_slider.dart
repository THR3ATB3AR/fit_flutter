import 'package:fit_flutter/data/repack.dart';
import 'package:fit_flutter/data/repack_list_type.dart';
import 'package:fit_flutter/services/repack_service.dart';
import 'package:fit_flutter/ui/widgets/repack_item.dart';
import 'package:flutter/material.dart';

class RepackSlider extends StatefulWidget {
  final RepackListType repackListType;
  final String title;
  final Function(Repack) onRepackTap;
  const RepackSlider(
      {super.key,
      required this.repackListType,
      required this.title,
      required this.onRepackTap});

  @override
  State<RepackSlider> createState() => _RepackSliderState();
}

class _RepackSliderState extends State<RepackSlider> {
  final ScrollController _scrollController = ScrollController();
  final RepackService _repackService = RepackService.instance;
  late List<Repack> repackList;

  @override
  void initState() {
    super.initState();
    setRepackList(widget.repackListType);
  }

  void setRepackList(RepackListType repackListType) {
    switch (repackListType) {
      case RepackListType.newest:
        repackList = _repackService.newRepacks;
        break;
      case RepackListType.popular:
        repackList = _repackService.popularRepacks;
        break;
      case RepackListType.updated:
        repackList = _repackService.updatedRepacks;
        break;
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 400,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Builder(
          builder: (context) {
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: repackList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: RepackItem(repack: repackList[index]),
                    onTap: () {
                      widget.onRepackTap(repackList[index]);
                    },
                  );
                },
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                  ),
                  onPressed: _scrollLeft,
                  child:
                      const Icon(Icons.keyboard_arrow_left_outlined, size: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                  ),
                  onPressed: _scrollRight,
                  child:
                      const Icon(Icons.keyboard_arrow_right_outlined, size: 30),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
