import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Quote {
  String symbol;
  String name;
  double lastPrice;
  double open;
  double close;
  double high;
  double low;
  double netChange;
  double percentChange;
  int volume;

  Quote({
    this.symbol,
    this.name,
    this.lastPrice,
    this.open,
    this.close,
    this.high,
    this.low,
    this.netChange,
    this.percentChange,
    this.volume,
  });

  Quote.fromMap(Map<String, dynamic> map)
      : symbol = map['symbol'],
        name = map['name'],
        lastPrice = map['lastPrice'],
        open = map['open'],
        close = map['close'],
        high = map['high'],
        low = map['low'],
        netChange = map['netChange'],
        percentChange = map['percentChange'],
        volume = map['volume'];
}

class QuoteRepository {
  String quoteUrl = "https://marketdata.websol.barchart.com/getQuote.json?apikey=73f507126db3ece2eae3dc738fc4f54f&symbols=SCHB%2CSCHF%2CSCHE%2CVTI%2CVXUS";
  Future<List<Quote>> fetchQuotes() async {
    http.Response response = await http.get(quoteUrl);
    final Map responseBody = json.decode(response.body);
    final List results = responseBody["results"];
    final statusCode = response.statusCode;
    if (statusCode != 200 || responseBody == null) {
      throw new FetchDataException(
          "An error ocurred : [Status Code : $statusCode]");
    }

    return results.map((c) => new Quote.fromMap(c)).toList();
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
