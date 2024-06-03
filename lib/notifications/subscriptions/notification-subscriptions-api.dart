import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:bedrive/notifications/subscriptions/notifcation-subscriptions-index-response.dart';
import 'package:bedrive/notifications/subscriptions/notification-subscription.dart';

class NotificationSubscriptionsApi {
  NotificationSubscriptionsApi(this.http);
  final AppHttpClient http;

  Future<List<NotificationSubscription>?> getSubscriptionsFromBackend(int? userId) async {
    final response = NotificationSubscriptionsIndexResponse.fromJson(
        await http.get('/notifications/$userId/subscriptions')
    );
    return response.userSelections;
  }

  Future<dynamic> updateSubscription(int? userId, String notifId, bool? isSubscribed) {
    return http.put(
      '/notifications/$userId/subscriptions',
      {'selections': [{'notif_id': notifId, 'channels': {'mobile': isSubscribed}}]},
    );
  }
}