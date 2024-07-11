import 'package:isar/isar.dart';


// run: dart run build_runner
part 'habit.g.dart';

@Collection()
class Habit{
    // habit id
  Id id = Isar.autoIncrement;

  // habit name
  late String name;

  // completed days
   List<DateTime> completeDays =[
      // DateTime(y,m,d),
      // DateTime(2024,1,1),
      // DateTime(2024,1,2),

   ];
}