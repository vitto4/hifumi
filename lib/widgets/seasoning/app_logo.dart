import "package:flutter/material.dart";
import "package:hifumi/abstractions/app_info.dart";
import "package:flutter_svg/flutter_svg.dart";

/// It's showtime for the ✨ epic logo ✨ I've managed to craft !
class AppLogo extends StatelessWidget {
  const AppLogo({
    Key? key,
  }) : super(key: key);

  static const double _logoHeight = 160.0;
  static const double _logoAspectRatio = 87.0 / 32.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: SvgPicture.asset(
          "assets/logo.svg",
          semanticsLabel: "${AppInfo.name} logo",
          height: _logoHeight,
          width: _logoAspectRatio * _logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
