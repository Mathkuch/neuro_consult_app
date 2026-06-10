import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data'; // Pour manipuler les bytes de l'image



class QuestionnairePatient extends StatefulWidget {
  const QuestionnairePatient({super.key});

  @override
  State<QuestionnairePatient> createState() => _QuestionnairePatientState();
}

class _QuestionnairePatientState extends State<QuestionnairePatient> {
    final GlobalKey _qrKey = GlobalKey();
    final Color blueCHRU = const Color(0xFF00599A);
    final Color lightBlueBG = const Color.fromARGB(255, 186, 217, 252);
    String? _modeAccouchement;
    // --- 1. IDENTITÉ ENFANT & CONSULTATION ---
    final TextEditingController _nomEnfantController = TextEditingController();
    final TextEditingController _prenomEnfantController = TextEditingController();
    final TextEditingController _motifController = TextEditingController();
    DateTime? ddnEnfant;
    String sexe = 'Masculin';
    String lateralite = 'droitier';
    // --- 2. PARENTS ---
    final TextEditingController _nomPereController = TextEditingController();
    final TextEditingController _prenomPereController = TextEditingController();
    final TextEditingController _metierPereController = TextEditingController();
    final TextEditingController _originePereController = TextEditingController(text: 'européenne');
    final TextEditingController _atcdPereController = TextEditingController();
    final TextEditingController _atcdFamPereController = TextEditingController();
    DateTime? ddnPere;
    int _ongletSauvegarde = 0;
    final TextEditingController _nomMereController = TextEditingController();
    final TextEditingController _prenomMereController = TextEditingController();
    final TextEditingController _metierMereController = TextEditingController();
    final TextEditingController _origineMereController = TextEditingController(text: 'européenne');
    final TextEditingController _atcdMereController = TextEditingController();
    final TextEditingController _atcdFamMereController = TextEditingController();
    DateTime? ddnMere;
    final TextEditingController _precisionConsanguiniteCtrl = TextEditingController();
        // --- 3. FRATRIE ---
    final TextEditingController _rangController = TextEditingController();
    final TextEditingController _nbEnfantsController = TextEditingController();
    final TextEditingController _atcdFratrieController = TextEditingController();
    final TextEditingController _demiFreresPatController = TextEditingController();
    final TextEditingController _demiFreresMatController = TextEditingController();
    // --- 4. NAISSANCE ET SCOLARITÉ ---
    final TextEditingController _grossesseController = TextEditingController(text: "La grossesse était spontanée, de déroulement normal. Les échographies fœtales étaient sans particularité. Il n'y avait pas d'anomalie des sérologies maternelles, ni de prise de toxique ou de médicament pendant la grossesse.");
    final TextEditingController _termeSAController = TextEditingController();
    final TextEditingController _poidsController = TextEditingController();
    final TextEditingController _tailleController = TextEditingController();
    final TextEditingController _pcController = TextEditingController();
    final TextEditingController _apgar1Controller = TextEditingController();
    final TextEditingController _apgar5Controller = TextEditingController();
    final TextEditingController _scolariteCtrl = TextEditingController(text: "Actuellement, l'enfant est en classe de . Il est gardé par ");
    final TextEditingController _detailAccouchementController = TextEditingController();
    // --- 5. Antécédents et Allergies
    final TextEditingController _atcdMedCtrl = TextEditingController();
    final TextEditingController _atcdChirCtrl = TextEditingController();
    final TextEditingController _allergiesController = TextEditingController();
    final TextEditingController _traitements = TextEditingController();
    final TextEditingController _vaccinsController = TextEditingController();
    // --- 6. HISTOIRE DE LA MALADIE ---
    final TextEditingController _cliniqueCtrl = TextEditingController();
    final TextEditingController _imagerieCtrl = TextEditingController();
    final TextEditingController _eegCtrl = TextEditingController();
    final TextEditingController _traitEssayesCtrl = TextEditingController();
    final TextEditingController _suiviCtrl = TextEditingController();

    // Étapes de développement
    final TextEditingController _assisCtrl = TextEditingController();
    final TextEditingController _marcheCtrl = TextEditingController();
    final TextEditingController _motsCtrl = TextEditingController();
    final TextEditingController _propreteCtrl = TextEditingController();
    final TextEditingController _sommeilCtrl = TextEditingController();
    final TextEditingController _alimCtrl = TextEditingController();

    // Contrôleurs additionnels sommeil pour les 6 mois - 4 ans
    // Stockage pour le développement et le sommeil
    final Map<String, bool> _devChecklist = {};
    final List<int?> _sdscResponses = List.filled(26, null);

    // Contrôleurs Sommeil (6 mois - 4 ans)
    final TextEditingController _heureCoucher = TextEditingController();
    final TextEditingController _heureLever = TextEditingController();
    final TextEditingController _dureeSieste = TextEditingController();
    final TextEditingController _dureeEveilNuit = TextEditingController();
    final TextEditingController _nbReveilNuit = TextEditingController();
    final TextEditingController _actionReveil = TextEditingController();

