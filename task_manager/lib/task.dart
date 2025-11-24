// Represents a single task in the task manager
class Task {
  // Non-nullable fields - must be initialized
  final String id;
  String title;
  String description;
  
  // Nullable field - can be null
  DateTime? dueDate;
  
  // Non-nullable with default value
  bool isCompleted;
  
  // Constructor with required and optional parameters
  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
  });
  
  // Method to mark task as completed
  void complete() {
    isCompleted = true;
  }
  
  // Method to check if task is overdue
  bool isOverdue() {
    // Safe null checking with ?.
    final due = dueDate;
    if (due == null) {
      return false; // No due date means not overdue
    }
    // Task is overdue if current time is after the due date
    // Note: We check if it is AFTER the due date, not just equal to it.
    return DateTime.now().isAfter(due);
  }
  
  // String representation for debugging
  @override
  String toString() {
    final status = isCompleted ? 'Completed' : 'Pending';
    final due = dueDate != null 
        ? 'Due: ${dueDate!.toLocal().toString().split(' ')[0]}' 
        : 'No due date';
    return 'Task: $title ($status) - $due';
  }
}