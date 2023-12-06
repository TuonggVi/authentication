import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AppAuth Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isBusy = false;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  String? _accessToken;
  String? _userInfo;
  // final response_type = 'code';
  //final String _clientId = 'native-client';
  final String _clientId = 'flutter';
  String returnUrl = "";
  final String _redirectUrl =
      'https://authenticationserver2023.azurewebsites.net/connect/login';
  final String _discoveryUrl =
      'https://authenticationserver2023.azurewebsites.net/.well-known/openid-configuration';
  final List<String> _scopes = <String>[
    "openid",
    "profile",
    "native-client-scope"
  ];

  final AuthorizationServiceConfiguration _serviceConfiguration =
      const AuthorizationServiceConfiguration(
    tokenEndpoint:
        'https://authenticationserver2023.azurewebsites.net/connect/token',
    authorizationEndpoint:
        'https://authenticationserver2023.azurewebsites.net/connect/authorize',
    endSessionEndpoint:
        'https://authenticationserver2023.azurewebsites.net/connect/endsession',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter AppAuth Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isBusy ? null : _signIn,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _accessToken != null ? _callApi : null,
              child: const Text('Call API'),
            ),
            const SizedBox(height: 16),
            if (_accessToken != null) Text('Access Token: $_accessToken'),
            const SizedBox(height: 8),
            if (_userInfo != null) Text('User Info: $_userInfo'),
            const SizedBox(height: 8),
            if (_isBusy) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future _signIn() async {
    try {
      setState(() {
        _isBusy = true;
      });

      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          serviceConfiguration: _serviceConfiguration,
          scopes: _scopes,
          promptValues: ['login'],
          issuer: 'https://authenticationserver2023.azurewebsites.net',
        ),
      );

      if (result != null) {
        _processAuthTokenResponse(result);
        // Trích xuất thông tin từ URL
        await _callApi();
        print('Authorization Code: ${result?.accessToken}');
print('Access Token: ${result?.accessToken}');
print('ID Token: ${result?.idToken}');
print('Token Type: ${result?.tokenType}');
      }
    } catch (e) {
      print('Error during sign in: $e');
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }

  Future _callApi() async {
    try {
      final http.Response httpResponse = await http.get(
        Uri.parse('https://protectedapi2023.azurewebsites.net/WeatherForecast'),
        headers: <String, String>{'Authorization': 'Bearer $_accessToken'},
      );

      setState(() {
        _userInfo =
            httpResponse.statusCode == 200 ? httpResponse.body : 'API Error';
      });
    } catch (e) {
      print('Error calling API: $e');
    }
  }

  void _processAuthTokenResponse(AuthorizationTokenResponse response) {
    setState(() {
      _accessToken = response.accessToken;
      print('Access Token: $_accessToken');
    });
  }

  void _processAuthResponse(AuthorizationResponse response) {
    setState(() {
      
      _isBusy = false;
    });
  }
}
