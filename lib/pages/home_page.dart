import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';

import '../utilities/habit_util.dart';





class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    // read existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }


 final TextEditingController textController = TextEditingController();

  // new habit
  void createNewHabit(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText:  "Create new habit",
            ),
          ),
          actions: [
            // save button
            MaterialButton(
                onPressed: () {

                  // get new habit name
                  String newHabitName = textController.text;

                  // save to db
                  context.read<HabitDatabase>().addHabit(newHabitName);
                  Navigator.pop(context);
                  textController.clear();
                },
              child: const Text("Save"),
            ),

            // cancel button
            MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                },

              child: const Text("Cancel"),
            )
          ],
        )
    );
}

void checkHabitOnOff(bool? value, Habit habit){
  // update habit completion status
  if(value != null){
    context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
  }
}

// edit habit dialog
void editHabitBox(Habit habit){
    textController.text = habit.name;
    showDialog(
        context: context,
        builder: (context)=> AlertDialog(
          content: TextField(
            controller: textController,
          ),
         actions: [
           // save button
           MaterialButton(
             onPressed: () {

               // get new habit name
               String newHabitName = textController.text;

               // save to db
               context.read<HabitDatabase>().updateHabitName(habit.id,newHabitName);
               Navigator.pop(context);
               textController.clear();
             },
             child: const Text("Save"),
           ),

           // cancel button
           MaterialButton(
             onPressed: (){
               Navigator.pop(context);
             },

             child: const Text("Cancel"),
           )
         ],
        )
    );
}
// delete habit dialog
  void deleteHabitBox(Habit habit){
    showDialog(
        context: context,
        builder: (context)=> AlertDialog(
          title: const Text("Are you sure you want to delete?"),
          actions: [
            // delete button
            MaterialButton(
              onPressed: () {

                // get new habit name
                String newHabitName = textController.text;

                // save to db
                context.read<HabitDatabase>().deleteHabit(habit.id);
                Navigator.pop(context);

              },
              child: const Text("Delete"),
            ),

            // cancel button
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(
        children: [
          // HEAT MAP
          _buildHeatMap(),
          // HABIT LIST
          _buildHabitList(),
        ],
      ),
    );
  }
  // build heat map
Widget _buildHeatMap(){
    // habit database
  final habitDatabase = context.watch<HabitDatabase>();
  // current habits
  List<Habit> currentHabits = habitDatabase.currentHabits;

  // return heatmap UI
  return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        // if data is available == build heatmap
          if(snapshot.hasData){
            return MyHeatMap(
                startDate: snapshot.data!,
                datasets: prepHeatMapDataSet(currentHabits)
            );
          } else {
            // handle where there is no data returned
            return Container();
          }
      },
  );
}

  // build habit list
  Widget _buildHabitList(){
    // db
    final habitDb = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDb.currentHabits;

    // return list of habits UI
    return ListView.builder(
      itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context,index){
          // get each individual habit
          final habit = currentHabits[index];
          // check if the habit is completed today
          bool isCompletedToday = isHabitCompletedToday(habit.completeDays);
          // return habit tile UI
          return MyHabitTile(
              isCompleted: isCompletedToday,
              text: habit.name,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        },
    );
  }

}

