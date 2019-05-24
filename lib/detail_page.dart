import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'data/quote_data.dart';

class DetailPage extends StatelessWidget {
  final Quote quote;
  DetailPage({Key key, this.quote}) : super(key: key);

  Widget build(BuildContext context) {
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

    return Scaffold(
        appBar: AppBar(
          title: Text('Quote'),
        ),
        body: new RichText(
          text: new TextSpan(
            children: [nameTextWidget, priceTextWidget, percentageChangeTextWidget]
          )
        ),
      );
  }
}
