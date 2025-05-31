import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:url_launcher/url_launcher.dart';

// Generate mock class
@GenerateMocks([UrlLauncherWrapper])
import 'launch_url_test.mocks.dart';

// Wrapper class for testing URL launcher
class UrlLauncherWrapper {
  Future<bool> canLaunch(String url) => canLaunchUrl(Uri.parse(url));
  Future<bool> launch(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

void main() {
  late MockUrlLauncherWrapper mockUrlLauncher;

  setUp(() {
    mockUrlLauncher = MockUrlLauncherWrapper();
  });

  Future<void> _launchURL(BuildContext context, String url, UrlLauncherWrapper launcher) async {
    final Uri uri = Uri.parse(url);
    if (await launcher.canLaunch(url)) {
      await launcher.launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nu s-a putut deschide link-ul: $url")),
      );
    }
  }

  testWidgets('Launches URL successfully', (WidgetTester tester) async {
    const testUrl = 'https://example.com';

    when(mockUrlLauncher.canLaunch(testUrl)).thenAnswer((_) async => true);
    when(mockUrlLauncher.launch(testUrl)).thenAnswer((_) async => true);

    final testWidget = MaterialApp(
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () => _launchURL(context, testUrl, mockUrlLauncher),
            child: Text('Open URL'),
          );
        },
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.tap(find.text('Open URL'));
    await tester.pump();

    verify(mockUrlLauncher.canLaunch(testUrl)).called(1);
    verify(mockUrlLauncher.launch(testUrl)).called(1);
  });

  testWidgets('Shows error message when URL cannot be launched', (WidgetTester tester) async {
    const testUrl = 'https://invalid-url.com';

    when(mockUrlLauncher.canLaunch(testUrl)).thenAnswer((_) async => false);

    final testWidget = MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _launchURL(context, testUrl, mockUrlLauncher),
                  child: Text('Open URL'),
                ),
                Builder(
                  builder: (context) => ScaffoldMessenger(child: Container()),
                ),
              ],
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.tap(find.text('Open URL'));
    await tester.pump();

    expect(find.text('Nu s-a putut deschide link-ul: $testUrl'), findsOneWidget);
    verify(mockUrlLauncher.canLaunch(testUrl)).called(1);
    verifyNever(mockUrlLauncher.launch(testUrl));
  });
}
