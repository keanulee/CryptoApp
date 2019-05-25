import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class History {
  String symbol;
  String tradingDay;
  num open;
  num close;
  num high;
  num low;
  int volume;

  History({
    this.symbol,
    this.tradingDay,
    this.open,
    this.close,
    this.high,
    this.low,
    this.volume,
  });

  History.fromMap(Map<String, dynamic> map)
      : symbol = map['symbol'],
        tradingDay = map['tradingDay'],
        open = map['open'],
        close = map['close'],
        high = map['high'],
        low = map['low'],
        volume = map['volume'];
}

class HistoryRepository {
  Future<List<History>> fetchHistory(String symbol) async {
    String historyUrl = "https://marketdata.websol.barchart.com/getHistory.json?apikey=73f507126db3ece2eae3dc738fc4f54f&symbol=$symbol&type=daily&startDate=20190101&maxRecords=20";
    http.Response response = await http.get(historyUrl);
    final Map responseBody = json.decode(response.body);
    final List results = responseBody["results"];
    final statusCode = response.statusCode;
    if (statusCode != 200 || responseBody == null) {
      throw new FetchDataException(
          "An error ocurred : [Status Code : $statusCode]");
    }

    return results.map((c) => new History.fromMap(c)).toList();
  }
}

class FetchDataException implements Exception {
  final _message;

  FetchDataException([this._message]);

  String toString() {
    if (_message == null) return "Exception";
    return "Exception: $_message";
  }
}
