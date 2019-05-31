import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_candlesticks/flutter_candlesticks.dart';
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
    _refresh();
  }

  Future<void> _refresh() {
    return _presenter.loadHistory(_quote.symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_quote.symbol),
        elevation: defaultTargetPlatform == TargetPlatform.iOS ? 0.0 : 5.0,
      ),
      body: new Column(
        children: <Widget>[
          _quoteWidget(),
          new Flexible(
            child: _isLoading
              ? new Center(child: new CircularProgressIndicator())
              : _historyWidget()
          )
        ]
      )
    );
  }

  Widget _quoteWidget() {
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

    return new ListTile(
      title: new RichText(
        text: new TextSpan(
          children: [nameTextWidget, priceTextWidget, changeTextWidget, ohlcTextWidget, volumeTextWidget]
        )
      )
    );
  }

  Widget _historyWidget() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.show_chart)),
              Tab(icon: Icon(Icons.list)),
            ],
          ),
        body: TabBarView(
          children: [
            _historyChartWidget(),
            _historyListWidget(),
          ],
        ),
      )
    );
  }

  Widget _historyListWidget() {
    return new RefreshIndicator(
      child: new ListView.separated(
        itemCount: _history.length,
        itemBuilder: (context, index) => _getListItemUi(_history[index]),
        separatorBuilder: (context, index) => Divider(),
      ),
      onRefresh: _refresh,
    );
  }

  Widget _historyChartWidget() {
    List data = _history.map((h) => {"open":h.open, "high":h.high, "low":h.low, "close":h.close, "volumeto":h.volume}).toList();
    return new OHLCVGraph(
      data: data,
      enableGridLines: true,
      volumeProp: 0.2,
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
        children: [ohlcTextWidget, volumeTextWidget]
      )
    );
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
