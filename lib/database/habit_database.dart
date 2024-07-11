import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier{
  static late Isar isar;
  /*
  *   S E T U P
  * */
  // initialize db
static Future<void> initialize() async {
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
}


// Save first date of app startup( for heatmap)
Future<void> saveFirstLaunchDate() async {
  final existingSettings = await isar.appSettings.where().findFirst();
  if(existingSettings == null){
    final settings = AppSettings()..firstLaunchDate = DateTime.now();
    await isar.writeTxn(() => isar.appSettings.put(settings));
  }
}

// Get first date of app startup (for heatmap)
Future<DateTime?> getFirstLaunchDate() async {
  final settings = await isar.appSettings.where().findFirst();
  return settings?.firstLaunchDate;
}

/*
*
* C R U D     O P E R A T I O N S
*
* */

// habit list
final List<Habit> currentHabits = [];
// Create - add new habit
Future<void> addHabit(String habitName)async {
  final newHabit = Habit()..name = habitName;
  
  // save to db
  await isar.writeTxn(() => isar.habits.put(newHabit));

  // re-read db
  readHabits();
}
// Read - read saved habits
Future<void> readHabits() async{
  // fetch all habits
  List<Habit> fetchedHabits = await isar.habits.where().findAll();

  // give to current habits
  currentHabits.clear();
  currentHabits.addAll(fetchedHabits);

  //update UI
  notifyListeners();
}
// Update - edit habits
Future<void> updateHabitCompletion(int id, bool isCompleted) async{
  // find the specific habit
  final habit = await isar.habits.get(id);

  // update completion status
  if(habit!=null){
    await isar.writeTxn(() async {
      // if habit is completed == add current date to the completeDays list
      if(isCompleted && !habit.completeDays.contains(DateTime.now())){

        // today
        final today = DateTime.now();

        // add the current date if is not already in the list
        habit.completeDays.add(
          DateTime(
            today.year,
            today.month,
            today.day,
          ),
        );

        // if habit is NOT completed -> remove the current date from the list 
      }else{
          // remove current date if the habit is marked as not completed
        habit.completeDays.removeWhere(
                (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
        );
      }

      // save updated list back to the db
      await isar.habits.put(habit);
    });
  }
  // re -read from the db
  readHabits();
}

// Update habit name
  Future<void> updateHabitName(int id, String newName) async {
    // find the specific habit
  final habit = await isar.habits.get(id);
    // update the habit name
  if(habit != null){
    // update name
    await isar.writeTxn(() async{
      habit.name = newName;

      // save to db
      await isar.habits.put(habit);
    });
  }
    // re-read from the db
    readHabits();
  }

// Delete - delete habit
  Future<void> deleteHabit(int id ) async{
    await isar.writeTxn(() async{

      await isar.habits.delete(id);

    });
    readHabits();
  }


}
