import 'dart:io';

import 'package:pub_updater/pub_updater.dart';
import 'package:stacked_cli/src/constants/command_constants.dart';
import 'package:stacked_cli/src/constants/config_constants.dart';
import 'package:stacked_cli/src/locator.dart';

import 'process_service.dart';

/// Provides functionality to interact with pacakges
class PubService {
  final _processService = locator<ProcessService>();

  final _pubUpdater = PubUpdater();

  /// Returns current `stacked_cli` version installed on the system.
  Future<String> getCurrentVersion() async {
    String version = currentVersionNotAvailable;

    final packages = await _processService.runPubGlobalList();
    for (var package in packages) {
      if (!package.contains(ksStackedCli)) continue;
      final splitResults = package.split(' ');
      if (splitResults.length > 2) {
        version = splitResults[1];
      } else {
        version = splitResults.last;
      }
      break;
    }

    return version;
  }

  /// Returns the latest published version of `stacked_cli` package.
  Future<String> getLatestVersion() async {
    return await _pubUpdater.getLatestVersion(ksStackedCli);
  }

  /// Checks whether or not has the latest version for `stacked_cli` package
  /// installed on the system.
  Future<bool> hasLatestVersion() async {
    final currentVersion = await getCurrentVersion();
    if (currentVersion == currentVersionNotAvailable) {
      await update();
      return true;
    }

    return await _pubUpdater.isUpToDate(
      packageName: ksStackedCli,
      currentVersion: currentVersion,
    );
  }

  /// Updates `stacked_cli` package on the system.
  Future<ProcessResult> update() async {
    return await _pubUpdater.update(packageName: ksStackedCli);
  }
}
