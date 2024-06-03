import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:tiggym_shared/tiggym_shared.dart';
import 'package:tiggym_wear/src/data/model/current_sessions_model.dart';
import 'package:tiggym_wear/src/util/services/wear_connectivity_service.dart';

class TrainingSessionRepository {
  final _syncMessages = BehaviorSubject<List<SyncModel<SyncTrainingSessionModel>>>.seeded([]);
  ValueStream<List<SyncModel<SyncTrainingSessionModel>>> get syncMessages => _syncMessages;

  final _trainingSessionState = BehaviorSubject<TrainingSessionStateModel?>.seeded(null);
  final _phoneCurrentSession = BehaviorSubject<TrainingSessionModel?>.seeded(null);
  ValueStream<TrainingSessionModel?> get phoneCurrentSession => _phoneCurrentSession;

  final _watchSession = BehaviorSubject<TrainingSessionModel?>.seeded(null);
  ValueStream<TrainingSessionModel?> get watchSession => _watchSession;

  final _ongoingSessionSync = BehaviorSubject<SyncModel<SyncTrainingSessionModel>?>.seeded(null);
  ValueStream<SyncModel<SyncTrainingSessionModel>?> get ongoingSessionSync => _ongoingSessionSync;

  ValueStream<CurrentSessionsModel> get currentSessions => Rx.combineLatest3(_phoneCurrentSession, _watchSession, _trainingSessionState, _getCurrentSessions)
      .shareValueSeeded(_getCurrentSessions(_phoneCurrentSession.value, _watchSession.value, _trainingSessionState.value));

  CurrentSessionsModel _getCurrentSessions(TrainingSessionModel? phoneSession, TrainingSessionModel? watchSession, TrainingSessionStateModel? sessionState) {
    final watchSyncId = watchSession?.syncId ?? 'watchSyncId';
    final phoneSyncId = phoneSession?.syncId ?? 'phoneSyncId';
    if (watchSession == null && phoneSession != null) {
      if (sessionState?.state == TrainingSessionStateEnum.ongoing) {
        return CurrentSessionsModel(
          phoneSession: null,
          watchSession: phoneSession,
          sessionState: sessionState,
        );
      }

      return CurrentSessionsModel(
        phoneSession: null,
        watchSession: null,
        sessionState: sessionState,
      );
    }

    if (watchSyncId == phoneSyncId) {
      if (sessionState?.state == TrainingSessionStateEnum.ongoing) {
        return CurrentSessionsModel(
          phoneSession: null,
          watchSession: watchSession,
          sessionState: sessionState,
        );
      }

      return CurrentSessionsModel(
        phoneSession: null,
        watchSession: null,
        sessionState: sessionState,
      );
    }

    return CurrentSessionsModel(
      phoneSession: phoneSession,
      watchSession: watchSession,
      sessionState: watchSession != null ? TrainingSessionStateModel(syncId: watchSyncId, state: TrainingSessionStateEnum.ongoing) : sessionState,
    );
  }

  TrainingSessionRepository() {
    final json = SharedPrefsService.instance.getString(SharedPrefsKeys.kSyncMessages);
    final value = json != null
        ? List<SyncModel<SyncTrainingSessionModel>>.from((json as List<dynamic>).map((e) => SyncModel<SyncTrainingSessionModel>.fromMap(e, SyncTrainingSessionModel.fromMap))).toList()
        : <SyncModel<SyncTrainingSessionModel>>[];
    _syncMessages.add(value);
  }

  void updatePhoneSession(SyncModel<SyncTrainingSessionModel> trainingSession) {
    final syncId = trainingSession.data.session?.syncId ?? trainingSession.data.sessionState.syncId;

    if (_syncMessages.value.any((element) => element.data.sessionState.syncId == syncId)) {
      return;
    }
    _trainingSessionState.add(trainingSession.data.sessionState);
    _phoneCurrentSession.add(trainingSession.data.session);

    if (syncId == _watchSession.value?.syncId) {
      _watchSession.add(trainingSession.data.session);
    }
  }

