import 'dart:io';
import '../lib/storage.dart';
import '../lib/task.dart';
import '../lib/task_manager.dart';

// ชื่อไฟล์สำหรับจัดเก็บข้อมูล
const String storageFilePath = 'tasks.json';

// Global variable for the TaskManager instance
late TaskManager manager;

Future<void> main(List<String> arguments) async {
  print('✨ Welcome to Task Manager CLI! ✨');
  
  // Initialize storage and manager
  final storage = TaskStorage(storageFilePath);
  manager = TaskManager(storage);

  // Load existing tasks at startup
  print('\n--- Initializing & Loading Tasks ---');
  await manager.loadTasks();

  await showMenu();
}

/// แสดงเมนูหลักและรับการป้อนข้อมูลจากผู้ใช้
Future<void> showMenu() async {
  bool running = true;
  while (running) {
    print('\n=======================================');
    print('          📋 TASK MANAGER MENU');
    print('=======================================');
    print('1. เพิ่ม Task (Add Task)');
    print('2. แก้ไข Task (Update Task)');
    print('3. ค้นหา Task ตาม Title (Search by Title)');
    print('4. ลบ Task (Remove Task)');
    print('5. แสดง Task ทั้งหมด (View All Tasks)');
    print('6. บันทึกและออกจากโปรแกรม (Save & Exit)');
    print('7. เคลียร์ไฟล์ข้อมูลที่บันทึกไว้ (Clear Saved Data)');
    print('=======================================');

    stdout.write('กรุณาเลือกเมนู (1-7): ');
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '');

    switch (choice) {
      case 1:
        addTaskMenu();
        break;
      case 2:
        updateTaskMenu();
        break;
      case 3:
        searchTaskMenu();
        break;
      case 4:
        removeTaskMenu();
        break;
      case 5:
        viewAllTasks();
        break;
      case 6:
        print('\n--- 💾 Saving & Exiting ---');
        await manager.saveTasks(); // 5. Save Task
        running = false;
        break;
      case 7:
        await manager.clearSavedData();
        break;
      default:
        print('❌ เมนูไม่ถูกต้อง ลองใหม่อีกครั้ง');
    }
  }
  print('\nThank you for using Task Manager CLI. Goodbye! 👋');
}

/// 1. เพิ่ม Task
void addTaskMenu() {
  print('\n--- ➕ Add New Task ---');
  stdout.write('Enter Task Title (required): ');
  final title = stdin.readLineSync() ?? '';
  if (title.trim().isEmpty) {
    print('Title cannot be empty. Task not added.');
    return;
  }
  
  stdout.write('Enter Task Description (optional): ');
  final description = stdin.readLineSync() ?? '';
  
  // Generate a unique ID (simple counter approach here)
  final newId = (manager.allTasks.length + 1).toString(); 

  final newTask = Task(
    id: newId,
    title: title.trim(),
    description: description.trim(),
  );
  
  manager.addTask(newTask);
  print('✅ Task "$title" (ID: $newId) added successfully.');
}

/// 2. แก้ไข Task
void updateTaskMenu() {
  print('\n--- ✏️ Update Task ---');
  if (manager.allTasks.isEmpty) {
    print('No tasks to update.');
    return;
  }
  viewAllTasks();
  
  stdout.write('Enter the ID of the task to update: ');
  final id = stdin.readLineSync() ?? '';
  final task = manager.getTaskById(id);
  
  if (task == null) {
    print('❌ Task with ID "$id" not found.');
    return;
  }

  print('\nUpdating Task ID: $id (Current Title: ${task.title})');
  
  // Update Title
  stdout.write('New Title (Leave blank to keep current: ${task.title}): ');
  final newTitle = stdin.readLineSync();
  
  // Update Description
  stdout.write('New Description (Leave blank to keep current: ${task.description}): ');
  final newDesc = stdin.readLineSync();

  // Update Completion Status
  stdout.write('Mark as Completed? (y/N): ');
  final completeInput = stdin.readLineSync()?.toLowerCase();
  final isCompleted = completeInput == 'y';
  
  // Call the update method in TaskManager
  manager.updateTask(
    id,
    title: newTitle?.isEmpty == false ? newTitle : null,
    description: newDesc?.isEmpty == false ? newDesc : null,
    isCompleted: isCompleted,
    // (Skipping dueDate update for simplicity in CLI)
  );
}

/// 3. ค้นหา Task ตาม Title
void searchTaskMenu() {
  print('\n--- 🔍 Search Tasks ---');
  stdout.write('Enter search query (Title): ');
  final query = stdin.readLineSync() ?? '';
  
  if (query.trim().isEmpty) {
    print('Search query cannot be empty.');
    return;
  }
  
  final results = manager.searchTasksByTitle(query.trim());
  
  if (results.isEmpty) {
    print('No tasks found matching "$query".');
  } else {
    print('\n--- Search Results for "$query" (${results.length} found) ---');
    for (var task in results) {
      print('ID: ${task.id} | ${task.toString()}');
    }
  }
}

/// 4. ลบ Task
void removeTaskMenu() {
  print('\n--- 🗑️ Remove Task ---');
  if (manager.allTasks.isEmpty) {
    print('No tasks to remove.');
    return;
  }
  viewAllTasks();

  stdout.write('Enter the ID of the task to remove: ');
  final id = stdin.readLineSync() ?? '';
  
  final taskToRemove = manager.getTaskById(id);
  if (taskToRemove == null) {
    print('❌ Task with ID "$id" not found.');
    return;
  }
  
  manager.removeTask(id);
  print('✅ Task ID "$id" removed successfully.');
}

/// 5. แสดง Task ทั้งหมด
void viewAllTasks() {
  if (manager.allTasks.isEmpty) {
    print('\n--- 📖 Task List (0 tasks) ---');
    print('No tasks currently in the manager.');
    return;
  }
  
  print('\n--- 📖 Current Task List (${manager.allTasks.length} tasks) ---');
  // Sort tasks by completion status for better viewing
  final sortedTasks = List<Task>.from(manager.allTasks)
      ..sort((a, b) => a.isCompleted ? 1 : -1); 

  for (var task in sortedTasks) {
    print('ID: ${task.id.padRight(2)} | ${task.toString()}');
  }
}