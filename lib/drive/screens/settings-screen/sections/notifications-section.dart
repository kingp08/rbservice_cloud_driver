import 'package:bedrive/auth/auth-state.dart';
import 'package:bedrive/drive/screens/settings-screen/sections/section-title.dart';
import 'package:bedrive/drive/http/backend-error.dart';
import 'package:bedrive/notifications/notification-id.dart';
import 'package:bedrive/notifications/subscriptions/notification-subscriptions-api.dart';
import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:bedrive/drive/dialogs/show-snackbar.dart';
import 'package:bedrive/utils/text.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationSection extends StatefulWidget {
  @override
  _NotificationSectionState createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection> {
  bool syncingToBackend = true;
  late NotificationSubscriptionsApi api;
  int? userId;

  bool? notifyOfSharedFile = true;

  @override
  void initState() {
    super.initState();
    api = NotificationSubscriptionsApi(context.read<AppHttpClient>());
    userId = context.read<AuthState>().currentUser!.id;
    _fetchSubscriptionFromBackend();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(name: 'Push Notifications'),
        CheckboxListTile(
          title: text('Sharing'),
          subtitle: text('When file or folder was shared with you.'),
          onChanged: syncingToBackend ? null : (bool? v) => _toggleNotifSubscription(v),
          value: notifyOfSharedFile,
        )
      ],
    );
  }

  _toggleNotifSubscription(bool? isSubscribed) async {
    setState(() => syncingToBackend = true);
    try {
      await api.updateSubscription(userId, NotificationType.fileShared, isSubscribed);
    } on BackendError catch(_) {
      showSnackBar(trans('Could not update notification settings. Try again later.'), context);
    }
    setState(() {
      notifyOfSharedFile = isSubscribed;
      syncingToBackend = false;
    });
  }

  _fetchSubscriptionFromBackend() async {
    try {
      final response = await api.getSubscriptionsFromBackend(userId);
      if (response != null) {
        notifyOfSharedFile = response.firstWhereOrNull((e) => e.notifId == NotificationType.fileShared)?.channels?.mobile ?? true;
      }
    } on BackendError catch (e) {
      print(e);
    }
    setState(() => syncingToBackend = false);
  }
}