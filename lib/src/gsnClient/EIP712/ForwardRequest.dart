import '../utils.dart';

class ForwardRequest {
  Address from;
  Address to;
  IntString value;
  IntString gas;
  IntString nonce;
  PrefixedHexString data;
  IntString validUntilTime;

  ForwardRequest({
    required this.from,
    required this.to,
    required this.value,
    required this.gas,
    required this.nonce,
    required this.data,
    required this.validUntilTime,
  });
  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'value': value,
      'gas': gas,
      'nonce': nonce,
      'data': data,
      'validUntilTime': validUntilTime,
    };
  }
}
