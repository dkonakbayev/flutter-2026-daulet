import 'package:flutter/material.dart';

import '../models/cause.dart';
import '../models/shift.dart';
import '../utils/format.dart';

typedef _Snapshot = ({
  String title,
  Cause? cause,
  DateTime? date,
  TimeOfDay? time,
  bool online,
  String place,
  String slots,
  String notes,
});

class ShiftFormScreen extends StatefulWidget {
  const ShiftFormScreen({super.key, this.shift});

  final Shift? shift;

  @override
  State<ShiftFormScreen> createState() => _ShiftFormScreenState();
}

class _ShiftFormScreenState extends State<ShiftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeKey = GlobalKey<FormFieldState<String>>();
  final _dateKey = GlobalKey<FormFieldState<String>>();
  final _timeKey = GlobalKey<FormFieldState<String>>();

  late final Shift _base;
  late final bool _isNew;
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _slots;
  late final TextEditingController _notes;
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _slotsFocus = FocusNode();
  final _notesFocus = FocusNode();

  Cause? _cause;
  DateTime? _date;
  TimeOfDay? _time;
  late bool _online;

  late final _Snapshot _initial;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _isNew = widget.shift == null;
    _base = widget.shift ?? Shift.empty();
    _title = TextEditingController(text: _base.title);
    _place = TextEditingController(text: _base.place);
    _slots = TextEditingController(text: '${_base.slots}');
    _notes = TextEditingController(text: _base.notes ?? '');
    _online = _base.online;
    if (!_isNew) {
      _cause = _base.cause;
      _setDate(DateUtils.dateOnly(_base.startsAt));
      _setTime(TimeOfDay.fromDateTime(_base.startsAt));
    }
    _initial = _snapshot();
  }

  @override
  void dispose() {
    for (final c in [_title, _place, _slots, _notes, _dateText, _timeText]) {
      c.dispose();
    }
    for (final f in [_titleFocus, _placeFocus, _slotsFocus, _notesFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  _Snapshot _snapshot() => (
    title: _title.text,
    cause: _cause,
    date: _date,
    time: _time,
    online: _online,
    place: _place.text,
    slots: _slots.text,
    notes: _notes.text,
  );

  void _refreshDirty() {
    final dirty = _snapshot() != _initial;
    if (dirty != _dirty) setState(() => _dirty = dirty);
  }

  void _setDate(DateTime date) {
    _date = date;
    _dateText.text = formatDate(date);
  }

  void _setTime(TimeOfDay time) {
    _time = time;
    _timeText.text = formatHm(time.hour, time.minute);
  }

  DateTime? _combined() {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: _isNew ? DateUtils.dateOnly(now) : DateTime(2000),
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() => _setDate(picked));
    _revalidate(_dateKey);
    _revalidate(_timeKey);
    _refreshDirty();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _setTime(picked));
    _revalidate(_timeKey);
    _refreshDirty();
  }

  void _revalidate(GlobalKey<FormFieldState<String>> key) {
    final field = key.currentState;
    if (field != null && field.hasError) field.validate();
  }

  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();
    if (title.length < 3) return 'At least 3 characters';
    if (title.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validateCause(Cause? cause) =>
      cause == null ? 'Choose a cause' : null;

  String? _validateDate(String? _) => _date == null ? 'Pick a date' : null;

  String? _validateTime(String? _) {
    if (_time == null) return 'Pick a time';
    final when = _combined();
    if (_isNew && when != null && !when.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final place = (value ?? '').trim();
    if (place.isEmpty)
      return _online ? 'Enter a meeting link' : 'Enter an address';
    if (_online && !place.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateSlots(String? value) {
    final slots = int.tryParse((value ?? '').trim());
    if (slots == null) return 'Enter a whole number';
    if (slots < 1 || slots > 500) return 'From 1 to 500';
    final (:taken, free: _) = _base.places;
    if (slots < taken) return '$taken people already signed up';
    return null;
  }

  String? _validateNotes(String? value) =>
      (value ?? '').length > 300 ? 'At most 300 characters' : null;

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context, _buildShift());
  }

  Shift _buildShift() {
    final notes = _notes.text.trim();
    return Shift(
      id: _base.id,
      title: _title.text.trim(),
      cause: _cause ?? _base.cause,
      startsAt: _combined() ?? _base.startsAt,
      slots: int.tryParse(_slots.text.trim()) ?? _base.slots,
      place: _place.text.trim(),
      online: _online,
      notes: notes.isEmpty ? null : notes,
      volunteers: _base.volunteers,
      favourite: _base.favourite,
    );
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  void _hideKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);

    return PopScope<Shift>(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New shift' : 'Edit shift')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: _refreshDirty,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: _hideKeyboard,
                  validator: _validateTitle,
                ),
                gap,
                DropdownButtonFormField<Cause>(
                  initialValue: _cause,
                  decoration: const InputDecoration(labelText: 'Cause'),
                  items: [
                    for (final cause in Cause.values)
                      DropdownMenuItem(
                        value: cause,
                        child: Row(
                          children: [
                            Icon(cause.icon),
                            const SizedBox(width: 8),
                            Text(cause.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (cause) {
                    setState(() => _cause = cause);
                    _refreshDirty();
                  },
                  validator: _validateCause,
                ),
                gap,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: _dateKey,
                        controller: _dateText,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: _validateDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        key: _timeKey,
                        controller: _timeText,
                        readOnly: true,
                        onTap: _pickTime,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        validator: _validateTime,
                      ),
                    ),
                  ],
                ),
                gap,
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _online,
                  title: const Text('Online shift'),
                  subtitle: const Text('The place becomes a meeting link'),
                  onChanged: (value) {
                    setState(() => _online = value ?? false);
                    _revalidate(_placeKey);
                    _refreshDirty();
                  },
                ),
                gap,
                TextFormField(
                  key: _placeKey,
                  controller: _place,
                  focusNode: _placeFocus,
                  decoration: InputDecoration(
                    labelText: _online ? 'Meeting link' : 'Address',
                    hintText: _online ? 'https://…' : null,
                    prefixIcon: Icon(
                      _online ? Icons.link : Icons.place_outlined,
                    ),
                  ),
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _slotsFocus.requestFocus(),
                  onTapOutside: _hideKeyboard,
                  validator: _validatePlace,
                ),
                gap,
                TextFormField(
                  controller: _slots,
                  focusNode: _slotsFocus,
                  decoration: const InputDecoration(
                    labelText: 'Places',
                    helperText: 'How many volunteers are needed (1–500)',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _notesFocus.requestFocus(),
                  onTapOutside: _hideKeyboard,
                  validator: _validateSlots,
                ),
                gap,
                TextFormField(
                  controller: _notes,
                  focusNode: _notesFocus,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                  minLines: 1,
                  maxLines: 3,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onTapOutside: _hideKeyboard,
                  validator: _validateNotes,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving…' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
