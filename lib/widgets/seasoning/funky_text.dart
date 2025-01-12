import "dart:async";
import "package:flutter/material.dart";
import "package:hifumi/entities/entities_barrel.dart";

/// M  k s  y u    e t  l o    i e  t a .
///  a  e    o r  t x    o k  l k    h t
class FunkyText extends StatefulWidget {
  final String text;

  const FunkyText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  State<FunkyText> createState() => _FunkyTextState();
}

class _FunkyTextState extends State<FunkyText> {
  int ticker = 0;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 750), (Timer timer) => tick());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void tick() {
    setState(() {
      (ticker < widget.text.length) ? ticker += 1 : ticker = 0;
    });
  }

  final TextStyle _style = const TextStyle(
    fontSize: FontSizes.medium,
    fontFamily: "NewTegomin",
    fontWeight: FontWeight.w600,
    color: LightTheme.textColorDimmer,
  );

  List<Widget> builder() {
    List<Widget> output = [];

    for (int i = 0; i < widget.text.length; i++) {
      output.add(
        Column(
          children: [
            !(ticker == i + 1) ? const Spacer(flex: 1) : Container(),
            Text(
              widget.text[i],
              style: _style,
            ),
            ticker == i + 1 ? const Spacer(flex: 1) : Container(),
          ],
        ),
      );
    }

    return output;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SizedBox(
        height: FontSizes.medium + 10.0,
        child: Row(
          children: builder(),
        ),
      ),
    );
  }
}
