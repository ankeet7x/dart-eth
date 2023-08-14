import '../utils.dart';

class RelayData {
  IntString maxFeePerGas;
  IntString maxPriorityFeePerGas;
  IntString transactionCalldataGasUsed;
  Address relayWorker;
  Address paymaster;
  PrefixedHexString paymasterData;
  IntString clientId;
  Address forwarder;

  RelayData({
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
    required this.transactionCalldataGasUsed,
    required this.relayWorker,
    required this.paymaster,
    required this.paymasterData,
    required this.clientId,
    required this.forwarder,
  });

  Map<String, dynamic> toJson() {
    return {
      'maxFeePerGas': maxFeePerGas,
      'maxPriorityFeePerGas': maxPriorityFeePerGas,
      'transactionCalldataGasUsed': transactionCalldataGasUsed,
      'relayWorker': relayWorker,
      'paymaster': paymaster,
      'paymasterData': paymasterData,
      'clientId': clientId,
      'forwarder': forwarder,
    };
  }
}