    // Données du développement psychomoteur (4 domaines)
    final Map<double, Map<String, List<String>>> _milestonesData = {
      0.167: {
        'Motricité Globale': ["A une tenue de tête", "Bouge vigoureusement les 4 membres de manière symétrique", "Passe du côté vers le dos", "Soulève la tête et les épaules sur le ventre", "Donne des coups avec ses mains et ses pieds pour s’amuser quand il est couché sur le dos", "A une préhension involontaire au contact"],
        'Motricité Fine': ["Ouvre les mains", "Joue avec ses mains", "Porte ses mains à sa bouche", "Peut secouer un objet pendant quelques secondes sans l’échapper"],
        'Langage oral': ["Vocalise", "Emet une réponse vocale à une sollicitation"],
        'Socialisation': ["A un sourire réponse", "Réagit quand votre voix ou votre ton change pour exprimer différentes émotions", "Observe les yeux et la bouche de la personne qui lui parle", "Cesse de téter pour écouter les sons qui l’entourent", "Rit aux éclats"],
      },
      0.333: {
        'Motricité Globale': ["Bouge vigoureusement les 4 membres de manière symétrique", "Tient sa tête droite maintenu assis", "Soulève la tête et les épaules sur le ventre", "Attrape des objets en soulevant un bras et en s’appuyant sur l’autre lorsqu’il est sur le ventre", "Passe sur le dos lorsqu’il est couché sur le ventre"],
        'Motricité Fine': ["A une préhension grossière, utilises toute la main", "Attrape un objet qui lui est tendu", "Porte les objets à sa bouche", "Regarde ses doigts", "Laisse tomber des objets et les ramasse"],
        'Langage oral': ["Vocalise ou gazouille", "Joue avec les sons en modifiant l’intensité (bas ou fort) et le débit de sa voix", "Émet des sons lorsqu’il regarde les gens ou ses jouets", "Produit des consonnes suivies de voyelle"],
        'Socialisation': ["Pleure pour attirer l’attention", "Reconnaît les personnes qui s’occupent le plus souvent de lui", "S’intéresse à son parent lorsque celui-ci varie le rythme de sa voix", "Rit aux éclats", "A un sourire sélectif à partir de 3 à 6 mois", "Fixe son regard dans le vôtre", "Lève les bras pour se faire prendre", "Rit aux éclats lorsqu’on le chatouille, lorsqu’on joue à faire « coucou » avec lui", "Peut se montrer triste ou en colère", "Repousse quelqu’un qui lui fait quelque chose qu’il n’aime pas"],
      },
      0.5: {
        'Motricité Globale': ["Tient sa tête stable sans osciller", "Tient assis en tripode, avec appui sur ses mains", "Passe sur le ventre lorsqu’il est couché sur le dos", "Peut se tourner vers la gauche et vers la droite lorsqu’il est couché sur le ventre", "Veut avancer sur le ventre"],
        'Motricité Fine': ["Attrape l’objet tenu à distance", "Utilise une main ou l’autre, sans préférence", "Porte à la bouche, passe un cube d’une main à l’autre", "Tourne son poignet pour faire pivoter et examiner des objets", "Utilise ses mains pour agripper, frapper et renverser des objets qu’il voit", "Commence à tenir un objet d’une main et à en prendre un autre avec l’autre main"],
        'Langage oral': ["Tourne la tête pour regarder la personne qui parle", "Vocalise des monosyllabes", "Babille (consonnes)", "Produit des consonnes suivies de voyelle", "Imite certains de vos sons et de vos intonations", "A tendance à se taire quand l’adulte parle et à produire des sons quand l’adulte se tait"],
        'Socialisation': ["Sourit en réponse au sourire de l’adulte", "Sollicite le regard de l’autre", "Distingue les visages familiers", "Demande les bras", "Réagit parfois au timbre émotif de la voix de ses parents", "Montre une préférence pour un jouet ou un objet particulier", "Sourit aux enfants qu’il ne connaît pas et veut les toucher", "Tourne la tête lorsqu’il l’appelle", "Porte attention à ce qu’il regarde"],
      },
      0.75: {
        'Motricité Globale': ["Rampe", "Tient assis sans appui", "marche à 4 pattes", "Tient debout avec appui", "Passe debout lorsqu’il est assis et que vous le tirez par les mains", "Avance en roulant du dos au ventre et du ventre au dos"],
        'Motricité Fine': ["A une pince inférieure (pouce-auriculaire)", "A une pince supérieure (opposition pouce-index)", "Fait tomber des objets par mégarde, puis les cherche du regard", "Examine des objets en les saisissant, en les secouant, en les glissant et en les frappant", "Transfère un objet de grosseur moyenne d’une main à l’autre", "Met son index dans des trous ou à l’intérieur d’autres objets qui l’intéressent", "Tient seul un biberon"],
        'Langage oral': ["A un babillage canonique", "Reconnaît certains mots dans des situations familières"],
        'Socialisation': ["Répond à son prénom à 7-8 mois", "Peur de l’étranger, détresse au départ de la mère", "Fait les marionnettes, bravo et au revoir", "Va chercher un objet caché", "Montre intentionnellement du doigt les objets qu’il veut"],
      },
      1.0: {
        'Motricité Globale': ["Passe tout seul de la position couchée à la position assise", "Tient assis seul sans appui et sans aide, dos bien droit", "Avance seul au sol", "Met ses mains lorsqu’il tombe en avant, sur les côtés ou vers l’arrière", "Marche lorsque vous le tenez par les deux mains", "Commence à marcher seul"],
        'Motricité Fine': ["Cherche l’objet que l’on vient de cacher", "Prend les petits objets entre le pouce et l’index (pince pulpaire)", "Donne un objet sur ordre", "Utilise son index pour pointer, pousser, toucher et explorer", "Empile de gros objets", "Utilise un objet pour frapper sur un autre objet, comme un outil", "Tient un gros crayon", "Boit au verre"],
        'Langage oral': ["Réagit à son prénom", "Comprend le « non » (un interdit)", "Prononce des syllabes redoublées", "Dit « Papa, maman », jargon de 3 à 5 mots compréhensibles par les parents", "Comprend les ordres simples"],
        'Socialisation': ["Regarde ce que l’adulte lui montre avec le doigt (attention conjointe)", "Fait des gestes sociaux (au revoir, bravo)", "Capable de se montrer triste, joyeux, fâché", "Montre son affection avec des câlins, des bisous, des caresses et des sourires", "Imite la personne qui tape des mains", "Peut se montrer impatient et réagir s’il n’obtient pas rapidement ce qu’il veut"],
      },
      1.5: {
        'Motricité Globale': ["Passe debout seul à partir du sol (transfert assis-debout sans aide)", "Marche sans aide (plus de cinq pas)", "Marche en fonçant sur un ballon pour le frapper vers l’âge de 19 mois et il le frappe du pied vers 24 mois", "Peut transporter un gros jouet en marchant"],
        'Motricité Fine': ["Empile deux cubes (sur modèle)", "Introduit un petit objet dans un petit récipient", "Enlève quelques vêtements", "Déballe un objet caché dans du papier", "Commence à utiliser des outils simples", "Boit dans une tasse en la soulevant"],
        'Langage oral': ["Désigne un objet ou une image sur consigne orale", "Comprend les consignes simples (chercher un objet connu, etc.)", "Dit spontanément cinq mots"],
        'Socialisation': ["Est capable d’exprimer un refus", "Montre avec le doigt ce qui l’intéresse pour attirer l’attention de l’adulte", "Est possessif avec ses jouets et les personnes de son entourage", "A des changements d’humeur rapides et manifester son désaccord", "Dit « non »"],
      },
      2.0: {
        'Motricité Globale': ["Court avec des mouvements coordonnés des bras", "Monte les escaliers marche par marche (seul ou avec aide)", "Shoote dans un ballon", "Saute sur place, les deux pieds ensemble", "Se met à cheval sur des jouets à roues et les fait avancer en bougeant les deux pieds en même temps"],
        'Motricité Fine': ["Empile cinq cubes (sur modèle)", "Utilise seul la cuillère (même si peu efficace)", "Encastre des formes géométriques simples", "Tourne les pages d’un livre", "Imite une ligne verticale", "Tour de 6 à 8 cubes", "Gribouille en tenant son crayon à pleine main"],
        'Langage oral': ["Dit spontanément plus de dix mots usuels", "Associe deux mots (bébé dodo, maman partie)", "Utilise un vocabulaire de 50 mots", "Dit son prénom", "Obéit aux ordres simples, « oui, non »", "Commence à compter"],
        'Socialisation': ["Participe à des jeux de faire semblant, d’imitation (dînette, garage)", "Est capable de s’opposer à vos demandes, de dire « non » et de décider de certaines choses par lui-même", "A de l'interêt pour les autres enfants (crèche, fratrie, etc.)", "Joue à faire semblant", "Peut attribuer des sentiments et des intentions aux objets comme à son toutou"],
      },
      3.0: {
        'Motricité Globale': ["Descend l’escalier seul en alternant les pieds (avec la rampe)", "Saute d’une marche", "Tient debout sur 1 pied sans appui pendant plus de 3 secondes", "Passe de la position assise à debout sans appui", "Monte les escaliers en alternant les pieds", "Pédale au tricycle", "S’accroupit et se relève sans aide", "Grimpe, glisse, monte une échelle et se balance sur le matériel d’un terrain de jeux"],
        'Motricité Fine': ["Empile huit cubes (sur modèle)", "Copie un cercle sur modèle visuel (non dessiné devant lui)", "Enfile seul un vêtement (bonnet, pantalon, tee-shirt)", "Dévisse/revisse le bouchon d’un flacon", "Recopie un cercle fermé – un trait vertical – un trait horizontal", "A une pince tripode du crayon", "Reproduit un pont de 3 cubes – une tour de 8 cubes – un mur de 4 cubes", "Manipule des ciseaux", "Dessine des maisons et des personnages avec deux ou quatre membres attachés à la tête", "Peut boutonner de gros boutons", "Est capable de se laver et sécher les mains"],
        'Langage oral': ["Dit des phrases de trois mots (avec sujet et verbe, objet)", "Utilise son prénom ou le « je » quand il parle de lui", "Comprend une consigne orale simple (sans geste de l’adulte)", "Dit son prénom", "Dit « je » et « oui »", "Nomme 3 couleurs", "Comprend le langage quotidien, « haut-bas » et « devant-derrière »", "Emploie des articles", "Conjugue des verbes", "A un vocabulaire diversifié (Verbe, adjectif, mots outils, mots fonctionnels, prépositions, pronoms… parfois mal prononcés)", "Peut compter environ jusqu’à 10"],
        'Socialisation': ["Prend plaisir à jouer avec des enfants de son âge", "Sait prendre son tour dans un jeu à deux ou à plusieurs", "Mange seul au repas", "Est capable de s'habiller avec aide (chaussons et chaussettes seul)", "A acquis la propreté diurne/nocturne", "Joue à faire semblant", "Joue à plusieurs", "Est capable de se sépare plus ou moins facilement de sa mère", "Peut anticiper les situations", "A des peurs comme celle des fantômes, des loups et des orages", "Peut exprimer de la jalousie et de l’agressivité envers les autres enfants"],
      },
      4.0: {
        'Motricité Globale': ["Saute à pieds joints (au minimum sur place)", "Monte les marches non tenues et en alternant", "Lance un ballon de façon dirigée", "Sait pédaler (tricycle ou vélo avec stabilisateur)", "Saute sur 1 pied en plus de l’appui monopodal", "Lance, attrape et fait rebondir un ballon"],
        'Motricité Fine': ["Dessine un bonhomme têtard", "Copie une croix orientée selon le modèle (non dessiné devant lui)", "Fait un pont avec trois cubes (sur démonstration)", "Enfile son manteau tout seul", "Est capable de s’habiller sans aide", "Dessine un bonhomme en 3 parties", "Utilise des ciseaux, des gommettes, de la pâte à modeler", "Joue aux puzzles et jeux de construction", "Peint au grand pinceau sur une grande feuille", "Colorie l’intérieur d’une forme simple"],
        'Langage oral': ["Utilise le « je » pour se désigner (ou équivalent dans sa langue natale)", "A un langage intelligible par une personne étrangère à la famille", "Conjugue des verbes au présent", "Pose la question « Pourquoi ? »", "Peut répondre à des consignes avec deux variables", "Compte quatre objets", "Comprend les phrases longues complexes et un récit simple", "Articule tous les sons"],
        'Socialisation': ["A des jeux imaginatifs avec des scénarios", "Sait trier des objets par catégories (couleurs, formes, etc.)", "Accepte de participer à une activité en groupe", "Cherche à jouer ou interagir avec des enfants de son âge"],
      },
      5.0: {
        'Motricité Globale': ["Tient en équilibre sur un pied au moins cinq secondes sans appui", "Marche sur une ligne (en mettant un pied devant l’autre)", "Attrape un ballon avec les mains", "Marche en ligne en arrière"],
        'Motricité Fine': ["Dessine un bonhomme en deux à quatre parties", "Copie son prénom en lettres majuscules (sur modèle)", "Copie un carré (avec quatre coins distincts)", "Dessine un bonhomme en 6 parties (4 membres, tronc, tête)", "Connaît sa main droite, pianotage digital", "Fait claquer sa langue, fait un clin d’œil, gonfle les joues", "Utilise des ciseaux, des gommettes, de la pâte à modeler"],
        'Langage oral': ["Fait des phrases de six mots avec une grammaire correcte", "Comprend des éléments de topologie (dans/sur/derrière)", "Nomme au moins trois couleurs", "Décrit une scène sur une image (personnages, objets, actions)", "Compte jusqu’à dix (comptine numérique)", "Comprend/construit un récit", "A acquis les règles du langage", "Parle sans déformer les mots"],
        'Socialisation': ["Connaît les prénoms de plusieurs de ses camarades", "Participe à des jeux collectifs en respectant les règles"],
      },
      6.0: {
        'Motricité Globale': ["Saute à cloche pied trois à cinq fois (sur place ou en avançant)", "Court de manière fluide et sait s’arrêter net", "Marche sur les pointes et les talons", "Fait du vélo sans les petites roues (casqué)"],
        'Motricité Fine': ["Ferme seul son vêtement (boutons ou fermeture éclair)", "Touche avec son pouce chacun des doigts de la même main après démonstration", "Copie un triangle", "Est capable de se laver et/ou s’essuier les mains sans assistance", "Dessine un bonhomme en 6 parties (4 membres, tronc, tête)"],
        'Langage oral': ["Peut raconter une petite histoire de manière structurée", "Peut dialoguer en respectant le tour de parole", "Fait des phrases construites (grammaticalement correctes)", "Joue aux contraires par analogie", "Compte jusqu’à 13", "Dénombre treize objets présentés (crayons, jetons, etc.)", "Peut répéter dans l’ordre trois chiffres non sériés (5, 2, 9)", "Reconnaît tous les chiffres (de 0 à 9)"],
        'Socialisation': ["Reconnaît l’état émotionnel d’autrui et réagit de manière ajustée (sait consoler son/sa camarade)", "Maintient son attention environ dix minutes sur une activité qui l’intéresse, sans recadrage"],
      },
    };
    // États pour les cases à cocher
    bool pasAtcdMed = true;
    bool pasAtcdChir = true;
    bool pasAllergie = true;
    bool vaccinsAJour = true;
    bool traitements = true;
    bool pasAtcdPersoPere = true, pasAtcdFamPere = true;
    bool pasAtcdPersoMere = true, pasAtcdFamMere = true;
    bool pasConsanguinite = true;
    bool hasDemiFreres = false, pasDemiMat = true, pasDemiPat = true;
    bool pasAtcdFratrie = true, grossesseNormale = true, accouchementNormal = true, dvpNormal = true;
    bool imagerieNonFaite = true;
    bool eegNonFait = true;
    bool pasTraitementEssaye = true;
    bool pasSuivi = true;
    bool pasTroubleSommeil = true;
    bool pasTroubleAlim = true; // Par défaut, l'onglet Sommeil est caché   // Pour l'affichage conditionnel de l'onglet Sommeil
    @override
    void initState() {
      super.initState();
      _nomEnfantController.addListener(() {
        _nomPereController.text = _nomEnfantController.text;
      });
    }
  // Remplace l'ancienne logique par votre calcul A4 (moyenne)
  List<double> _getAgesAAfficher() {
    if (ddnEnfant == null) return [];
    
    double a = _calculerAgeMois() / 12.0; // Âge réel en années
    List<double> table = [0.167, 0.333, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0];
    
    // Trouver A2 (l'âge de la table juste en dessous ou égal)
    int indexA2 = table.lastIndexWhere((age) => age <= a);
    
    // Cas où l'enfant est plus jeune que le premier palier ou plus vieux que le dernier
    if (indexA2 == -1) return [0.167, 0.333];
    if (indexA2 >= table.length - 1) return [5.0, 6.0];

    double a2 = table[indexA2];
    double a3 = table[indexA2 + 1];
    double a4 = (a3 + a2) / 2.0;
    return (a >= a4) ? [a2, a3] : [ (indexA2 > 0 ? table[indexA2 - 1] : 0.167), a2 ];
  }

