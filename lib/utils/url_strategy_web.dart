import 'package:flutter_web_plugins/url_strategy.dart';

void configureUrlStrategy() {
  // Use hash-based URL strategy for GitHub Pages compatibility
  // Path-based strategy doesn't work on GitHub Pages project pages for sub-routes
  setUrlStrategy(HashUrlStrategy());
}
