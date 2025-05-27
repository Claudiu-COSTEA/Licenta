import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wrestling_app/views/shared/widgets/custom_wrestlers_verification_list.dart';

import '../../models/wrestler_verification_model.dart';
import '../../services/camera_services.dart';
import '../../services/referee_api_services.dart';

class RefereeWrestlersVerification extends StatefulWidget {

  final String wrestlerStyle;
  final String wrestlerWeightCategory;
  final int competitionUUID;

  const RefereeWrestlersVerification({super.key, required this.wrestlerStyle, required this.wrestlerWeightCategory, required this.competitionUUID});

  @override
  State<RefereeWrestlersVerification> createState() => _RefereeWrestlersVerificationState();
}

class _RefereeWrestlersVerificationState extends State<RefereeWrestlersVerification> {

  late bool _isLoading = false;

  List<WrestlerVerification> wrestlerVerification = [];
  final RefereeServices _refereeService = RefereeServices();


  @override
  void initState() {
    super.initState();
    fetchAndSetWeightCategories();
  }

  // ✅ Function to fetch weight categories and update state
  Future<void> fetchAndSetWeightCategories() async {
    try {
      List<WrestlerVerification> wrestlers = await _refereeService.fetchWrestlers(widget.wrestlerStyle, widget.wrestlerWeightCategory, widget.competitionUUID);
      setState(() {
        wrestlerVerification = wrestlers;
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
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 50.0, right: 16.0, bottom: 16.0),
    child: _isLoading
    ? const Center(child: CircularProgressIndicator())
        : Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
            Text(
              'Lista luptatori - ${widget.wrestlerWeightCategory} Kg',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
            ),

          const SizedBox(width: 50),

          IconButton(
            icon: Icon(Icons.qr_code_scanner, size: 50, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerScreen()),
              );
            },
          ),
        ],
      ),
      Expanded(
        child: CustomWrestlersVerificationList(competitionUUID: widget.competitionUUID, weightCategory: widget.wrestlerWeightCategory, wrestlingStyle: widget.wrestlerStyle,),
      ),
          ],
    ),
    ),
    );
  }
}
