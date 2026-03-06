/// Constantes critiques et configuration statique du système
class AppConstants {
  // Biometric Thresholds
  static const double faceScoreThreshold = 0.85;
  static const double gestureScoreThreshold = 0.90;
  static const double minEntropy = 0.10;
  static const double maxEntropy = 0.40;
  static const double rppgConfidenceThreshold = 0.70;
  static const double correlationScoreThreshold = 0.80; // V2
  
  // Performance
  static const int constantProcessingTimeMs = 1200;
  
  // Panic Detection
  static const double panicGestureAngleDeltaDegrees = 5.0;
  static const int panicGestureHoldDurationMs = 800;
  
  // Failure Escalation
  static const int maxBiometricAttempts = 5;
  static const int maxSecretQuestionAttempts = 3;
  
  // Lockout Protocol
  static const List<int> lockoutDurationsMinutes = [5, 30]; // 3 fails = 5m, 5 fails = 30m
  static const int lockoutThreshold1 = 3;
  static const int lockoutThreshold2 = 5;

  // Crypto & DB
  static const String databaseName = 'secure_vault.db';
  static const String cryptoAlgorithm = 'AES-256-GCM';
}
