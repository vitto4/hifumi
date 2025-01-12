import "package:flutter/material.dart";
import "package:hifumi/entities/light_theme.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/pages/pages_barrel.dart";

/// Hello there ! If you've decided to read the code for this app, I'll be your guide throughout your journey.
/// This will be unpleasant at times, but worry not, I'll be there to make you even more confused. You're welcome.
void main() => runApp(
      MaterialApp(
        title: "hifumi",
        theme: ThemeData(
          fontFamily: "Varela Round",
          brightness: Brightness.light,
          scaffoldBackgroundColor: LightTheme.base,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              for (final platform in TargetPlatform.values) platform: const ZoomPageTransitionsBuilder(),
            },
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontFamily: "Varela Round",
              ),
            ),
          ),
        ),
        initialRoute: "/",
        onGenerateRoute: (settings) {
          // Spinning up a page without having loaded data BAD >:(    must load instead
          if (settings.arguments is! Map || (settings.arguments as Map)["st"] == null || (settings.arguments as Map)["ds"] == null) {
            return MaterialPageRoute(builder: (context) => const Loading());
          }

          /// Homemade routing, with the added benefit of disabling URL navigation in web.
          ///
          ///   \bugs
          /// (escaping bugs for extra good luck)
          /// (yes, we're doing dad jokes here)
          switch (settings.name) {
            case "/":
              return MaterialPageRoute(builder: (context) => const Loading());
            case "/onboarding":
              return MaterialPageRoute(
                  builder: (context) => OnboardingPage(
                        st: (settings.arguments as Map)["st"] as StorageInterface,
                        ds: (settings.arguments as Map)["ds"] as DSInterface,
                      ));
            case '/home':
              return MaterialPageRoute(
                  builder: (context) => Home(
                        st: (settings.arguments as Map)["st"] as StorageInterface,
                        ds: (settings.arguments as Map)["ds"] as DSInterface,
                      ));
            case '/quiz':
              return MaterialPageRoute(
                  builder: (context) => QuizPage(
                        st: (settings.arguments as Map)["st"] as StorageInterface,
                        ds: (settings.arguments as Map)["ds"] as DSInterface,
                        review: (settings.arguments as Map)["review"] as bool,
                      ));
            case '/settings':
              return MaterialPageRoute(
                  builder: (context) => Settings(
                        st: (settings.arguments as Map)["st"] as StorageInterface,
                        ds: (settings.arguments as Map)["ds"] as DSInterface,
                      ));
            default:
              return MaterialPageRoute(builder: (context) => const Loading());
          }
        },
      ),
    );
