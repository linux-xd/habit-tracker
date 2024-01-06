import 'package:flutter/material.dart';
import 'package:habit_tracker/components/app_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heatmap.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';

import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // read the existing habits data on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  // text cpntroller for adding habits
  final TextEditingController textController = TextEditingController();

  // create new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: "Create a new habit",
          ),
        ),
        actions: [
          //save button
          MaterialButton(
            onPressed: () {
              // get new habit name from text controller
              String newHabitName = textController.text;

              // save it to database
              context.read<HabitDatabase>().addHabits(newHabitName);

              // pop the box
              Navigator.pop(context);

              // clear the text controller
              textController.clear();
            },
            child: const Text("Create"),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              // pop the box
              Navigator.pop(context);

              // clear the text controller
              textController.clear();
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  //check habit on and off
  void checkHabitOnOff(bool? value, Habit habit) {
    // update habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // edit habit box
  void editHabitBox(Habit habit) {
    // set the conterollerd current text to the habits current name
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //save button
          MaterialButton(
            onPressed: () {
              // get new habit name from text controller
              String newHabitName = textController.text;

              // save it to database
              context
                  .read<HabitDatabase>()
                  .updateHabitName(habit.id, newHabitName);

              // pop the box
              Navigator.pop(context);

              // clear the text controller
              textController.clear();
            },
            child: const Text("Save"),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              // pop the box
              Navigator.pop(context);

              // clear the text controller
              textController.clear();
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // delete habit
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure you want to delete this ?"),
        actions: [
          // delete button
          MaterialButton(
            onPressed: () {
              // save it to database
              context.read<HabitDatabase>().deleteHabit(habit.id);

              // pop the box
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),

          //cancel button
          MaterialButton(
            onPressed: () {
              // pop the box
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
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
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: ListView(
        children: [
          // heatmap
          _buildHeatMap(),

          // habit list
          _buildHabitsList(),
        ],
      ),
    );
  }

  // build heatmap
  Widget _buildHeatMap() {
    // habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return heatmap UI
    return FutureBuilder(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          // once the data is available return the heatmap
          if (snapshot.hasData) {
            return MyHeatMap(
              startDate: snapshot.data!,
              dataSets: prepareHeatMapDataSet(currentHabits),
            );
          }
          // handle case where no data is available
          else {
            return Container();
          }
        });
  }

  // build habits list
  Widget _buildHabitsList() {
    // get access to habits database
    final habitsDataBase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitsDataBase.currentHabits;

    //return list of habits for UI
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // get each individual habit
        final habit = currentHabits[index];

        // check if the habit is compeleted for today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        // return habit tile UI
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}