  // Transforme les chiffres en texte lisible pour l'utilisateur
  String _getAgeLabel(double age) {
    if (age < 1.0) return "${(age * 12).round()} mois";
    if (age == 1.5) return "18 mois";
    return "${age.toInt()} ans";
  }
  
 @override
  Widget build(BuildContext context) {
    int ageMois = _calculerAgeMois();
    
    // 1. Définition des conditions de visibilité
    bool afficherSommeil = !pasTroubleSommeil;
    bool afficherDev = ddnEnfant != null && ageMois < 78; // Moins de 6.5 ans

    // 2. Initialisation des listes avec les 3 onglets de base
    List<Tab> mesTabs = [
      const Tab(text: 'Généralités'),
      const Tab(text: 'Antécédents'),
      const Tab(text: 'Histoire'),
    ];

    List<Widget> mesVues = [
      _buildTabGeneral(),
      _buildTabSante(),
      _buildTabHistoire(),
    ];

    // 1. On calcule le nombre d'onglets actifs
    int nbOnglets = 3; // Les 3 de base : Généralités, Antécédents, Histoire
    if (ddnEnfant != null && _calculerAgeMois() < 78) nbOnglets++;
    if (!pasTroubleSommeil) nbOnglets++;

    // 3. Ajout SYNCHRONISÉ des onglets optionnels
    if (afficherDev) {
      // On ajoute le titre ET la vue au même moment
      mesTabs.add(const Tab(text: 'Développement'));
      mesVues.add(_buildTabDeveloppement());
    }

    if (afficherSommeil) {
      // On ajoute le titre ET la vue au même moment
      mesTabs.add(const Tab(text: 'Sommeil'));
      mesVues.add(_buildTabSDSC());
    }

    // 4. Rendu de l'interface
    return DefaultTabController(
      key: ValueKey(nbOnglets), 
      length: nbOnglets, // Maintenant la longueur est garantie correcte
      initialIndex: _ongletSauvegarde,
      child: Scaffold(
        backgroundColor: lightBlueBG,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            toolbarHeight: 140,
            title: Column(
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  'lib/assets/images/logo_chru.png', 
                  height: 60,
                  errorBuilder: (c, e, s) => Icon(Icons.local_hospital, color: blueCHRU, size: 40),
                ),
                const SizedBox(height: 8),
                Text(
                  "Préparation de la consultation de neurologie pédiatrique",
                  style: TextStyle(color: blueCHRU, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            bottom: TabBar(
              isScrollable: false,
              labelColor: blueCHRU,
              unselectedLabelColor: Colors.grey,
              indicatorColor: blueCHRU,
              tabs: [
                const Tab(text: "Généralités"),
                const Tab(text: "Antécédents"),
                const Tab(text: "Histoire"),
                if (ddnEnfant != null && _calculerAgeMois() < 78) const Tab(text: "Développement"),
                if (!pasTroubleSommeil) const Tab(text: "Sommeil"),
              ],
            ),
          ),
        body: TabBarView(
          children: mesVues,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showQR,
          label: const Text('Générer QR Code', style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.qr_code, color: Colors.white),
          backgroundColor: blueCHRU,
        ),
      ),
    );
  }
  
  int _calculerAgeMois() {
    if (ddnEnfant == null) return 0;
    final maintenant = DateTime.now();
    return (maintenant.year - ddnEnfant!.year) * 12 + maintenant.month - ddnEnfant!.month;
  }
  Widget _buildTabGeneral() {
    return SingleChildScrollView(
      key: const PageStorageKey('tab_general'), // Recommandé pour garder la position du scroll
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // --- CARTE ENFANT ---
        _card('Enfant', Icons.child_care, Column(children: [
          _input('Nom', controller: _nomEnfantController),
          _input('Prénom', controller: _prenomEnfantController),
          _genderRadio(),
          _dateTile('Date de naissance de l\'enfant', ddnEnfant, (d) => setState(() => ddnEnfant = d)),
          _input('Motif de la consultation (raison de la consultation sans détailler)', 
            controller: _motifController, 
            maxLines: 3, 
            hint: 'Ex: retard de developpement, autisme, crise d\'épilepsie...'),
        ])),

        // --- CARTE PÈRE ---
        _card('Père', Icons.person, _parentBlock(
          'Père',
          nomCtrl: _nomPereController,
          prenomCtrl: _prenomPereController,
          metierCtrl: _metierPereController,
          origineCtrl: _originePereController,
          atcdPersoCtrl: _atcdPereController,
          atcdFamCtrl: _atcdFamPereController,
          date: ddnPere,
          onDateChanged: (d) => setState(() => ddnPere = d),
          pasAtcdPerso: pasAtcdPersoPere,
          onAtcdPersoChanged: (v) => setState(() => pasAtcdPersoPere = v!),
          pasAtcdFam: pasAtcdFamPere,
          onAtcdFamChanged: (v) => setState(() => pasAtcdFamPere = v!),
        )),

        // --- CARTE MÈRE ---
        _card('Mère', Icons.person_3, _parentBlock(
          'Mère',
          nomCtrl: _nomMereController,
          prenomCtrl: _prenomMereController,
          metierCtrl: _metierMereController,
          origineCtrl: _origineMereController,
          atcdPersoCtrl: _atcdMereController,
          atcdFamCtrl: _atcdFamMereController,
          date: ddnMere,
          onDateChanged: (d) => setState(() => ddnMere = d),
          pasAtcdPerso: pasAtcdPersoMere,
          onAtcdPersoChanged: (v) => setState(() => pasAtcdPersoMere = v!),
          pasAtcdFam: pasAtcdFamMere,
          onAtcdFamChanged: (v) => setState(() => pasAtcdFamMere = v!),
        )),

        // --- CARTE FAMILLE ---
        _card('Famille', Icons.family_restroom, Column(children: [
          // Utilisation de Transform.scale pour réduire la taille du bouton
          Transform.scale(
            scale: 0.85, // Réduit la taille de 15%
            child: _toggle(
              pasConsanguinite ? 'Pas de lien de parenté entre les parents' : 'Présence d\'un lien de parenté entre les parents',
              pasConsanguinite,
              (v) => setState(() => pasConsanguinite = v!),
            ),
          ),
          // Affichage conditionnel du champ de précision si un lien existe [cite: 67]
          if (!pasConsanguinite) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _input(
                'Précisez le lien (ex: cousins, grand-mères du couple soeurs...)', 
                controller: _precisionConsanguiniteCtrl
              ),
            ),
          const Divider(),
          _fratrieBlock(), 
          const SizedBox(height: 80), // Sécurité pour que le QR Code ne cache pas le contenu 
        ])),
      ]),
    );
  }
  // Fonction qui ouvre l'horloge de Flutter
  Future<void> _choisirHeure(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? heureChoisie = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0), // Heure par défaut
      builder: (context, child) {
        // Force l'affichage au format 24h (évite le format AM/PM américain)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (heureChoisie != null) {
      setState(() {
        // Formate l'heure proprement avec un "h" (ex: 07h30)
        String heures = heureChoisie.hour.toString().padLeft(2, '0');
        String minutes = heureChoisie.minute.toString().padLeft(2, '0');
        controller.text = "${heures}h${minutes}";
      });
    }
  }

  // Le widget de champ texte cliquable
  Widget _timeInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true, // Empêche l'ouverture du clavier normal
        onTap: () => _choisirHeure(context, controller), // Ouvre l'horloge au clic
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time, color: blueCHRU), // Ajoute une icône d'horloge
        ),
      ),
    );
  }
  Widget _buildTabDeveloppement() {
    double ageExact = _calculerAgeMois() / 12.0;
    int anneePrincipale = ageExact.floor();
    int anneeSecondaire = (ageExact - anneePrincipale < 0.5) ? anneePrincipale - 1 : anneePrincipale + 1;

    List<int> anneesAffichage = [anneePrincipale, anneeSecondaire]..sort();
    anneesAffichage = anneesAffichage.where((a) => a >= 2 && a <= 6).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Évaluation du Développement", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: blueCHRU)),
          const SizedBox(height: 8),
          const Text("Veuillez cocher les acquisitions maîtrisées par l'enfant.",
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
          const SizedBox(height: 16),

          if (anneesAffichage.isEmpty)
            const Text("L'évaluation détaillée par domaines est disponible pour les enfants de 2 à 6 ans."),

          // Appel dynamique des blocs de questions selon l'âge
          ..._getAgesAAfficher().map((double age) => _buildYearSection(age)),
        ],
      ),
    );
  }

