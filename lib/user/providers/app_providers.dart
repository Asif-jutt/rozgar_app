import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rozgar/user/providers/jobs_feed_provider.dart';

class AppProviders {
  AppProviders._();

  static List<ChangeNotifierProvider> get all => [
        ChangeNotifierProvider(create: (_) => JobsFeedProvider()),
      ];

  static Widget wrap(Widget child) {
    return MultiProvider(
      providers: all,
      child: child,
    );
  }
}
