import 'dart:async';
import 'dart:convert';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym/src/data/repository/exercise_repository/exercise_repository.dart';
import 'package:tiggym/src/data/repository/training_template_repository/training_template_repository.dart';
import 'package:tiggym/src/data/constants/app_shared_prefs_keys.dart';
import 'package:tiggym/src/data/repository/training_template_repository/training_template_resume_repository.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../../controllers/training_session_controller.dart';

class WearConnectivityService {
  WearOsDevice? _localDevice;
  final isSupported = BehaviorSubject.seeded(false);
  final enabled = BehaviorSubject.seeded(false);
  late final FlutterWearOsConnectivity _flutterWearOsConnectivity = FlutterWearOsConnectivity();
  bool initialized = false;
  final List<StreamSubscription> _subscriptions = [];
  WearConnectivityService._privateConstructor();

  static final WearConnectivityService instance = WearConnectivityService._privateConstructor();

  Future<void> initialize() async {
    if (!initialized) {
      isSupported.add(await _flutterWearOsConnectivity.isSupported());
      initialized = true;
      if (!isSupported.value) {
        return;
      }
      await _flutterWearOsConnectivity.configureWearableAPI();
      _localDevice = await _flutterWearOsConnectivity.getLocalDevice();

      bool enabled = SharedPrefsService.instance.getBool(AppSharedPrefsKeys.kWearSyncEnabled) ?? false;
      this.enabled.add(enabled);

      if (enabled) {
        final data = await _flutterWearOsConnectivity.findDataItemsOnURIPath(
          pathURI: Uri(
            scheme: 'wear',
            path: WearConnectivityPaths.ongoingSessionRemote,
          ),
        );
        await _ongoingSessionRemoteStartupUpdate(data);
        await addListeners();
      }
    }
  }

  Future<void> setEnabled(bool enabled) async {
    this.enabled.add(enabled);
    SharedPrefsService.instance.setBool(AppSharedPrefsKeys.kWearSyncEnabled, enabled);

    if (enabled) {
      syncData();
      await addListeners();
      await _flutterWearOsConnectivity.registerNewCapability(WearConnectivityCapabilities.mainAppCapability);
    } else {
      await _flutterWearOsConnectivity.removeExistingCapability(WearConnectivityCapabilities.mainAppCapability);
      await removeListeners();
    }
  }

  Future<void> removeListeners() async {
    _flutterWearOsConnectivity.removeDataListener();
    _flutterWearOsConnectivity.removeMessageListener();
    for (var element in _subscriptions) {
      element.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> addListeners() async {
    _subscriptions.add(_flutterWearOsConnectivity
        .dataChanged(
          pathURI: Uri(
            scheme: 'wear',
            path: WearConnectivityPaths.ongoingSessionRemote,
          ),
        )
        .listen(_ongoingSessionRemoteUpdate));
    _subscriptions.add(_flutterWearOsConnectivity
        .messageReceived(
          pathURI: Uri(
            scheme: 'wear',
            path: WearConnectivityPaths.syncMessages,
          ),
        )
        .listen(_onSyncMessageReceived));

    _subscriptions.add(GetIt.I.get<TrainingSessionController>().ongoingSessionSync.throttleTime(const Duration(seconds: 1), trailing: true, leading: false).listen((event) {
      syncCurrentSession();
    }));
    _subscriptions.add(GetIt.I.get<TrainingTemplateResumeRepository>().data.throttleTime(const Duration(seconds: 1), trailing: true, leading: false).listen((event) {
      syncTrainings();
    }));
    _subscriptions.add(GetIt.I.get<ExerciseRepository>().data.throttleTime(const Duration(seconds: 1), trailing: true, leading: false).listen((event) {
      syncExercises();
    }));
  }

  Future<void> _onSyncMessageReceived(WearOSMessage message) async {
    final json = utf8.decode(message.data);
    final data = SyncModel<SyncTrainingSessionModel>.fromMap(jsonDecode(json), SyncTrainingSessionModel.fromMap);

    GetIt.I.get<TrainingSessionController>().syncMessage(data);
  }

  Future<void> _ongoingSessionRemoteUpdate(List<DataEvent> event) async {
    final syncs = event.map((e) => SyncModel<SyncTrainingSessionModel>.fromMap(e.dataItem.mapData, SyncTrainingSessionModel.fromMap)).toList();

    GetIt.I.get<TrainingSessionController>().updateSync(syncs);
  }

  Future<void> _ongoingSessionRemoteStartupUpdate(List<DataItem> items) async {
    final syncs = items.map((e) => SyncModel<SyncTrainingSessionModel>.fromMap(e.mapData, SyncTrainingSessionModel.fromMap)).toList();

    GetIt.I.get<TrainingSessionController>().updateSync(syncs);
  }

  Future<void> syncData() async {
    syncTrainings();
    syncExercises();
    syncCurrentSession();
  }

  Future<void> syncTrainings() async {
    final trainings = await GetIt.I.get<TrainingTemplateRepository>().getTrainings();
    final data = SyncModel<SyncTrainingTemplatesModel>(
      id: UuidService.instance.uuid(),
      previousId: '',
      deviceId: '',
      deviceName: '',
      data: SyncTrainingTemplatesModel(trainings: trainings),
    ).toMap();
    await _flutterWearOsConnectivity.syncData(path: WearConnectivityPaths.training, data: data);
  }

  Future<void> syncExercises() async {
    final exercises = GetIt.I.get<ExerciseRepository>().data.value;
    final data = SyncModel<SyncExercisesModel>(
      id: UuidService.instance.uuid(),
      previousId: '',
      deviceId: '',
      deviceName: '',
      data: SyncExercisesModel(exercises: exercises),
    ).toMap();
    await _flutterWearOsConnectivity.syncData(path: WearConnectivityPaths.exercises, data: data);
  }

  Future<void> syncCurrentSession() async {
    var ongoingSession = GetIt.I.get<TrainingSessionController>().ongoingSessionSync.value;

    if (ongoingSession != null) {
      await _flutterWearOsConnectivity.syncData(
        path: WearConnectivityPaths.ongoingSession,
        data: ongoingSession
            .copyWith(
              deviceId: ongoingSession.deviceId.isEmpty ? _localDevice?.id : ongoingSession.deviceId,
              deviceName: ongoingSession.deviceName.isEmpty ? _localDevice?.name : ongoingSession.deviceName,
            )
            .toMap(),
      );
    }
  }

  void sendConsumedMessage(SyncModel<SyncTrainingSessionModel> data) {
    _flutterWearOsConnectivity.sendMessage(
      utf8.encode(data.id),
      deviceId: data.deviceId,
      path: WearConnectivityPaths.ongoingSession,
    );
  }
}
