import 'package:flutter/material.dart';
import 'locale_en.dart';
import 'locale_zh.dart';
import 'locale_ja.dart';
import 'locale_ko.dart';
import 'locale_fr.dart';
import 'locale_es.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en, 'zh': zh, 'ja': ja, 'ko': ko, 'fr': fr, 'es': es,
  };

  String _getValue(String key) => _localizedValues[locale.languageCode]?[key] ?? en[key] ?? key;

  String get languageCode => locale.languageCode;

  String get appName => _getValue('appName');
  String get studyChat => _getValue('studyChat');
  String get flashcards => _getValue('flashcards');
  String get settings => _getValue('settings');
  String get newChat => _getValue('newChat');
  String get chatHistory => _getValue('chatHistory');
  String get askAnything => _getValue('askAnything');
  String get thinking => _getValue('thinking');
  String get connected => _getValue('connected');
  String get offline => _getValue('offline');
  String get makeFlashcards => _getValue('makeFlashcards');
  String get quizMe => _getValue('quizMe');
  String get studyPlan => _getValue('studyPlan');
  String get translate => _getValue('translate');
  String get camera => _getValue('camera');
  String get tapToReveal => _getValue('tapToReveal');
  String get tapToFlip => _getValue('tapToFlip');
  String get again => _getValue('again');
  String get gotIt => _getValue('gotIt');
  String get question => _getValue('question');
  String get answer => _getValue('answer');
  String get noFlashcardsYet => _getValue('noFlashcardsYet');
  String get noFlashcardsHint => _getValue('noFlashcardsHint');
  String get noChatsYet => _getValue('noChatsYet');
  String get dueNow => _getValue('dueNow');
  String get reviewed => _getValue('reviewed');
  String get deleteChat => _getValue('deleteChat');
  String get renameChat => _getValue('renameChat');
  String get deleteAllChats => _getValue('deleteAllChats');
  String get confirmDelete => _getValue('confirmDelete');
  String get cancel => _getValue('cancel');
  String get save => _getValue('save');
  String get connection => _getValue('connection');
  String get laptopIpAddress => _getValue('laptopIpAddress');
  String get testConnection => _getValue('testConnection');
  String get connectedSuccess => _getValue('connectedSuccess');
  String get connectionFailed => _getValue('connectionFailed');
  String get models => _getValue('models');
  String get notifications => _getValue('notifications');
  String get dailyReminder => _getValue('dailyReminder');
  String get reviewReminder => _getValue('reviewReminder');
  String get inactivityReminder => _getValue('inactivityReminder');
  String get testNotification => _getValue('testNotification');
  String get language => _getValue('language');
  String get stats => _getValue('stats');
  String get totalFlashcards => _getValue('totalFlashcards');
  String get dueForReview => _getValue('dueForReview');
  String get chatSessions => _getValue('chatSessions');
  String get about => _getValue('about');
  String get darkMode => _getValue('darkMode');
  String get welcomeMessage => _getValue('welcomeMessage');

  // Prompts for AI
  String get promptFlashcards => _getValue('promptFlashcards');
  String get promptQuiz => _getValue('promptQuiz');
  String get promptPlan => _getValue('promptPlan');
  String get promptTranslate => _getValue('promptTranslate');

  // Theme & Settings
  String get themeSettings => _getValue('themeSettings');
  String get dangerZone => _getValue('dangerZone');
  String get fontSize => _getValue('fontSize');
  String get appearance => _getValue('appearance');
  String get cardsMastered => _getValue('cardsMastered');
  String get clearAllFlashcards => _getValue('clearAllFlashcards');
  String get deleteDataWarning => _getValue('deleteDataWarning');
  String get delete => _getValue('delete');
  String get flashcardReview => _getValue('flashcardReview');
  String get confirmDeleteAllChats => _getValue('confirmDeleteAllChats');
  String get confirmClearAllFlashcards => _getValue('confirmClearAllFlashcards');

  // Onboarding & Download
  String get getStarted => _getValue('getStarted');
  String get next => _getValue('next');
  String get downloadAIModel => _getValue('downloadAIModel');
  String get downloadAIModelDesc => _getValue('downloadAIModelDesc');
  String get downloadNow => _getValue('downloadNow');
  String get skipForNow => _getValue('skipForNow');
  String get modelInstalled => _getValue('modelInstalled');
  String get startStudying => _getValue('startStudying');
  String get requiresWifi => _getValue('requiresWifi');
  String get downloadFailed => _getValue('downloadFailed');
  String get retry => _getValue('retry');
  String get modelManagement => _getValue('modelManagement');
  String get onDeviceModel => _getValue('onDeviceModel');
  String get installed => _getValue('installed');
  String get notInstalled => _getValue('notInstalled');
  String get deleteModel => _getValue('deleteModel');
  String get deleteModelConfirm => _getValue('deleteModelConfirm');

  // Hugging Face Login
  String get loginToHF => _getValue('loginToHF');
  String get hfUsername => _getValue('hfUsername');
  String get hfToken => _getValue('hfToken');
  String get hfLoginDesc => _getValue('hfLoginDesc');
  String get login => _getValue('login');
  String get optional => _getValue('optional');

  // Study Camera
  String get studyCamera => _getValue('studyCamera');
  String get takePhoto => _getValue('takePhoto');
  String get pickFromGallery => _getValue('pickFromGallery');
  String get analysisComplete => _getValue('analysisComplete');
  String get askFollowUp => _getValue('askFollowUp');
  String get newPhoto => _getValue('newPhoto');
  String get sendToAI => _getValue('sendToAI');
  String get analyzingImage => _getValue('analyzingImage');
  String get extractingText => _getValue('extractingText');
  String get imagePromptHint => _getValue('imagePromptHint');
  String get solveThis => _getValue('solveThis');
  String get explainKeyPoints => _getValue('explainKeyPoints');
  String get summarize => _getValue('summarize');
  String get noTextDetected => _getValue('noTextDetected');
  String get connectLaptopForImageAnalysis => _getValue('connectLaptopForImageAnalysis');

  // Home screen — simple getters
  String get goodMorning => _getValue('goodMorning');
  String get goodAfternoon => _getValue('goodAfternoon');
  String get goodEvening => _getValue('goodEvening');
  String get readyToStudy => _getValue('readyToStudy');
  String get dayStreak => _getValue('dayStreak');
  String get totalDays => _getValue('totalDays');
  String get today => _getValue('today');
  String get cards => _getValue('cards');
  String get chats => _getValue('chats');
  String get breakTime => _getValue('breakTime');
  String get focusSession => _getValue('focusSession');
  String get timerRest => _getValue('timerRest');
  String get timerFocus => _getValue('timerFocus');
  String get reset => _getValue('reset');
  String get finishEarly => _getValue('finishEarly');
  String get breakTip => _getValue('breakTip');
  String get focusTip => _getValue('focusTip');
  String get sessionComplete => _getValue('sessionComplete');
  String get takeABreak => _getValue('takeABreak');
  String get keepGoing => _getValue('keepGoing');
  String get breakOver => _getValue('breakOver');

  // Home screen — parameterized helpers
  String pomodorosDoneToday(int count) =>
      _getValue('pomodorosDoneToday').replaceAll('{count}', '$count');

  String streakLabel(int streak) {
    // English needs singular/plural handling; other languages don't
    if (locale.languageCode == 'en') {
      return 'Streak: $streak day${streak == 1 ? '' : 's'} 🔥';
    }
    return _getValue('streakLabel').replaceAll('{streak}', '$streak');
  }

  String sessionsCompletedToday(int count) {
    if (locale.languageCode == 'en') {
      return '$count session${count == 1 ? '' : 's'} completed today';
    }
    return _getValue('sessionsCompletedToday').replaceAll('{count}', '$count');
  }

  // QR Gallery
  String get scanFromGallery => _getValue('scanFromGallery');
  String get noQrInImage => _getValue('noQrInImage');

  // Custom Timer
  String get customTimer => _getValue('customTimer');
  String get workDuration => _getValue('workDuration');
  String get breakDuration => _getValue('breakDuration');
  String get minutesUnit => _getValue('minutesUnit');
  String get apply => _getValue('apply');

  // Camera / Math Solver
  String get mathSolver => _getValue('mathSolver');
  String get generalMode => _getValue('generalMode');
  String get solveStepByStep => _getValue('solveStepByStep');
  String get stepSolution => _getValue('stepSolution');
  String get saveMathCards => _getValue('saveMathCards');

  // Document Import
  String get importDocument => _getValue('importDocument');

  // Mind Map
  String get mindMap => _getValue('mindMap');
  String get generatingMindMap => _getValue('generatingMindMap');
  String get mindMapHint => _getValue('mindMapHint');
  String get mindMapError => _getValue('mindMapError');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh', 'ja', 'ko', 'fr', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
