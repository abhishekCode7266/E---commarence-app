import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../models/priority_enum.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

/// Screen allowing creation of a new task or editing an existing task.
class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? taskToEdit;

  const AddEditTaskScreen({
    super.key,
    this.taskToEdit,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _reminderSet = false;
  bool _isLoading = false;

  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');

    if (task?.dueDate != null) {
      _selectedDueDate = task!.dueDate;
      _selectedDueTime = TimeOfDay.fromDateTime(task.dueDate!);
    }

    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _reminderSet = task?.reminderSet ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;

    // Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate == null || !mounted) return;

    // Pick Time
    final TimeOfDay initialTime = _selectedDueTime ?? TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (!mounted) return;

    setState(() {
      _selectedDueDate = pickedDate;
      _selectedDueTime = pickedTime ?? const TimeOfDay(hour: 12, minute: 0);
    });
  }

  DateTime? _computeFullDueDate() {
    if (_selectedDueDate == null) return null;
    final time = _selectedDueTime ?? const TimeOfDay(hour: 12, minute: 0);
    return DateTime(
      _selectedDueDate!.year,
      _selectedDueDate!.month,
      _selectedDueDate!.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final userId = authProvider.user?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User session expired. Please re-login.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final finalDueDate = _computeFullDueDate();

    bool success;
    if (isEditing) {
      final updated = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: finalDueDate,
        priority: _selectedPriority,
        reminderSet: _selectedDueDate != null && _reminderSet,
      );
      success = await taskProvider.updateTask(updated);
    } else {
      final newTask = TaskModel(
        id: '',
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: finalDueDate,
        priority: _selectedPriority,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reminderSet: _selectedDueDate != null && _reminderSet,
      );
      success = await taskProvider.createTask(newTask);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final error = taskProvider.errorMessage ?? 'Failed to save task.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDateString = _selectedDueDate != null
        ? DateFormat('EEE, MMM d, yyyy').format(_selectedDueDate!)
        : 'Select due date';
    final formattedTimeString = _selectedDueTime != null
        ? _selectedDueTime!.format(context)
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              CustomTextField(
                controller: _titleController,
                label: 'Task Title *',
                hint: 'e.g. Finish Capstone Project Presentation',
                validator: AppValidators.validateTaskTitle,
              ),
              const SizedBox(height: 16),

              // Description Field
              CustomTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Add helpful details, subtasks, or links...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Due Date & Time Picker
              const Text(
                'Due Date & Time',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDueDate != null
                              ? '$formattedDateString at $formattedTimeString'
                              : 'Set a due date',
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedDueDate != null
                                ? theme.textTheme.bodyLarge?.color
                                : Colors.grey,
                          ),
                        ),
                      ),
                      if (_selectedDueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedDueDate = null;
                              _selectedDueTime = null;
                              _reminderSet = false;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Priority Selector
              const Text(
                'Priority',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: TaskPriority.values.map((priority) {
                  return ButtonSegment<TaskPriority>(
                    value: priority,
                    label: Text(priority.label),
                    icon: Icon(priority.icon, color: priority.color, size: 16),
                  );
                }).toList(),
                selected: {_selectedPriority},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedPriority = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Reminder Switch ListTile
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Remind me when due',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _selectedDueDate != null
                      ? 'Receive local notification alert at scheduled time'
                      : 'Set a due date first to enable reminders',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                value: _selectedDueDate != null && _reminderSet,
                onChanged: _selectedDueDate != null
                    ? (val) => setState(() => _reminderSet = val)
                    : null,
                secondary: Icon(
                  Icons.notifications_active_outlined,
                  color: _selectedDueDate != null
                      ? theme.colorScheme.primary
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: isEditing ? 'Save Changes' : 'Create Task',
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
