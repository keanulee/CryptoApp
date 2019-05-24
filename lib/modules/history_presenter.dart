import 'package:fluttercrypto/data/history_data.dart';

abstract class HistoryListViewContract {
  void onLoadHistoryComplete(List<History> items);
  void onLoadHistoryError();
}

class HistoryListPresenter {
  HistoryListViewContract _view;
  HistoryRepository _repository;

  HistoryListPresenter(this._view) {
    _repository = new HistoryRepository();
  }

  void loadHistorys(String symbol) {
    _repository
        .fetchHistory(symbol)
        .then((c) => _view.onLoadHistoryComplete(c))
        .catchError((onError) => _view.onLoadHistoryError());
  }
}
