# GestureFace v3.1

Système d'authentification biométrique double facteur simultané (visage + geste main) avec protection des données, panic mode et camouflage.

## 🚀 Guide Rapide — Comment installer GestureFace sur votre iPhone

> **Prérequis :** un PC Windows, un câble USB Lightning/USB-C, et votre iPhone.

1. **Mergez cette Pull Request** (bouton vert "Merge" sur GitHub) → le build CI se lance automatiquement.
2. Attendez ~5 min, puis allez dans l'onglet **[Actions](https://github.com/biloute593/FAGE/actions)** du projet.
3. Cliquez sur le dernier run ✅ vert **"iOS Build (Unsigned)"**.
4. En bas de la page, dans **Artifacts**, téléchargez **`GestureFace-iOS-Build`** et décompressez le `.zip`.
5. Téléchargez et installez **[Sideloadly](https://sideloadly.io)** (gratuit) sur votre PC Windows.
6. **Branchez votre iPhone** par câble USB à votre PC.
7. Ouvrez Sideloadly → **glissez-déposez** le fichier `GestureFace.ipa` dans la fenêtre.
8. Entrez votre **identifiant Apple** (compte gratuit) → cliquez sur **Start**.
9. Sur l'iPhone : **Réglages → Général → VPN et gestion de l'appareil** → cliquez sur votre email → **"Faire confiance"**.
10. **C'est fait !** 🎉 L'app GestureFace est sur votre écran d'accueil.

> ⚠️ L'app est valide **7 jours** (limite Apple pour compte gratuit). Refaites les étapes 6-9 avec le même `.ipa` pour la réinstaller.

---

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

### Étape 1 — Télécharger l'IPA depuis GitHub

1. Allez sur la page GitHub du projet : [https://github.com/biloute593/FAGE](https://github.com/biloute593/FAGE)
2. Cliquez sur l'onglet **Actions** en haut de la page.
3. Sélectionnez le workflow **"iOS Build (Unsigned)"** dans la liste à gauche.
4. Cliquez sur la dernière exécution réussie (icône ✅ verte).
5. En bas de la page du workflow run, dans la section **Artifacts**, téléchargez **`GestureFace-iOS-Build`**.
6. Décompressez le fichier `.zip` téléchargé — vous y trouverez le fichier **`GestureFace.ipa`**.

> **Note :** Les artifacts sont conservés pendant **7 jours**. Si le lien a expiré, relancez le workflow manuellement via le bouton **"Run workflow"** dans l'onglet Actions.

### Étape 2 — Installer le .ipa sur votre iPhone depuis Windows

Apple bloque l'installation d'applications non provenant de l'App Store. Puisque vous n'avez pas de compte développeur payant Apple (99$/an), vous devez utiliser la méthode du **Sideloading** depuis votre PC Windows :

| Outil | Plateforme | Lien |
|-------|-----------|------|
| **Sideloadly** (recommandé) | Windows / macOS | [sideloadly.io](https://sideloadly.io) |
| **AltStore** | Windows / macOS | [altstore.io](https://altstore.io) |

#### Méthode recommandée : Sideloadly

1. Téléchargez et installez **[Sideloadly](https://sideloadly.io)** (gratuit) sur votre PC Windows.
2. **Branchez votre iPhone par câble USB** à votre PC.
3. Ouvrez Sideloadly, puis **glissez-déposez** le fichier `GestureFace.ipa` dans la fenêtre.
4. Entrez votre **identifiant Apple basique** (un compte gratuit suffit) et cliquez sur **Start**.
5. Sur votre iPhone : allez dans **Réglages > Général > VPN et gestion de l'appareil**, cliquez sur votre email, puis appuyez sur **"Faire confiance"**.
6. **C'est fait !** L'application GestureFace apparaît sur votre écran d'accueil.

> L'application est valide pendant **7 jours** (limite imposée par Apple pour les comptes développeur gratuits). Il suffit de répéter l'opération avec Sideloadly pour la réinstaller — vous pouvez réutiliser le même fichier `GestureFace.ipa` déjà téléchargé.

#### Méthode alternative : AltStore

1. Installez AltStore sur votre PC Windows et sur votre iPhone (voir [altstore.io](https://altstore.io)).
2. Connectez votre iPhone via USB.
3. Ouvrez AltStore sur l'iPhone, allez dans **My Apps** > **+** et sélectionnez le fichier `GestureFace.ipa`.
4. Entrez votre identifiant Apple (un compte gratuit suffit).
5. L'application sera installée et valide pendant 7 jours (renouvelable automatiquement par AltStore tant que votre PC est allumé sur le même réseau Wi-Fi).

### Build local (optionnel)

Si vous préférez compiler l'IPA vous-même (nécessite macOS) :

```bash
flutter create . --org com.gestureface   # Génère les fichiers iOS si absents
flutter pub get
flutter build ios --release --no-codesign
mkdir -p Payload
mv build/ios/iphoneos/Runner.app Payload/
zip -r -9 GestureFace.ipa Payload/
```

Le fichier `GestureFace.ipa` sera créé dans le répertoire courant.

## Compiler la version Android

Pour générer le fichier APK Android depuis Windows, utilisez le script PowerShell fourni :

```powershell
.\build_gestureface.ps1
```

Le fichier `GestureFace.apk` sera créé dans le répertoire courant. Transférez-le sur votre téléphone Android et installez-le (activez "Sources inconnues" dans les paramètres si nécessaire).

## Architecture
Le projet respecte une architecture par modules, synchronisée via un Event Bus asynchrone pour traiter chaque frame vidéo (30fps) dans des délais de l'ordre de ~37ms.

### Avertissement Sécurité
Le répertoire `/data/` est explicitement ignoré par `.gitignore`. Ne commitez jamais de clés ou de bases de données de développement.
