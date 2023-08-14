import 'ForwardRequest.dart';
import 'RelayData.dart';

class RelayRequest {
  ForwardRequest request;
  RelayData relayData;

  RelayRequest({required this.request, required this.relayData});
  Map<String, dynamic> toJson() {
    return {
      'request': request.toJson(),
      'relayData': relayData.toJson(),
    };
  }
}
