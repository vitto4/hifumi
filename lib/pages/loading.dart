import "dart:async";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:hifumi/services/services_barrel.dart";
import "package:hifumi/widgets/seasoning/funky_text.dart";
import "package:hifumi/widgets/seasoning/app_logo.dart";
import "package:hifumi/widgets/seasoning/console.dart";

/// Loading screen.
/// Its purpose is to load up both the word dataset and user data (from [shared_preferences]) before launching the app.
/// While we're at it, we'll also validate the contents of [shared_preferences].
class Loading extends StatefulWidget {
  const Loading({
    Key? key,
  }) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  final Completer<void> _completer = Completer<void>();

  final GlobalKey<ConsoleWidgetState> _consoleKey = GlobalKey<ConsoleWidgetState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _completer.complete();
    });
  }

  /// Groundwork, load the DS and user data.
  Future<Map<String, dynamic>> _initialize() async {
    // Set the status bar theme to dark, otherwise icons won't be visible
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));

    // Only start the loading process when the loading screen has finished initializing
    // This is done so that we can display everything in the console, though it may add a slight delay
    await _completer.future;

    /* ---------------------------------- Fonts --------------------------------- */
    /// Can be slow to load on the web version, resulting in tofu. We don't want that.
    /// This is an attempt to solve the problem.
    ///
    /// ! We don't do that anymore : https://github.com/flutter/flutter/issues/160185

    // _consoleKey.currentState?.printMessage("Loading fonts");

    // final fontLoaderValera = FontLoader('Varela Round')
    //   ..addFont(
    //     rootBundle.load("fonts/VarelaRound-Regular.ttf"),
    //   );
    // await fontLoaderValera.load();

    // final fontLoaderNotoSansDisplay = FontLoader('NotoSansDisplay')
    //   ..addFont(
    //     rootBundle.load("fonts/NotoSansDisplay-Regular.ttf"),
    //   );
    // await fontLoaderNotoSansDisplay.load();

    // final fontLoaderNotoSansJP = FontLoader('NotoSansJP')
    //   ..addFont(
    //     rootBundle.load("fonts/NotoSansJP.ttf"),
    //   );
    // await fontLoaderNotoSansJP.load();

    // final fontLoaderNotoSerifJP = FontLoader('NotoSerifJP')
    //   ..addFont(
    //     rootBundle.load("fonts/NotoSerifJP.ttf"),
    //   );
    // await fontLoaderNotoSerifJP.load();

    // final fontLoaderNewTegomin = FontLoader('NewTegomin')
    //   ..addFont(
    //     rootBundle.load("fonts/NewTegomin-Regular.ttf"),
    //   );
    // await fontLoaderNewTegomin.load();

    /* --------------------------- Shared preferences --------------------------- */
    _consoleKey.currentState?.printMessage("Loading user data");

    final StorageInterface st = StorageInterface();
    await st.init();
    st.writeDefaults();

    /* ------------------------------ Word dataset ----------------------------- */
    _consoleKey.currentState?.printMessage("Loading dataset");

    final DSInterface ds = DSInterface();
    await ds.init();

    /* --------------------------------- Checkup -------------------------------- */
    _consoleKey.currentState?.printMessage("Validation");

    st.validate(ds);

    // To add the check mark after `"Validation"`
    _consoleKey.currentState?.printMessage("");

    /* ------------------------------------ . ----------------------------------- */
    return {
      "st": st,
      "ds": ds,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Display the loading screen while the app is initializing
    return FutureBuilder(
      future: _initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          (snapshot.data!["st"] as StorageInterface).readOnboarding()
              ? WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, "/onboarding", arguments: snapshot.data);
                })
              : WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, "/home", arguments: snapshot.data);
                });
        }
        return Scaffold(
          body: Center(
            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  height: getLoadingShrink(context) ? 400.0 : constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Spacer(flex: 2),
                      const AppLogo(),
                      const Spacer(flex: 5),
                      ConsoleWidget(
                        key: _consoleKey,
                        initialMessage: "Starting up",
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Row(
                        children: <Widget>[
                          Spacer(),
                          FunkyText(text: "言葉準備中..."),
                          SizedBox(width: 3.0),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
