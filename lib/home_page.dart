import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'data/quote_data.dart';
import 'modules/quote_presenter.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> implements QuoteListViewContract {
  QuoteListPresenter _presenter;
  List<Quote> _quotes;
  bool _isLoading;

  _HomePageState() {
    _presenter = new QuoteListPresenter(this);
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _presenter.loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Quotes"),
          elevation: defaultTargetPlatform == TargetPlatform.iOS ? 0.0 : 5.0,
        ),
        body: _isLoading
            ? new Center(
          child: new CircularProgressIndicator(),
        )
            : _quotesWidget());
  }

  Widget _quotesWidget() {
    return new Container(
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                itemCount: _quotes.length * 2, // Dividers are items too
                itemBuilder: (BuildContext context, int index) {
                  final int i = index ~/ 2;
                  final Quote quote = _quotes[i];
                  if (index.isOdd) {
                    return new Divider();
                  }
                  return _getListItemUi(quote);
                },
              ),
            )
          ],
        ));
  }

  ListTile _getListItemUi(Quote quote) {
    return new ListTile(
      title: new Text(quote.symbol,
          style: new TextStyle(fontWeight: FontWeight.bold)),
      subtitle:
      _getSubtitleText(quote),
      isThreeLine: true,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailPage(quote: quote)));
      }
    );
  }

  Widget _getSubtitleText(Quote quote) {
    String name = quote.name;
    double priceUSD = quote.lastPrice;
    double percentageChange = quote.percentChange;
    TextSpan nameTextWidget = new TextSpan(
        text: "$name\n", style: new TextStyle(color: Colors.black));
    TextSpan priceTextWidget = new TextSpan(
        text: "\$$priceUSD\n", style: new TextStyle(color: Colors.black));
    String percentageChangeText = "$percentageChange%";
    TextSpan percentageChangeTextWidget;

    if (percentageChange > 0) {
      percentageChangeTextWidget = new TextSpan(
          text: percentageChangeText,
          style: new TextStyle(color: Colors.green));
    } else {
      percentageChangeTextWidget = new TextSpan(
          text: percentageChangeText, style: new TextStyle(color: Colors.red));
    }

    return new RichText(
        text: new TextSpan(
            children: [nameTextWidget, priceTextWidget, percentageChangeTextWidget]));
  }

  @override
  void onLoadQuotesComplete(List<Quote> items) {
    setState(() {
      _quotes = items;
      _isLoading = false;
    });
  }

  @override
  void onLoadQuotesError() {
    // TODO: implement onLoadQuotesError
  }
}
