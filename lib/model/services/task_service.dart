import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:birdo/core/services/service_locator.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/services/day_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

class TaskService {
  static bool _testMode = false;
  static Box<Task>? _testBox;

  static void enableTestMode(Box<Task> testBox) {
    _testMode = true;
    _testBox = testBox;
  }

  static void disableTestMode() {
    _testMode = false;
    _testBox = null;
  }

  static Box<Task> _getBox() {
    if (_testMode && _testBox != null) {
      return _testBox!;
    }
    return Hive.box<Task>(taskBox);
  }

  static Future<void> saveTask(Task task) async {
    debugPrint('TaskService: Saving task: ${task.title} (${task.id})');
    final box = _getBox();
    await box.put(task.id, task);
  }

  static Future<Task?> getTask(String taskId) async {
    debugPrint('TaskService: Getting task: $taskId');
    try {
      final box = _getBox();
      final task = box.get(taskId);
      if (task != null) {
        debugPrint('TaskService: Found task: ${task.title} (${task.id})');
      } else {
        debugPrint('TaskService: Task not found');
      }
      return task;
    } catch (e) {
      debugPrint('TaskService: Error getting task: $e');
      return null;
    }
  }

  static Future<List<Task>> getTasksForDay(DateTime date) async {
    debugPrint(
      'TaskService: Getting tasks for day: ${ServiceLocator.dateTimeService.generateDayId(date)}',
    );
    final day = await DayService.getOrCreate(date);
    debugPrint('TaskService: Found day record: ${day.id}');
    debugPrint('TaskService: Number of tasks in day: ${day.dailyTasks.length}');

    if (day.dailyTasks.isEmpty) {
      debugPrint('TaskService: No tasks found for this day');
      return [];
    }

    debugPrint('TaskService: Returning ${day.dailyTasks.length} tasks');
    for (var task in day.dailyTasks) {
      debugPrint('TaskService: Task: ${task.title} (${task.id})');
    }
    return day.dailyTasks;
  }

  static Future<List<Task>> getCurrentDayTasks() async {
    debugPrint('TaskService: Getting current day tasks...');
    final currentDate = ServiceLocator.dateTimeService.getCurrentDate();
    return getTasksForDay(currentDate);
  }

  static Future<void> addRecurringTasksToCurrentDay() async {
    debugPrint('TaskService: Getting recurring tasks');
    final box = _getBox();
    final allTasks = box.values.toList();
    final recurring =
        allTasks.where((t) => t.cadence != TaskCadence.never).toList();
    final currentDate = ServiceLocator.dateTimeService.getCurrentDate();
    final currentDayTasks = await getTasksForDay(currentDate);
    final currentDayTaskIds = currentDayTasks.map((t) => t.referenceId).toSet();

    debugPrint('TaskService: Found ${recurring.length} recurring tasks');
    for (final t in recurring) {
      final createdDate = DateTime(
        t.createdDate.year,
        t.createdDate.month,
        t.createdDate.day,
      );
      switch (t.cadence) {
        case TaskCadence.daily:
          if (!currentDayTaskIds.contains(t.id)) {
            await createTask(
              title: t.title,
              energyReward: t.energyReward,
              category: t.category,
              cadence: TaskCadence.never,
              referenceId: t.id,
            );
          }
        case TaskCadence.weekly:
          if (ServiceLocator.dateTimeService.isToday(createdDate) ||
              currentDate.difference(createdDate).inDays % 7 == 0) {
            if (!currentDayTaskIds.contains(t.id)) {
              await createTask(
                title: t.title,
                energyReward: t.energyReward,
                category: t.category,
                cadence: TaskCadence.never,
                referenceId: t.id,
              );
            }
          }
          break;
        case TaskCadence.monthly:
          if (ServiceLocator.dateTimeService.isToday(createdDate) ||
              (currentDate.day == createdDate.day)) {
            if (!currentDayTaskIds.contains(t.id)) {
              await createTask(
                title: t.title,
                energyReward: t.energyReward,
                category: t.category,
                cadence: TaskCadence.never,
                referenceId: t.id,
              );
            }
          }
          break;
        default:
          continue;
      }
    }
  }

  static Future<Task> createTask({
    required String title,
    required int energyReward,
    required TaskCategory category,
    required TaskCadence cadence,
    String? referenceId,
    DateTime? date,
  }) async {
    final task = Task.create(
      title: title,
      energyReward: energyReward,
      category: category,
      cadence: cadence,
      referenceId: referenceId,
    );

    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Creating task: ${task.title} (${task.id}) for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    final day = await DayService.getOrCreate(targetDate);
    debugPrint('TaskService: Found day record: ${day.id}');
    debugPrint('TaskService: Current tasks in day: ${day.dailyTasks.length}');

    await DayService.addTaskToDay(targetDate, task);
    // this should add recurring to current day as well.
    debugPrint('TaskService: Added task to day using DayService');

    await saveTask(task);
    debugPrint('TaskService: Saved task to taskBox');

    return task;
  }

  static Future<Task> createRecurringTask({
    required String title,
    required int energyReward,
    required TaskCategory category,
    required TaskCadence cadence,
    String? referenceId,
    DateTime? date,
  }) async {
    final task = Task.create(
      title: title,
      energyReward: energyReward,
      category: category,
      cadence: cadence,
      referenceId: referenceId,
    );

    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Creating task: ${task.title} (${task.id}) for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );
    saveTask(task);


    final todayTask = Task.create(
      title: title,
      energyReward: energyReward,
      category: category,
      cadence: TaskCadence.never,
      referenceId: task.id,
    );

    final day = await DayService.getOrCreate(targetDate);
    debugPrint('TaskService: Found day record: ${day.id}');
    debugPrint('TaskService: Current tasks in day: ${day.dailyTasks.length}');

    await DayService.addTaskToDay(targetDate, todayTask);
    debugPrint('TaskService: Added task to day using DayService');

    await saveTask(todayTask);
    debugPrint('TaskService: Saved task to taskBox');

    return todayTask;
  }

  static Future<void> completeTask(Task task, {DateTime? date}) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Completing task: ${task.id} for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    task.complete();
    await saveTask(task);

    await DayService.completeTask(targetDate, task.id);
  }

  static Future<void> resetTask(Task task, {DateTime? date}) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Resetting task: ${task.id} for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    task.reset();
    await saveTask(task);

    await DayService.removeCompletedTask(targetDate, task.id);
  }

  static Future<void> updateTask(Task task, {DateTime? date}) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Updating task: ${task.title} (${task.id}) for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    await DayService.updateTaskInDay(targetDate, task);

    await saveTask(task);
  }

  static Future<void> deleteTask(Task task, {DateTime? date}) async {
    final targetDate = date ?? ServiceLocator.dateTimeService.getCurrentDate();
    debugPrint(
      'TaskService: Deleting task: ${task.id} for date: ${ServiceLocator.dateTimeService.generateDayId(targetDate)}',
    );

    await DayService.removeTaskFromDay(targetDate, task.id);

    final box = _getBox();
    await box.delete(task.id);
  }
}
