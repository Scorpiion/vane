part of vane_transformer;

/*
 * Algorithm to find where to insert toJson() function:
 *
 * 1. Find a row that contains "class" + "extends" + "VaneModel"
 * 2. Parse out the model class from said row, called Model here
 * 3. Continue until we find a row with "Model.model()"
 * 4. Insert toJson() function below "Model.model()"
 *
 */

      /// 1. Create a new temp dir, /tmp/model_62342336
      /// 2. Add a pubspec.yaml based on imports in model.dart
      /// 3. Run pub get
      /// 4. Run a program with VaneModel.transform to get the generated code
      ///      - Inside this function, double check if the model override
      ///        toJson, then don't add a second toJson....


class VaneModelTransformer extends Transformer {
  final BarbackSettings _settings;

  // Only run on dart files and ignore file in vane
  Future<bool> isPrimary(AssetId id) {
    if(id.extension == ".dart") {
      if(id.path.contains('packages/vane') == false) {
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
      List<String> models = new List<String>();

      // Only run transformer on Dart files that contain VaneModel classes
      for(var i = 0; i < lines.length; i++) {
        // Order of checks based on probability of hits in content
        if(lines[i].contains("extends") &&
           lines[i].contains("VaneModel") &&
           lines[i].contains("class")) {
          String model = lines[i].split('extends')[0].trim().split(' ')[1];
          transform.logger.info('Found VaneModel class ${model}');
          models.add(model);
        }
      }

      if(models.isEmpty) {
        c.complete(true);
        return new Future.value("");
      }

      // Create a copy of the code that we can use as a base for our generated
      // code that we later execute to produce the json serialization code.
      String codeGenerationCode = new String.fromCharCodes(content.codeUnits);

      // Add start of code generation code
      codeGenerationCode = '${codeGenerationCode}\nvoid main() {';

      // Add code for each declared model
      for(var model in models) {
        codeGenerationCode = '${codeGenerationCode}\n  print(VaneModel.transform(new ${model}.model()));';
      }

      // Add end of code generation code
      codeGenerationCode = '${codeGenerationCode}\n}\n\n';


      print("--------------- codeGenerationCode ----------------------");
      transform.logger.info(codeGenerationCode);
      print("-------------------------------------");

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

      // Parse out code from stdout
      List<String> contentWithJson = content.split('\n');

      for(var i = 0; i < contentWithJson.length; i++) {
        // Order of checks based on probability of hits in content
        if(contentWithJson[i].contains("extends") &&
           contentWithJson[i].contains("VaneModel") &&
           contentWithJson[i].contains("class")) {
          String clazz = contentWithJson[i].split('extends')[0].trim().split(' ')[1];

          while(i < contentWithJson.length) {
            i++;

            if(contentWithJson[i].contains('${clazz}.model()') == true) {
              contentWithJson.insert(i + 1, '\n${codeGen.stdout}');
              i = i + 1 + codeGen.stdout.length;
              break;
            }
          }
        }
      }

      // Write new code with json serialization code to build dir
      transform.addOutput(new Asset.fromString(id, contentWithJson.join('\n')));

      // Complete transformer
      c.complete(true);
    });

    return c.future;
  }
}





// TODO: Delete vane_model dir
// TODO: Check so that this class don't override implements
// TODO: Check so that this class don't override toJson()
// TODO: Handle outcommneted code






















