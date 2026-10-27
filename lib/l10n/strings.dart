/// Interface text in each learner language. Kept as plain Dart so adding a
/// language is one more map entry, with no code generation step.
class Strings {
  const Strings._(this.lang, this._t);

  final String lang;
  final Map<String, String> _t;

  static const supported = ['en', 'fr', 'es'];

  static const languageNames = {
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
  };

  static Strings of(String lang) => Strings._(lang, _tables[lang] ?? _tables['en']!);

  String operator [](String key) => _t[key] ?? _tables['en']![key] ?? key;

  String get appTitle => this['appTitle'];
  String get appSubtitle => this['appSubtitle'];
  String get chooseLanguage => this['chooseLanguage'];
  String get chooseLanguageBody => this['chooseLanguageBody'];
  String get review => this['review'];
  String wordsDue(int n) => (n == 1 ? this['wordDue'] : this['wordsDue']).replaceAll('{n}', '$n');
  String get tips => this['tips'];
  String lessonMeta(int words, int sentences) => this['lessonMeta']
      .replaceAll('{w}', '$words')
      .replaceAll('{s}', '$sentences');
  String get whatDoesThisMean => this['whatDoesThisMean'];
  String get whichEstonianWord => this['whichEstonianWord'];
  String get translateIntoEstonian => this['translateIntoEstonian'];
  String get translateIntoYourLanguage => this['translateIntoYourLanguage'];
  String get typeWhatYouHear => this['typeWhatYouHear'];
  String get tapMatchingPairs => this['tapMatchingPairs'];
  String get typeInEstonian => this['typeInEstonian'];
  String get tapToListen => this['tapToListen'];
  String get cantListenNow => this['cantListenNow'];
  String get check => this['check'];
  String get continueLabel => this['continue'];
  String get correct => this['correct'];
  String get notQuite => this['notQuite'];
  String get correctAnswer => this['correctAnswer'];
  String get meaning => this['meaning'];
  String get quitTitle => this['quitTitle'];
  String get quitBody => this['quitBody'];
  String get keepGoing => this['keepGoing'];
  String get quit => this['quit'];
  String get wellDone => this['wellDone'];
  String get xp => this['xp'];
  String get accuracy => this['accuracy'];
  String get streak => this['streak'];
  String get reviewComplete => this['reviewComplete'];
  String get settings => this['settings'];
  String get language => this['language'];
  String get estonianVoice => this['estonianVoice'];
  String get voiceInstalled => this['voiceInstalled'];
  String get voiceMissing => this['voiceMissing'];
  String get test => this['test'];
  String get retry => this['retry'];
  String get resetProgress => this['resetProgress'];
  String get resetProgressBody => this['resetProgressBody'];
  String get resetConfirm => this['resetConfirm'];
  String get cannotUndo => this['cannotUndo'];
  String get cancel => this['cancel'];
  String get reset => this['reset'];
  String get about => this['about'];
  String get aboutBody => this['aboutBody'];

