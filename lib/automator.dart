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
    if (_automating.value) {
      // short-circuit
      return;
    }
    _automating.value = true;

    appRouter.go(ScreenPaths.home);

    for (var action in [
      AutomationAction.homeScreenReset,
      AutomationAction.homeScreenNext,
      AutomationAction.homeScreenNext,
      AutomationAction.homeScreenNext,
      AutomationAction.homeScreenNext,
      AutomationAction.homeScreenShowDetailsPage,
      AutomationAction.editorialScrollToBottom,
      AutomationAction.switchDetailsTabToPhotos,
      AutomationAction.switchDetailsTabToArtifacts,
      AutomationAction.switchDetailsTabToTimeline,
    ]) {
      await Future.delayed(action.delay, () => _callAction(action));
      if (!_automating.value) {
        return;
      }
    }

    await Future.delayed(_shortDelay);

    stopAutomation();
  }

  void stopAutomation() {
    if (_automating.value) {
      _automating.value = false;
    }
  }

  final _actions = <AutomationAction, VoidCallback>{};
  void registerAction(AutomationAction action, VoidCallback callback) {
    _actions[action] = callback;
  }

  void _callAction(AutomationAction action) {
    final callback = _actions[action];
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
  switchDetailsTabToTimeline;

  Duration get delay => switch (this) {
        AutomationAction.homeScreenNext => _shortDelay,
        _ => _moderateDelay,
      };
}

const _shortDelay = Duration(milliseconds: 1500);
const _moderateDelay = Duration(seconds: 2);
