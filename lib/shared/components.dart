import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/cubit/cubit.dart';
import 'package:todo_list/cubit/states.dart';

Widget defaultFormField({
  required TextEditingController txtcon1,
  Function(String)? onChange,
  Function()? onTap,
  required String lable,
  Icon? pre,
  String? warningMsg,
  bool isPassword = false,
  Icon? suff,
  TextInputType? type,
  Function()? suffOnPressed,
}) =>
    TextFormField(
      onChanged: onChange,
      onTap: onTap != null ? onTap : () {},
      controller: txtcon1,
      validator: (txt) {
        if (txt!.isEmpty) {
          return warningMsg;
        }
        if (txt.length < 4) {
          return 'too small';
        }
      },
      obscureText: isPassword,
      keyboardType: type != null ? type : TextInputType.text,
      decoration: InputDecoration(
        labelText: lable,
        labelStyle: TextStyle(fontSize: 18, color: Colors.black),
        prefixIcon: pre != null ? pre : SizedBox(),
        suffixIcon: IconButton(
          onPressed: suffOnPressed,
          icon: suff != null ? suff : SizedBox(),
        ),
        border: OutlineInputBorder(),
      ),
    );

Widget defaultTask({
  required int id,
  required String time,
  required String task,
  required String date,
  required BuildContext context,
  required int maxLines,
}) {
  bool delete = true;
  return Dismissible(
    direction: DismissDirection.horizontal,
    key: UniqueKey(),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            child: Text(time),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    tasksCubit
                        .get(context)
                        .openTask(rowNum: id, maxLines: maxLines);
                    tasksCubit
                        .get(context)
                        .getData(tasksCubit.get(context).database);
                  },
                  child: Text(
                    task,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              tasksCubit.get(context).updateData(
                    status: 'done',
                    rowNum: id,
                  );
              tasksCubit.get(context).getData(tasksCubit.get(context).database);
            },
            icon: Icon(Icons.check_box),
            color: Colors.green,
            iconSize: 35,
          ),
          IconButton(
            onPressed: () {
              tasksCubit.get(context).updateData(
                    status: 'archived',
                    rowNum: id,
                  );
              tasksCubit.get(context).getData(tasksCubit.get(context).database);
            },
            icon: Icon(Icons.archive),
            color: Colors.black45,
            iconSize: 35,
          ),
        ],
      ),
    ),
    onDismissed: (direction) async {
      print(id);
      var recored = await tasksCubit.get(context).getRecored(id: id);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: Text("Task deleted"),
            backgroundColor: Colors.red,
            //backgroundColor: Color(0xffFBB917),
            //backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: () async {
                delete = false;
                tasksCubit
                    .get(context)
                    .getData(tasksCubit.get(context).database);
              },
            ),
          ))
          .closed
          .then((value) {
        if (delete) {
          if (direction == DismissDirection.startToEnd ||
              direction == DismissDirection.endToStart)
            tasksCubit.get(context).deleteRecored(id).then((value) {
              tasksCubit.get(context).getData(tasksCubit.get(context).database);
            });
        }
      });
    },
  );
}