Widget _buildYearSection(double age) {
    // On utilise le helper pour transformer 0.167 en "2 mois" ou 3.0 en "3 ans"
    final String labelAge = _getAgeLabel(age);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête de la section (ex: Acquisitions attendues à 6 mois)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: blueCHRU,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              "Acquisitions attendues à $labelAge", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
          
          // Parcours des domaines (Motricité, Langage, etc.) pour cet âge
          ...(_milestonesData[age] ?? {}).entries.map((domaine) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sous-titre du domaine (ex: Motricité Fine)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  // Utilisation de withOpacity pour la compatibilité ou withValues selon votre version
                  color: blueCHRU.withValues(alpha: 0.05), 
                  child: Text(
                    domaine.key, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: blueCHRU)
                  ),
                ),
                
                // Liste des items avec Checkbox
                ...domaine.value.map((item) => CheckboxListTile(
                  title: Text(item, style: const TextStyle(fontSize: 13)),
                  // La clé de stockage utilise l'âge (double) pour rester unique
                  value: _devChecklist["$age-$item"] ?? false,
                  onChanged: (v) => setState(() => _devChecklist["$age-$item"] = v!),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true, // Pour réduire la taille comme demandé
                  activeColor: blueCHRU,
                )),
              ],
            );
          }),
        ],
      ),
    );
  }
  Widget _buildTabSDSC() {
    int ageMois = _calculerAgeMois();
    
    // Sécurité si la date de naissance n'est pas saisie
    if (ddnEnfant == null) {
      return const Center(
        child: Text("Veuillez saisir la date de naissance dans l'onglet Généralités."),
      );
    }

    bool estPetit = ageMois < 48; // Moins de 4 ans
    int totalQuestions = estPetit ? 22 : 25;

    return CustomScrollView(
      slivers: [
        // --- PARTIE 1 : TOUT CE QUI DÉFILE NORMALEMENT AU-DESSUS ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de l'échelle
                Text(
                  estPetit 
                    ? "Échelle des troubles du sommeil (6 mois à 4 ans)" 
                    : "Échelle des troubles du sommeil (4 à 16 ans)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: blueCHRU),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Basez-vous sur les observations des 6 derniers mois.",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                ),
                const SizedBox(height: 16),

                // SECTION 1 : Infos spécifiques pour les 6 mois - 4 ans
                if (estPetit) _card(
                  'Habitudes de sommeil', 
                  Icons.access_time, 
                  Column(children: [
                    _timeInput("Heure habituelle de coucher", _heureCoucher), // Vérifiez vos noms de variables ici
                    _timeInput("Heure habituelle de lever matinal", _heureLever),
                    _timeInput("Durée approximative des siestes", _dureeSieste),
                    _timeInput("Temps passé éveillé la nuit", _dureeEveilNuit),
                    _input("Nombre de réveils par nuit", controller: _nbReveilNuit),
                    _input("Que faites-vous lors des réveils ?", controller: _actionReveil, maxLines: 2),
                  ])
                ),

                const SizedBox(height: 10),

                // SECTION 2 : Questions 1 et 2 (Durée et Latence)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        _buildSpecialLikert(
                          "Combien d'heures l'enfant dort-il la plupart des nuits ?",
                          1,
                          ["Plus de 9h", "8h à 9h", "7h à 8h", "5h à 7h", "Moins de 5h"],
                        ),
                        _buildSpecialLikert(
                          "Combien de temps après sa mise au lit l'enfant met-il habituellement pour s'endormir ?",
                          2,
                          ["< 15 min", "15-30 min", "30-45 min", "45-60 min", "> 60 min"],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 10), // Espace avant l'entête collant
              ],
            ),
          ),
        ),

        // --- PARTIE 2 : L'ENTÊTE QUI SE COLLE EN HAUT (STICKY) ---
        SliverAppBar(
          pinned: true, // Magie : il reste collé en haut !
          floating: false,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Prend la couleur du fond de l'app
          elevation: 2, // Ajoute une petite ombre quand ça défile en dessous
          toolbarHeight: 70, // Hauteur de votre entête (ajustez si besoin)
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Pour s'aligner avec les cartes
            child: _buildFrequencyHeader(),
          ),
        ),

        // --- PARTIE 3 : LES QUESTIONS QUI DÉFILENT ---
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              _genererQuestionsFrequence(estPetit, totalQuestions),
            ),
          ),
        ),

        // --- PARTIE 4 : LE FOOTER (ET LA PROTECTION QR CODE) ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 100.0), // Padding de 100 pour le QR code !
            child: Text(
              "Note : Assurez-vous d'avoir répondu à toutes les lignes pour permettre le calcul du score.",
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }


   Widget _buildTabHistoire() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Section Clinique : Histoire de la maladie
        _card(
          'Histoire de la maladie', 
          Icons.visibility, 
          _input(
            "Détaillez les faits qui font que vous consultez en neurologie pédiatrique en commençant par la date de début", 
            controller: _cliniqueCtrl, 
            maxLines: 5
          )
        ),
        
        // Section Examens & Traitements
        _card('Prise en charge déjà réalisée', Icons.analytics, Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- IMAGERIE AVEC PUCES ---
              Expanded(
                child: _toggle(
                  imagerieNonFaite ? "Imagerie non faite" : "Résultats Imagerie", 
                  imagerieNonFaite, 
                  (v) => setState(() {
                    imagerieNonFaite = v!;
                    if (!v && _imagerieCtrl.text.trim().isEmpty) _imagerieCtrl.text = "• ";
                  }), 
                  controller: _imagerieCtrl, 
                  isBulletList: true, // Activé ici
                  hint: "Date, type d'imagerie, résultats (par exemple: 2024: IRM cérébrale : séquelles de prématurité ou normale...)"),
              ),
              const SizedBox(width: 8),
              // --- EEG AVEC PUCES ---
              Expanded(
                child: _toggle(
                  eegNonFait ? "EEG non fait" : "Résultats EEG", 
                  eegNonFait, 
                  (v) => setState(() {
                    eegNonFait = v!;
                    if (!v && _eegCtrl.text.trim().isEmpty) _eegCtrl.text = "• ";
                  }), 
                  controller: _eegCtrl, 
                  isBulletList: true, // Activé ici
                  hint: "Date, type d'EEG, résultats (par exemple: 2024: EEG de sommeil : pointes centrales droites ou normale...)"
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          // --- TRAITEMENTS ESSAYÉS AVEC PUCES ---
          _toggle(
            pasTraitementEssaye ? "Aucun traitement essayé" : "Traitements essayés", 
            pasTraitementEssaye, 
            (v) => setState(() {
              pasTraitementEssaye = v!; 
              if (!v && _traitEssayesCtrl.text.trim().isEmpty) _traitEssayesCtrl.text = "• "; 
            }), 
            controller: _traitEssayesCtrl, 
            isBulletList: true, // Déjà activé
            hint: "Détaillez les traitements essayés, leur efficacité et les éventuels effets secondaires"
          ),
        ])),

        // Section Vie Quotidienne
        _card('Scolarité & Suivi', Icons.home, Column(children: [
          _input('Scolarité (classe, présence d\'une aide, niveau dans la classe...)/ mode de garde (à domicile, crèche, école maternelle...))', controller: _scolariteCtrl, maxLines: 2),
          const Divider(),
          _toggle(
            pasSuivi ? "Pas de suivi particulier (orthophonie, CAMSP, CMP...)" : "Suivi(s) en cours orthophonie, CAMSP, CMP...", 
            pasSuivi, 
            (v) => setState(() => pasSuivi = v!), 
            controller: _suiviCtrl, 
            hint: "Précisez l'intervenant et la fréquence des interventions, par exemple: Orthophonie 2 fois par semaine, CAMSP 1 fois par mois..."
          ),
          _toggle(
            pasTroubleSommeil ? "Pas de trouble du sommeil" : "Trouble(s) du sommeil", 
            pasTroubleSommeil, 
            (v) {
              setState(() {
                pasTroubleSommeil = v!;
                _ongletSauvegarde = 2; // <-- ON MÉMORISE : "Je suis sur l'onglet Histoire (index 2)"
              });
            }, 
            controller: _sommeilCtrl, 
            hint: "Précisez (ex: endormissement tardif, réveils...)"
          ),
          _toggle(
            pasTroubleAlim ? "Pas de trouble de l'alimentation" : "Trouble(s) de l'alimentation", 
            pasTroubleAlim, 
            (v) => setState(() => pasTroubleAlim = v!), 
            controller: _alimCtrl, 
            hint: "Précisez (ex: sélectivité, reflux , ne prend pas de morceaux...)"
          ),
        ])),
      ]),
    );
  }
  Widget _buildTabSante() {
    return SingleChildScrollView(
      key: const PageStorageKey('tab_sante'),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // --- BLOC NAISSANCE ---
        _card('Naissance (carnet de santé recommandé)', Icons.pregnant_woman, Column(children: [
          _toggle(
            grossesseNormale ? 'Grossesse normale' : 'Anomalie(s) grossesse',
            grossesseNormale,
            (v) => setState(() => grossesseNormale = v!),
            controller: _grossesseController,
            hint: 'Précisez (ex: diabète gestationnel, menace d\'accouchement prématuré...)',
          ),
          const Divider(),
          CheckboxListTile(
            title: Text(accouchementNormal ? 'Accouchement normal (voie basse, sans aide)' : 'Anomalie(s) accouchement'),
            value: accouchementNormal,
            activeColor: blueCHRU,
            onChanged: (v) => setState(() {
              accouchementNormal = v!;
              if (v) _modeAccouchement = null;
            }),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          if (!accouchementNormal) 
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _modeAccouchementRadio("Naissance par césarienne programmée pour"),
                  _modeAccouchementRadio("Naissance par césarienne en urgence pour"),
                  _modeAccouchementRadio("Naissance déclenchée par voie basse pour"),
                  _modeAccouchementRadio("Naissance spontanée par voie basse avec manœuvres instrumentales pour"),
                  if (_modeAccouchement != null) ...[
                    const SizedBox(height: 10),
                    _input(
                      "Précisez le motif", 
                      controller: _detailAccouchementController,
                    ),
                  ],
                ],
              ),
            ),
          const Divider(),
          _birthGrid(), // Appel de la grille (Terme, Poids, Taille, PC, Apgar)
        ])),

        // --- BLOC ANTÉCÉDENTS ---
        _card('Antécédents & Traitements', Icons.medical_services, Column(children: [
          _toggle(
            pasAtcdMed ? "Aucun antécédent médical" : "Antécédent(s) médicaux", 
            pasAtcdMed, 
            (v) => setState(() {
              pasAtcdMed = v!;
              if (!v && _atcdMedCtrl.text.isEmpty) _atcdMedCtrl.text = "• ";
            }), 
            controller: _atcdMedCtrl, 
            isBulletList: true
          ),
          _toggle(
            pasAtcdChir ? "Aucun antécédent chirurgical" : "Antécédent(s) chirurgicaux", 
            pasAtcdChir, 
            (v) => setState(() {
              pasAtcdChir = v!;
              if (!v && _atcdChirCtrl.text.isEmpty) _atcdChirCtrl.text = "• ";
            }), 
            controller: _atcdChirCtrl, 
            isBulletList: true
          ),
          _toggle(
            pasAllergie ? "Aucune allergie connue" : "Allergie(s) identifiée(s)", 
            pasAllergie, 
            (v) => setState(() => pasAllergie = v!), 
            controller: _allergiesController,
            hint: "Précisez l'allergie et la réaction"
          ),
          _toggle(
            vaccinsAJour ? "Vaccinations à jour" : "Vaccinations non à jour", 
            vaccinsAJour, 
            (v) => setState(() => vaccinsAJour = v!), 
            controller: _vaccinsController,
            hint: "Précisez les vaccins manquants",
          ),
          _toggle(
            traitements ? "Aucun traitement en cours" : "Traitements en cours", 
            traitements, 
            (v) => setState(() {
              traitements = v!;
              if (!v && _traitements.text.isEmpty) _traitements.text = "• ";
            }), 
            controller: _traitements, 
            isBulletList: true, 
            hint: "Un médicament par ligne"
          ),
        ])),

        // --- BLOC DÉVELOPPEMENT ---
        _card('Développement', Icons.trending_up, Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _toggle(dvpNormal ? 'Développement psychomoteur normal' : 'Développement anormal / retardé', 
              dvpNormal, (v) => setState(() => dvpNormal = v!)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("Âge d'acquisition (laissez vide si non acquis) :", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildChampsDeveloppement(), // Liaison des étapes clés
            const Divider(),
            const Text('Latéralité', style: TextStyle(fontWeight: FontWeight.bold)),
            _lateralityRadio(),
          ],
        )),
      ]),
    );
  }

  // --- LOGIQUE PARENTS ---
