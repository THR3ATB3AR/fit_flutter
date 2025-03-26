import 'package:fit_flutter/services/repack_service.dart';
import 'package:fit_flutter/ui/widgets/repack_item.dart';
import 'package:flutter/material.dart';

class AllRepacksPage extends StatefulWidget {
  const AllRepacksPage({super.key, required this.openRepackPage});
  final Function openRepackPage;

  @override
  State<AllRepacksPage> createState() => _AllRepacksPageState();
}

class _AllRepacksPageState extends State<AllRepacksPage> {
  final RepackService _repackService = RepackService.instance;
  final ScrollController _scrollController = ScrollController();
  int _currentMax = 50;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() {
        _currentMax += 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: StreamBuilder<void>(
          stream: _repackService.repacksStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final displayedRepacks = _repackService.everyRepack.take(_currentMax).toList();

            return GridView.builder(
              shrinkWrap: true,
              cacheExtent: 100,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.75,
              ),
              itemCount: displayedRepacks.length,
              itemBuilder: (context, index) {
                final repack = displayedRepacks[index];
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
      ),
    );
  }
}