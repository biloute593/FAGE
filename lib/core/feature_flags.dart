/// Feature Flags pour contrôler l'activation des fonctionnalités V2.
class FeatureFlags {
  // Active les fonctionnalités liées à l'analyse de Micro Motion Correlation (Phase V2)
  static const bool enableMicroMotionCorrelationEngine = false;

  // Active la vérification rPPG cross-modal avec la vibration osseuse (Phase V2)
  static const bool enableRppgCrossModalValidation = false;

  // Active les biométriques comportementales continues complètes (Phase V2)
  static const bool enableContinuousBehavioralBiometrics = false;

  // Active le modèle ML pour le rPPG skin-inclusive (Phase 5 MVP)
  static const bool enableRppgMlModel = true;
  
  // Définit si l'évaluation rPPG est bloquante pour l'authentification dans le MVP.
  // Par défaut, le MVP mentionne que le rPPG n'est pas bloquant (optionnel pour la V1)
  static const bool isRppgBlocking = false;
}
