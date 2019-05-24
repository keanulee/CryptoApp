import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'data/quote_data.dart';
import 'data/history_data.dart';
import 'modules/history_presenter.dart';


class DetailPage extends StatefulWidget {
  final Quote quote;
  DetailPage({Key key, this.quote}) : super(key: key);

  @override
  _DetailPageState createState() => new _DetailPageState(quote);
}

class _DetailPageState extends State<DetailPage> implements HistoryListViewContract {
  Quote _quote;
  HistoryListPresenter _presenter;
  List<History> _history;
  bool _isLoading;

  _DetailPageState(Quote quote) {
    _quote = quote;
    _presenter = new HistoryListPresenter(this);
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _presenter.loadHistorys(_quote.symbol);
  }

  Widget build(BuildContext context) {
    String name = _quote.name;
    num lastPrice = _quote.lastPrice;
    num netChange = _quote.netChange;
    num percentageChange = _quote.percentChange;
    num open = _quote.open;
    num close = _quote.close;
    num high = _quote.high;
    num low = _quote.low;
    int volume = _quote.volume;

    TextSpan nameTextWidget = new TextSpan(
      text: "$name\n", style: new TextStyle(color: Colors.black));
    TextSpan priceTextWidget = new TextSpan(
      text: "\$$lastPrice\n", style: new TextStyle(color: Colors.black));
    TextSpan changeTextWidget;

    if (percentageChange > 0) {
      changeTextWidget = new TextSpan(
        text: "+$netChange ($percentageChange%)\n",
        style: new TextStyle(color: Colors.green)
      );
    } else {
      changeTextWidget = new TextSpan(
        text: "$netChange ($percentageChange%)\n",
        style: new TextStyle(color: Colors.red)
      );
    }

    TextSpan ohlcTextWidget = new TextSpan(
      text: "\$$open / \$$high / \$$low / \$$close\n", style: new TextStyle(color: Colors.black));
    TextSpan volumeTextWidget = new TextSpan(
      text: "$volume", style: new TextStyle(color: Colors.black));

    return Scaffold(
      appBar: AppBar(
        title: Text(_quote.symbol),
      ),
      body: new Container(
        child: new Column(children: <Widget>[
          new ListTile(
            title: new RichText(
              text: new TextSpan(
                children: [nameTextWidget, priceTextWidget, changeTextWidget, ohlcTextWidget, volumeTextWidget]
              )
            )
          ),
          new Divider(),
          _isLoading
            ? new Center(child: new CircularProgressIndicator())
            : _historyWidget()
        ]) 
      )
    );
  }

  Widget _historyWidget() {
    return new Flexible(
      child: new ListView.builder(
        itemCount: _history.length * 2, // Dividers are items too
        itemBuilder: (BuildContext context, int index) {
          final int i = index ~/ 2;
          final History history = _history[i];
          if (index.isOdd) {
            return new Divider();
          }
          return _getListItemUi(history);
        },
      ),
    );
  }

  ListTile _getListItemUi(History history) {
    return new ListTile(
      title: new Text(history.tradingDay,
        style: new TextStyle(fontWeight: FontWeight.bold)
      ),
      subtitle: _getSubtitleText(history),
    );
  }

  Widget _getSubtitleText(History history) {
    num open = history.open;
    num close = history.close;
    num high = history.high;
    num low = history.low;
    int volume = history.volume;

    TextSpan ohlcTextWidget = new TextSpan(
        text: "\$$open / \$$high / \$$low / \$$close\n", style: new TextStyle(color: Colors.black));
    TextSpan volumeTextWidget = new TextSpan(
        text: "$volume", style: new TextStyle(color: Colors.black));

    return new RichText(
        text: new TextSpan(
            children: [ohlcTextWidget, volumeTextWidget]));
  }

  @override
  void onLoadHistoryComplete(List<History> items) {
    setState(() {
      _history = items;
      _isLoading = false;
    });
  }

  @override
  void onLoadHistoryError() {
    // TODO: implement onLoadHistoryError
  }
}
