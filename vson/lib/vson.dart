// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

library vson;

import 'dart:convert';
@MirrorsUsed(symbols: 'VaneModel', override: '*')
import 'dart:mirrors';

import 'package:logging/logging.dart';
import 'package:constrain/constrain.dart';
import 'package:observe/observe.dart';

part 'src/vane_model.dart';
part 'src/vane_model_mirror.dart';
part 'src/vane_model_type_check.dart';
part 'src/vane_model_vmms.dart';

