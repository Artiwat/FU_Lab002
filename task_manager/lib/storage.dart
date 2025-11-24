import 'dart:io';
import 'dart:convert';
import 'task.dart';

// Handles task persistence to file system
class TaskStorage {
  final String filePath;
  
  TaskStorage(this.filePath);
  
  // Save tasks to file asynchronously
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final file = File(filePath);
      
      // Convert tasks to JSON
      final jsonList = tasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate?.toIso8601String(),
        'isCompleted': task.isCompleted,
      }).toList();
      
      // Write to file with proper formatting
      final jsonString = JsonEncoder.withIndent('  ').convert(jsonList);
      await file.writeAsString(jsonString);
      
      print('Saved ${tasks.length} tasks to $filePath');
      return true;
    } catch (e) {
      print('Error saving tasks: $e');
      return false;
    }
  }
  
  // Load tasks from file asynchronously
  Future<List<Task>> loadTasks() async {
    try {
      final file = File(filePath);
      
      // Check if file exists
      if (!await file.exists()) {
        print('No saved tasks found');
        return [];
      }
      
      // Read and parse JSON
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List;
      
      // Convert JSON to Task objects
      final tasks = jsonList.map((json) {
        return Task(
          id: json['id'] as String,
          title: json['title'] as String,
          // Handle nullable/optional fields during loading
          description: json['description'] as String? ?? '',
          dueDate: json['dueDate'] != null 
              ? DateTime.parse(json['dueDate'] as String) 
              : null,
          isCompleted: json['isCompleted'] as bool? ?? false,
        );
      }).toList();
      
      print('Loaded ${tasks.length} tasks from $filePath');
      return tasks;
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }
  
  // Delete all saved tasks
  Future<bool> clearTasks() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('Cleared all saved tasks');
        return true;
      }
      return false;
    } catch (e) {
      print('Error clearing tasks: $e');
      return false;
    }
  }
  
  // Simulate network delay for learning async
  Future<void> simulateNetworkDelay() async {
    print('Simulating network request...');
    await Future.delayed(Duration(seconds: 2));
    print('Network request completed!');
  }
}