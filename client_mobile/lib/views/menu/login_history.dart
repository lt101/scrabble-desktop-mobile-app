import 'dart:math';

import 'package:client_leger/services/user-info/user_info_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LoginHistory extends StatefulWidget {
  LoginHistory(this._userInfoService, {super.key});
  late UserInfoService _userInfoService;

  @override
  State<LoginHistory> createState() => _LoginHistoryState();
}

class _LoginHistoryState extends State<LoginHistory> {
  late LoginDataSource _connectionDataSource;
  late Future<List<dynamic>> _loginHistory;

  @override
  void initState() {
    super.initState();
    _loginHistory = widget._userInfoService.getLoginHistory().then((val) {
      _connectionDataSource = LoginDataSource(getConnectionData(val));
      return val;
    });
  }

  List<Connection> getConnectionData(List<dynamic> gameList) {
    List<dynamic> list = gameList;
    var arraySize = list.length;
    List<String> logins = List.filled(arraySize, '', growable: true);
    List<String> logouts = List.filled(arraySize, '', growable: true);
    var loginCounter = 0;
    var logoutCounter = 0;
    for (int i = 0; i < list.length; i++) {
      Map<String, dynamic> temp = Map<String, dynamic>.from(list[i]);
      if (temp['logDate'] != null) {
        if (temp['status'] == 'login') {
          logins[loginCounter++] = temp['logDate'];
        } else if (temp['status'] == 'logout') {
          logouts[logoutCounter++] = temp['logDate'];
        }
      }
    }

    List<Connection> connectionData = List.filled(
        (arraySize / 2).round(), Connection(0, '', ''),
        growable: true);
    for (int i = 0; i < max(logins.length / 2, logouts.length / 2); i++) {
      connectionData[i] = Connection(i, logins[i], logouts[i]);
    }
    return connectionData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loginHistory,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SafeArea(
                child: Scaffold(
              body: SfDataGrid(
                allowSorting: false,
                selectionMode: SelectionMode.multiple,
                source: _connectionDataSource,
                columns: [
                  GridColumn(
                      minimumWidth: 80,
                      width: 80,
                      columnName: 'index',
                      label: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Index',
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                  GridColumn(
                      minimumWidth: 450,
                      columnName: 'logins',
                      label: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Connexions',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      minimumWidth: 450,
                      columnName: 'logouts',
                      label: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.deconnexions,
                            overflow: TextOverflow.ellipsis,
                          ))),
                ],
              ),
            ));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class LoginDataSource extends DataGridSource {
  LoginDataSource(List<Connection> connections) {
    dataGridRows = connections
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'index', value: dataGridRow.index),
              DataGridCell<String>(
                  columnName: 'logins', value: dataGridRow.login),
              DataGridCell<String>(
                  columnName: 'logouts', value: dataGridRow.logout),
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

class Connection {
  Connection(this.index, this.login, this.logout);
  int index;
  String login;
  String logout;
}
