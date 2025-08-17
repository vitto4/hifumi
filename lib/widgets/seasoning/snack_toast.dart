import "package:flutter/material.dart";
import "package:hifumi/abstractions/abstractions_barrel.dart";

/// This is clearly a snackbar and not a toast.
/// But I named it like that so embrace the chaos (:
class SnackToast {
  const SnackToast();

  static SnackBar bar({
    Key? key,
    required String text,
    bool confused = true,
  }) => SnackBar(
    key: key,
    content: Row(
      children: <Widget>[
        if (confused)
          const Text(
            "(・・ ) ?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: FontSizes.medium,
              color: LightTheme.forestGreenLighter,
            ),
          ),
        const SizedBox(width: 13.0),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: LightTheme.base),
          ),
        ),
      ],
    ),
    shape: const RoundedRectangleBorder(
      side: BorderSide(
        color: LightTheme.forestGreen,
        width: 1.5,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
    ),
    elevation: .0,
    showCloseIcon: true,
    behavior: SnackBarBehavior.floating,
    backgroundColor: LightTheme.forestGreenLight,
  );
}
