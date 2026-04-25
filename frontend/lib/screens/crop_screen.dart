import 'package:flutter/material.dart';
import '../localization/translator.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class CropScreen extends StatefulWidget {
  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {

  final nController = TextEditingController();
  final pController = TextEditingController();
  final kController = TextEditingController();
  final tempController = TextEditingController();
  final humidityController = TextEditingController();
  final phController = TextEditingController();
  final rainfallController = TextEditingController();

  bool loading = false;
  String message = "";
  List recommendations = [];

  Future<void> recommendCrop() async {

    try {

      // ---------------- Empty field validation ----------------
      if (nController.text.isEmpty ||
          pController.text.isEmpty ||
          kController.text.isEmpty ||
          tempController.text.isEmpty ||
          humidityController.text.isEmpty ||
          phController.text.isEmpty ||
          rainfallController.text.isEmpty) {

        setState(() {
          message = "Please fill all fields";
        });
        return;
      }

      // ---------------- Numeric validation ----------------
      double? N = double.tryParse(nController.text);
      double? P = double.tryParse(pController.text);
      double? K = double.tryParse(kController.text);
      double? temperature = double.tryParse(tempController.text);
      double? humidity = double.tryParse(humidityController.text);
      double? ph = double.tryParse(phController.text);
      double? rainfall = double.tryParse(rainfallController.text);

      if (N == null ||
          P == null ||
          K == null ||
          temperature == null ||
          humidity == null ||
          ph == null ||
          rainfall == null) {

        setState(() {
          message = "Invalid numeric values";
        });
        return;
      }

      // ---------------- Negative value validation ----------------
      if (N < 0 || P < 0 || K < 0 || temperature < 0 || humidity < 0 || rainfall < 0) {
        setState(() {
          message = "Values cannot be negative";
        });
        return;
      }

      // ---------------- Start loading ----------------
      setState(() {
        loading = true;
        message = "";
        recommendations = [];
      });

      final user = await SessionService.getUser();
      final phone = user["phone"] ?? "";

      final response = await ApiService.recommendCrop(
        phone: phone,
        N: N,
        P: P,
        K: K,
        temperature: temperature,
        humidity: humidity,
        ph: ph,
        rainfall: rainfall,
      );

      setState(() {
        loading = false;
      });

      // ---------------- Handle API response ----------------
      if (response["success"] == true) {

        final data = response["data"];

        setState(() {
          message = data["message"] ?? "";
          recommendations = data["top_5_recommendations"] ?? [];
        });

      } else {

        setState(() {
          message = response["message"] ?? "Server error";
        });

      }

    } catch (e) {

      setState(() {
        loading = false;
        message = "Unexpected error occurred";
      });

    }
  }

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget recommendationList() {

    if (recommendations.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const Text(
          "Top 5 Crop Recommendations",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...recommendations.map((r) {

          return Card(
            child: ListTile(
              title: Text(r["crop"].toString()),
              trailing: Text("${r["confidence"]}%"),
            ),
          );

        }).toList()
      ],
    );
  }

  @override
  void dispose() {
    nController.dispose();
    pController.dispose();
    kController.dispose();
    tempController.dispose();
    humidityController.dispose();
    phController.dispose();
    rainfallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, "crop_recommendation")),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [

            inputField("Nitrogen (N)", nController),
            inputField("Phosphorus (P)", pController),
            inputField("Potassium (K)", kController),
            inputField(t(context, "temperature"), tempController),
            inputField("Humidity", humidityController),
            inputField(t(context, "soil_ph"), phController),
            inputField(t(context, "rainfall"), rainfallController),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : recommendCrop,
              child: loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(t(context, "recommend_crop")),
            ),

            const SizedBox(height: 20),

            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),

            recommendationList()
          ],
        ),
      ),
    );
  }
}