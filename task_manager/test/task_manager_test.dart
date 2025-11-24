import 'package:test/test.dart';
import 'dart:io';
// Import the actual classes from your project structure
import '../lib/task.dart';
import '../lib/task_manager.dart';
import '../lib/storage.dart'; // Import TaskStorage

void main() {
  // Define a temporary file path for testing persistence
  const testFilePath = 'temp_tasks_test.json';
  
  // Setup: Clean up the test file before the persistence tests run
  setUpAll(() async {
    final file = File(testFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  });

  group('TaskManager & Task', () {
    // Test for Add, Remove, and GetAll
    test('1. addTask, removeTask, and allTasks getter', () {
      // ใช้ TaskStorage ที่ชี้ไปยังไฟล์ชั่วคราวสำหรับการทดสอบ
      final storage = TaskStorage(testFilePath);
      final manager = TaskManager(storage);
      
      final task1 = Task(id: 't1', title: 'Buy Milk');
      final task2 = Task(id: 't2', title: 'Code Review', isCompleted: true);

      // 1. เพิ่ม Task ได้
      manager.addTask(task1);
      manager.addTask(task2);

      expect(manager.allTasks.length, 2); 
      expect(manager.allTasks[0].title, 'Buy Milk');

      // 4. ลบ Task ได้
      manager.removeTask('t1');
      expect(manager.allTasks.length, 1);
      expect(manager.allTasks[0].title, 'Code Review');
      
      // Attempt to remove a non-existent task (should not fail)
      manager.removeTask('t99');
      expect(manager.allTasks.length, 1);
    });
    
    // Test for Update Task
    test('2. updateTask correctly modifies a task', () {
      final storage = TaskStorage(testFilePath);
      final manager = TaskManager(storage);
      final taskId = 'u1';
      final task = Task(id: taskId, title: 'Old Title', description: 'Old Desc');
      manager.addTask(task);

      // 2. แก้ไข Task ได้
      manager.updateTask(
        taskId, 
        title: 'New Title', 
        description: 'New Description', 
        isCompleted: true
      );
      
      final updatedTask = manager.getTaskById(taskId)!;
      expect(updatedTask.title, 'New Title');
      expect(updatedTask.description, 'New Description');
      expect(updatedTask.isCompleted, true);
    });

    // Test for Search Task
    test('3. searchTasksByTitle correctly filters tasks', () {
      final storage = TaskStorage(testFilePath);
      final manager = TaskManager(storage);
      manager.addTask(Task(id: 's1', title: 'Dart Programming'));
      manager.addTask(Task(id: 's2', title: 'Flutter App Development'));
      manager.addTask(Task(id: 's3', title: 'Grocery Shopping'));

      // 3. ค้นหา Task ตาม title ได้
      final searchDart = manager.searchTasksByTitle('Dart');
      expect(searchDart.length, 1);
      expect(searchDart[0].id, 's1');
      
      // Test case-insensitivity
      final searchDev = manager.searchTasksByTitle('development');
      expect(searchDev.length, 1);
      expect(searchDev[0].id, 's2');

      // Test partial match
      final searchOp = manager.searchTasksByTitle('op');
      expect(searchOp.length, 2); // 'Shopping' and 'Development'
    });
    
    // Test for Save/Load Persistence
    test('5. saveTasks and loadTasks correctly persist and restore data', () async {
      final storage = TaskStorage(testFilePath);
      final manager = TaskManager(storage);
      
      // Add data to save
      final saveTask1 = Task(id: 'p1', title: 'Persist Task 1', isCompleted: true);
      final saveTask2 = Task(id: 'p2', title: 'Persist Task 2', dueDate: DateTime(2025, 12, 31));
      manager.addTask(saveTask1);
      manager.addTask(saveTask2);

      // 5. Save Task เป็น JSON
      await manager.saveTasks();
      
      // Create a new manager instance to simulate app restart
      final newStorage = TaskStorage(testFilePath);
      final newManager = TaskManager(newStorage);
      expect(newManager.allTasks.length, 0); // Should be empty before loading

      // 5. Load Task จาก JSON
      await newManager.loadTasks();
      
      // Verify loaded data
      expect(newManager.allTasks.length, 2);
      final loadedTask1 = newManager.getTaskById('p1')!;
      final loadedTask2 = newManager.getTaskById('p2')!;
      
      expect(loadedTask1.title, 'Persist Task 1');
      expect(loadedTask1.isCompleted, true);
      
      expect(loadedTask2.title, 'Persist Task 2');
      expect(loadedTask2.dueDate!.year, 2025);
      
      // Cleanup the test file
      final success = await newManager.clearSavedData();
      expect(success, true);
    });
  });
}