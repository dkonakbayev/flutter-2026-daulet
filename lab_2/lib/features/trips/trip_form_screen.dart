import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_error_message.dart';
import '../../core/api/api_exception.dart';
import '../../core/widgets/busy_button.dart';
import 'date_field.dart';
import 'trip.dart';
import 'trip_validators.dart';
import 'trips_model.dart';

/// Create and edit in one screen. Returns the saved trip through `pop`.
class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key, this.trip});

  /// null or an unsaved draft → create; a trip with an id → edit.
  final Trip? trip;

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _form = GlobalKey<FormState>();
  late final Trip _initial = widget.trip ?? Trip.draft();
  late final String _budget0 = _initial.isNew
      ? ''
      : _initial.budget.toStringAsFixed(0);
  late final _country = TextEditingController(text: _initial.countryName);
  late final _code = TextEditingController(text: _initial.countryCode);
  late final _budget = TextEditingController(text: _budget0);
  late final _notes = TextEditingController(text: _initial.notes ?? '');
  late DateTime _start = _initial.startDate;
  late DateTime _end = _initial.endDate;
  late int _rating = _initial.rating;
  bool _saving = false;

  List<TextEditingController> get _controllers => [
    _country,
    _code,
    _budget,
    _notes,
  ];

  bool get _dirty =>
      _country.text != _initial.countryName ||
      _code.text != _initial.countryCode ||
      _budget.text != _budget0 ||
      _notes.text != (_initial.notes ?? '') ||
      _start != _initial.startDate ||
      _end != _initial.endDate ||
      _rating != _initial.rating;

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_changed);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _changed() => setState(() {});

  Trip _draft() {
    final notes = _notes.text.trim();
    return Trip(
      id: _initial.id,
      countryCode: _code.text.trim().toUpperCase(),
      countryName: _country.text.trim(),
      startDate: _start,
      endDate: _end,
      budget: double.parse(_budget.text.trim()),
      rating: _rating,
      notes: notes.isEmpty ? null : notes,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final trips = context.read<TripsModel>();
    try {
      final saved = await trips.save(_draft());
      if (!mounted) return;
      // pop() ignores PopScope, so Save never asks
      Navigator.of(context).pop(saved);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ApiErrorMessage.of(e))));
    }
  }

  Future<void> _onPop(bool didPop, Object? result) async {
    if (didPop) return;
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('The trip has unsaved changes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  void _unfocus(PointerDownEvent _) => FocusScope.of(context).unfocus();

  List<Widget> _fields() => [
    TextFormField(
      controller: _country,
      textInputAction: TextInputAction.next,
      onTapOutside: _unfocus,
      decoration: const InputDecoration(labelText: 'Country'),
      validator: TripValidators.country,
    ),
    TextFormField(
      controller: _code,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.characters,
      onTapOutside: _unfocus,
      decoration: const InputDecoration(labelText: 'Country code'),
      validator: TripValidators.code,
    ),
    DateField(
      label: 'Start date',
      value: _start,
      onPicked: (d) => setState(() => _start = d),
    ),
    DateField(
      label: 'End date',
      value: _end,
      onPicked: (d) => setState(() => _end = d),
      validator: () => TripValidators.endDate(_start, _end),
    ),
    TextFormField(
      controller: _budget,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onTapOutside: _unfocus,
      decoration: const InputDecoration(labelText: 'Budget, USD'),
      validator: TripValidators.budget,
    ),
    DropdownButtonFormField<int>(
      initialValue: _rating,
      decoration: const InputDecoration(labelText: 'Rating'),
      items: [
        for (var i = 1; i <= 5; i++)
          DropdownMenuItem(value: i, child: Text('$i ★')),
      ],
      onChanged: (v) => setState(() => _rating = v ?? _rating),
    ),
    TextFormField(
      controller: _notes,
      maxLines: 3,
      textInputAction: TextInputAction.done,
      onTapOutside: _unfocus,
      decoration: const InputDecoration(labelText: 'Notes'),
    ),
  ];

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    // a clean form leaves at once; a dirty one asks in _onPop
    canPop: !_dirty,
    onPopInvokedWithResult: _onPop,
    child: Scaffold(
      appBar: AppBar(title: Text(_initial.isNew ? 'New trip' : 'Edit trip')),
      body: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final f in _fields())
              Padding(padding: const EdgeInsets.only(bottom: 12), child: f),
            BusyButton(busy: _saving, label: 'Save', onPressed: _save),
          ],
        ),
      ),
    ),
  );
}
