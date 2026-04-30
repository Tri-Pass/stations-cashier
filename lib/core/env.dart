class Env {
  const Env._();
  static const bool isDev = true;
  static const String baseApiUrl = isDev ? _apiDevUrl : _apiUrl;
  static const String socketUrl = isDev ? _socketTest : _socketUrlProd;
  static const String socketCluster = isDev ? _testSocketClusterUrl : _socketClusterUrl;
  static const String _apiUrl = String.fromEnvironment('API_URL');
  static const String _socketTest = String.fromEnvironment('SOCKET_URL_TEST');
  static const String _apiDevUrl = String.fromEnvironment('API_DEV_URL', defaultValue: 'https://stations.wetaxi.ma');
  static const String _socketClusterUrl = String.fromEnvironment('SOCKET_CLUSTER_URL');
  static const String _testSocketClusterUrl = String.fromEnvironment('TEST_SOCKET_CLUSTER_URL');
  static const String _socketUrlProd = String.fromEnvironment('SOCKET_URL');
}
