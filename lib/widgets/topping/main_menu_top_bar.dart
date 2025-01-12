import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";
import "package:hifumi/services/responsive_layout_niceties.dart";
import "package:hifumi/widgets/seasoning/scroll_to_top_button.dart";
import "package:hifumi/widgets/seasoning/app_logo.dart";
import "package:hifumi/widgets/seasoning/click_me.dart";

/// Upmost piece of the main menu, provides a rock-solid shelter for lesson tiles.
/// Did I hear a rock and stone ??
class MainMenuTopBar extends StatelessWidget {
  final Function openSettings;
  final Widget child;

  const MainMenuTopBar({
    Key? key,
    required this.openSettings,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool landscape = getOrientation(context) == ScreenOrientation.landscape;
    final bool isSettingsButtonAligned = getSettingsButtonAligned(context);

    // FIXME : Implement middle button scroll when Flutter issue #66537 is resolved
    // https://github.com/flutter/flutter/issues/66537
    return ScrollToTopView(
      child: Column(
        children: isSettingsButtonAligned
            ? [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Spacer(),
                          const Padding(
                            padding: EdgeInsets.only(
                              top: 10.0,
                            ),
                            child: AppLogo(),
                          ),
                          Expanded(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(.0, 11.0, .0, .0),
                                child: _SettingsButton(openSettings: openSettings, landscape: landscape),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                this.child,
              ]
            : <Widget>[
                const SizedBox(
                  height: 4.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _SettingsButton(openSettings: openSettings, landscape: landscape),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, .0),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      AppLogo(),
                    ],
                  ),
                ),
                this.child,
              ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({
    Key? key,
    required this.openSettings,
    required this.landscape,
  }) : super(key: key);

  final Function openSettings;
  final bool landscape;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => this.openSettings.call(),
      child: const ClickMePrettyPlease(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: FontSizes.base,
                  color: LightTheme.textColorDim,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                width: 4.0,
              ),
              Icon(
                Icons.settings,
                color: LightTheme.textColorDim,
              ),
              SizedBox(width: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
