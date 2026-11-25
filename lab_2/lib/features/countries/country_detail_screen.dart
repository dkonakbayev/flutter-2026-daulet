import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'countries_model.dart';
import 'country.dart';
import 'country_detail_body.dart';

/// Shows the list's copy at once and asks `/codes.alpha_3/{code}` for the fresh copy
/// (timezones, borders, subregion).
class CountryDetailScreen extends StatefulWidget {
  const CountryDetailScreen({super.key, required this.country});

  final Country country;

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  late final Future<Country> _full;

  @override
  void initState() {
    super.initState();
    // Created once here, never in build. If the user pops mid-flight the
    // FutureBuilder is disposed and simply ignores the late answer: no
    // setState after dispose, the console stays clean.
    _full = context.read<CountriesModel>().details(widget.country.code);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.country.name.common)),
    body: FutureBuilder<Country>(
      future: _full,
      initialData: widget.country,
      builder: (context, snapshot) => CountryDetailBody(
        snapshot.data ?? widget.country,
        loadingMore: snapshot.connectionState == ConnectionState.waiting,
      ),
    ),
  );
}
