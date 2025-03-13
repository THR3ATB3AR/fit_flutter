import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/ui/widgets/repack_item.dart';
import 'package:flutter/material.dart';

class RepackSlider extends StatefulWidget {
  final List<Repack> repacksList;
  final String title;
  final Function(Repack) onRepackTap;
  const RepackSlider(
      {super.key,
      required this.repacksList,
      required this.title,
      required this.onRepackTap});

  @override
  State<RepackSlider> createState() => _RepackSliderState();
}

class _RepackSliderState extends State<RepackSlider> {
  final ScrollController _scrollController = ScrollController();

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
                itemCount: widget.repacksList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: RepackItem(repack: widget.repacksList[index]),
                    onTap: () {
                      widget.onRepackTap(widget.repacksList[index]);
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
