import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/cubit/cubit.dart';
import 'package:todo_list/shared/components.dart';
import 'package:todo_list/cubit/states.dart';

class HomeScreen extends StatelessWidget {
  late TextEditingController title_ctrl = TextEditingController();
  late TextEditingController date_ctrl = TextEditingController();
  late TextEditingController time_ctrl = TextEditingController();
  late TextEditingController status_ctrl = TextEditingController();
  late TextEditingController controller5 = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var Formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => tasksCubit()..createDatabase(),
        child: BlocConsumer<tasksCubit, TasksStates>(listener: (contex, state) {
          if (state is NewTaskState) print("newTasksState.....");
          if (state is ScreenChangedState) print("screenChangedState.....");
        }, builder: (context, state) {
          tasksCubit cubit = tasksCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            body: ConditionalBuilder(
                condition: true,
                builder: (context) {
                  return cubit.taskScreens[cubit.currentIndex];
                },
                fallback: (context) {
                  return Center(child: CircularProgressIndicator());
                }),
            bottomNavigationBar: BottomNavigationBar(
              iconSize: 40,
              onTap: (index) {
                cubit.changeIndex(index);
                cubit.getNewData(cubit.database);
                cubit.getDoneData(cubit.database);
                cubit.getArchiveData(cubit.database);
              },
              selectedFontSize: 20,
              currentIndex: cubit.currentIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: "Tasks",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.done),
                  label: "Done",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive),
                  label: "Archived",
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (!cubit.FAB_opend) {
                  cubit.notFAB();
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Form(
                              key: Formkey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  defaultFormField(
                                    txtcon1: title_ctrl,
                                    lable: "Task",
                                    pre: Icon(Icons.title),
                                    warningMsg: "Task can not be empty",
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  defaultFormField(
                                    txtcon1: date_ctrl,
                                    lable: "Date",
                                    pre: Icon(Icons.date_range),
                                    warningMsg: "Date can not be empty",
                                    onTap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now())
                                          .then((value) {
                                        date_ctrl.text =
                                            DateFormat.yMMMd().format(value!);
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  defaultFormField(
                                    txtcon1: time_ctrl,
                                    lable: "Time",
                                    pre: Icon(Icons.watch_later_outlined),
                                    type: TextInputType.datetime,
                                    warningMsg: "Time can not be empty",
                                    onTap: () {
                                      showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now())
                                          .then((value) {
                                        time_ctrl.text = value!.format(context);
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        elevation: 20,
                      )
                      .closed
                      .then((value) {
                    cubit.closeFAB();
                  });
                } else {
                  if (Formkey.currentState!.validate()) {
                    await cubit
                        .insertToDatabase(
                      title: title_ctrl.text,
                      date: date_ctrl.text,
                      time: time_ctrl.text,
                    )
                        .then((value) {
                      cubit.getData(cubit.database).then((value) {
                        Navigator.pop(context);
                        title_ctrl.text = "";
                        date_ctrl.text = "";
                        time_ctrl.text = "";
                        status_ctrl.text = "";
                        cubit.notFAB();
                      });
                    });
                    cubit.getData(cubit.database);
                  }
                }
              },
              child: cubit.FAB_icon,
              heroTag: 1,
            ),
          );
        }));
  }
}
