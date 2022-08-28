import 'package:flutter/material.dart';
import 'package:zendesk_plugin/zendesk_plugin.dart';

const zendeskAccountKey = 'GoTJuTZtQOwnMznUNfzw0wN8uU5jWais';
const applicationId = '5d2f484c22b742b9875b9efa375f215b85259160a9dfddb2';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initZendesk();
  }

  Future<void> initZendesk() async {
    if (!mounted) {
      return;
    }
    await Zendesk.initialize(zendeskAccountKey, applicationId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zendesk Chat Plugin'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Initialize  example with proper\nkeys in main.dart',
                  textAlign: TextAlign.center,
                ),
              ),
              MaterialButton(
                onPressed: openChat,
                color: Colors.blueGrey,
                textColor: Colors.white,
                child: const Text('Open Chat'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openChat() async {
    try {
      await Zendesk.setVisitorInfo(
        name: 'Text Client',
        email: 'test+client@example.com',
        phoneNumber: '0000000000',
        department: 'Support',
      );
      await Zendesk.startChat(
        primaryColor: Colors.red,
        messagingName: 'Nameku',
        iosBackButtonTitle: 'Back',
        isPreChatFormEnabled: false,
        isAgentAvailabilityEnabled: false,
        isChatTranscriptPromptEnabled: false,
      );
    } catch (ex) {
      print('An error occured $ex');
    }
  }
}
