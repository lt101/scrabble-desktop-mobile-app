import 'package:client_leger/services/user-info/user_info_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class GameHistory extends StatefulWidget {
  GameHistory(this._userInfoService, {super.key});
  late UserInfoService _userInfoService;

  @override
  State<GameHistory> createState() => _GameHistoryState();
}

class _GameHistoryState extends State<GameHistory> {
  late GameDataSource _gameDataSource;
  late Future<List<dynamic>> _gameHistory;

  @override
  void initState() {
    super.initState();
    _gameHistory = widget._userInfoService.getGamesPlayedHistory().then((val) {
      _gameDataSource = GameDataSource(getGameData(val));
      return val;
    });
  }

  List<Game> getGameData(List<dynamic> historyList) {
    List<dynamic> list = historyList;
    var arraySize = list.length;
    List<String> startDate = List.filled(arraySize, '', growable: true);
    List<String> endDate = List.filled(arraySize, '', growable: true);
    List<String> result = List.filled(arraySize, '', growable: true);

    List<Game> gameData =
        List.filled(arraySize, Game('', '', ''), growable: true);
    for (int i = 0; i < arraySize; i++) {
      String result =
          (list[i]['isWinner'] as bool) ? "Partie Gagnée" : "Partie Perdue";
      gameData[i] = Game(list[i]['startDate'], list[i]['endDate'], result);
    }
    return gameData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _gameHistory,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SafeArea(
                child: Scaffold(
              body: SfDataGrid(
                allowSorting: false,
                selectionMode: SelectionMode.multiple,
                source: _gameDataSource,
                columns: [
                  GridColumn(
                      minimumWidth: 330,
                      columnName: 'startDate',
                      label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.startDate,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                  GridColumn(
                      minimumWidth: 330,
                      columnName: 'endDate',
                      label: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.endDate,
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      minimumWidth: 330,
                      columnName: 'result',
                      label: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.gameResult,
                            overflow: TextOverflow.ellipsis,
                          ))),
                ],
              ),
            ));
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class GameDataSource extends DataGridSource {
  GameDataSource(List<Game> connections) {
    dataGridRows = connections
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'startDate', value: dataGridRow.startDate),
              DataGridCell<String>(
                  columnName: 'endDate', value: dataGridRow.endDate),
              DataGridCell<String>(
                  columnName: 'result', value: dataGridRow.result),
            ]))
        .toList();
  }

  late List<DataGridRow> dataGridRows;
  @override
  List<DataGridRow> get rows => dataGridRows;
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: (dataGridCell.columnName == 'index' ||
                  dataGridCell.columnName == 'salary')
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }
}

class Game {
  Game(this.startDate, this.endDate, this.result);
  String startDate;
  String endDate;
  String result;
}
