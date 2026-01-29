import 'package:connectivity_plus/connectivity_plus.dart';

// Abstract class: Defines contract for connectivity services
abstract class ConnectivityService {
  // Stream: Provides real-time connection status updates
  Stream<bool> get connectionStatusStream;
  // Method: Check current connection status synchronously
  Future<bool> isConnected();
}

// Implementation class: Concrete connectivity service
class ConnectivityServiceImpl implements ConnectivityService {
  // Dependency: Connectivity instance for network checks
  final Connectivity _connectivity;

  // Constructor: Requires Connectivity instance
  ConnectivityServiceImpl(this._connectivity);

  // Implementation: Stream that emits connection status changes
  @override
  Stream<bool> get connectionStatusStream {
    return _connectivity.onConnectivityChanged
        .map((ConnectivityResult result) {
      // Convert ConnectivityResult to boolean (true if connected)
      return result != ConnectivityResult.none;
    })
        .distinct(); // Only emit when connection status actually changes
  }

  // Implementation: Check if device is currently connected
  @override
  Future<bool> isConnected() async {
    // Get current connectivity status
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    // Return true if any connection exists, false otherwise
    return result != ConnectivityResult.none;
  }
}
