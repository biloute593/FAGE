import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../core/event_bus.dart';
import '../core/constants.dart';

/// Fallback : Secret Question
/// Activé après 5 échecs biométriques successifs
class SecretQuestionFallback {
  final EventBus eventBus;

  // L'utilisateur défini ceci à l'inscription.
  // "MODE PERSONNALISÉ" ou "MODE ALÉATOIRE"
  String _hashedAnswer = ""; 
  String question = "Première voiture ?";

  int _failedAttempts = 0;

  SecretQuestionFallback({required this.eventBus});

  void enroll(String customQuestion, String rawAnswer) {
    question = customQuestion;
    _hashedAnswer = _hash(rawAnswer.trim().toLowerCase());
  }

  bool verify(String inputAnswer) {
    String inputHashed = _hash(inputAnswer.trim().toLowerCase());
    
    if (inputHashed == _hashedAnswer) {
      _failedAttempts = 0;
      eventBus.fire(AppEvent.authSuccess, {'method': 'secret_question'});
      return true;
    } else {
      _failedAttempts++;
      eventBus.fire(AppEvent.authFailure, {'reason': 'wrong_secret_answer', 'attempt': _failedAttempts});
      
      if (_failedAttempts >= AppConstants.maxSecretQuestionAttempts) {
        // Déclenche l'escalade vers le Device PIN
        eventBus.fire(AppEvent.tamperDetected, {'threat': 'secret_question_bruteforce'});
      }
      return false;
    }
  }

  String _hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
