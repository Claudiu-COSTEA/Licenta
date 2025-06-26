import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wrestling_app/models/wrestler_weight_category_model.dart';
import 'package:wrestling_app/views/shared/widgets/custom_weight_categories_verification_list.dart';
import 'package:wrestling_app/services/referee_api_services.dart';

class RefereeWeightCategoriesVerification extends StatefulWidget {

  final int competitionUUID;

  const RefereeWeightCategoriesVerification({super.key, required this.competitionUUID});

  @override
  State<RefereeWeightCategoriesVerification> createState() => _RefereeWeightCategoriesVerification();
}

class _RefereeWeightCategoriesVerification extends State<RefereeWeightCategoriesVerification> {

  List<WrestlerWeightCategory> weightCategories = [];
  final RefereeServices _refereeService = RefereeServices();
  late bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAndSetWeightCategories();
  }

  // ✅ Function to fetch weight categories and update state
  Future<void> fetchAndSetWeightCategories() async {
    try {
      List<WrestlerWeightCategory> categories = await _refereeService.fetchWeightCategories(widget.competitionUUID);
      setState(() {
        weightCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching weight categories: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 0.0, right: 16.0, bottom: 16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Lista categorii de greutate',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: CustomWeightCategoriesVerificationList(items: weightCategories, onRefresh: fetchAndSetWeightCategories, competitionUUID: widget.competitionUUID,),
            ),
          ],
        ),
      ),
    );
  }
}
