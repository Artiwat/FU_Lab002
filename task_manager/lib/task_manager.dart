import 'task.dart';
import 'storage.dart'; // เพิ่มการอิมพอร์ต TaskStorage

// Manages a collection of tasks and handles persistence
class TaskManager {
  final TaskStorage _storage; // ใช้ในการบันทึก/โหลดข้อมูล
  final List<Task> _tasks = [];

  // Constructor: Requires a TaskStorage instance
  TaskManager(this._storage);

  // Getter to provide an immutable view of all tasks
  List<Task> get allTasks => List.unmodifiable(_tasks);

  // --- Core Task Operations ---

  // 1. Add a task to the manager
  void addTask(Task task) {
    if (getTaskById(task.id) == null) {
      _tasks.add(task);
    } else {
      print('Warning: Task with ID ${task.id} already exists and was not added.');
    }
  }

  // 2. Update/Edit a task by its ID (NEW FEATURE)
  void updateTask(String id, {String? title, String? description, DateTime? dueDate, bool? isCompleted}) {
    final taskToUpdate = getTaskById(id);
    if (taskToUpdate != null) {
      if (title != null) {
        taskToUpdate.title = title;
      }
      if (description != null) {
        taskToUpdate.description = description;
      }
      if (dueDate != null) {
        taskToUpdate.dueDate = dueDate;
      }
      if (isCompleted != null) {
        taskToUpdate.isCompleted = isCompleted;
      }
      print('Task ID $id updated successfully.');
    } else {
      print('Error: Task with ID $id not found for update.');
    }
  }

  // 3. Search tasks by title (NEW FEATURE)
  List<Task> searchTasksByTitle(String query) {
    // ค้นหาแบบไม่คำนึงถึงขนาดตัวอักษรและตรวจสอบส่วนใดส่วนหนึ่งของชื่อ
    final lowerQuery = query.toLowerCase();
    return _tasks
        .where((task) => task.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // 4. Remove a task by its ID
  void removeTask(String id) {
    final initialLength = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);
    if (_tasks.length < initialLength) {
      print('Task ID $id removed successfully.');
    } else {
      print('Warning: Task ID $id not found for removal.');
    }
  }

  // Find a task by its ID (Helper)
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // --- Persistence Operations (เชื่อมต่อกับ TaskStorage) ---
  
  // 5. Save tasks to file
  Future<bool> saveTasks() async {
    return await _storage.saveTasks(_tasks);
  }
  
  // 5. Load tasks from file
  Future<void> loadTasks() async {
    final loadedTasks = await _storage.loadTasks();
    _tasks.clear(); // ล้างรายการเดิม
    _tasks.addAll(loadedTasks); // เพิ่มรายการที่โหลดมาใหม่
    print('Tasks loaded into TaskManager.');
  }

  // Clear all saved data from the file system
  Future<bool> clearSavedData() async {
    return await _storage.clearTasks();
  }
}