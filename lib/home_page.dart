import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/quote_data.dart';
import 'modules/quote_presenter.dart';
import 'detail_page.dart';

final Future<SharedPreferences> prefsFuture = SharedPreferences.getInstance();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> implements QuoteListViewContract {
  List<String> _symbolsList;
  QuoteListPresenter _presenter;
  List<Quote> _quotes;
  bool _isLoading;

  _HomePageState() {
    _presenter = new QuoteListPresenter(this);;
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _loadSymbolsList();
  }

  Future<void> _loadSymbolsList() async {
    SharedPreferences prefs = await prefsFuture;
    _symbolsList = prefs.getStringList('symbols');
    if (_symbolsList == null) {
      _symbolsList = ['GOOG','SCHB','SCHF','SCHE','VTI','VXUS'];
    }
    return _refresh();
  }

  Future<bool> _saveSymbolsList() async {
    SharedPreferences prefs = await prefsFuture;
    return prefs.setStringList('symbols', _symbolsList);
  }

  Future<void> _refresh() {
    return _presenter.loadQuotes(_symbolsList);
  }

  Future<void> _addSymbol() async {
    TextEditingController controller = new TextEditingController();
    String symbol = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Add symbol'),
          children: <Widget>[
            SimpleDialogOption(
              child: new TextField(
                decoration: new InputDecoration(hintText: 'Symbol'),
                controller: controller,
              ),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, controller.text); },
              child: const Text('Add'),
            ),
            SimpleDialogOption(
              onPressed: () { Navigator.pop(context, null); },
              child: const Text('Cancel'),
            ),
          ],
        );
      }
    );

    if (symbol.isNotEmpty) {
      _symbolsList.add(symbol);
      _saveSymbolsList();
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Quotes"),
        elevation: defaultTargetPlatform == TargetPlatform.iOS ? 0.0 : 5.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addSymbol,
          ),
        ],
      ),
      body: _isLoading
        ? new Center(child: new CircularProgressIndicator())
        : _quotesList()
    );
  }

  Widget _quotesList() {
    return new RefreshIndicator(
      child: new ListView.separated(
        itemCount: _quotes.length, // Dividers are items too
        itemBuilder: (context, index) {
          Quote quote = _quotes[index];
          return new Dismissible(
            key: Key(quote.symbol),
            background: Container(color: Colors.red),
            onDismissed: (direction) => setState(() {
              _symbolsList.removeAt(index);
              _saveSymbolsList();
              _quotes.removeAt(index);
            }),
            child:_getListItemUi(quote)
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
      onRefresh: _refresh,
    );
  }

  ListTile _getListItemUi(Quote quote) {
    return new ListTile(
      title: new Text(quote.symbol,
        style: new TextStyle(fontWeight: FontWeight.bold)
      ),
      subtitle: _getSubtitleText(quote),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(quote: quote)));
      }
    );
  }

  Widget _getSubtitleText(Quote quote) {
    String name = quote.name;
    num lastPrice = quote.lastPrice;
    num netChange = quote.netChange;
    num percentageChange = quote.percentChange;

    TextSpan nameTextWidget = new TextSpan(
      text: "$name\n",
      style: new TextStyle(color: Colors.black)
    );
    TextSpan priceTextWidget = new TextSpan(
      text: "\$$lastPrice\n",
      style: new TextStyle(color: Colors.black)
    );
    TextSpan changeTextWidget;

    if (percentageChange > 0) {
      changeTextWidget = new TextSpan(
        text: "+$netChange ($percentageChange%)",
        style: new TextStyle(color: Colors.green)
      );
    } else {
      changeTextWidget = new TextSpan(
        text: "$netChange ($percentageChange%)",
        style: new TextStyle(color: Colors.red)
      );
    }

    return new RichText(
      text: new TextSpan(
        children: [nameTextWidget, priceTextWidget, changeTextWidget]
      )
    );
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
