import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/services/http_client_factory_stub.dart'
    if (dart.library.js_interop) 'package:mini_mart_management_mobile_app/services/http_client_factory_web.dart';

http.Client createConfiguredClient() => createHttpClient();