  void changeSession(TrainingSessionModel trainingSession) {
    _watchSession.add(trainingSession);

    _ongoingSessionSync.add(SyncModel<SyncTrainingSessionModel>(
      id: UuidService.instance.uuid(),
      previousId: '',
      deviceId: '',
      deviceName: '',
      data: SyncTrainingSessionModel(
          session: trainingSession,
          sessionState: TrainingSessionStateModel(
            syncId: trainingSession.syncId ?? '',
            state: TrainingSessionStateEnum.ongoing,
          )),
    ));
  }

  void finishSession() {
    final watchSession = currentSessions.value.watchSession;
    final session = watchSession?.copyWith(
      name: watchSession.name.isEmpty ? (WearConnectivityService.instance.localDevice?.name ?? 'Watch') : null,
      duration: Duration(
        seconds: DateTime.now().secondsSinceEpoch - watchSession.date.secondsSinceEpoch,
      ),
    );
    if (session?.syncId == _phoneCurrentSession.value?.syncId) {
      _watchSession.add(null);
      _phoneCurrentSession.add(null);
    } else {
      _watchSession.add(null);
    }
    final syncMessage = SyncModel<SyncTrainingSessionModel>(
      id: UuidService.instance.uuid(),
      previousId: '',
      deviceId: '',
      deviceName: '',
      data: SyncTrainingSessionModel(
          session: session,
          sessionState: TrainingSessionStateModel(
            syncId: session?.syncId ?? '',
            state: TrainingSessionStateEnum.finished,
          )),
    );
    // _ongoingSessionSync.add(syncMessage);
    addSyncMessage(syncMessage);
    sendMessage(syncMessage);
  }

  void discardSession() {
    final watchSession = currentSessions.value.watchSession;
    final session = watchSession?.copyWith(
      name: watchSession.name.isEmpty ? (WearConnectivityService.instance.localDevice?.name ?? 'Watch') : null,
      duration: Duration(
        seconds: DateTime.now().secondsSinceEpoch - watchSession.date.secondsSinceEpoch,
      ),
    );
    if (session?.syncId == _phoneCurrentSession.value?.syncId) {
      _watchSession.add(null);
      _phoneCurrentSession.add(null);
    } else {
      _watchSession.add(null);
    }
    final syncMessage = SyncModel<SyncTrainingSessionModel>(
      id: UuidService.instance.uuid(),
      previousId: '',
      deviceId: '',
      deviceName: '',
      data: SyncTrainingSessionModel(
          session: session,
          sessionState: TrainingSessionStateModel(
            syncId: session?.syncId ?? '',
            state: TrainingSessionStateEnum.discarded,
          )),
    );
    // _ongoingSessionSync.add(syncMessage);
    addSyncMessage(syncMessage);
    sendMessage(syncMessage);
  }

  void addSyncMessage(SyncModel<SyncTrainingSessionModel> message) {
    final newValue = [..._syncMessages.value, message];
    _syncMessages.add(newValue);
    SharedPrefsService.instance.setString(SharedPrefsKeys.kOngoingSession, jsonEncode(newValue.map((e) => e.toMap()).toList()));
  }

  void sendMessage(SyncModel message) {
    WearConnectivityService.instance.sendSyncMessage(message);
  }

  void updateConsumedMessage(String messageId) {
    final newValue = [..._syncMessages.value]..removeWhere((element) => element.id == messageId);
    _syncMessages.add(newValue);
    SharedPrefsService.instance.setString(SharedPrefsKeys.kOngoingSession, jsonEncode(newValue.map((e) => e.toMap()).toList()));
  }

  void syncPending() {
    final value = syncMessages.value;

    for (var i = 0; i < value.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        sendMessage(value.elementAt(i));
      });
    }
  }
}
