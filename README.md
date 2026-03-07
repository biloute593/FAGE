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

## Récupérer le fichier IPA pour tester sur iPhone

Le fichier **GestureFace.ipa** est généré automatiquement par le CI (GitHub Actions) à chaque push sur la branche `main`.

### Étapes pour télécharger l'IPA

1. Allez sur la page GitHub du projet : [https://github.com/biloute593/FAGE](https://github.com/biloute593/FAGE)
2. Cliquez sur l'onglet **Actions** en haut de la page.
3. Sélectionnez le workflow **"iOS Build (Unsigned)"** dans la liste à gauche.
4. Cliquez sur la dernière exécution réussie (icône ✅ verte).
5. En bas de la page du workflow run, dans la section **Artifacts**, téléchargez **`GestureFace-iOS-Build`**.
6. Décompressez le fichier `.zip` téléchargé — vous y trouverez le fichier **`GestureFace.ipa`**.

> **Note :** Les artifacts sont conservés pendant **7 jours**. Si le lien a expiré, relancez le workflow manuellement via le bouton **"Run workflow"** dans l'onglet Actions.

### Installer l'IPA sur votre iPhone

L'IPA est **non signée** (`--no-codesign`), ce qui signifie qu'elle ne peut pas être installée directement depuis l'App Store. Utilisez l'une des méthodes suivantes :

| Outil | Plateforme | Lien |
|-------|-----------|------|
| **AltStore** | Windows / macOS | [altstore.io](https://altstore.io) |
| **Sideloadly** | Windows / macOS | [sideloadly.io](https://sideloadly.io) |

**Avec AltStore :**
1. Installez AltStore sur votre PC/Mac et sur votre iPhone.
2. Connectez votre iPhone via USB.
3. Ouvrez AltStore sur l'iPhone, allez dans **My Apps** > **+** et sélectionnez le fichier `GestureFace.ipa`.
4. Entrez votre identifiant Apple (un compte gratuit suffit).
5. L'application sera installée et valide pendant 7 jours (limite imposée par Apple pour les comptes développeur gratuits, renouvelable automatiquement par AltStore).

**Avec Sideloadly :**
1. Installez Sideloadly sur votre PC/Mac.
2. Connectez votre iPhone via USB.
3. Glissez-déposez le fichier `GestureFace.ipa` dans Sideloadly.
4. Entrez votre identifiant Apple et cliquez sur **Start**.
5. Sur l'iPhone, allez dans **Réglages > Général > VPN et gestion de l'appareil** et faites confiance au certificat.

### Build local (optionnel)

Si vous préférez compiler l'IPA vous-même :

```bash
flutter create . --org com.gestureface   # Génère les fichiers iOS si absents
flutter pub get
flutter build ios --release --no-codesign
mkdir -p Payload
mv build/ios/iphoneos/Runner.app Payload/
zip -r -9 GestureFace.ipa Payload/
```

Le fichier `GestureFace.ipa` sera créé dans le répertoire courant.

## Architecture
Le projet respecte une architecture par modules, synchronisée via un Event Bus asynchrone pour traiter chaque frame vidéo (30fps) dans des délais de l'ordre de ~37ms.

### Avertissement Sécurité
Le répertoire `/data/` est explicitement ignoré par `.gitignore`. Ne commitez jamais de clés ou de bases de données de développement.
