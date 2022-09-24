import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/cubit/cubit.dart';
import 'package:todo_list/cubit/states.dart';
import 'package:todo_list/shared/components.dart';

class ArchivedTasks extends StatelessWidget {
  List<Map> tasks = [];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<tasksCubit, TasksStates>(
        listener: (context, state) {},
        builder: (context, state) {
          tasks = tasksCubit.get(context).archivedData;
          return ConditionalBuilder(
            condition: tasks.length > 0,
            builder: (context) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ListView.separated(
                  itemBuilder: (context, index) => defaultTask(
                        time: tasks[index]['time'],
                        task: tasks[index]['title'],
                        date: tasks[index]['date'],
                        id: tasks[index]['id'],
                        maxLines: tasks[index]['maxlines'],
                        context: context,
                      ),
                  separatorBuilder: (context, index) => Container(
                        height: 10,
                        child: Center(
                            child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 35),
                          child: Container(
                            color: Colors.black12,
                            height: 0.5,
                          ),
                        )),
                      ),
                  itemCount: tasks.length),
            ),
            fallback: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu, size: 60, color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      "No Tasks Yet, Please Add Some Tasks",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
