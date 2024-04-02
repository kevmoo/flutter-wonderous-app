import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:wonders/router.dart';

/// A helper class for automating actions in the Wonderous app.
///
/// This is for reproducing consistent scenarios for recording performance
/// profiles in Chrome DevTools.
class Automator {
  Automator._();

  late final _bindings = WidgetsFlutterBinding.ensureInitialized();

  final _totalSpans = <FrameTiming>[];

  static final instance = Automator._();

  ValueListenable<bool> get automating => _automating;
  final _automating = ValueNotifier(false);

  Future<void> beginAutomation() async {
    if (_automating.value) {
      // short-circuit
      return;
    }
    try {
      _automating.value = true;

      _totalSpans.clear();
      _bindings.addTimingsCallback(_timingsCallback);

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
          // cancel out early if automation has stopped!
          return;
        }
      }

      await Future.delayed(_shortDelay);
    } finally {
      stopAutomation();
    }
  }

  void stopAutomation() {
    if (_automating.value) {
      _automating.value = false;

      _bindings.removeTimingsCallback(_timingsCallback);

      if (_totalSpans.isNotEmpty) {
        final things = <String, Duration Function(FrameTiming)>{
          'totalSpan': (ft) => ft.totalSpan,
          'buildDuration': (ft) => ft.buildDuration,
        };

        for (var thing in things.entries) {
          final timing = _totalSpans
              .map((e) => thing.value(e).inMicroseconds)
              .toList(growable: false)
            ..sort();

          print('*****');
          print(thing.key);
          for (var item in const [50, 90, 95, 99]) {
            final index = timing.length * item ~/ 100.0;
            print(
              [item, (timing[index] / 1000.0).toStringAsFixed(2)]
                  .map((e) => e.toString().padLeft(6))
                  .join('  '),
            );
          }
          print('');
          print('*****');
        }
      }
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

  void _timingsCallback(List<FrameTiming> timings) {
    assert(
      _automating.value,
      'Automation should be running when these events are fired',
    );
    _totalSpans.addAll(timings);
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
