import "package:flutter/material.dart";
import "package:hifumi/pages/onboarding/welcome.dart";
import "package:hifumi/pages/settings/language_picker.dart";
import "package:hifumi/pages/settings/edition_picker.dart";
import "package:hifumi/services/services_barrel.dart" show SPInterface, DSInterface;

/// As implied, show this to the user on the first run.
/// For now it's only displaying a [LanguagePicker] and [EditionPicker].
class OnboardingPage extends StatefulWidget {
  final SPInterface st;
  final DSInterface ds;

  const OnboardingPage({
    Key? key,
    required this.st,
    required this.ds,
  }) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    // Trying to mimic flutter's default page route transition animation
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutQuint);
        return ScaleTransition(scale: Tween<double>(begin: .7, end: 1.0).animate(curvedAnimation), child: child);
      },
      child: switch (_step) {
        2 => EditionPicker(
          key: UniqueKey(),
          st: this.widget.st,
          onDone: () {
            this.widget.st.writeOnboarding(false);
            Navigator.pushReplacementNamed(context, "/");
          },
        ),
        1 => LanguagePicker(
          key: UniqueKey(),
          st: this.widget.st,
          ds: this.widget.ds,
          buttonText: "Next",
          onDone: () {
            setState(() {
              _step = 2;
            });
          },
        ),
        0 || _ => Welcome(
          key: UniqueKey(),
          st: this.widget.st,
          // ds: this.widget.ds,
          onDone: () {
            setState(() {
              _step = 1;
            });
          },
        ),
      },
    );
  }
}
