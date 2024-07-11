import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
 final void Function(bool?)? onChanged;
 void Function(BuildContext)? editHabit;
 void Function(BuildContext)? deleteHabit;
  final String text;
  final bool isCompleted;
   MyHabitTile({
    super.key,
    required this.isCompleted,
    required this.text,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,

  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // edit option
            SlidableAction(
                onPressed: editHabit,
                backgroundColor: Colors.grey.shade800,
              icon: Icons.settings,
              borderRadius: BorderRadius.circular(10),
            ),

            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: (){
            if(onChanged  != null){
              // toggle completion status
              onChanged!(!isCompleted);
            }
          },
          // habit tile
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10)
            ),
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
            child: ListTile(
                title: Text(text,
                  style: TextStyle(color: isCompleted ? Colors.white : Theme.of(context).colorScheme.inversePrimary),
                ),
              leading: Checkbox(
                activeColor: Colors.green,
                value: isCompleted,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
