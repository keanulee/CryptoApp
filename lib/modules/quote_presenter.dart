import 'package:fluttercrypto/data/quote_data.dart';

abstract class QuoteListViewContract {
  void onLoadQuotesComplete(List<Quote> items);
  void onLoadQuotesError();
}

class QuoteListPresenter {
  QuoteListViewContract _view;
  QuoteRepository _repository;

  QuoteListPresenter(this._view) {
    _repository = new QuoteRepository();
  }

  Future<void> loadQuotes() {
    return _repository
        .fetchQuotes()
        .then((c) => _view.onLoadQuotesComplete(c))
        .catchError((onError) => _view.onLoadQuotesError());
  }
}
