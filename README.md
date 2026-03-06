# GestureFace v3.1

Système d'authentification biométrique double facteur simultané (visage + geste main) avec protection des données, panic mode et camouflage.

## Features
- **Dual-Factor Authentication**: Exige simultanément la reconnaissance faciale (MediaPipe Face Landmarker + ArcFace) et un geste de la main spécifique (MediaPipe Hand Landmarker).
- **Anti-Tampering**: Protection contre le root, jailbreak, et memory tampering (System Integrity Monitor).
- **Temporal Binding Token**: Anti-replay absolu par la création de tokens temporels cryptographiques.
- **Micro-Motion & Physiological Liveness**: Analyse de micro-tremblements, de l'entropie du geste, et de flux rPPG.
- **Camouflage & Panic Mode**: Lancement en mode "fake environment" via un geste spécifique pour leurrer les attaquants.

## Installation pas à pas
1. Installez le SDK Flutter (>=3.3.0).
2. Clonez ce repository.
3. Exécutez `flutter pub get`.
4. Ajoutez les modèles ML (.tflite) requis dans `assets/models/` (ArcFace, FaceLandmarker, HandLandmarker, rPPG).
5. Compilez l'application en mode release pour garantir l'activation de Native Keystore System:
   `flutter run --release`

## Architecture
Le projet respecte une architecture par modules, synchronisée via un Event Bus asynchrone pour traiter chaque frame vidéo (30fps) dans des délais de l'ordre de ~37ms.

### Avertissement Sécurité
Le répertoire `/data/` est explicitement ignoré par `.gitignore`. Ne commitez jamais de clés ou de bases de données de développement.