  static const _tables = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Õpi eesti',
      'appSubtitle': 'Learn Estonian',
      'chooseLanguage': 'I speak…',
      'chooseLanguageBody': 'Pick the language you want to learn Estonian from. You can change it later in Settings.',
      'review': 'Review',
      'wordDue': '{n} word is due for practice',
      'wordsDue': '{n} words are due for practice',
      'tips': 'Tips',
      'lessonMeta': '{w} words · {s} sentences',
      'whatDoesThisMean': 'What does this mean?',
      'whichEstonianWord': 'Which is the Estonian word?',
      'translateIntoEstonian': 'Translate into Estonian',
      'translateIntoYourLanguage': 'Translate into English',
      'typeWhatYouHear': 'Type what you hear',
      'tapMatchingPairs': 'Tap the matching pairs',
      'typeInEstonian': 'Type in Estonian',
      'tapToListen': 'Tap to listen · hold for slow',
      'cantListenNow': "Can't listen now",
      'check': 'Check',
      'continue': 'Continue',
      'correct': 'Correct!',
      'notQuite': 'Not quite',
      'correctAnswer': 'Correct answer:',
      'meaning': 'Meaning:',
      'quitTitle': 'Quit this lesson?',
      'quitBody': 'Progress in this lesson will be lost.',
      'keepGoing': 'Keep going',
      'quit': 'Quit',
      'wellDone': 'Tubli! (Well done!)',
      'xp': 'XP',
      'accuracy': 'Accuracy',
      'streak': 'Streak',
      'reviewComplete': 'Review complete',
      'settings': 'Settings',
      'language': 'I learn from',
      'estonianVoice': 'Estonian voice',
      'voiceInstalled': 'Installed. Listening exercises work offline.',
      'voiceMissing': 'Not installed. On the phone go to Settings › System › Languages › '
          'Text-to-speech, open Google Speech Services and install the Estonian voice '
          'while online. Until then listening exercises are skipped.',
      'test': 'Test',
      'retry': 'Retry',
      'resetProgress': 'Reset progress',
      'resetProgressBody': 'Clears lessons, XP, streak and word strengths.',
      'resetConfirm': 'Reset progress?',
      'cannotUndo': 'This cannot be undone.',
      'cancel': 'Cancel',
      'reset': 'Reset',
      'about': 'About',
      'aboutBody': 'Õpi eesti keelt. All lessons are stored on the phone; no internet connection is needed.',
    },
    'fr': {
      'appTitle': 'Õpi eesti',
      'appSubtitle': "Apprendre l'estonien",
      'chooseLanguage': 'Je parle…',
      'chooseLanguageBody': "Choisissez la langue à partir de laquelle vous apprenez l'estonien. Vous pourrez la changer dans les réglages.",
      'review': 'Révision',
      'wordDue': '{n} mot à réviser',
      'wordsDue': '{n} mots à réviser',
      'tips': 'Conseils',
      'lessonMeta': '{w} mots · {s} phrases',
      'whatDoesThisMean': 'Que veut dire ce mot ?',
      'whichEstonianWord': 'Quel est le mot estonien ?',
      'translateIntoEstonian': 'Traduisez en estonien',
      'translateIntoYourLanguage': 'Traduisez en français',
      'typeWhatYouHear': 'Écrivez ce que vous entendez',
      'tapMatchingPairs': 'Associez les paires',
      'typeInEstonian': 'Écrivez en estonien',
      'tapToListen': 'Appuyez pour écouter · maintenez pour ralentir',
      'cantListenNow': 'Je ne peux pas écouter',
      'check': 'Vérifier',
      'continue': 'Continuer',
      'correct': 'Correct !',
      'notQuite': 'Pas tout à fait',
      'correctAnswer': 'Bonne réponse :',
      'meaning': 'Signification :',
      'quitTitle': 'Quitter la leçon ?',
      'quitBody': 'La progression de cette leçon sera perdue.',
      'keepGoing': 'Continuer',
      'quit': 'Quitter',
      'wellDone': 'Tubli ! (Bravo !)',
      'xp': 'XP',
      'accuracy': 'Précision',
      'streak': 'Série',
      'reviewComplete': 'Révision terminée',
      'settings': 'Réglages',
      'language': "J'apprends depuis",
      'estonianVoice': 'Voix estonienne',
      'voiceInstalled': 'Installée. Les exercices d\'écoute fonctionnent hors ligne.',
      'voiceMissing': 'Non installée. Sur le téléphone, allez dans Paramètres › Système › Langues › '
          'Synthèse vocale, ouvrez Services de reconnaissance vocale Google et installez la voix '
          'estonienne (connexion nécessaire). En attendant, les exercices d\'écoute sont ignorés.',
      'test': 'Tester',
      'retry': 'Réessayer',
      'resetProgress': 'Réinitialiser la progression',
      'resetProgressBody': 'Efface les leçons, les XP, la série et la force des mots.',
      'resetConfirm': 'Réinitialiser la progression ?',
      'cannotUndo': 'Cette action est irréversible.',
      'cancel': 'Annuler',
      'reset': 'Réinitialiser',
      'about': 'À propos',
      'aboutBody': "Õpi eesti keelt. Toutes les leçons sont stockées sur le téléphone ; aucune connexion n'est nécessaire.",
    },
    'es': {
      'appTitle': 'Õpi eesti',
      'appSubtitle': 'Aprende estonio',
      'chooseLanguage': 'Yo hablo…',
      'chooseLanguageBody': 'Elige el idioma desde el que quieres aprender estonio. Puedes cambiarlo después en Ajustes.',
      'review': 'Repaso',
      'wordDue': '{n} palabra pendiente de repaso',
      'wordsDue': '{n} palabras pendientes de repaso',
      'tips': 'Consejos',
      'lessonMeta': '{w} palabras · {s} frases',
      'whatDoesThisMean': '¿Qué significa esto?',
      'whichEstonianWord': '¿Cuál es la palabra en estonio?',
      'translateIntoEstonian': 'Traduce al estonio',
      'translateIntoYourLanguage': 'Traduce al español',
      'typeWhatYouHear': 'Escribe lo que oyes',
      'tapMatchingPairs': 'Une las parejas',
      'typeInEstonian': 'Escribe en estonio',
      'tapToListen': 'Toca para escuchar · mantén para lento',
      'cantListenNow': 'No puedo escuchar ahora',
      'check': 'Comprobar',
      'continue': 'Continuar',
      'correct': '¡Correcto!',
      'notQuite': 'No exactamente',
      'correctAnswer': 'Respuesta correcta:',
      'meaning': 'Significado:',
      'quitTitle': '¿Salir de la lección?',
      'quitBody': 'Se perderá el progreso de esta lección.',
      'keepGoing': 'Seguir',
      'quit': 'Salir',
      'wellDone': 'Tubli! (¡Muy bien!)',
      'xp': 'XP',
      'accuracy': 'Precisión',
      'streak': 'Racha',
      'reviewComplete': 'Repaso terminado',
      'settings': 'Ajustes',
      'language': 'Aprendo desde',
      'estonianVoice': 'Voz en estonio',
      'voiceInstalled': 'Instalada. Los ejercicios de escucha funcionan sin conexión.',
      'voiceMissing': 'No instalada. En el teléfono ve a Ajustes › Sistema › Idiomas › '
          'Síntesis de voz, abre Servicios de voz de Google e instala la voz en estonio '
          '(necesita conexión). Mientras tanto se omiten los ejercicios de escucha.',
      'test': 'Probar',
      'retry': 'Reintentar',
      'resetProgress': 'Reiniciar progreso',
      'resetProgressBody': 'Borra lecciones, XP, racha y fuerza de las palabras.',
      'resetConfirm': '¿Reiniciar el progreso?',
      'cannotUndo': 'Esto no se puede deshacer.',
      'cancel': 'Cancelar',
      'reset': 'Reiniciar',
      'about': 'Acerca de',
      'aboutBody': 'Õpi eesti keelt. Todas las lecciones están en el teléfono; no hace falta conexión a internet.',
    },
  };
}
