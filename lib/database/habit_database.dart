import 'package:flutter/widgets.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;
  /*
    S E T U P
  */

  // initialise database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  // save date of app first launch
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first date of app startup (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

// CRUD Operations --->
// list of habits
  final List<Habit> currentHabits = [];

// create  --> add new habit
  Future<void> addHabits(String habitName) async {
    // create new habit
    final newHabit = Habit()..name = habitName;

    // sabe it in da
    await isar.writeTxn(() => isar.habits.put(newHabit));

    //re-read from database
    readHabits();
  }

// read from database
  Future<void> readHabits() async {
    // fetch all the habits from the database
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    // give to current habits list
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    // update the ui accordingly
    notifyListeners();
  }

// update --> check if on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // find the specific habit
    final habit = await isar.habits.get(id);

    // update completion status
    if (habit != null) {
      await isar.writeTxn(
        () async {
          // if habit is completed -->  add the current data to the completedDays list
          if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
            // today
            final today = DateTime.now();

            // add the current date if it is not in the list
            habit.completedDays.add(
              DateTime(
                today.year,
                today.month,
                today.day,
              ),
            );
          }
          // if habit is not completed then --> remmove the data from the list
          else {
            // remove the current date if the habit is marked as not comepled
            habit.completedDays.removeWhere(
              (date) =>
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day,
            );
          }
          // save the updated habits back to the database
          await isar.habits.put(habit);
        },
      );
    }
    // re-read from the database
    readHabits();
  }

// update  --> edit habit name in database
  Future<void> updateHabitName(int id, String newName) async {
    // find the specific habit
    final habit = await isar.habits.get(id);

    // update the habit name
    if (habit != null) {
      // update name
      await isar.writeTxn(() async {
        habit.name = newName;
        // save updated  habit back to database
        await isar.habits.put(habit);
      });
    }

    // re-read from the database
    readHabits();
  }

// delete --> delete in database
  Future<void> deleteHabit(int id) async {
    // perform delete operation
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    //  re-read from the database
    readHabits();
  }
}
