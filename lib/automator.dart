import 'package:flutter/foundation.dart';
import 'package:wonders/router.dart';

/// A helper class for automating actions in the Wonderous app.
///
/// This is for reproducing consistent scenarios for recording performance
/// profiles in Chrome DevTools.
class Automator {
  Automator._();

  static final instance = Automator._();

  ValueListenable<bool> get automating => _automating;
  final _automating = ValueNotifier(false);

  Future<void> beginAutomation() async {
    _automating.value = true;

    appRouter.go(ScreenPaths.home);
    callAction(AutomationAction.homeScreenReset);

    for (int i = 0; i < 4; i++) {
      await Future.delayed(
        _shortDelay,
        () => callAction(AutomationAction.homeScreenNext),
      );
    }

    // Open the details for the current Wonder.
    await Future.delayed(
      _moderateDelay,
      () => callAction(AutomationAction.homeScreenShowDetailsPage),
    );

    // Scroll to the bottom of the editorial.
    await Future.delayed(
      _moderateDelay,
      () => callAction(AutomationAction.editorialScrollToBottom),
    );
    await Future.delayed(
      _moderateDelay,
      () => callAction(AutomationAction.switchDetailsTabToPhotos),
    );
    await Future.delayed(
      _moderateDelay,
      () => callAction(AutomationAction.switchDetailsTabToArtifacts),
    );
    await Future.delayed(
      _moderateDelay,
      () => callAction(AutomationAction.switchDetailsTabToTimeline),
    );

    _automating.value = false;
  }

  void stopAutomation() {
    _automating.value = false;
  }

  final actions = <AutomationAction, VoidCallback>{};
  void registerAction(AutomationAction action, VoidCallback callback) {
    actions[action] = callback;
  }

  void callAction(AutomationAction action) {
    final callback = actions[action];
    callback?.call();
  }
}

enum AutomationAction {
  homeScreenReset,
  homeScreenNext,
  homeScreenShowDetailsPage,
  editorialScrollToBottom,
  switchDetailsTabToPhotos,
  switchDetailsTabToArtifacts,
  switchDetailsTabToTimeline,
}

const _shortDelay = Duration(milliseconds: 1500);
const _moderateDelay = Duration(seconds: 2);
const _longDelay = Duration(seconds: 4);
