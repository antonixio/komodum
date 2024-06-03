import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/data/constants/app_shared_prefs_keys.dart';
import 'package:tiggym_wear/src/data/model/connected_device_model.dart';
import 'package:tiggym_wear/src/data/repositories/exercise_repository.dart';
import 'package:tiggym_wear/src/data/repositories/training_session_repository.dart';

import '../../data/repositories/training_template_repository.dart';

class WearConnectivityService {
  WearOsDevice? _localDevice;
  WearOsDevice? get localDevice => _localDevice;
  SyncModel<SyncTrainingSessionModel>? dataSync;
  final List<StreamSubscription> _subscriptions = [];

  final connectedDevice = BehaviorSubject<ConnectedDeviceModel?>.seeded(null);
  late final FlutterWearOsConnectivity _flutterWearOsConnectivity = FlutterWearOsConnectivity();
  bool initialized = false;
  WearConnectivityService._privateConstructor();
  final List<StreamSubscription> subscriptions = [];

  Uri? getUri(String path) {
    final value = connectedDevice.value;

    if (value != null) {
      return Uri(path: path, host: value.deviceId, scheme: 'wear');
    }

    return null;
  }

  static final WearConnectivityService instance = WearConnectivityService._privateConstructor();

  Future<void> initialize() async {
    if (!initialized) {
      initialized = true;
      await _flutterWearOsConnectivity.configureWearableAPI();
      _localDevice = await _flutterWearOsConnectivity.getLocalDevice();
      initializeConnectedDevice();
      addListeners();
    }
  }

  void addListeners() {
    _subscriptions.add(GetIt.I.get<TrainingSessionRepository>().ongoingSessionSync.throttleTime(const Duration(seconds: 1), leading: false, trailing: true).listen((event) {
      syncCurrentSession(event);
    }));
  }

  Future<void> syncCurrentSession(SyncModel<SyncTrainingSessionModel>? event) async {
    if (event != null) {
      dataSync = event;
      await _flutterWearOsConnectivity.syncData(
          path: WearConnectivityPaths.ongoingSessionRemote,
          data: event
              .copyWith(
                deviceId: _localDevice?.id,
                deviceName: _localDevice?.name,
              )
              .toMap());
    }
  }

  void saveConnectedDevice(ConnectedDeviceModel connected) {
    connectedDevice.add(connected);
    SharedPrefsService.instance.setString(AppSharedPrefsKeys.kDeviceConnected, connected.toJson());
    initializeDataFromConnectedDevice();
  }

  void initializeConnectedDevice() {
    try {
      final json = SharedPrefsService.instance.getString(AppSharedPrefsKeys.kDeviceConnected);
      if (json != null) {
        connectedDevice.add(ConnectedDeviceModel.fromJson(json));
        initializeDataFromConnectedDevice();
      }
    } catch (err) {}
  }

  Future<void> initializeDataFromConnectedDevice() async {
    await initializeTrainingTemplates();
    await initializeExercises();
    await initializePhoneSession();

    subscriptions.add(_flutterWearOsConnectivity.messageReceived(pathURI: Uri(scheme: 'wear', path: WearConnectivityPaths.consumedMessages)).listen((event) {
      final messageId = utf8.decode(event.data);
      GetIt.I.get<TrainingSessionRepository>().updateConsumedMessage(messageId);
    }));
  }

  Future<void> initializeTrainingTemplates() async {
    try {
      final json = SharedPrefsService.instance.getString(AppSharedPrefsKeys.kTrainingTemplates);
      if (json != null) {
        // trainings.add();
      }

      final uri = getUri(WearConnectivityPaths.training);
      if (uri != null) {
        final data = await _flutterWearOsConnectivity.findDataItemOnURIPath(pathURI: uri);
        if (data != null) {
          _updateTrainingTemplatesFromDataItem(data);
        }
        subscriptions.add(_flutterWearOsConnectivity.dataChanged(pathURI: uri).listen((event) {
          final map = event.last.dataItem;
          _updateTrainingTemplatesFromDataItem(map);
        }));
      }
    } catch (err) {
      print("Erro $err");
    }
  }

  void _updateTrainingTemplatesFromDataItem(DataItem dataItem) {
    final trainings = SyncModel<SyncTrainingTemplatesModel>.fromMap(dataItem.mapData, SyncTrainingTemplatesModel.fromMap);
    GetIt.I.get<TrainingTemplateRepository>().updateTrainings(trainings);
  }

  Future<void> initializeExercises() async {
    try {
      final json = SharedPrefsService.instance.getString(AppSharedPrefsKeys.kExercises);
      if (json != null) {
        // trainings.add();
      }

      final uri = getUri(WearConnectivityPaths.exercises);
      if (uri != null) {
        final data = await _flutterWearOsConnectivity.findDataItemOnURIPath(pathURI: uri);
        if (data != null) {
          _updateExercisesFromDataItem(data);
        }
        subscriptions.add(_flutterWearOsConnectivity.dataChanged(pathURI: uri).listen((event) {
          final map = event.last.dataItem;
          _updateExercisesFromDataItem(map);
        }));
      }
    } catch (err) {
      print("Erro $err");
    }
  }

  void _updateExercisesFromDataItem(DataItem dataItem) {
    final exercises = SyncModel<SyncExercisesModel>.fromMap(dataItem.mapData, SyncExercisesModel.fromMap);
    GetIt.I.get<ExerciseRepository>().updateExercises(exercises);
  }

  Future<void> initializePhoneSession() async {
    final uri = getUri(WearConnectivityPaths.ongoingSession);
    try {
      if (uri != null) {
        final data = await _flutterWearOsConnectivity.findDataItemOnURIPath(pathURI: uri);
        if (data != null) {
          _updatePhoneSessionFromDataItem(data);
        }
      }
    } catch (err) {
      print(err);
    }

    try {
      if (uri != null) {
        subscriptions.add(_flutterWearOsConnectivity.dataChanged(pathURI: uri).listen((event) {
          final map = event.last.dataItem;
          _updatePhoneSessionFromDataItem(map);
        }));
      }
    } catch (err) {
      print("Erro $err");
    }
  }

  void _updatePhoneSessionFromDataItem(DataItem dataItem) {
    final trainingSession = SyncModel<SyncTrainingSessionModel>.fromMap(dataItem.mapData, SyncTrainingSessionModel.fromMap);
    if ((trainingSession.deviceId != _localDevice?.id || dataSync?.deviceId != trainingSession.deviceId)) {
      dataSync = trainingSession;
      GetIt.I.get<TrainingSessionRepository>().updatePhoneSession(trainingSession);
    }
  }

  Future<List<WearOsDevice>> getDevices() async {
    await Future.delayed(const Duration(seconds: 3));
    CapabilityInfo? capabilityInfo = await _flutterWearOsConnectivity.findCapabilityByName(WearConnectivityCapabilities.mainAppCapability);
    return capabilityInfo?.associatedDevices.toList() ?? <WearOsDevice>[];
  }

  void sendSyncMessage(SyncModel<MappableModel> message) {
    final connectedDev = connectedDevice.value;
    if (connectedDev != null) {
      _flutterWearOsConnectivity.sendMessage(
        Uint8List.fromList(utf8.encode(jsonEncode(message
            .copyWith(
              deviceId: _localDevice?.id,
              deviceName: _localDevice?.name,
            )
            .toMap()))),
        deviceId: connectedDev.deviceId,
        path: WearConnectivityPaths.ongoingSession,
      );
    }
  }
}
