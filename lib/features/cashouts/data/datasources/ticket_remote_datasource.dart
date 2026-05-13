// TODO: switch _useMock to false and uncomment real API calls when backend is ready
import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';

const bool _useMock = true;

class GetDriverTicketsParams {
  final String driverId;
  final String? date;
  final String? status;
  const GetDriverTicketsParams({required this.driverId, this.date, this.status});
}

class CashoutTicketParams {
  final String driverId;
  final String? ticketId;
  final bool all;
  const CashoutTicketParams({
    required this.driverId,
    this.ticketId,
    this.all = false,
  });
}

// ─── Mock state ───────────────────────────────────────────────────────────────

final _paidTicketIds = <String>{};

Map<String, dynamic> _buildMockResponse(String driverId) {
  final today = DateTime.now();
  DateTime t(int h, int m) => DateTime(today.year, today.month, today.day, h, m);

  final rawTickets = <Map<String, dynamic>>[
    {
      'id': 'ticket_001',
      'line': {'id': 'line_01', 'origin': 'Bab Doukkala', 'destination': 'Mhamid', 'price': 30.0},
      'totalSeats': 4,
      'paidMethod': 'cash',
      'amount': 120.0,
      'departedAt': t(8, 30).toIso8601String(),
      'status': 'unpaid',
    },
    {
      'id': 'ticket_002',
      'line': {'id': 'line_01', 'origin': 'Bab Doukkala', 'destination': 'Mhamid', 'price': 30.0},
      'totalSeats': 6,
      'paidMethod': 'nfc',
      'amount': 180.0,
      'departedAt': t(9, 15).toIso8601String(),
      'status': 'paid',
    },
    {
      'id': 'ticket_003',
      'line': {'id': 'line_02', 'origin': 'Bab Doukkala', 'destination': 'Daoudiate', 'price': 8.0},
      'totalSeats': 5,
      'paidMethod': 'cash',
      'amount': 40.0,
      'departedAt': t(10, 0).toIso8601String(),
      'status': 'unpaid',
    },
    {
      'id': 'ticket_004',
      'line': {'id': 'line_01', 'origin': 'Bab Doukkala', 'destination': 'Daoudiate', 'price': 30.0},
      'totalSeats': 6,
      'paidMethod': 'nfc',
      'amount': 180.0,
      'departedAt': t(11, 30).toIso8601String(),
      'status': 'paid',
    },
    {
      'id': 'ticket_005',
      'line': {'id': 'line_03', 'origin': 'Bab Doukkala', 'destination': 'Daoudiate', 'price': 8.0},
      'totalSeats': 4,
      'paidMethod': 'cash',
      'amount': 32.0,
      'departedAt': t(13, 0).toIso8601String(),
      'status': 'unpaid',
    },
    {
      'id': 'ticket_006',
      'line': {'id': 'line_01', 'origin': 'Bab Doukkala', 'destination': 'Daoudiate', 'price': 30.0},
      'totalSeats': 5,
      'paidMethod': 'cash',
      'amount': 150.0,
      'departedAt': t(14, 30).toIso8601String(),
      'status': 'unpaid',
    },
  ];

  // Apply cashout state
  final tickets = rawTickets.map((t) {
    if (_paidTicketIds.contains(t['id'])) {
      return {...t, 'status': 'paid'};
    }
    return t;
  }).toList();

  // Compute summary
  double cashAmount = 0;
  double nfcAmount = 0;
  for (final t in tickets) {
    if (t['paidMethod'] == 'cash') {
      cashAmount += (t['amount'] as num).toDouble();
    } else {
      nfcAmount += (t['amount'] as num).toDouble();
    }
  }

  return {
    'status': 'success',
    'data': {
      'driver': {
        'id': driverId,
        'name': 'Youssef Bennani',
        'phone': '+212661234567',
      },
      'tickets': tickets,
      'summary': {
        'totalTickets': tickets.length,
        'totalCashAmount': cashAmount,
        'totalNfcAmount': nfcAmount,
        'totalAmount': cashAmount + nfcAmount,
      },
    },
  };
}

// ─── Data source ──────────────────────────────────────────────────────────────

class TicketRemoteDataSource {
  final ApiClient _client;
  TicketRemoteDataSource(this._client);

  Future<dynamic> getDriverTickets(GetDriverTicketsParams params) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      // Return empty when querying a past date (mock only has today's data)
      if (params.date != null) {
        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        if (params.date != todayStr) {
          return {
            'status': 'success',
            'data': {
              'driver': {'id': params.driverId, 'name': '', 'phone': ''},
              'tickets': [],
              'summary': {
                'totalTickets': 0,
                'totalCashAmount': 0,
                'totalNfcAmount': 0,
                'totalAmount': 0,
              },
            },
          };
        }
      }
      return _buildMockResponse(params.driverId);
    }

    final parts = ['driverId=${Uri.encodeQueryComponent(params.driverId)}'];
    if (params.date != null) parts.add('date=${params.date}');
    if (params.status != null) parts.add('status=${params.status}');
    return _client.get('${ApiEndpoints.tickets}?${parts.join('&')}');
  }

  Future<dynamic> cashoutTicket(CashoutTicketParams params) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (params.all) {
        final mock = _buildMockResponse(params.driverId);
        final tickets = (mock['data']['tickets'] as List).cast<Map<String, dynamic>>();
        for (final t in tickets) {
          if (t['paidMethod'] == 'cash' && t['status'] == 'unpaid') {
            _paidTicketIds.add(t['id'] as String);
          }
        }
      } else if (params.ticketId != null) {
        _paidTicketIds.add(params.ticketId!);
      }
      return {'status': 'success', 'data': {'totalAmountCashedOut': 0}};
    }

    return _client.post(ApiEndpoints.tickets, {
      'driverId': params.driverId,
      'ticketId': params.ticketId,
      'all': params.all,
    });
  }
}
