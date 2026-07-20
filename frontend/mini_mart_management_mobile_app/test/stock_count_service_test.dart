import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/services/stock_count_service.dart';

void main() {
  group('StockCountService mutations', () {
    test(
      'send a matching CSRF header and cookie for every unsafe request',
      () async {
        final client = _RecordingClient();
        final service = StockCountService(client: client);
        final count = _stockCount();
        final lines = [
          StockCountLine(
            stockCountLineId: 10,
            productId: 20,
            productCode: 'P-20',
            productName: 'Product',
            snapshotQuantity: 3,
            actualQuantity: 0,
            variance: -3,
            note: null,
            rowVersion: 'line-version',
          ),
        ];

        await service.create(StockCountScope.global);
        await service.start(count);
        await service.cancelDraft(count);
        await service.addLines(count, [20, 21]);
        await service.updateLines(count, lines);
        await service.submit(count);
        await service.approve(count);
        await service.reject(count, 'Count again');

        final unsafeRequests = client.requests
            .where((request) => request.method != 'GET')
            .toList(growable: false);
        expect(unsafeRequests, hasLength(8));
        for (final request in unsafeRequests) {
          expect(request.headers['X-XSRF-TOKEN'], 'csrf-token');
          expect(request.headers['Cookie'], contains('XSRF-TOKEN=csrf-token'));
        }

        final cancellation =
            unsafeRequests.singleWhere((request) => request.method == 'DELETE')
                as http.Request;
        expect(cancellation.url.path, '/api/stock-counts/1');
        expect(jsonDecode(cancellation.body), {'rowVersion': 'count-version'});

        final addLines =
            unsafeRequests.singleWhere(
                  (request) =>
                      request.method == 'POST' &&
                      request.url.path == '/api/stock-counts/1/lines',
                )
                as http.Request;
        expect(jsonDecode(addLines.body), {
          'stockCountRowVersion': 'count-version',
          'productIds': [20, 21],
        });
      },
    );

    test('decodes cancelled status', () {
      expect(StockCountStatus.fromJson(5), StockCountStatus.cancelled);
      expect(
        StockCountStatus.fromJson('Cancelled'),
        StockCountStatus.cancelled,
      );
    });

    test('encodes and decodes selected scope', () {
      expect(StockCountScope.selected.apiValue, 3);
      expect(StockCountScope.fromJson(3), StockCountScope.selected);
      expect(StockCountScope.fromJson('Selected'), StockCountScope.selected);
    });
  });
}

StockCount _stockCount() => StockCount.fromJson(_stockCountJson());

Map<String, dynamic> _stockCountJson() => {
  'stockCountId': 1,
  'stockCountCode': 'SC-001',
  'scope': 1,
  'status': 2,
  'createdAt': '2026-07-18T00:00:00Z',
  'createdByEmployeeId': 1,
  'createdByEmployeeName': 'Warehouse Staff',
  'rowVersion': 'count-version',
  'categories': <dynamic>[],
  'lines': <dynamic>[],
};

class _RecordingClient extends http.BaseClient {
  final List<http.BaseRequest> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (request.url.path == '/api/auth/csrf-token') {
      return _response(
        {
          'data': {'csrfToken': 'csrf-token'},
        },
        headers: {'set-cookie': 'XSRF-TOKEN=csrf-token; Path=/'},
      );
    }
    return _response(_stockCountJson());
  }

  http.StreamedResponse _response(
    Map<String, dynamic> body, {
    Map<String, String> headers = const {},
  }) => http.StreamedResponse(
    Stream.value(utf8.encode(jsonEncode(body))),
    200,
    headers: headers,
  );
}
