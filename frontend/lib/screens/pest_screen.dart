import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../localization/translator.dart';
import '../providers/language_provider.dart';

// ─── Localized remedy database ───────────────────────────────────────────────
// Structure: language → pest → field (organic / chemical / prevention / urgency)

const Map<String, Map<String, Map<String, String>>> pestRemediesLocalized = {

  // ── English ──────────────────────────────────────────────────────────────
  "en": {
    "ants": {
      "name": "Ants",
      "organic": "Diatomaceous earth around stem base; cinnamon powder barrier.",
      "chemical": "Chlorpyrifos granules around base.",
      "prevention": "Control aphids nearby; use sticky bands on stems.",
      "urgency": "Low",
    },
    "bees": {
      "name": "Bees",
      "organic": "Relocate hive — bees are BENEFICIAL pollinators, do not kill.",
      "chemical": "None recommended.",
      "prevention": "Plant away from hive; contact local beekeeper if needed.",
      "urgency": "Beneficial",
    },
    "beetles": {
      "name": "Beetles",
      "organic": "Handpick adults; kaolin clay barrier spray.",
      "chemical": "Carbaryl or Malathion as per label.",
      "prevention": "Crop rotation; remove plant debris after harvest.",
      "urgency": "Medium",
    },
    "caterpillars": {
      "name": "Caterpillars",
      "organic": "Bacillus thuringiensis (Bt) spray; neem oil.",
      "chemical": "Spinosad or Chlorpyrifos — follow dosage carefully.",
      "prevention": "Install pheromone traps; inspect leaves weekly.",
      "urgency": "High",
    },
    "earthworms": {
      "name": "Earthworms",
      "organic": "No action needed — earthworms are BENEFICIAL for soil.",
      "chemical": "None — do not apply pesticides.",
      "prevention": "Encourage them: add compost, reduce tilling.",
      "urgency": "Beneficial",
    },
    "earwigs": {
      "name": "Earwigs",
      "organic": "Rolled newspaper traps; diatomaceous earth.",
      "chemical": "Carbaryl dust in evening.",
      "prevention": "Remove garden debris; reduce ground moisture.",
      "urgency": "Low",
    },
    "grasshoppers": {
      "name": "Grasshoppers",
      "organic": "Neem oil spray; attract natural predators like birds.",
      "chemical": "Malathion dust in early morning.",
      "prevention": "Till soil in autumn to expose egg pods.",
      "urgency": "High",
    },
    "moths": {
      "name": "Moths",
      "organic": "Pheromone sticky traps; Bt spray on larvae.",
      "chemical": "Lambda-cyhalothrin for adult control.",
      "prevention": "Seal gaps in storage; install light traps.",
      "urgency": "Medium",
    },
    "slugs": {
      "name": "Slugs",
      "organic": "Beer traps; crushed eggshells around plants.",
      "chemical": "Iron phosphate bait.",
      "prevention": "Remove mulch near base; water in morning only.",
      "urgency": "Low",
    },
    "snails": {
      "name": "Snails",
      "organic": "Copper tape barriers; hand-pick at night.",
      "chemical": "Metaldehyde bait.",
      "prevention": "Reduce moisture around beds; use raised beds.",
      "urgency": "Low",
    },
    "wasps": {
      "name": "Wasps",
      "organic": "Fake nest deterrent; peppermint oil near nests.",
      "chemical": "Pyrethrin aerosol at dusk — wear protection.",
      "prevention": "Seal cracks; cover food outdoors.",
      "urgency": "Medium",
    },
    "weevils": {
      "name": "Weevils",
      "organic": "Beneficial nematodes; diatomaceous earth.",
      "chemical": "Permethrin soil drench.",
      "prevention": "Store grain in sealed containers; inspect regularly.",
      "urgency": "High",
    },
  },

  // ── Telugu ────────────────────────────────────────────────────────────────
  "te": {
    "ants": {
      "name": "చీమలు",
      "organic": "కాండం చుట్టూ డయాటమేషియస్ ఎర్త్ వాడండి; దాల్చిన చెక్క పొడి అడ్డంకి పెట్టండి.",
      "chemical": "కాండం చుట్టూ క్లోర్పైరిఫాస్ గ్రాన్యూల్స్ వేయండి.",
      "prevention": "దగ్గర్లో ఉన్న అఫిడ్‌లను నియంత్రించండి; కాండాలపై స్టికీ బ్యాండ్‌లు వాడండి.",
      "urgency": "తక్కువ",
    },
    "bees": {
      "name": "తేనెటీగలు",
      "organic": "గూడు మారించండి — తేనెటీగలు పరాగ సంపర్కానికి ఉపయోగపడతాయి, చంపవద్దు.",
      "chemical": "సిఫారసు చేయబడలేదు.",
      "prevention": "గూడుకు దూరంగా నాటండి; అవసరమైతే స్థానిక తేనెటీగ నిపుణుడిని సంప్రదించండి.",
      "urgency": "ప్రయోజనకరం",
    },
    "beetles": {
      "name": "బీటిళ్ళు",
      "organic": "పెద్ద పురుగులను చేతితో తొలగించండి; కావోలిన్ క్లే స్ప్రే చేయండి.",
      "chemical": "లేబుల్ ప్రకారం కార్బారిల్ లేదా మాలాతియాన్ వాడండి.",
      "prevention": "పంట మార్పిడి చేయండి; పంట తర్వాత మొక్క వ్యర్థాలు తొలగించండి.",
      "urgency": "మధ్యమం",
    },
    "caterpillars": {
      "name": "శలభపు పిల్లలు",
      "organic": "బాసిల్లస్ తురింజియెన్సిస్ (Bt) స్ప్రే; వేప నూనె వాడండి.",
      "chemical": "స్పైనోసాడ్ లేదా క్లోర్పైరిఫాస్ — మోతాదు జాగ్రత్తగా అనుసరించండి.",
      "prevention": "ఫెరోమోన్ ట్రాప్‌లు పెట్టండి; వారానికోసారి ఆకులు తనిఖీ చేయండి.",
      "urgency": "అధికం",
    },
    "earthworms": {
      "name": "వానపాములు",
      "organic": "చర్య అవసరం లేదు — వానపాములు మట్టికి మేలు చేస్తాయి.",
      "chemical": "వద్దు — పురుగుమందులు వాడవద్దు.",
      "prevention": "వాటిని ప్రోత్సహించండి: కంపోస్ట్ వేయండి, దున్నడం తగ్గించండి.",
      "urgency": "ప్రయోజనకరం",
    },
    "earwigs": {
      "name": "చెవిపురుగులు",
      "organic": "చుట్టిన వార్తాపత్రిక ట్రాప్‌లు వాడండి; డయాటమేషియస్ ఎర్త్ చల్లండి.",
      "chemical": "సాయంత్రం కార్బారిల్ పొడి వాడండి.",
      "prevention": "తోట వ్యర్థాలు తొలగించండి; నేల తేమ తగ్గించండి.",
      "urgency": "తక్కువ",
    },
    "grasshoppers": {
      "name": "మిడతలు",
      "organic": "వేప నూనె స్ప్రే చేయండి; పక్షులను ఆకర్షించండి.",
      "chemical": "తెల్లవారుజామున మాలాతియాన్ పొడి వాడండి.",
      "prevention": "శీతాకాలంలో గుడ్లను తొలగించడానికి మట్టి దున్నండి.",
      "urgency": "అధికం",
    },
    "moths": {
      "name": "చిమ్మట",
      "organic": "ఫెరోమోన్ స్టికీ ట్రాప్‌లు; లార్వాలపై Bt స్ప్రే చేయండి.",
      "chemical": "పెద్ద పురుగుల నియంత్రణకు లాంబ్డా-సైహలోత్రిన్ వాడండి.",
      "prevention": "నిల్వలో సందులు మూయండి; లైట్ ట్రాప్‌లు పెట్టండి.",
      "urgency": "మధ్యమం",
    },
    "slugs": {
      "name": "స్లగ్‌లు",
      "organic": "బీర్ ట్రాప్‌లు; మొక్కల చుట్టూ పగిలిన గుడ్డు పెంకులు వేయండి.",
      "chemical": "ఇనుప ఫాస్ఫేట్ ఎర వాడండి.",
      "prevention": "మొక్క అడుగు దగ్గర మల్చ్ తొలగించండి; ఉదయం మాత్రమే నీళ్ళు పోయండి.",
      "urgency": "తక్కువ",
    },
    "snails": {
      "name": "నత్తగొబ్బులు",
      "organic": "రాగి టేప్ అడ్డంకులు పెట్టండి; రాత్రి చేతితో ఏరండి.",
      "chemical": "మెటాల్డిహైడ్ ఎర వాడండి.",
      "prevention": "మడుల దగ్గర తేమ తగ్గించండి; పెరిగిన మడులు వాడండి.",
      "urgency": "తక్కువ",
    },
    "wasps": {
      "name": "కందిరీగలు",
      "organic": "నకిలీ గూడు నివారకం వాడండి; గూళ్ళ దగ్గర పుదీనా నూనె పెట్టండి.",
      "chemical": "సాయంత్రం పైరెత్రిన్ ఏరోసాల్ — రక్షణ ధరించండి.",
      "prevention": "సందులు మూయండి; బయట తినే పదార్థాలు కప్పండి.",
      "urgency": "మధ్యమం",
    },
    "weevils": {
      "name": "తొలుచు పురుగులు",
      "organic": "ప్రయోజనకర నెమటోడ్‌లు; డయాటమేషియస్ ఎర్త్ వాడండి.",
      "chemical": "పర్మెత్రిన్ మట్టి ద్రావణం వాడండి.",
      "prevention": "ధాన్యం మూసిన పాత్రలలో నిల్వ చేయండి; క్రమం తప్పకుండా తనిఖీ చేయండి.",
      "urgency": "అధికం",
    },
  },

  // ── Hindi ─────────────────────────────────────────────────────────────────
  "hi": {
    "ants": {
      "name": "चींटियाँ",
      "organic": "तने के आधार पर डायटोमेशियस अर्थ; दालचीनी पाउडर की अवरोधक पट्टी लगाएं।",
      "chemical": "आधार के चारों ओर क्लोरपाइरिफोस ग्रेन्यूल्स डालें।",
      "prevention": "नजदीकी एफिड्स को नियंत्रित करें; तनों पर चिपचिपे बैंड लगाएं।",
      "urgency": "कम",
    },
    "bees": {
      "name": "मधुमक्खियाँ",
      "organic": "छत्ता हटाएं — मधुमक्खियाँ परागण के लिए उपयोगी हैं, इन्हें न मारें।",
      "chemical": "अनुशंसित नहीं।",
      "prevention": "छत्ते से दूर पौधे लगाएं; जरूरत हो तो स्थानीय मधुमक्खी पालक से संपर्क करें।",
      "urgency": "लाभकारी",
    },
    "beetles": {
      "name": "भृंग",
      "organic": "वयस्कों को हाथ से हटाएं; काओलिन क्ले बाधा स्प्रे करें।",
      "chemical": "लेबल के अनुसार कार्बेरिल या मैलाथियन का उपयोग करें।",
      "prevention": "फसल चक्र अपनाएं; कटाई के बाद पौधों का मलबा हटाएं।",
      "urgency": "मध्यम",
    },
    "caterpillars": {
      "name": "इल्लियाँ",
      "organic": "बेसिलस थुरिंजिएंसिस (Bt) स्प्रे; नीम का तेल लगाएं।",
      "chemical": "स्पिनोसैड या क्लोरपाइरिफोस — खुराक सावधानी से लें।",
      "prevention": "फेरोमोन ट्रैप लगाएं; साप्ताहिक पत्तियों की जांच करें।",
      "urgency": "अधिक",
    },
    "earthworms": {
      "name": "केंचुए",
      "organic": "कोई कार्रवाई नहीं — केंचुए मिट्टी के लिए लाभदायक हैं।",
      "chemical": "नहीं — कीटनाशक न लगाएं।",
      "prevention": "इन्हें प्रोत्साहित करें: खाद डालें, जुताई कम करें।",
      "urgency": "लाभकारी",
    },
    "earwigs": {
      "name": "कान की मक्खी",
      "organic": "लुढ़के हुए अखबार के ट्रैप; डायटोमेशियस अर्थ छिड़कें।",
      "chemical": "शाम को कार्बेरिल धूल डालें।",
      "prevention": "बगीचे का मलबा हटाएं; जमीन की नमी कम करें।",
      "urgency": "कम",
    },
    "grasshoppers": {
      "name": "टिड्डे",
      "organic": "नीम तेल स्प्रे करें; पक्षियों को आकर्षित करें।",
      "chemical": "सुबह-सुबह मैलाथियन धूल डालें।",
      "prevention": "अंडे के समूह उजागर करने के लिए शरद ऋतु में मिट्टी जोतें।",
      "urgency": "अधिक",
    },
    "moths": {
      "name": "पतंगे",
      "organic": "फेरोमोन चिपचिपे ट्रैप; लार्वा पर Bt स्प्रे करें।",
      "chemical": "वयस्क नियंत्रण के लिए लैम्बडा-साइहेलोथ्रिन।",
      "prevention": "भंडारण में दरारें बंद करें; लाइट ट्रैप लगाएं।",
      "urgency": "मध्यम",
    },
    "slugs": {
      "name": "स्लग",
      "organic": "बीयर ट्रैप; पौधों के आसपास कुचले अंडे के छिलके बिछाएं।",
      "chemical": "आयरन फॉस्फेट चारा रखें।",
      "prevention": "आधार के पास मल्च हटाएं; केवल सुबह पानी दें।",
      "urgency": "कम",
    },
    "snails": {
      "name": "घोंघे",
      "organic": "तांबे की टेप की बाधाएं; रात में हाथ से उठाएं।",
      "chemical": "मेटाल्डिहाइड चारा रखें।",
      "prevention": "क्यारियों के पास नमी कम करें; उठी हुई क्यारियाँ उपयोग करें।",
      "urgency": "कम",
    },
    "wasps": {
      "name": "ततैया",
      "organic": "नकली घोंसला निवारक; घोंसलों के पास पुदीना तेल रखें।",
      "chemical": "शाम को पाइरेथ्रिन एरोसोल — सुरक्षात्मक कपड़े पहनें।",
      "prevention": "दरारें बंद करें; बाहर खाने को ढककर रखें।",
      "urgency": "मध्यम",
    },
    "weevils": {
      "name": "घुन",
      "organic": "लाभदायक नेमाटोड; डायटोमेशियस अर्थ का उपयोग करें।",
      "chemical": "परमेथ्रिन मिट्टी ड्रेंच करें।",
      "prevention": "अनाज को सीलबंद डिब्बों में रखें; नियमित जांच करें।",
      "urgency": "अधिक",
    },
  },
};

