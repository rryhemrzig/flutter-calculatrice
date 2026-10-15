# Calculatrice mobile Flutter

## Présentation
Application de calculatrice développée en Flutter/Dart. L’interface utilise un fond noir, un affichage blanc, des touches gris foncé et une touche égale orange.

## Fonctionnalités
- Addition, soustraction, multiplication et division.
- Nombres décimaux.
- Modulo `%` (reste de la division entière : `10 % 3 = 1`).
- Effacement complet avec `C`.
- Suppression du dernier caractère avec `⌫`.
- Respect de la priorité des opérations (`2 + 3 × 4 = 14`).
- Message d’erreur en cas de division par zéro ou d’expression incomplète.
- Interface responsive, utilisable en portrait et sur écran plus large.
- Aucun package externe requis pour les calculs.

## Prérequis
- Flutter SDK installé.
- Android Studio avec Android SDK et un émulateur, ou un téléphone Android avec le débogage USB activé.
- VS Code avec l’extension Flutter (facultatif).

## Lancer le projet
Dans un terminal, placez-vous dans le dossier `calculatrice_flutter`, puis exécutez :

```bash
flutter doctor
flutter pub get
flutter devices
flutter run
```

Si aucun appareil n’est listé, démarrez un émulateur depuis Android Studio (`Device Manager`) ou connectez votre téléphone et activez les options développeur puis le débogage USB.

## Créer un APK Android
```bash
flutter build apk --release
```
Le fichier APK sera normalement généré dans :
`build/app/outputs/flutter-apk/app-release.apk`

## Lancer les tests
```bash
flutter test
```

Les tests fournis vérifient l’affichage initial, la remise à zéro, une addition et la priorité de multiplication.

## Organisation
- `lib/main.dart` : interface, gestion des boutons, calculs et parseur d’expressions.
- `test/widget_test.dart` : tests automatisés de l’interface et des calculs.
- `pubspec.yaml` : configuration du projet Flutter.

## Note sur le bouton %
Dans cette version, `%` représente le modulo (reste d’une division), et non le pourcentage classique. Exemple : `10 % 3 = 1`.
