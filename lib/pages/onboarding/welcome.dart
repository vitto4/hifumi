import 'package:flutter/material.dart';
import 'package:hifumi/abstractions/ui/@screen_orientation.dart';
import 'package:hifumi/abstractions/ui/font_sizes.dart';
import 'package:hifumi/abstractions/ui/themes.dart';
import 'package:hifumi/services/services_barrel.dart';
import 'package:hifumi/widgets/archipelago/island_button.dart';
import 'package:hifumi/widgets/archipelago/island_container.dart';
import 'package:hifumi/widgets/seasoning/app_logo.dart';

class Welcome extends StatefulWidget {
  final SPInterface st;
  final Function onDone;

  const Welcome({
    Key? key,
    required this.st,
    required this.onDone,
  }) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = 0;
  }

  @override
  Widget build(BuildContext context) {
    final bool landscape = getOrientation(context) == ScreenOrientation.landscape;

    return Scaffold(
      backgroundColor: LightTheme.base,
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: landscape ? .57 : .88,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    height: getPickersShrink(context) ? 500.0 : constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            const Spacer(flex: 1),
                            const AppLogo(),
                            const Spacer(flex: 2),
                            FlatIslandContainer(
                              backgroundColor: LightTheme.lightAccent,
                              borderColor: LightTheme.baseAccent,
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: 150.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: AnimatedDialogSwitcher(
                                      // Magic widget that attaches to its child the `key` we pass
                                      // We need to do that otherwise the AnimatedSwitcher won't play when we switch
                                      // to a second widget that's the same type as the first
                                      child: KeyedSubtree(
                                        key: ValueKey<int>(index),
                                        child: _DIALOG_ELEMENTS.elementAt(index),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(flex: 3),
                            IslandButton(
                              backgroundColor: LightTheme.green,
                              borderColor: LightTheme.greenBorder,
                              smartExpand: true,
                              onTap: (index < _DIALOG_ELEMENTS.length - 1)
                                  ? () => setState(() {
                                      index += 1;
                                    })
                                  : widget.onDone,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Text(
                                    _BUTTON_TEXT.elementAt(index),
                                    style: TextStyle(
                                      fontSize: FontSizes.huge,
                                      fontWeight: FontWeight.bold,
                                      color: LightTheme.base,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DialogElement extends StatelessWidget {
  final String title;
  final String text;

  final String titleFontFamily;
  final String textFontFamily;

  final double fontSize;

  final Color textColor;

  const DialogElement({
    Key? key,
    required this.title,
    required this.text,
    this.titleFontFamily = "Roboto",
    this.textFontFamily = "Varela Round",
    this.fontSize = 19.5,
    this.textColor = LightTheme.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(flex: 2),
        Text(
          title,
          style: TextStyle(fontSize: FontSizes.nitpick, color: textColor.withValues(alpha: .5), fontFamily: titleFontFamily),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4.0),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor.withValues(alpha: .8),
            fontFamily: textFontFamily,
          ),
          textAlign: TextAlign.center,
        ),
        Spacer(flex: 3),
      ],
    );
  }
}

class AnimatedDialogSwitcher extends StatelessWidget {
  final Widget child;

  const AnimatedDialogSwitcher({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final fade = Tween<double>(begin: .0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInQuint),
        );
        final slide =
            Tween<Offset>(
              begin: Offset(.15, 0.0),
              end: Offset(.0, 0.0),
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.ease),
            );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: child,
    );
  }
}

const List<Widget> _DIALOG_ELEMENTS = <Widget>[
  DialogElement(
    title: "(* ^ ω ^)",
    text: "Oh, hi there !",
  ),
  DialogElement(
    title: "(・・ ) ?",
    text: "So, I see you're using the Minna no Nihongo Shokyū I & II textbooks ?",
  ),
  DialogElement(
    title: "(´･ᴗ･ ` )",
    text: "Ah, and you could use some help to memorise all of that spooky vocabulary.",
  ),
  DialogElement(
    title: "ദ്ദി(˵ •̀ ᴗ - ˵ ) ✧",
    text: "Hehe, I just so happen to have a set of flashcards waiting for you !",
  ),
  DialogElement(
    title: "(*ᵕᴗᵕㅅ)",
    text: "First, let's get the formalities out of the way.",
  ),
];

const List<String> _BUTTON_TEXT = <String>[
  "Hello !",
  "Yup",
  "Definitely",
  "No way ?",
  "Next",
];
