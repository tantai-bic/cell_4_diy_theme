import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef NetworkTask = Future<void> Function();

class NetworkState {
  final bool isOnline;
  final NetworkTask? interruptedTask;
  final String? interruptedTaskLabel;

  const NetworkState({
    required this.isOnline,
    this.interruptedTask,
    this.interruptedTaskLabel,
  });

  NetworkState copyWith({
    bool? isOnline,
    NetworkTask? interruptedTask,
    String? interruptedTaskLabel,
    bool clearTask = false,
  }) =>
      NetworkState(
        isOnline: isOnline ?? this.isOnline,
        interruptedTask: clearTask ? null : (interruptedTask ?? this.interruptedTask),
        interruptedTaskLabel: clearTask ? null : (interruptedTaskLabel ?? this.interruptedTaskLabel),
      );
}

class NetworkNotifier extends AsyncNotifier<NetworkState> {
  @override
  Future<NetworkState> build() async {
    final result = await Connectivity().checkConnectivity();
    final isOnline = result != ConnectivityResult.none;

    Connectivity().onConnectivityChanged.listen((r) {
      final online = r != ConnectivityResult.none;
      final s = state.valueOrNull;
      if (s != null && s.isOnline != online) {
        state = AsyncData(s.copyWith(isOnline: online));
      }
    });

    return NetworkState(isOnline: isOnline);
  }

  void setInterruptedTask(NetworkTask task, String label) {
    final s = state.valueOrNull;
    if (s != null) {
      state = AsyncData(s.copyWith(interruptedTask: task, interruptedTaskLabel: label));
    }
  }

  Future<void> retryInterruptedTask() async {
    final s = state.valueOrNull;
    if (s?.interruptedTask != null) {
      final task = s!.interruptedTask!;
      state = AsyncData(s.copyWith(clearTask: true));
      await task();
    }
  }

  void clearInterruptedTask() {
    final s = state.valueOrNull;
    if (s != null) {
      state = AsyncData(s.copyWith(clearTask: true));
    }
  }
}

final networkProvider =
    AsyncNotifierProvider<NetworkNotifier, NetworkState>(NetworkNotifier.new);
