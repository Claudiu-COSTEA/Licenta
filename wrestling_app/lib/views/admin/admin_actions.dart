import 'package:flutter/material.dart';
import 'package:wrestling_app/services/auth_service.dart';
import 'package:wrestling_app/services/admin_apis_services.dart';

import 'add_competition_screen.dart';
import 'competitions_list_screen.dart';
import 'send_invitation_screen.dart';
import 'prediction_screen.dart';
import 'generate_pdf_screen.dart';

class AdminActions extends StatelessWidget {
  AdminActions({super.key});

  final _auth  = AuthService();
  final _admin = AdminServices();

  // ——— cele 7 definiții scurte ———
  List<_Action> get _items => [
    _Action('Adaugă\ncompetiție',     Icons.add,            (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => AddCompetitionScreen()))),
    _Action('Evidență\ncompetiții',   Icons.list_alt,       (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => CompetitionsListScreen()))),
    _Action('Trimite\ninvitație',     Icons.send,           (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => SendInvitationScreen()))),
    _Action('Predicție',              Icons.analytics,      (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => PredictionScreen()))),
    _Action('Licență\nPDF',           Icons.file_upload,    (_)  => _admin.pickAndUploadLicensePdf()),
    _Action('Medical\nPDF',           Icons.local_hospital, (_)  => _admin.pickAndUploadMedicalPdf()),
    _Action('Generare\nPDF',          Icons.picture_as_pdf, (ctx) => Navigator.push(ctx, MaterialPageRoute(builder: (_) => GeneratePdfScreen()))),
  ];

  static const _primary = Color(0xFFB4182D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _auth.signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,              // ← 3 coloane ➜ 7 carduri intr-un singur ecran
          physics: const NeverScrollableScrollPhysics(), // fără scroll
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,          // ← mai “scund” decât larg (ajustează după gust)
          children: _items.map((a) {
            return GestureDetector(
              onTap: () => a.onTap(context),
              child: Card(
                elevation: 3,
                color: _primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(a.icon, size: 35, color: Colors.white),
                      const SizedBox(height: 6),
                      Text(
                        a.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Action {
  final String    title;
  final IconData  icon;
  final void Function(BuildContext) onTap;
  _Action(this.title, this.icon, this.onTap);
}