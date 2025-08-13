import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/modules/others/support/widget/supportWidget.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final _messageController = new TextEditingController();

  final _messageFocusNode = new FocusNode();
  final _searchFocusNode = new FocusNode();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("Support", style: Styles.h4WhiteBold),
      ),
      body: Stack(
        children: [
          supportWidget(
            onSendMessage: () => _onSendMessage(),
            onSearch: (String text) {},
            messageController: _messageController,
            messageFocusNode: _messageFocusNode,
            searchFocusNode: _searchFocusNode,
            onCall: () => callLauncher("tel:${Properties.contactDetails["phone"]}"),
            onWhatsapp: ()  => callLauncher("${Properties.contactDetails["whatsapp"]}"),
            onEmail: () => callLauncher("mailto:${Properties.contactDetails["email"]}"),
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onSendMessage() async {
    _messageFocusNode.unfocus();
    if (_messageController.text.isEmpty) {
      toastContainer(text: "Enter message to continue", backgroundColor: BColors.red);
      return;
    }

    final Email email = Email(
      body: '''
Name: ${userModel!.data!.user!.name}
UserId: ${userModel!.data!.user!.userid}
Phone: ${userModel!.data!.user!.phone}
Email: ${userModel!.data!.user!.email ?? "N/A"}

${_messageController.text}
''',
      subject: '${Properties.titleFull} Mobile Support',
      recipients: [Properties.contactDetails["email"]!],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    setState(() => _isLoading = true);
    await FlutterEmailSender.send(email);
    setState(() => _isLoading = false);
  }
}
