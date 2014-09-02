part of vane_transformer;

class Model {
  String name;
  int row;
  String constructor;
  List<String> code;

  Model(this.name, this.constructor, this.row);
}

/// Ignored lib imports that are not work together with dart:io
final List<String> IGNORED_LIBS = [
  "dart:html",
  "package:polymer/polymer.dart",
  "package:vane/vane_elements.dart"
];

class VaneModelTransformer extends Transformer {
  final BarbackSettings _settings;

  /// Only run on dart files and ignore files that are part of Vane itself.
  ///
  /// Later in apply we also add a special check to avoid copies of the files
  /// with bad imports. Not sure where these come from but it seems when
  /// building a web app with models in lib the file comes twice, one is it
  /// should be and one with different incompatible imports, we ignore the
  /// second.
  Future<bool> isPrimary(AssetId id) {
    if(id.extension == ".dart") {
      if(id.path.contains('packages/vane') == false &&
         id.path.contains('package:vane') == false) {
        return new Future.value(true);
      } else {
        return new Future.value(false);
      }
    } else {
      return new Future.value(false);
    }
  }

  VaneModelTransformer.asPlugin(this._settings);

  Future apply(Transform transform) {
    var c = new Completer();

    // Skip the transform in debug mode.
//    if(_settings.mode.name == 'debug') {
//      c.complete(true);
//      return new Future.value("");
//    }

    // Read and process dart file, but only if it contains VaneModel classes
    transform.primaryInput.readAsString().then((String content) {
      var id = transform.primaryInput.id;
      List<String> lines = content.split('\n');
      List<Model> models = new List<Model>();

      bool lookForConstructor = false;

      // Only run transformer on Dart files that contain VaneModel classes
      for(var i = 0; i < lines.length; i++) {
        // Look for duplicate files with bad imports
        if(lines[i].contains("import") &&
           lines[i].contains("/packages/")) {
          c.complete(true);
          return new Future.value("");
        }

        // Order of checks based on probability of hits in content
        if(lines[i].contains("VaneModel") &&
           lines[i].contains("extends") &&
           lines[i].contains("class")) {
          String model = lines[i].split('extends')[0].trim().split(' ')[1];

          // Save model
          models.add(new Model(model, "", i + 1));

          // Start looking for a model constructor
          lookForConstructor = true;
        }

        // If we have found a model, we continue to look to see what constructor
        // that model need. We have three alternatives, an empty constructor
        // like "Foo();", or an empty model constructor like "Foo.model();" or
        // if we don't find any constructor we assume it's an empty constructor.
        if(lookForConstructor == true) {
          if(lines[i].contains("${models.last.name}.model();")) {
            models.last.constructor = ".model";
            lookForConstructor = false;
          }
        }
      }

      if(models.isEmpty) {
        c.complete(true);
        return new Future.value("");
      } else {
        transform.logger.info('Generating code for VaneModel classes: ${models.sublist(1).fold('${models[0].name}', (x, y) => "$x, ${y.name}")}');
      }

      // Create a copy of the code that we can use as a base for our generated
      // code that we later execute to produce the json serialization code.
      String codeGenerationCode = new String.fromCharCodes(content.codeUnits);
      String delimit = "1592fec14205f706c94019a3bb82df25a6e9754f22ab845d102a137e3cbdfb08";

      // Add empty Observable class to let classes mixin and extends it. The
      // Observable class is part of the ignored Polymer package.
      codeGenerationCode = '${codeGenerationCode}\n\nabstract class Observable { }\n';
      codeGenerationCode = '${codeGenerationCode}\n\nabstract class ChangeNotifier { }\n';

      // Add start of code generation code
      codeGenerationCode = '${codeGenerationCode}\nvoid main() {  print("");';
      final k = models.length - 1;

      // Add code for each declared model
      for(var i = 0; i < models.length; i++) {
        codeGenerationCode = '${codeGenerationCode}\n  print(VaneModel.transform(new ${models[i].name}${models[i].constructor}()));';
        if(i < k) {
          codeGenerationCode = '${codeGenerationCode}\n  print("${delimit}");';
        }
      }

      // Add end of code generation code
      codeGenerationCode = '${codeGenerationCode}\n}\n\n';

      // Remove any nonsupported imports
      codeGenerationCode = codeGenerationCode.split('\n').map((s) => IGNORED_LIBS.any((lib) => s.contains(lib)) ? "" : s).join('\n');

      // Create a temp directory
      Directory modelDir = Directory.systemTemp.createTempSync('vane_model_');

      // Create a pubspec.yaml file
      String pubspecYaml = 'name: model\ndependencies:';

      // Check for any package imports and add any imported package to the
      // pubspec.yaml file string
      codeGenerationCode.split('\n').where((l)
          => l.contains("import 'package:")).forEach((line) {
        // Parse out the package name from the import string
        String pkgName = line.substring(16, line.length).split('/')[0];

        // TODO: The best solution here is to use "network imports" like pub
        // does in it's own isolates. We just have to get the port of barbacks
        // server somehow. If we use those both the pubspec and running pub get
        // might not be needed anymore.

        // Add dependency to pubspec.yaml
        if(pkgName == "vane") {
          // TODO: This is a temp dev fix
          pubspecYaml = '${pubspecYaml}\n  ${pkgName}: \n    path: /home/robert/Workspace/Vane';
        } else {
          // TODO: We might wanna use the exact same version settings as the
          // app, but how do we know where the project pubspec.yaml is?
          pubspecYaml = '${pubspecYaml}\n  ${pkgName}: any';
        }
      });

      // Add new line at the end of the file
      pubspecYaml = '${pubspecYaml}\n\n';

      // Write pubspec.yaml file to temp dir
      File pubspecYamlFile = new File('${modelDir.path}/pubspec.yaml');
      pubspecYamlFile.writeAsStringSync(pubspecYaml);

      // Write codeGenerationCode file to temp dir
      File codeGenerationCodeFile = new File('${modelDir.path}/main.dart');
      codeGenerationCodeFile.writeAsStringSync(codeGenerationCode);

      // Run pub get to get the correct package layout
      ProcessResult pubGet = Process.runSync('pub', ['get'], workingDirectory: modelDir.path);
      if(pubGet.exitCode != 0) {
        transform.logger.error('Error running pub, exit code: ${pubGet.exitCode}\n');
        transform.logger.error('${pubGet.stderr}\n');

        // TODO: What is the correct way to tell pub there was an error? Throw error?
        c.complete(true);
        return new Future.value("");
      }

      // Run main.dart to generate json serialization code
      ProcessResult codeGen = Process.runSync('dart', ['${modelDir.path}/main.dart'], workingDirectory: modelDir.path);
      if(codeGen.exitCode != 0 || codeGen.stderr != "") {
        transform.logger.error('Error running code generation program, exit code: ${codeGen.exitCode}\n');
        transform.logger.error('${codeGen.stderr}\n');

        // TODO: What is the correct way to tell pub there was an error? Throw error?
        c.complete(true);
        return new Future.value("");
      }

      // Delete temporary directory
      modelDir.deleteSync(recursive: true);

      // Parse out code from stdout
      List<String> contentWithJson = content.split('\n');

      // Loop over generated code and add it to the model classes
      List<String> generatedCode = codeGen.stdout.toString().split(delimit);
      for(var i = 0; i < generatedCode.length; i++) {
        // Save generated code (and inherently it's length used below)
        models[i].code = generatedCode[i].split('\n');

        // Calculate offset used to insert generated code, we add the original
        // row the class was found at with the totalt amount of inserted row
        // so far (the added rows from added generated code).
        int offset = models.sublist(0, i).fold(0, (x, y) => x + y.code.length);

        // Add the original row to the offset
        offset = offset + models[i].row;

        // Add function used for Json encode/decode to the outputed code
        contentWithJson.insertAll(offset, models[i].code);
      }

      // Write new code with json serialization code to build dir
      transform.addOutput(new Asset.fromString(id, contentWithJson.join('\n')));

      // Complete transformer
      c.complete(true);
    });

    return c.future;
  }
}

