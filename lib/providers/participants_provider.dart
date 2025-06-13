import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../services/participant_service.dart';

class ParticipantsState {
  final List<String> people;
  final int currentPersonIndex;
  final bool showAddPerson;
  final bool hasValidClipboardContent;

  const ParticipantsState({
    required this.people,
    required this.currentPersonIndex,
    required this.showAddPerson,
    required this.hasValidClipboardContent,
  });

  ParticipantsState copyWith({
    List<String>? people,
    int? currentPersonIndex,
    bool? showAddPerson,
    bool? hasValidClipboardContent,
  }) {
    return ParticipantsState(
      people: people ?? this.people,
      currentPersonIndex: currentPersonIndex ?? this.currentPersonIndex,
      showAddPerson: showAddPerson ?? this.showAddPerson,
      hasValidClipboardContent: hasValidClipboardContent ?? this.hasValidClipboardContent,
    );
  }
}

class ParticipantsNotifier extends StateNotifier<ParticipantsState> {
  ParticipantsNotifier() : super(const ParticipantsState(
    people: [],
    currentPersonIndex: 0,
    showAddPerson: false,
    hasValidClipboardContent: false,
  )) {
    _loadSavedParticipants();
    _checkClipboardContent();
  }

  Future<void> _loadSavedParticipants() async {
    final savedParticipants = await ParticipantService.loadParticipantList();
    state = state.copyWith(people: savedParticipants);
  }

  Future<void> _saveParticipantList() async {
    await ParticipantService.saveParticipantList(state.people);
  }

  Future<void> _checkClipboardContent() async {
    final hasValid = await ParticipantService.hasValidClipboardContent();
    state = state.copyWith(hasValidClipboardContent: hasValid);
  }

  Future<void> checkClipboardContent() async {
    await _checkClipboardContent();
  }

  void addPerson(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      // Check if participant already exists (case-insensitive)
      final existsAlready = state.people.any((existing) => 
          existing.toLowerCase() == trimmedName.toLowerCase());
      
      if (!existsAlready) {
        final newPeople = [...state.people, trimmedName];
        state = state.copyWith(
          people: newPeople,
          showAddPerson: false,
        );
        _saveParticipantList();
      } else {
        // Still close the add person dialog even if duplicate
        state = state.copyWith(showAddPerson: false);
      }
    }
  }

  void removePerson(int index) {
    final newPeople = [...state.people];
    newPeople.removeAt(index);
    
    int newCurrentIndex = state.currentPersonIndex;
    if (newCurrentIndex >= newPeople.length && newPeople.isNotEmpty) {
      newCurrentIndex = newPeople.length - 1;
    } else if (newPeople.isEmpty) {
      newCurrentIndex = 0;
    }

    state = state.copyWith(
      people: newPeople,
      currentPersonIndex: newCurrentIndex,
    );
    _saveParticipantList();
  }

  void clearAllParticipants() {
    state = state.copyWith(
      people: [],
      currentPersonIndex: 0,
    );
    _saveParticipantList();
  }

  void shuffleParticipants() {
    if (state.people.length > 1) {
      final shuffledPeople = [...state.people];
      final random = Random.secure();
      shuffledPeople.shuffle(random);
      state = state.copyWith(
        people: shuffledPeople,
        currentPersonIndex: 0,
      );
      _saveParticipantList();
    }
  }

  void setCurrentPersonIndex(int index) {
    if (index >= 0 && index < state.people.length) {
      state = state.copyWith(currentPersonIndex: index);
    }
  }

  void previousPerson() {
    if (state.currentPersonIndex > 0) {
      state = state.copyWith(currentPersonIndex: state.currentPersonIndex - 1);
    }
  }

  void nextPerson() {
    if (state.currentPersonIndex < state.people.length - 1) {
      state = state.copyWith(currentPersonIndex: state.currentPersonIndex + 1);
    }
  }

  void setShowAddPerson(bool show) {
    state = state.copyWith(showAddPerson: show);
  }

  Future<int> pasteParticipantList() async {
    try {
      final clipboardData = await ParticipantService.getClipboardContent();
      if (clipboardData.isNotEmpty) {
        final participants = ParticipantService.parseParticipantList(clipboardData);
        if (participants.isNotEmpty) {
          // Merge with existing participants and remove duplicates
          final existingPeople = state.people.toSet(); // Convert to Set for efficient lookup
          final newParticipants = <String>[];
          
          // Add only participants that don't already exist (case-insensitive)
          for (final participant in participants) {
            final trimmedParticipant = participant.trim();
            if (trimmedParticipant.isNotEmpty && 
                !existingPeople.any((existing) => existing.toLowerCase() == trimmedParticipant.toLowerCase())) {
              newParticipants.add(trimmedParticipant);
            }
          }
          
          if (newParticipants.isNotEmpty) {
            // Combine existing and new participants
            final allParticipants = [...state.people, ...newParticipants];
            final random = Random.secure();
            allParticipants.shuffle(random);
            
            state = state.copyWith(
              people: allParticipants,
              currentPersonIndex: 0,
            );
            _saveParticipantList();
          }
          return newParticipants.length; // Return number of participants added
        }
      }
      return 0; // No participants found or added
    } catch (e) {
      // Error will be handled by caller
      await _checkClipboardContent();
      throw Exception('Failed to paste participants');
    }
  }
}

final participantsProvider = StateNotifierProvider<ParticipantsNotifier, ParticipantsState>((ref) {
  return ParticipantsNotifier();
});