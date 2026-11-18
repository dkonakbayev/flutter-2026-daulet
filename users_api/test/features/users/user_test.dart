import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/features/users/user.dart';

void main() {
  group('User.fromJson', () {
    test('converts valid JSON into User', () {
      final json = {
        'id': 1,
        'name': 'Leanne Graham',
        'username': 'Bret',
        'email': 'leanne@example.com',
        'phone': '1-770-736-8031',
        'website': 'hildegard.org',
        'address': {
          'street': 'Kulas Light',
          'suite': 'Apt. 556',
          'city': 'Gwenborough',
          'zipcode': '92998-3874',
          'geo': {'lat': '-37.3159', 'lng': '81.1496'},
        },
        'company': {
          'name': 'Romaguera-Crona',
          'catchPhrase': 'Multi-layered client-server neural-net',
        },
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Leanne Graham');
      expect(user.address.city, 'Gwenborough');
      expect(user.address.geo.lat, -37.3159);
      expect(user.company.name, 'Romaguera-Crona');
    });

    test('throws TypeError when lat has an invalid type', () {
      final json = {
        'id': 1,
        'name': 'Leanne Graham',
        'username': 'Bret',
        'email': 'leanne@example.com',
        'phone': '1-770-736-8031',
        'website': 'hildegard.org',
        'address': {
          'street': 'Kulas Light',
          'suite': 'Apt. 556',
          'city': 'Gwenborough',
          'zipcode': '92998-3874',
          'geo': {'lat': -37.3159, 'lng': '81.1496'},
        },
        'company': {
          'name': 'Romaguera-Crona',
          'catchPhrase': 'Multi-layered client-server neural-net',
        },
      };

      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
