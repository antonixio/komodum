import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tiggym/src/util/services/wear_connectivity_service.dart';
import 'package:tiggym_shared/tiggym_shared.dart';

import '../data/repository/training_session_repository/training_session_repository.dart';

class TrainingSessionController {
  final _ongoingSession = BehaviorSubject<TrainingSessionModel?>.seeded(null);
  ValueStream<TrainingSessionModel?> get ongoingSession => _ongoingSession;

  final _ongoingSessionSync = BehaviorSubject<SyncModel<SyncTrainingSessionModel>?>.seeded(null);
  ValueStream<SyncModel<SyncTrainingSessionModel>?> get ongoingSessionSync => _ongoingSessionSync;

  final _popOngoingTraining = PublishSubject<String>();
  Stream<String> get popOngoingTraining => _popOngoingTraining;

  bool get hasOngoingSession => _ongoingSession.value != null;

  void initialize() {
    try {
      final json = SharedPrefsService.instance.getString(SharedPrefsKeys.kOngoingSession);
      if (json != null) {
        final map = jsonDecode(json);
        if (map is Map) {
          _ongoingSession.add(TrainingSessionModel.fromMap(map as Map<String, dynamic>));
        }
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  void updateOngoing(TrainingSessionModel value, {bool sync = true}) {
    _ongoingSession.add(value);
    SharedPrefsService.instance.setString(SharedPrefsKeys.kOngoingSession, jsonEncode(value.toMap()));
    if (sync) {
      _ongoingSessionSync.add(SyncModel<SyncTrainingSessionModel>(
        id: UuidService.instance.uuid(),
        previousId: '',
        deviceId: '',
        deviceName: '',
        data: SyncTrainingSessionModel(
            session: _ongoingSession.value,
            sessionState: TrainingSessionStateModel(
              syncId: _ongoingSession.value?.syncId ?? '',
              state: TrainingSessionStateEnum.ongoing,
            )),
      ));
    }
  }

  Future<void> finishOngoingTraining() async {
    final training = _ongoingSession.value;
    if (training != null) {
      if ((training.id ?? 0) <= 0) {
        await GetIt.I.get<TrainingSessionRepository>().insert(training);
      } else {
        await GetIt.I.get<TrainingSessionRepository>().update(training);
      }

      _ongoingSessionSync.add(SyncModel<SyncTrainingSessionModel>(
        id: UuidService.instance.uuid(),
        previousId: '',
        deviceId: '',
        deviceName: '',
        data: SyncTrainingSessionModel(
            session: null,
            sessionState: TrainingSessionStateModel(
              syncId: _ongoingSession.value?.syncId ?? '',
              state: TrainingSessionStateEnum.finished,
            )),
      ));
      _ongoingSession.add(null);
      SharedPrefsService.instance.remove(SharedPrefsKeys.kOngoingSession);
    }
  }

  void cancelOngoingTrainingSession() {
    _ongoingSessionSync.add(SyncModel<SyncTrainingSessionModel>(
      id: UuidService.instance.uuid(),
      previousId: '',
      deviceId: '',
      deviceName: '',
      data: SyncTrainingSessionModel(
          session: null,
          sessionState: TrainingSessionStateModel(
            syncId: _ongoingSession.value?.syncId ?? '',
            state: TrainingSessionStateEnum.discarded,
          )),
    ));
    _ongoingSession.add(null);
    SharedPrefsService.instance.remove(SharedPrefsKeys.kOngoingSession);
  }

  void updateSync(List<SyncModel<SyncTrainingSessionModel>> syncs) {
    final currentSync = _ongoingSessionSync.value;

    final finisheds = syncs.where((element) => element.data.sessionState.syncId == _ongoingSession.value?.syncId && element.data.sessionState.state == TrainingSessionStateEnum.finished).toList()
      ..sort((a, b) => -a.dateTime.compareTo(b.dateTime));
    final finished = finisheds.firstOrNull;

    if (finished != null) {
      _popOngoingTraining.add('finished');
      _ongoingSession.add(null);
      SharedPrefsService.instance.remove(SharedPrefsKeys.kOngoingSession);
      _ongoingSessionSync.add(finished);

      final finishedSession = finished.data.session;
      if (finishedSession != null) {
        GetIt.I.get<TrainingSessionRepository>().validateAndInsert(finishedSession);
      }

      return;
    }
    final discardeds = syncs.where((element) => element.data.sessionState.syncId == _ongoingSession.value?.syncId && element.data.sessionState.state == TrainingSessionStateEnum.discarded).toList()
      ..sort((a, b) => -a.dateTime.compareTo(b.dateTime));
    final discarded = discardeds.firstOrNull;

    if (discarded != null) {
      _popOngoingTraining.add('discarded');
      SharedPrefsService.instance.remove(SharedPrefsKeys.kOngoingSession);
      _ongoingSession.add(null);

      _ongoingSessionSync.add(discarded);

      return;
    }

    final ongoingTrainingSyncs = syncs.where((element) => element.data.session?.syncId == _ongoingSession.value?.syncId).toList()..sort((a, b) => -a.dateTime.compareTo(b.dateTime));
    final ongoingTraining = ongoingTrainingSyncs.firstOrNull;

    if (ongoingTraining?.data.session != null && (ongoingTraining?.dateTime.compareTo(currentSync?.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0)) ?? 0) > 0) {
      updateOngoing(ongoingTraining!.data.session!, sync: false);
      _ongoingSessionSync.add(ongoingTraining);
      return;
    }

    final remotesOngoing = syncs.where((element) => element.data.sessionState.state == TrainingSessionStateEnum.ongoing).toList()..sort((a, b) => -a.dateTime.compareTo(b.dateTime));
    final remoteOngoing = remotesOngoing.firstOrNull;

    if (_ongoingSession.value == null && remoteOngoing?.data.session != null) {
      updateOngoing(remoteOngoing!.data.session!, sync: false);
      _ongoingSessionSync.add(ongoingTraining);
      return;
    }
  }

  Future<void> syncMessage(SyncModel<SyncTrainingSessionModel> data) async {
    if (data.data.sessionState.state == TrainingSessionStateEnum.discarded) {
      if (data.data.sessionState.syncId == _ongoingSession.value?.syncId) {
        _popOngoingTraining.add('discarded');
        _ongoingSession.add(null);

        SharedPrefsService.instance.remove(SharedPrefsKeys.kOngoingSession);

        _ongoingSessionSync.add(data);
      }
      WearConnectivityService.instance.sendConsumedMessage(data);
      return;
    }
    if (data.data.sessionState.state == TrainingSessionStateEnum.finished) {
      if (data.data.sessionState.syncId == _ongoingSession.value?.syncId) {
        _popOngoingTraining.add('finished');
        _ongoingSession.add(null);

        SharedPrefsService.instance.remove(SharedPrefsKeys.kOngoingSession);

        _ongoingSessionSync.add(data);
      }

      final finishedSession = data.data.session;
      if (finishedSession != null) {
        await GetIt.I.get<TrainingSessionRepository>().validateAndInsert(finishedSession);
        WearConnectivityService.instance.sendConsumedMessage(data);
      }
      return;
    }
  }
}
