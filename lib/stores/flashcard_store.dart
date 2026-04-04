import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class FlashcardStore extends ChangeNotifier {
  static final FlashcardStore _instance = FlashcardStore._();
  factory FlashcardStore() => _instance;
  FlashcardStore._();

  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();
  
  List<Flashcard> _flashcards = [];

  List<Flashcard> get cards => List.unmodifiable(_flashcards);
  List<Flashcard> get dueCards => _flashcards.where((c) => c.nextReview.isBefore(DateTime.now())).toList();
  int get totalCards => _flashcards.length;
  int get dueCount => dueCards.length;

  List<String> get groupIds {
    return _flashcards.map((f) => f.groupId).toSet().toList();
  }

  List<Flashcard> getCardsInGroup(String groupId) {
    return _flashcards.where((f) => f.groupId == groupId).toList();
  }

  String getGroupName(String groupId) {
    final card = _flashcards.firstWhere(
      (f) => f.groupId == groupId,
      orElse: () => Flashcard(id: '', groupId: groupId, groupName: 'Study Set', front: '', back: ''),
    );
    return card.groupName;
  }

  int getDueCountInGroup(String groupId) {
    return getCardsInGroup(groupId)
        .where((f) => f.nextReview.isBefore(DateTime.now()))
        .length;
  }

  void deleteGroup(String groupId) {
    _flashcards.removeWhere((f) => f.groupId == groupId);
    save();
    notifyListeners();
  }

  void renameGroup(String groupId, String newName) {
    _flashcards = _flashcards.map((f) {
      if (f.groupId == groupId) {
        return f.copyWith(groupName: newName);
      }
      return f;
    }).toList();
    save();
    notifyListeners();
  }

  void updateCard(Flashcard updated) {
    final index = _flashcards.indexWhere((f) => f.id == updated.id);
    if (index != -1) {
      _flashcards[index] = updated;
      save();
      notifyListeners();
    }
  }

  Future<void> load() async {
    _flashcards = await _storage.loadFlashcards();
    notifyListeners();
  }

  Future<void> save() async {
    await _storage.saveFlashcards(_flashcards);
    _notifications.scheduleFlashcardReminders(_flashcards);
  }

  void addCards(List<Flashcard> newCards) {
    _flashcards.addAll(newCards);
    save();
    notifyListeners();
  }

  void removeCard(String id) {
    _flashcards.removeWhere((c) => c.id == id);
    save();
    notifyListeners();
  }

  void clearAll() {
    _flashcards.clear();
    save();
    notifyListeners();
  }
}
