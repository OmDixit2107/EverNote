import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/tasks_provider.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context);

    // Get incomplete and completed tasks
    final incompleteTasks = tasksProvider.incompleteTasks;
    final completedTasks = tasksProvider.completedTasks;

    // Filter tasks if search query exists
    final filteredIncompleteTasks = _searchQuery.isEmpty
        ? incompleteTasks
        : tasksProvider
            .searchTasks(_searchQuery)
            .where((task) => !task.isCompleted)
            .toList();

    final filteredCompletedTasks = _searchQuery.isEmpty
        ? completedTasks
        : tasksProvider
            .searchTasks(_searchQuery)
            .where((task) => task.isCompleted)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20),
                          const SizedBox(width: 8),
                          Text('Search: $_searchQuery'),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Icon(Icons.close, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: tasksProvider.tasks.isEmpty
                ? _buildEmptyState()
                : _buildTasksList(
                    filteredIncompleteTasks, filteredCompletedTasks),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_box_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create a task',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(
      List<Task> incompleteTasks, List<Task> completedTasks) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (incompleteTasks.isNotEmpty) ...[
          const Text(
            'To Do',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...incompleteTasks.map((task) => _buildTaskItem(context, task)),
          const SizedBox(height: 16),
        ],
        if (completedTasks.isNotEmpty) ...[
          const Text(
            'Completed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...completedTasks.map((task) => _buildTaskItem(context, task)),
        ],
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        Provider.of<TasksProvider>(context, listen: false).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task moved to trash'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                Provider.of<TasksProvider>(context, listen: false)
                    .restoreTask(task.id);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: isDarkMode ? Colors.grey[800] : null,
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) {
              Provider.of<TasksProvider>(context, listen: false)
                  .toggleTaskStatus(task.id);
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? (isDarkMode ? Colors.grey[400] : Colors.grey)
                  : (isDarkMode ? Colors.white : null),
            ),
          ),
          subtitle: task.dueDate != null
              ? Text(
                  'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate!)}',
                  style: TextStyle(
                    color: task.dueDate!.isBefore(DateTime.now()) &&
                            !task.isCompleted
                        ? Colors.red
                        : (isDarkMode ? Colors.grey[400] : Colors.grey),
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit,
                    color: isDarkMode ? Colors.grey[300] : null),
                onPressed: () {
                  _showEditTaskDialog(context, task);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    color: isDarkMode ? Colors.grey[300] : null),
                onPressed: () {
                  // Delete the task
                  Provider.of<TasksProvider>(context, listen: false)
                      .deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task moved to trash'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          Provider.of<TasksProvider>(context, listen: false)
                              .restoreTask(task.id);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchText = _searchQuery;
        return AlertDialog(
          title: const Text('Search Tasks'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter search term',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              searchText = value;
            },
            controller: TextEditingController(text: _searchQuery),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = searchText;
                });
                Navigator.pop(context);
              },
              child: const Text('SEARCH'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Due Date:'),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Text(
                            selectedDate != null
                                ? DateFormat('MMM d, yyyy')
                                    .format(selectedDate!)
                                : 'Select Date',
                          ),
                        ),
                        if (selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                selectedDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      Provider.of<TasksProvider>(context, listen: false)
                          .addTask(
                        title: titleController.text.trim(),
                        dueDate: selectedDate,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    DateTime? selectedDate = task.dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Due Date:'),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Text(
                            selectedDate != null
                                ? DateFormat('MMM d, yyyy')
                                    .format(selectedDate!)
                                : 'Select Date',
                          ),
                        ),
                        if (selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                selectedDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      final updatedTask = task.copyWith(
                        title: titleController.text.trim(),
                        dueDate: selectedDate,
                      );

                      Provider.of<TasksProvider>(context, listen: false)
                          .updateTask(updatedTask);

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