const List<String> _classNames = [
  "ants", "bees", "beetles", "caterpillars", "earthworms", "earwigs",
  "grasshoppers", "moths", "slugs", "snails", "wasps", "weevils"
];

// ─── Screen ──────────────────────────────────────────────────────────────────

class PestScreen extends StatefulWidget {
  @override
  State<PestScreen> createState() => _PestScreenState();
}

class _PestScreenState extends State<PestScreen> {
  static const _channel = MethodChannel('com.example.frontend/tflite');

  File? _selectedImage;
  bool _loading = false;
  bool _modelReady = false;
  String _message = "";
  String? _pestKey;      // internal key e.g. "ants"
  double? _confidence;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final modelData = await rootBundle.load('assets/pest_model.tflite');
      final modelBytes = Uint8List.view(
        modelData.buffer,
        modelData.offsetInBytes,
        modelData.lengthInBytes,
      );
      await _channel.invokeMethod('loadModel', {'modelBytes': modelBytes});
      setState(() => _modelReady = true);
    } catch (e) {
      setState(() => _message = "Model load failed: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 90);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _pestKey = null;
          _confidence = null;
          _message = "";
        });
      }
    } catch (e) {
      setState(() => _message = "Could not pick image: $e");
    }
  }

  Future<void> _runInference() async {
    if (_selectedImage == null) {
      setState(() => _message = t(context, "select_image_first"));
      return;
    }
    if (!_modelReady) {
      setState(() => _message = "Model not ready, please wait.");
      return;
    }

    setState(() {
      _loading = true;
      _message = "";
      _pestKey = null;
      _confidence = null;
    });

    try {
      final rawBytes = await _selectedImage!.readAsBytes();
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) throw Exception("Failed to decode image");
      final resized = img.copyResize(decoded, width: 224, height: 224);

      final floats = Float32List(224 * 224 * 3);
      int idx = 0;
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y);
          floats[idx++] = pixel.r / 255.0;
          floats[idx++] = pixel.g / 255.0;
          floats[idx++] = pixel.b / 255.0;
        }
      }

      final result = await _channel.invokeMethod<Map>('runInference', {
        'inputBytes': floats.buffer.asUint8List(),
      });

      final classIndex = result!['classIndex'] as int;
      final confidence = (result['confidence'] as num).toDouble();

      setState(() {
        _loading = false;
        _pestKey = _classNames[classIndex];
        _confidence = confidence * 100;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _message = "Inference error: $e";
      });
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  Map<String, String>? _remedy(String lang) {
    return (pestRemediesLocalized[lang] ?? pestRemediesLocalized["en"]!)
        [_pestKey];
  }

  String _currentLang() =>
      context.read<LanguageProvider>().language;

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(t(context, "pest_analyzer")),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 16),
            _buildPickerButtons(),
            const SizedBox(height: 16),
            _buildAnalyzeButton(),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
            ],
            if (_pestKey != null) ...[
              const SizedBox(height: 20),
              _buildResultCard(),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 220,
      decoration: AppStyle.glassCard,
      clipBehavior: Clip.antiAlias,
      child: _selectedImage != null
          ? Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bug_report_outlined, size: 64,
                    color: AppColors.primary.withOpacity(0.5)),
                const SizedBox(height: 10),
                Text(
                  t(context, "upload_leaf_image"),
                  style: TextStyle(
                      color: AppColors.primary.withOpacity(0.7), fontSize: 15),
                ),
              ],
            ),
    );
  }

  Widget _buildPickerButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.camera_alt),
            label: Text(t(context, "camera")),
            onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.photo_library),
            label: Text(t(context, "gallery")),
            onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: AppStyle.primaryButton,
        onPressed: _loading ? null : _runInference,
        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(t(context, "analyze_disease"),
                style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildResultCard() {
    final lang = _currentLang();
    final remedy = _remedy(lang);
    if (remedy == null) return const SizedBox();

    final pestName = remedy["name"] ?? _pestKey!;
    final urgency = remedy["urgency"] ?? "Low";
    final confidencePct = _confidence?.toStringAsFixed(1) ?? "—";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyle.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  pestName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _urgencyBadge(urgency, lang),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${t(context, 'confidence')}: $confidencePct%",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const Divider(height: 28),
          _remedySection(
            icon: Icons.eco,
            iconColor: Colors.green[700]!,
            title: t(context, "organic_remedy"),
            body: remedy["organic"]!,
          ),
          const SizedBox(height: 14),
          _remedySection(
            icon: Icons.science,
            iconColor: Colors.blue[700]!,
            title: t(context, "chemical_remedy"),
            body: remedy["chemical"]!,
          ),
          const SizedBox(height: 14),
          _remedySection(
            icon: Icons.shield,
            iconColor: Colors.orange[700]!,
            title: t(context, "prevention"),
            body: remedy["prevention"]!,
          ),
        ],
      ),
    );
  }

  Widget _urgencyBadge(String urgency, String lang) {
    // Urgency label already localized inside the remedy map.
    // Color is derived from the English key stored in "en" map.
    final engUrgency =
        (pestRemediesLocalized["en"]?[_pestKey]?["urgency"]) ?? "Low";
    final colors = {
      "High": Colors.red[600]!,
      "Medium": Colors.orange[600]!,
      "Low": Colors.green[600]!,
      "Beneficial": Colors.blue[600]!,
    };
    return Chip(
      label: Text(urgency,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
      backgroundColor: colors[engUrgency] ?? Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _remedySection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(body,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }
}
