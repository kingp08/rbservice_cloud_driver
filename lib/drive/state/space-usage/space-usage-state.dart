import 'package:bedrive/drive/http/app-http-client.dart';
import 'package:bedrive/drive/state/space-usage/space-usage.dart';
import 'package:flutter/material.dart';

class SpaceUsageState extends ChangeNotifier {
  SpaceUsageState(this.http);
  AppHttpClient? http;
  SpaceUsage usage = SpaceUsage();
  
  Future<SpaceUsage> sync() async {
    final response = await http!.get('/user/space-usage');
    usage = SpaceUsage(bytesUsed: response['used'], bytesAvailable: response['available']);
    notifyListeners();
    return usage;
  }
}