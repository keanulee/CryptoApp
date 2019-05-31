import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

String apikey = '73f507126db3ece2eae3dc738fc4f54f';

class Quote {
  String symbol;
  String name;
  num lastPrice;
  num open;
  num close;
  num high;
  num low;
  num netChange;
  num percentChange;
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
  Future<List<Quote>> fetchQuotes(List<String> symbolsList) async {
    String symbols = symbolsList.join('%2C');
    String quoteUrl = "https://marketdata.websol.barchart.com/getQuote.json?apikey=$apikey&symbols=$symbols";
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