Widget _parentBlock(
  String label, {
  required TextEditingController nomCtrl,
  required TextEditingController prenomCtrl,
  required TextEditingController metierCtrl,
  required TextEditingController origineCtrl,
  required TextEditingController atcdPersoCtrl,
  required TextEditingController atcdFamCtrl,
  required DateTime? date,
  required Function(DateTime) onDateChanged,
  required bool pasAtcdPerso,
  required Function(bool?) onAtcdPersoChanged,
  required bool pasAtcdFam,
  required Function(bool?) onAtcdFamChanged,
}) {
  return Column(
    children: [
      _input('Nom ($label)', controller: nomCtrl),
      _input('Prénom ($label)', controller: prenomCtrl),
      _dateTile('Date de naissance ($label)', date, onDateChanged),
      _input('Métier ($label)', controller: metierCtrl),
      _input('Origine géographique', controller: origineCtrl),
      const Divider(),
      _toggle(
        pasAtcdPerso ? 'Pas d\'antécédents personnels ($label)' : 'Présence d\'antécédents personnels ($label)',
        pasAtcdPerso,
        onAtcdPersoChanged,
        controller: atcdPersoCtrl,
        hint: 'Précisez les antécédents (ex: épilepsie, retard...)'
      ),
      _toggle(
        pasAtcdFam ? 'Pas d\'antécédents familiaux ($label)' : 'Présence d\'antécédents familiaux ($label)',
        pasAtcdFam,
        onAtcdFamChanged,
        controller: atcdFamCtrl,
        hint: 'Précisez les antécédents familiaux du côté du $label'
      ),
    ],
  );
}

  Widget _fratrieBlock() {
    return Column(children: [
      // --- RANG ET NOMBRE D'ENFANTS ---
      Row(children: [
        Expanded(
          child: _input('Rang de l\'enfant', controller: _rangController)
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8), 
          child: Text('sur')
        ),
        Expanded(
          child: _input('Nombre total d\'enfants du couple', controller: _nbEnfantsController)
        ),
      ]),

      // --- DEMI-FRÈRES / SŒURS ---
      CheckboxListTile(
        title: const Text('Présence de demi-frères ou sœurs'),
        value: hasDemiFreres,
        activeColor: blueCHRU,
        onChanged: (v) => setState(() => hasDemiFreres = v!),
        controlAffinity: ListTileControlAffinity.leading,
      ),

      if (hasDemiFreres) 
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Column(children: [
            _toggle(
              pasDemiMat ? 'Pas de demi-frère/sœur maternel' : 'Demi-frère(s) et/ou soeur(s) Maternel(s)', 
              pasDemiMat, 
              (v) => setState(() => pasDemiMat = v!), 
              controller: _demiFreresMatController, // Liaison au contrôleur
              hint: 'Précisez (ex: une petite demi-soeur de 2 ans...)'
            ),
            _toggle(
              pasDemiPat ? 'Pas de demi-frère/sœur paternel' : 'Demi-frère(s) et/ou soeur(s) Paternel(s)', 
              pasDemiPat, 
              (v) => setState(() => pasDemiPat = v!), 
              controller: _demiFreresPatController, // Liaison au contrôleur
              hint: 'Précisez (ex: un grand demi-frère...)'
            ),
          ]),
        ),

      // --- ANTÉCÉDENTS FRATRIE ---
      _toggle(
        pasAtcdFratrie ? 'Pas d\'ATCD dans la fratrie' : 'Antécédent(s) dans la fratrie', 
        pasAtcdFratrie, 
        (v) => setState(() => pasAtcdFratrie = v!), 
        controller: _atcdFratrieController, // Liaison au contrôleur
        hint: 'Précisez (ex: grand frère a un autisme léger, épilepsie...)'
      ),
    ]);
  }

  // --- HELPERS UI ---
  Widget _card(String t, IconData i, Widget c) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: blueCHRU.withValues(alpha:0.1))),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(i, color: blueCHRU), const SizedBox(width: 8), Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: blueCHRU))]),
      const SizedBox(height: 12),
      c,
    ])),
  );

  Widget _modeAccouchementRadio(String title) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: title,
      groupValue: _modeAccouchement,
      activeColor: blueCHRU,
      onChanged: (v) => setState(() => _modeAccouchement = v),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _input(
    String label, {
    TextEditingController? controller,
    int maxLines = 1, // <-- Le "= 1" est CRUCIAL ici pour éviter l'erreur Null
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _dateTile(String l, DateTime? d, Function(DateTime) onP) => ListTile(
    title: Text(d == null ? l : '$l : ${DateFormat('dd/MM/yyyy', 'fr_FR').format(d)}'), // Formatage FR
    trailing: Icon(Icons.calendar_month, color: blueCHRU),
    onTap: () async {
      DateTime? p = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        locale: const Locale('fr', 'FR'), // Calendrier en français
      );
      if (p != null) onP(p);
    },
  );

  Widget _toggle(
    String label,
    bool value,
    Function(bool?) onChanged, {
    TextEditingController? controller,
    String? hint,
    bool isBulletList = false, // <-- Ajout de ce paramètre
  }) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(label, style: const TextStyle(fontSize: 14)),
          value: value,
          onChanged: onChanged,
          activeThumbColor: blueCHRU,
        ),
        // On affiche le champ de texte si la condition est remplie (ex: "Présence d'ATCD")
        if (!value && controller != null) 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _input(
              hint ?? "Précisez...",
              controller: controller,
              maxLines: 3, // Correction de l'erreur int : on donne une valeur fixe
            ),
          ),
      ],
    );
  }

  Widget _birthGrid() {
    return Column(
      children: [
        _input('Terme de naissance (SA)', controller: _termeSAController, keyboardType: TextInputType.number),
        Row(children: [
          Expanded(child: _input('Poids (g)', controller: _poidsController, keyboardType: TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(child: _input('Taille (cm)', controller: _tailleController, keyboardType: TextInputType.number)),
        ]),
        Row(children: [
          Expanded(child: _input('PC (cm)', controller: _pcController, keyboardType: TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(child: _input('Apgar 1 min', controller: _apgar1Controller, keyboardType: TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(child: _input('Apgar 5 min', controller: _apgar5Controller, keyboardType: TextInputType.number)),
        ]),
      ],
    );
  }
  Widget _genderRadio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        const Text('Sexe : ', style: TextStyle(fontWeight: FontWeight.bold)),
        // ignore: deprecated_member_use
        Expanded(child: RadioListTile(title: const Text('Masculin'), value: 'Masculin', groupValue: sexe, activeColor: blueCHRU, onChanged: (v) => setState(() => sexe = v.toString()))),
        // ignore: deprecated_member_use
        Expanded(child: RadioListTile(title: const Text('Féminin'), value: 'Féminin', groupValue: sexe, activeColor: blueCHRU, onChanged: (v) => setState(() => sexe = v.toString()))),
      ]),
    );
  }

  Widget _lateralityRadio() => Wrap(children: ['droitier', 'gaucher', 'ambidextre', 'inconnue'].map((v) => Row(mainAxisSize: MainAxisSize.min, children: [Radio(value: v, activeColor: blueCHRU, groupValue: lateralite, onChanged: (val) => setState(() => lateralite = val.toString())), Text(v)])).toList());

  // --------------------------------------------------------
  // FONCTION 1 : LA CRÉATION ET L'AFFICHAGE DE LA FENÊTRE
  // --------------------------------------------------------
  void _showQR() {
    int ageMois = _calculerAgeMois();
    bool afficherSommeil = !pasTroubleSommeil;
    bool afficherDev = ddnEnfant != null && ageMois < 78;

    // 1. Préparation des données
    Map<String, dynamic> dataPourQR = {
      'nomEnfant': _nomEnfantController.text,
      // ... ajoutez ici vos autres champs textuels
    };

    if (afficherSommeil) {
      dataPourQR['sommeilSDSC'] = _sdscResponses;
    }

    if (afficherDev) {
      StringBuffer devBinaire = StringBuffer();
      _milestonesData.forEach((age, domaines) {
        domaines.forEach((domaine, items) {
          for (String item in items) {
            bool isChecked = _devChecklist["$age-$item"] ?? false;
            devBinaire.write(isChecked ? '1' : '0');
          }
        });
      });
      dataPourQR['dev'] = devBinaire.toString();
    }

    // 2. Conversion et Chiffrement
    String jsonString = jsonEncode(dataPourQR);
    final key = enc.Key.fromUtf8('ChruNeuroPed2026_ClefSecrete_32c'); 
    final iv = enc.IV.fromUtf8('ChruNeuroPedIV16');
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    String qrDataSecurisee = encrypted.base64;

    // 3. Affichage de la fenêtre moderne avec le bouton
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche de fermer en cliquant à côté
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Questionnaire terminé !', 
          textAlign: TextAlign.center, 
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Ce QR Code contient vos réponses de manière sécurisée.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // --- LE QR CODE PRÊT À ÊTRE PHOTOGRAPHIÉ ---
              RepaintBoundary(
                key: _qrKey, // La fameuse clé pour le cibler
                child: Container(
                  color: Colors.white, // Fond blanc obligatoire pour la photo
                  padding: const EdgeInsets.all(16.0),
                  child: QrImageView(
                    data: qrDataSecurisee,
                    version: QrVersions.auto,
                    size: 220.0,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- LE BOUTON DE PARTAGE MMS/MAIL ---
              ElevatedButton.icon(
                onPressed: _partagerQRCode,
                icon: const Icon(Icons.send_to_mobile, size: 24),
                label: const Text("Envoyer par SMS / E-mail", style: TextStyle(fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueCHRU, // Votre bleu
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              
              const SizedBox(height: 15),
              const Text(
                "Ou faites une capture d'écran pour la montrer lors de la consultation.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // FONCTION 2 : LA MAGIE DU PARTAGE (Capture et Envoi)
  // --------------------------------------------------------
  Future<void> _partagerQRCode() async {
    try {
      // On récupère le nom saisi pour le mettre dans le message
      String nom = _nomEnfantController.text.trim();
      String prenom = _prenomEnfantController.text.trim();
      String identite = (nom.isNotEmpty || prenom.isNotEmpty) ? "$prenom $nom" : "mon enfant";

      // On photographie le QR Code (grâce au RepaintBoundary)
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      
      // On convertit en fichier image PNG
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // On ouvre le menu du téléphone (Messages, Mail, etc.)
      await Share.shareXFiles(
        [XFile.fromData(pngBytes, name: 'QR_Code_Neurologie.png', mimeType: 'image/png')],
        text: 'Bonjour, voici le QR Code du questionnaire de Neurologie Pédiatrique pour $identite.',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez patienter que le QR code s'affiche complètement.")),
      );
    }
  }

  Widget _buildChampsDeveloppement() {
    int ageMois = _calculerAgeMois();
    if (ddnEnfant == null) return const Text("Veuillez saisir la date de naissance de l'enfant.");

    return Column(children: [
      if (ageMois >= 8) _input("Tenue assise sans appui (en mois)", controller: _assisCtrl),
      if (ageMois >= 15) _input("Âge de la marche (en mois)", controller: _marcheCtrl),
      if (ageMois >= 18) _input("Premiers mots (en mois)", controller: _motsCtrl),
      if (ageMois >= 30) ...[
        _input("Propreté acquise à (en mois/ans)", controller: _propreteCtrl),
      ],
    ]);
  }
  Widget _buildFrequencyHeader() {
    List<String> headers = ["Jamais", "Rarement", "Parfois", "Souvent", "Toujours"];
    List<String> subHeaders = ["", "1-3 f/mois", "1-2 f/sem", "3-5 f/sem", "Tous les j."];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: blueCHRU.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(flex: 5, child: SizedBox()), // Espace pour la question
          ...List.generate(5, (i) => Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(headers[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: blueCHRU)),
                Text(subHeaders[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey,fontWeight: FontWeight.bold,)),
              ],
            ),
          )),
        ],
      ),
    );
  }
// 3. Ligne de réponse "Zebra" et alignement parfait[cite: 1, 2]
  Widget _buildLikertRow(String question, int index) {
    bool isEven = index % 2 == 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : lightBlueBG.withValues(alpha:0.3),
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha:0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5, 
            child: Text("$index. $question", style: const TextStyle(fontSize: 13, color: Colors.black87))
          ),
          ...List.generate(5, (i) => Expanded(
            flex: 2,
            child: Center(
              child: Radio<int>(
                value: i + 1,
                groupValue: _sdscResponses[index],
                activeColor: blueCHRU,
                onChanged: (v) => setState(() => _sdscResponses[index] = v),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // Spécial Q1 et Q2 avec en-têtes intégrés[cite: 1, 2]
  Widget _buildSpecialLikert(String question, int index, List<String> labels) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Row(
          children: [
            const Expanded(flex: 5, child: SizedBox()),
            ...labels.map((l) => Expanded(
              flex: 2,
              child: Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: blueCHRU.withValues(alpha:0.8))),
            )),
          ],
        ),
        _buildLikertRow(question, index),
      ],
    );
  }

  // 4. Libellés officiels complets[cite: 1, 2]
  List<Widget> _genererQuestionsFrequence(bool estPetit, int total) {
    // Liste pour les enfants de 4 à 16 ans (Source 1)
    final List<String> labelsGrands = [
      "", "", // Q1 et Q2 gérées par _buildSpecialLikert
      "L'enfant va au lit avec réticence",
      "L'enfant a des difficultés à s'endormir",
      "L'enfant ressent de l'anxiété ou des peurs au moment de s'endormir",
      "Lorsque l'enfant s'endort, il semble vivre ses rêves",
      "L'enfant transpire excessivement à l'endormissement",
      "L'enfant se réveille plus de 2 fois par nuit",
      "L'enfant a des difficultés à s'endormir à nouveau après s'être réveillé dans la nuit",
      "Dans son sommeil, l'enfant a des mouvements brusques ou des secousses des jambes ou il change souvent de position durant la nuit ou encore il jette les couvertures au pied de son lit",
      "L'enfant a des difficultés à respirer durant la nuit",
      "L'enfant fait des pauses respiratoires ou cherche sa respiration pendant son sommeil",
      "L'enfant ronfle",
      "L'enfant transpire excessivement pendant la nuit",
      "Vous avez assisté à un épisode de somnambulisme de l'enfant (il se lève et déambule pendant son sommeil)",
      "Vous avez déjà entendu l'enfant parler dans son sommeil",
      "L'enfant grince des dents pendant son sommeil",
      "L'enfant se réveille en hurlant ou est confus au point qu'il est impossible de l'approcher, mais il n'a aucun souvenir de ces événements le matin suivant",
      "L'enfant fait des cauchemars dont il ne se rappelle pas le matin venu",
      "L'enfant est difficile à réveiller le matin",
      "L'enfant se réveille le matin en se sentant fatigué",
      "L'enfant se sent incapable de bouger quand il se réveille le matin",
      "L'enfant est somnolent durant la journée",
      "L'enfant s'endort brutalement, de façon inattendue, à l'école ou lors de ses activités",
      "Lorsque l'enfant rit, il a une perte de tonus musculaire qui peut entraîner un affaissement du corps ou une chute"
    ];

    // Liste pour les enfants de 6 mois à 4 ans (Source 2)
    final List<String> labelsPetits = [
      "", "", // Q1 et Q2
      "L'enfant va au lit avec réticence",
      "L'enfant a des difficultés à s'endormir",
      "L'enfant ressent de l'anxiété ou des peurs au moment de s'endormir",
      "Lorsque l'enfant s'endort, il semble vivre ses rêves",
      "L'enfant transpire excessivement à l'endormissement",
      "L'enfant se réveille plus de 2 fois par nuit",
      "L'enfant a des difficultés à s'endormir à nouveau après s'être réveillé dans la nuit",
      "Dans son sommeil, l'enfant a des mouvements brusques ou des secousses des jambes ou il change souvent de position durant la nuit ou encore il jette les couvertures au pied de son lit",
      "L'enfant a des difficultés à respirer durant la nuit",
      "L'enfant fait des pauses respiratoires ou cherche sa respiration pendant son sommeil",
      "L'enfant ronfle",
      "L'enfant transpire excessivement pendant la nuit",
      "Vous avez déjà entendu l'enfant parler dans son sommeil",
      "L'enfant se réveille en hurlant ou est confus au point qu'il est impossible de l'approcher, mais il n'a aucun souvenir de ces événements le matin suivant",
      "L'enfant fait des cauchemars dont il ne se rappelle pas le matin venu",
      "L'enfant est difficile à réveiller le matin",
      "L'enfant se réveille le matin en se sentant fatigué",
      "L'enfant se sent incapable de bouger quand il se réveille le matin",
      "L'enfant est somnolent durant la journée",
      "L'enfant s'endort brutalement, de façon inattendue, à l'école ou lors de ses activités"
    ];

    final List<String> currentLabels = estPetit ? labelsPetits : labelsGrands;

    return List.generate(total - 2, (i) {
      int idx = i + 3;
      return _buildLikertRow(currentLabels[idx - 1], idx);
    });
  }
}