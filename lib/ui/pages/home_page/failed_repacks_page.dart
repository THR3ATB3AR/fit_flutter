import 'package:flutter/material.dart';
import 'package:fit_flutter/services/repack_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FailedRepacksPage extends StatefulWidget {
  const FailedRepacksPage({super.key});

  @override
  State<FailedRepacksPage> createState() => _FailedRepacksPageState();
}

class _FailedRepacksPageState extends State<FailedRepacksPage> {
  BoxConstraints constraints = const BoxConstraints.expand();
  late Future<Map<String, String>> _failedRepacksFuture;

  @override
  void initState() {
    super.initState();
    _failedRepacksFuture = _loadFailedRepacks();
  }

  Future<Map<String, String>> _loadFailedRepacks() async {
    await RepackService.instance.loadRepacks();
    return RepackService.instance.failedRepacks;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: FutureBuilder<Map<String, String>>(
        future: _failedRepacksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No failed repacks found.'));
          } else {
            final failedRepacks = snapshot.data!;
            return ListView.builder(
              itemCount: failedRepacks.length,
              itemBuilder: (BuildContext context, int index) {
                final title = failedRepacks.keys.elementAt(index);
                final url = failedRepacks.values.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse(url));
                  },
                  child: Card(
                    elevation: 1,
                    color: Colors.transparent,
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text(url),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
