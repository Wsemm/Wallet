import 'package:flutter/material.dart';

typedef GroupFormResult = ({String name, String? description});

class GroupNameDialog extends StatefulWidget {
  const GroupNameDialog({super.key, this.initialName, this.initialDesc});

  final String? initialName;
  final String? initialDesc;

  bool get isEditing => initialName != null;

  static Future<GroupFormResult?> show(
    BuildContext context, {
    String? initialName,
    String? initialDesc,
  }) {
    return showDialog<GroupFormResult>(
      context: context,
      builder: (_) =>
          GroupNameDialog(initialName: initialName, initialDesc: initialDesc),
    );
  }

  @override
  State<GroupNameDialog> createState() => _GroupNameDialogState();
}

class _GroupNameDialogState extends State<GroupNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDesc);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final desc = _descController.text.trim();
    Navigator.pop<GroupFormResult>(context, (
      name: _nameController.text.trim(),
      description: desc.isEmpty ? null : desc, // empty -> null
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Rename group' : 'New group'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Group name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter a group name'
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            TextFormField(
              controller: _descController,
              autofocus: true,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Group description',
                border: OutlineInputBorder(),
              ),

              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
