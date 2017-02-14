library dart_coveralls.calc;

import 'dart:async';
import 'dart:io';

import 'package:dart_coveralls/dart_coveralls.dart';
import 'package:path/path.dart' as p;

import 'command_line.dart';

class CalcPart extends CommandLinePart {
  CalcPart() : super(_initializeParser());

  Future execute(ArgResults res) async {
    if (res["help"]) {
      print(parser.usage);
      return;
    }

    String packageRoot = res["package-root"];
    String packagesPath = res["packages"];
    if (packageRoot != null) {
      if (p.isRelative(packageRoot)) {
        packageRoot = p.absolute(packageRoot);
      }

      if (!FileSystemEntity.isDirectorySync(packageRoot)) {
        print("Package root directory does not exist");
        return;
      }
    } else {
      if (p.isRelative(packagesPath)) {
        packagesPath = p.absolute(packagesPath);
      }

      if (!FileSystemEntity.isFileSync(packagesPath)) {
        print("Packages file does not exist");
        return;
      }
    }

    if (res.rest.length != 1) {
      print("Please specify a test file to run");
      return;
    }

    var file = res.rest.single;
    if (p.isRelative(file)) {
      file = p.absolute(file);
    }

    if (!FileSystemEntity.isFileSync(file)) {
      print("Dart file does not exist");
      return;
    }

    var workers = int.parse(res["workers"]);
    var collector = new LcovCollector(packageRoot: packageRoot, packagesPath: packagesPath);

    var r = await collector.getLcovInformation(file, workers: workers);

    if (res["output"] != null) {
      await new File(res["output"]).writeAsString(r);
    } else {
      print(r);
    }
  }
}

ArgParser _initializeParser() {
  ArgParser parser = new ArgParser(allowTrailingOptions: true)
    ..addOption("workers", help: "Number of workers for parsing", defaultsTo: "1")
    ..addOption("output", help: "Output file path");
  return CommandLinePart.addCommonOptions(parser);
}
