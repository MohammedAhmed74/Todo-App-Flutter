import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/body_screens/archived_tasks.dart';
import 'package:todo_list/body_screens/done_tasks.dart';
import 'package:todo_list/body_screens/new_tasks.dart';
import 'package:todo_list/cubit/states.dart';

class tasksCubit extends Cubit<TasksStates> {
  tasksCubit() : super(InitialState());

  static tasksCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> taskScreens = [
    NewTasks(),
    DoneTasks(),
    ArchivedTasks(),
  ];

  List<String> titles = [
    "New Tasks",
    "Done Tasks",
    "Archived Tasks",
  ];
  void changeIndex(int index) {
    currentIndex = index;
    emit(ScreenChangedState());
  }

  Icon FAB_icon = Icon(Icons.edit);
  bool FAB_opend = false;

  void notFAB() {
    FAB_opend = !FAB_opend;
    FAB_opend ? FAB_icon = Icon(Icons.add) : FAB_icon = Icon(Icons.edit);
    emit(FABchangedState());
  }

  void closeFAB() {
    FAB_opend = false;
    FAB_opend ? FAB_icon = Icon(Icons.add) : FAB_icon = Icon(Icons.edit);
    emit(FABchangedState());
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  Database  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  late Database database;
  List<Map> data = [];
  List<Map> newData = [];
  List<Map> doneData = [];
  List<Map> archivedData = [];

  Future createDatabase() async {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
    );
  }

  _onCreate(Database db, int version) {
    print('onCreate ...');
    db.execute(
        '''CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT, maxlines INTEGER)
    ''').then((value) {
      print('table created ...');
      emit(DatabaseCreateState());
    }).catchError((error) {
      print('error : $error');
    });
  }

  _onOpen(Database db) {
    print('database opened...');
    getData(db).then((value) {
      print(data);
      emit(DatabaseOpenState());
    });
  }

  Future insertToDatabase({
    required String title,
    required String date,
    required String time,
    String status = 'new',
  }) async {
    print('********************************** $status');
    database.transaction((txn) async {
      txn.rawInsert(
          'INSERT INTO tasks(title, date, time, status, maxlines) VALUES (?,?,?,?,?)',
          [title, date, time, status, 5]).then((value) {
        print('$value inserted successfully...');
        emit(DatabaseInsertState());
        getData(database).then((value) {
          emit(DatabaseGetState());
        });
      }).catchError((error) {
        print('error : $error');
      });
    });
  }

  Future getData(Database db) async {
    print("getting data..");
    data = await db.rawQuery("SELECT * FROM tasks").catchError((error) {
      print("error: $error");
    });
    getNewData(db).then((value) {
      emit(NewTasksScreenState());
      getDoneData(db).then((value) {
        emit(DoneTasksScreenState());
        getArchiveData(db).then((value) {
          emit(ArchiveTasksScreenState());
        });
      });
    });
  }

  Future deleteRecored(int rawNum) async {
    database.rawDelete("DELETE FROM tasks WHERE id = $rawNum").then((value) {
      emit(DatabaseDeleteState());
      getData(database);
      emit(DatabaseGetState());
    });
  }

  countRecords({required String tableName}) async {
    int? count = Sqflite.firstIntValue(
        await database.rawQuery("SELECT COUNT(*) FROM $tableName"));
    print(count);
  }

  updateData({
    required String status,
    required int rowNum,
  }) async {
    int count = await database
        .rawUpdate('UPDATE tasks SET status =?  WHERE id =?', [status, rowNum]);
    print("$count rows updated...");
    emit(DatabaseUpdateState());
  }

  Future getNewData(Database db) async {
    print("getting data..");
    newData = await db.rawQuery(
        "SELECT * FROM tasks WHERE status = ?", ["new"]).catchError((error) {
      print("error: $error");
    });
  }

  Future getDoneData(Database db) async {
    print("getting data..");
    doneData = await db.rawQuery(
        "SELECT * FROM tasks WHERE status = ?", ["done"]).catchError((error) {
      print("error: $error");
    });
  }

  Future getArchiveData(Database db) async {
    print("getting data..");
    archivedData = await db.rawQuery("SELECT * FROM tasks WHERE status = ?",
        ["archived"]).catchError((error) {
      print("error: $error");
    });
  }

  openTask({
    required int maxLines,
    required int rowNum,
  }) async {
    if (maxLines == 5)
      maxLines = 30;
    else
      maxLines = 5;
    int count = await database.rawUpdate(
        'UPDATE tasks SET maxlines =?  WHERE id =?', [maxLines, rowNum]);
    print("$count rows updated...");

    emit(OpenTaskState());
  }

  Future getRecored({required int id}) async {
    List<Map> recored =
        await database.rawQuery("SELECT * FROM tasks WHERE id = ?", [id]);
    return recored;
  }
}
