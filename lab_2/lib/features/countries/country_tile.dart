import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import 'country.dart';
import 'country_flag.dart';

class CountryTile extends StatelessWidget {
  const CountryTile(this.country, {super.key});

  final Country country;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CountryFlag(country.flagUrl, width: 48),
    title: Text(country.name.common),
    subtitle: Text(
      [?country.capital, country.region].join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () =>
        Navigator.of(context)
            .pushNamed(AppRoutes.countryDetail, arguments: country),
  );
}
