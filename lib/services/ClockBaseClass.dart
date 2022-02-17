import 'package:flutter/cupertino.dart';

abstract class ClockBase {
  @protected
  late Duration currentQuatersClock;
  @protected
  late Duration currentShotClock;
  @protected
  late int? resumeQuatersClockMin;
  @protected
  late int? resumeQuatersClockSec;
  @protected
  late int? resumeShotClock;
  @protected
  late bool isClockResume;

  Duration get currentQuatersClockDuration => currentQuatersClock;

  set currentQuatersClockDuration(Duration currentQuatersClockDuration) {
    currentQuatersClock = currentQuatersClockDuration;
  }

  Duration get currentShotClockDuration => currentShotClock;

  set currentShotClockDuration(Duration currentShotClockDuration) {
    currentShotClock = currentShotClockDuration;
  }

  int? get resumeQuatersClockMinutes => resumeQuatersClockMin;

  set resumeQuatersClockMinutes(int? resumeQuatersClockMinutes) {
    resumeQuatersClockMin = resumeQuatersClockMinutes;
  }

  int? get resumeQuatersClockSeconds => resumeQuatersClockSec;

  set resumeQuatersClockSeconds(int? resumeQuatersClockSeconds) {
    resumeQuatersClockSec = resumeQuatersClockSeconds;
  }

  int? get resumeShotClockDuration => resumeShotClock;

  set resumeShotClockDuration(int? resumeShotClockDuration) {
    resumeShotClock = resumeShotClockDuration;
  }

  bool get resumeClock => isClockResume;

  set resumeClock(bool resumeClock) {
    isClockResume = resumeClock;
  }
}
