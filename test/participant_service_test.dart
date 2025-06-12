import 'package:flutter_test/flutter_test.dart';
import 'package:standup/services/participant_service.dart';

void main() {
  group('ParticipantService', () {
    group('parseParticipantList', () {
      test('parses single line email list correctly', () {
        const input = 'John Doe <john@example.com>, Jane Smith <jane@example.com>';
        final result = ParticipantService.parseParticipantList(input);
        expect(result, equals(['John Doe', 'Jane Smith']));
      });

      test('parses complex multiline email list with irregular whitespace', () {
        const input = '''Adam Malinowski <adam.malinowski@canonical.com>, c_ed02200be717ac23f97922a34b5fa3f59805dfcff28a0f039e8ede0b50fbe749@group.calendar.google.com, Szu 
  Liang 
    Ho
       
          <dio.he@canonical.com>, Douglas Chiang <douglas.chiang@canonical.com>, Fernando Bravo Hernández <fernando.bravo.hernandez@canonical.com>, Gennadii 
  Tuzov 
          <gennadii.tuzov@canonical.com>, George Boukeas <george.boukeas@canonical.com>, Kevin Yeh <kevin.yeh@canonical.com>, Massimiliano Girardi 
          <massimiliano.girardi@canonical.com>, Mengmeng Tang <meng.tang@canonical.com>, Nadzeya Hutsko <nadzeya.hutsko@canonical.com>, Nancy Chen 
          <nancy.chen@canonical.com>, Omar Abou Selo <omar.selo@canonical.com>, Paolo Gentili <paolo.gentili@canonical.com>, Pierre Equoy <pierre.equoy@canonical.com>''';
        
        final result = ParticipantService.parseParticipantList(input);
        final expected = [
          'Adam Malinowski',
          'Szu Liang Ho',
          'Douglas Chiang',
          'Fernando Bravo Hernández',
          'Gennadii Tuzov',
          'George Boukeas',
          'Kevin Yeh',
          'Massimiliano Girardi',
          'Mengmeng Tang',
          'Nadzeya Hutsko',
          'Nancy Chen',
          'Omar Abou Selo',
          'Paolo Gentili',
          'Pierre Equoy'
        ];
        
        expect(result, equals(expected));
      });

      test('handles names with extra whitespace and newlines', () {
        const input = '''John  
  Smith   <john@example.com>, 
  Jane
    Doe
      <jane@example.com>''';
        
        final result = ParticipantService.parseParticipantList(input);
        expect(result, equals(['John Smith', 'Jane Doe']));
      });

      test('returns empty list for invalid input', () {
        const input = 'No email addresses here';
        final result = ParticipantService.parseParticipantList(input);
        expect(result, isEmpty);
      });

      test('handles empty input', () {
        const input = '';
        final result = ParticipantService.parseParticipantList(input);
        expect(result, isEmpty);
      });

      test('handles mixed valid and invalid entries', () {
        const input = 'John Doe <john@example.com>, Invalid Entry, Jane Smith <jane@example.com>';
        final result = ParticipantService.parseParticipantList(input);
        expect(result, equals(['John Doe', 'Jane Smith']));
      });

      test('handles names with special characters', () {
        const input = 'José María <jose@example.com>, François Müller <francois@example.com>';
        final result = ParticipantService.parseParticipantList(input);
        expect(result, equals(['José María', 'François Müller']));
      });
    });
  });
}