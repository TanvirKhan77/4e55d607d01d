import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Stream<bool> get connectionStatusStream;
  Future<bool> isConnected();
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityServiceImpl(this._connectivity);

  @override
  Stream<bool> get connectionStatusStream {
    return _connectivity.onConnectivityChanged
        .map((ConnectivityResult result) {
      return result != ConnectivityResult.none;
    })
        .distinct();
  }

  @override
  Future<bool> isConnected() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
