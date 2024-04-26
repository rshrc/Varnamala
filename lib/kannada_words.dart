import 'package:words625/utils.dart';

final kannadaJson = {
  "Animal (Prani)": {
    "dog": "naayi",
    "cat": "bekku",
    "fish": "meenu",
    "bird": "hakki",
    "cow": "hasu",
    "pig": "handi",
    "mouse": "illu",
    "horse": "kudure",
    "wing": "rekke",
    "animal": "prani"
  },
  "Transportation (Sagane)": {
    "train": "railu",
    "plane": "vimaana",
    "car": "kaaru",
    "truck": "truck",
    "bicycle": "saikalu",
    "bus": "basu",
    "boat": "hadagu",
    "ship": "hadagu",
    "tire": "taiaru",
    "gasoline": "gyaasolina",
    "engine": "enjin",
    "train ticket": "railu ticket",
    "transportation": "sagane"
  },
  "Location (Sthala)": {
    "city": "nagara",
    "house": "mane",
    "apartment": "aavaraNa",
    "street/road": "raste",
    "airport": "vimana nilaya",
    "train station": "railu nilya",
    "bridge": "sethu",
    "hotel": "hotelu",
    "restaurant": "restorauNt",
    "farm": "krushi",
    "court": "nyayaalaya",
    "school": "shale",
    "office": "kacheri",
    "room": "kamra",
    "town": "ooru",
    "university": "vishwavidyalaya",
    "club": "clubu",
    "bar": "baaru",
    "park": "uuhana",
    "camp": "shibiru",
    "store/shop": "angadi",
    "theater": "rangamane",
    "library": "granthalaya",
    "hospital": "aushadhashaale",
    "church": "devaalaya",
    "market": "maarkattu",
    "country": "desha",
    "building": "bhaavana",
    "ground": "sime",
    "space": "akasha",
    "bank": "baaNku",
    "location": "sthala"
  },
  "Color (Rangha)": {
    "red": "kempu",
    "green": "hasiru",
    "blue": "neeli",
    "yellow": "haladi",
    "brown": "kaapi",
    "pink": "gulabi",
    "orange": "kesari",
    "black": "kappu",
    "white": "bili",
    "gray": "boodu",
    "color": "rangha"
  },
  "People (Janara)": {
    "son": "maga",
    "daughter": "magaLu",
    "mother": "tai",
    "father": "appa",
    "parent": "appa/tai",
    "baby": "koodi",
    "man": "manuShya",
    "woman": "mahilE",
    "brother": "saMbandhi",
    "sister": "sauMbhAgyavati",
    "family": "kutumba",
    "grandfather": "ajja",
    "grandmother": "ajji",
    "husband": "ganda",
    "wife": "hengasu",
    "king": "raaja",
    "queen": "rANi",
    "president": "pradhAna",
    "neighbor": "houdini",
    "boy": "huDuga",
    "girl": "huDugi",
    "child": "maga/magaLu",
    "adult": "vayaskara",
    "human": "manuShya",
    "friend": "snehi",
    "victim": "peetige",
    "player": "aataMDa",
    "fan": "abhimaani",
    "crowd": "jana",
    "person": "vyakti"
  },
  "Job (Vrutti)": {
    "teacher": "guru",
    "student": "vidyArthi",
    "lawyer": "vakeelaru",
    "doctor": "vaidya",
    "patient": "rogi",
    "waiter": "upachaara",
    "secretary": "lekhaka",
    "priest": "pujari",
    "police":
        "policeru", // Singular refers to the force, plural refers to officers
    "army": "sainya",
    "soldier": "sainika",
    "artist": "kalaakaara",
    "author": "lipikaara",
    "manager": "prabandhaka",
    "reporter": "pratinidhi",
    "actor": "naaTaka",
    "job": "uddya"
  },
  "Society (Samaja)": {
    "religion": "mata",
    "heaven": "swarga",
    "hell": "narakha",
    "death": "mrityu",
    "medicine": "aushadha",
    "money": "duddu",
    "dollar": "daallar",
    "bill": "bilu",
    "marriage": "vivaaha",
    "wedding": "maduva",
    "team": "dal",
    "race": "rannaru",
    "sex": "linga", // Can also be "género" (gender) depending on context
    "murder": "hate",
    "prison": "jailu",
    "technology": "tantra",
    "energy": "shakti",
    "war": "yuddha",
    "peace": "shaanti",
    "attack": "hoDike",
    "election": "chunavu",
    "magazine": "patrike",
    "newspaper": "vartapatrike",
    "poison": "visha",
    "gun": "tuppa",
    "sport": "kreedegalu",
    "exercise": "vyayaama",
    "ball": "goli",
    "game": "aata",
    "price": "beleya",
    "contract": "mukhtavaru",
    "drug": "dravya",
    "sign": "sainya", // Can also be "signo" (symbol)
    "science": "vigyaana",
    "God": "daivadhe"
  },
  "Beverages (PānagaLu)": {
    "coffee": "kāphi",
    "tea": "chahā",
    "wine": "vainu",
    "beer": "biyāru",
    "juice": "rasa",
    "water": "neeru",
    "milk": "hālu",
    "beverage": "pānagaLu"
  },
  "Food (Ahaāra)": {
    "egg": "mutta",
    "cheese": "cheese",
    "bread": "bāru",
    "soup": "sāru",
    "cake": "cake",
    "chicken": "kori",
    "pork": "panju",
    "beef": "beef",
    "apple": "sebu",
    "banana": "bāle",
    "orange": "kesari",
    "lemon": "nimbe",
    "corn": "mukka",
    "rice": "akki",
    "oil": "ennu",
    "seed": "beejagalu",
    "knife": "cāku",
    "spoon": "chāma",
    "fork": "pāngi",
    "plate": "pālet",
    "cup": "cappa",
    "breakfast": "tākabāla",
    "lunch": "ōtā",
    "dinner": "dinnara",
    "sugar": "sakkare",
    "salt": "ūppu",
    "bottle": "bootelu",
    "food": "ahaāra"
  },
  "Home (Gruha)": {
    "table": "mejā",
    "chair": "kūru",
    "bed": "hodi",
    "dream": "swapna",
    "window": "kitaki",
    "door": "bāgu",
    "bedroom": "hodi kōṭe",
    "kitchen": "rasōyi",
    "bathroom": "sōndhālya",
    "pencil": "pensil",
    "pen": "pēnu",
    "photograph": "pōṭo",
    "soap": "sōpu",
    "book": "pustaka",
    "page": "pustaka panna",
    "key": "ki",
    "paint": "varṇa",
    "letter": "patrike",
    "note": "nōṭa",
    "wall": "goḍi",
    "paper": "kāgadha",
    "floor": "maṭṭu",
    "ceiling": "maṭṭu kōṭe",
    "roof": "uru",
    "pool": "pūl",
    "lock": "saṅkēta",
    "telephone": "teḷiphoṇ",
    "garden": "upavana",
    "yard": "kandu",
    "needle": "suḷe",
    "bag": "baṅgaḷa",
    "box": "kācha",
    "gift": "bhāgya",
    "card": "patra",
    "ring": "haṇḍi",
    "tool": "sāmagaḷu"
  },
  "Electronics (Vidyut SāmarthyagaLu)": {
    "clock": "gadegal",
    "lamp": "diwāḷa",
    "fan": "fanu",
    "cell phone": "selu phōnu",
    "network": "nēṭavarku",
    "computer": "sangathi",
    "program": "kāryakrama",
    "laptop": "lapṭopa",
    "screen": "drishya",
    "camera": "chāyacitra",
    "television": "darśana",
    "radio": "rādiyo"
  },
  "Body (Deha)": {
    "head": "tale",
    "neck": "kaṇṭha",
    "face": "mukha",
    "beard": "berḍu",
    "hair": "kaiḷi",
    "eye": "kannu",
    "mouth": "bāyi",
    "lip": "bāyaḷu",
    "nose": "mūṅgu",
    "tooth": "hallu",
    "ear": "kivi",
    "tear": "kaṅgaḷu",
    "tongue": "nāḷi",
    "back": "hinde",
    "toe": "bēḷagiya hāvu",
    "finger": "bittu",
    "foot": "kaḷe",
    "hand": "kai",
    "leg": "kaḷe",
    "arm": "bāṇa",
    "shoulder": "bāhu",
    "heart": "hṛdaya",
    "blood": "rakta",
    "brain": "mūrga",
    "knee": "muṭṭāḷu",
    "sweat": "sweda",
    "disease": "roga",
    "bone": "mūḷu",
    "voice": "dhvani",
    "skin": "cara",
    "body": "deha"
  },
  "Nature (Prakṛuti)": {
    "sea": "samudra",
    "ocean": "mahāsāgara",
    "river": "nadī",
    "mountain": "bettada",
    "rain": "male",
    "snow": "hima",
    "tree": "maṭṭu",
    "sun": "sūrya",
    "moon": "candra",
    "world": "loka",
    "Earth": "bhūmi",
    "forest": "aranya",
    "sky": "ākāśa",
    "plant": "sāsu",
    "wind": "gali",
    "soil": "māṭi",
    "flower": "huvu",
    "valley": "gūḍa",
    "root": "muḷu",
    "lake": "kere",
    "star": "tārā",
    "grass": "hululina gidda",
    "leaf": "elu",
    "air": "vāyu",
    "sand": "maṇḍu",
    "beach": "kaḍe",
    "wave": "gūḍa",
    "fire": "beḷaku",
    "ice": "kāya",
    "island": "dvīpa",
    "hill": "kūḍa",
    "heat": "tāpa",
    "nature": "prakṛuti"
  },
  "Materials (Vastugalu)": {
    "glass": "gadi",
    "metal": "loha",
    "plastic": "plāstik",
    "wood": "kattē",
    "stone": "kallu",
    "diamond": "hira",
    "clay": "maaNḍa",
    "dust": "dhūli",
    "gold": "suvarṇa",
    "copper": "tamra",
    "silver": "chandi",
    "material": "vastu"
  },
  "Math/Measurements (Ganita/MāpagaLu)": {
    "meter": "mitar",
    "centimeter": "sēṅtimēṭar",
    "kilogram": "kiḷo gram",
    "inch": "inci",
    "foot": "aduge",
    "pound": "ponḍu",
    "half": "adha",
    "circle": "vṛtta",
    "square": "vargada",
    "temperature": "tāpamāna",
    "date": "dinaāṅk",
    "weight": "tōḷa",
    "edge": "tegē",
    "corner": "kōṇa"
  },
  "Misc Nouns (Bēdagu Sthānigalu)": {
    "map": "nakshe",
    "dot": "bindu",
    "consonant": "vyañjana",
    "vowel": "svara",
    "light": "jōtē",
    "sound": "dhvani",
    "yes": "hōgu",
    "no": "illa",
    "piece": "kōṭi",
    "pain": "nirutsāha",
    "injury": "gāyada",
    "hole": "tuppa",
    "image": "chitra",
    "pattern": "kālavu",
    "noun": "nāma",
    "verb": "kirīṭi",
    "adjective": "gunamatta"
  },
  "Directions (DiguLu)": {
    "top": "mele",
    "bottom": "keLage",
    "side": "bāḷe",
    "front": "munḍa",
    "back": "hinde",
    "outside": "horage",
    "inside": "olage",
    "up": "mele",
    "down": "keLage",
    "left": "bāḷe",
    "right": "dayavi",
    "straight": "nēra",
    "north": "uttara",
    "south": "dakshiṇa",
    "east": "pūrva",
    "west": "pashchima",
    "direction": "dishā"
  },
  "Seasons (Ṛtu)": {
    "Summer": "hagalu",
    "Spring": "vasanta",
    "Winter": "mugulu",
    "Fall": "kaḍagu",
    "season": "ṛtu"
  },
  "Numbers (Sankhyegalu)": {
    "0": "sonne",
    "1": "ondu",
    "2": "eraḍu",
    "3": "mūru",
    "4": "nālku"
  },
  "Months (MāsegaLu)": {
    "January": "jānuvari",
    "February": "phebruvari",
    "March": "mārcu",
    "April": "ēpril",
    "May": "mē",
    "June": "jūni",
    "July": "jūli",
    "August": "āgastu",
    "September": "saptēmbharu",
    "October": "āktōbaru",
    "November": "nōvēmbharu",
    "December": "dīsēmbharu"
  },
  "Days of the Week (ವಾರದ ದಿನಗಳು)": {
    "Monday": "somavara",
    "Tuesday": "mangalavara",
    "Wednesday": "budhavara",
    "Thursday": "guruvara",
    "Friday": "shukravara",
    "Saturday": "shanivara",
    "Sunday": "bhanuvara"
  },
  "Time (ಸಮಯ)": {
    "year": "varsha",
    "month": "mase",
    "week": "vāra",
    "day": "dina",
    "hour": "ghaṇṭe",
    "minute": "nimisha",
    "second": "sekend",
    "morning": "beḷigge",
    "afternoon": "mādhyāhnike",
    "evening": "sāyanka",
    "night": "ratri",
    "time": "samaya"
  },
  "Verbs (ಕ್ರಿಯೆಗಳು)": {
    "work": "kelasa māḍu",
    "play": "ATavADisu",
    "walk": "nade",
    "run": "hogu",
    "drive": "cālana māḍu",
    "fly": "Udu",
    "swim": "neerige",
    "go": "hOgu",
    "stop": "nilisu",
    "follow": "anusarisu",
    "think": "hElu",
    "speak": "mAtanADu",
    "say": "heLu",
    "eat": "tinnu",
    "drink": "kUdhu",
    "kill": "kolli",
    "die": "sAyu",
    "smile": "biLidu muguLisu",
    "laugh": "hAsu",
    "cry": "neeru surisu",
    "buy": "kharidi mADu",
    "pay": "paise mADu",
    "sell": "mArATa mADu",
    "shoot": "goli hAku",
    "learn": "kalitu",
    "jump": "hELu",
    "smell": "sUrisu",
    "hear": "kEli",
    "listen": "gouravi",
    "taste": "rasavannu bhAvisu",
    "touch": "sparsisu",
    "see": "nodu",
    "watch": "nodu",
    "kiss": "muttADu",
    "burn": "dagisu",
    "melt": "Kyaṭa mADu",
    "dig": "karitu",
    "explode": "phatakasada mADu",
    "sit": "kUru",
    "stand": "nillu",
    "love": "prema mADu",
    "pass by": "nillu",
    "cut": "kATa",
    "fight": "jagAlu",
    "lie down": "naDu",
    "dance": "nRtya",
    "sleep": "nidda",
    "wake up": "eDamele",
    "sing": "giTisu",
    "count": "eLe",
    "marry": "maduve mADu",
    "pray": "prArthana mADu",
    "win": "jayisu",
    "lose": "hArADu",
    "mix": "misf mADu",
    "stir": "marini mADu",
    "bend": "kuNi mADu",
    "wash": "tOgi",
    "cook": "uppittu",
    "open": "tola",
    "close": "mUgisu",
    "write": "bare",
    "call": "nAve",
    "turn": "tuLu",
    "build": "nirmaNe mADu",
    "teach": "mElu",
    "grow": "bADu",
    "draw": "citra",
    "feed": "Bukku mADu",
    "catch": "hiDi",
    "throw": "eDeyu",
    "clean": "safAyI mADu",
    "find": "huduku",
    "fall": "biDumu",
    "push": "dhAkini",
    "pull": "hAki",
    "carry": "dayavi",
    "break": "madu",
    "wear": "hAku",
    "hang": "ArukADu",
    "shake": "ArukADu",
    "sign": "nAma haKu",
    "beat": "mukka",
    "lift": "elevate"
  },
  "Adjectives (ವಿಶೇಷಣಗಳು)": {
    "long": "dirgha",
    "short (long)": "kurdu",
    "tall": "unga",
    "short (vs. tall)": "kannu",
    "wide": "Avaru",
    "narrow": "siggu",
    "big": "doddadu",
    "large": "vishAla",
    "small": "sanna",
    "little": "sanna",
    "slow": "vilamba",
    "fast": "begane",
    "hot": "Hottu",
    "cold": "sarige",
    "warm": "tApa",
    "cool": "sunya",
    "new": "hosa",
    "old (new)": "hajara",
    "young": "yuvaka",
    "old (young)": "dina",
    "good": "Olleyadu",
    "bad": "kaDime",
    "wet": "dUra",
    "dry": "sUka",
    "sick": "ArOGya",
    "healthy": "Arogya",
    "loud": "Bhaṣa",
    "quiet": "ALAsa",
    "happy": "santOSa",
    "sad": "duḥkha",
    "beautiful": "sundara",
    "ugly": "kharaBu",
    "deaf": "kaNasu",
    "blind": "andha",
    "nice": "ruchi",
    "mean": "sTairli",
    "rich": "huḍuga",
    "poor": "karuNa",
    "thick": "darpa",
    "thin": "nuNḍu",
    "expensive": "abhimani",
    "cheap": "sasti",
    "flat": "rasa",
    "curved": "innalu",
    "male": "purusha",
    "female": "strI",
    "tight": "tight",
    "loose": "lasagalI",
    "high": "jasti",
    "low": "dina",
    "soft": "komal",
    "hard": "kahiNu",
    "deep": "Gahira",
    "shallow": "geyaLu",
    "clean": "sAdhu",
    "dirty": "maili",
    "strong": "Balasha",
    "weak": "thuTTu",
    "dead": "mRta",
    "alive": "ajIva",
    "heavy": "garvAyta",
    "light (heavy)": "suvarNa",
    "dark": "kaddu",
    "light (dark)": "parisarada"
  },
  "Pronouns (ಸರ್ವನಾಮಗಳು)": {
    "I": "naanu",
    "you (singular)": "nIvu",
    "he": "avanu",
    "she": "avalu",
    "it": "avu",
    "we": "nAve",
    "you (plural, as in 'y'all')": "nimma",
    "they": "avaru"
  }
};

// select random word from flatLangList
final flatKannadaLangList = flattenLanguage(kannadaJson);
