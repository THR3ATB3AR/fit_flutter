import 'package:dynamic_color/dynamic_color.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:fit_flutter/ui/themes/themes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class DynamicThemeBuilder extends StatefulWidget {
  const DynamicThemeBuilder({
    super.key,
    required this.title,
    required this.home,
  });
  final String title;
  final Widget home;

  @override
  State<DynamicThemeBuilder> createState() => _DynamicThemeBuilderState();
}

class _DynamicThemeBuilderState extends State<DynamicThemeBuilder>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        final ThemeData lightDynamicTheme = ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme?.harmonized(),
        );
        final ThemeData darkDynamicTheme = ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: darkColorScheme?.harmonized(),
        );
        return DynamicTheme(
          themeCollection: ThemeCollection(
            themes: {
              0: darkDynamicTheme,
              1: lightDynamicTheme,
              2: acrylicTheme,
            },
          ),
          builder: (context, theme) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
            debugShowCheckedModeBanner: false,
            title: widget.title,
            theme: theme,
            home: widget.home,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
