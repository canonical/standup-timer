import 'package:shared_preferences/shared_preferences.dart';
import 'package:clipboard/clipboard.dart';

class ParticipantService {
  static const String _participantsKey = 'participants';

  static Future<void> saveParticipantList(List<String> participants) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_participantsKey, participants);
  }

  static Future<List<String>> loadParticipantList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_participantsKey) ?? [];
  }

  static Future<String> getClipboardContent() async {
    try {
      return await FlutterClipboard.paste();
    } catch (e) {
      return '';
    }
  }

  static List<String> parseParticipantList(String input) {
    final RegExp emailPattern = RegExp(r'([^<,]+?)\s*<[^>]+>', multiLine: true, dotAll: true);
    final matches = emailPattern.allMatches(input);
    return matches.map((match) => match.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim()).toList();
  }

  static Future<bool> hasValidClipboardContent() async {
    try {
      final clipboardData = await getClipboardContent();
      final participants = parseParticipantList(clipboardData);
      return participants.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}