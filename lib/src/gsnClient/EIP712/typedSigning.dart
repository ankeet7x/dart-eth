import 'package:web3dart/web3dart.dart';

const Map<String, String> gsnDomainSeparatorType = {
  'prefix': 'string name,string version',
  'version': '3',
};

Map<String, dynamic> getDomainSeparator(
    String name, EthereumAddress verifier, int chainId) {
  return {
    'name': name,
    'version': gsnDomainSeparatorType['version'],
    'chainId': chainId,
    'verifyingContract': verifier.hex,
  };
}

class MessageTypeProperty {
  final String name;
  final String type;

  MessageTypeProperty(this.name, this.type);
}

final List<MessageTypeProperty> eip712DomainType = [
  MessageTypeProperty('name', 'string'),
  MessageTypeProperty('version', 'string'),
  MessageTypeProperty('chainId', 'uint256'),
  MessageTypeProperty('verifyingContract', 'address'),
];

final List<MessageTypeProperty> eip712DomainTypeWithoutVersion = [
  MessageTypeProperty('name', 'string'),
  MessageTypeProperty('chainId', 'uint256'),
  MessageTypeProperty('verifyingContract', 'address'),
];

final List<MessageTypeProperty> relayDataType = [
  MessageTypeProperty('maxFeePerGas', 'uint256'),
  MessageTypeProperty('maxPriorityFeePerGas', 'uint256'),
  MessageTypeProperty('transactionCalldataGasUsed', 'uint256'),
  MessageTypeProperty('relayWorker', 'address'),
  MessageTypeProperty('paymaster', 'address'),
  MessageTypeProperty('forwarder', 'address'),
  MessageTypeProperty('paymasterData', 'bytes'),
  MessageTypeProperty('clientId', 'uint256'),
];

final List<MessageTypeProperty> forwardRequestType = [
  MessageTypeProperty('from', 'address'),
  MessageTypeProperty('to', 'address'),
  MessageTypeProperty('value', 'uint256'),
  MessageTypeProperty('gas', 'uint256'),
  MessageTypeProperty('nonce', 'uint256'),
  MessageTypeProperty('data', 'bytes'),
  MessageTypeProperty('validUntilTime', 'uint256'),
];

final List<MessageTypeProperty> relayRequestType = [
  ...forwardRequestType,
  MessageTypeProperty('relayData', 'RelayData'),
];

class TypedGsnRequestData {
  final Map<String, List<MessageTypeProperty>> types;
  final Map<String, dynamic> domain;
  final String primaryType;
  final Map<String, dynamic> message;

  TypedGsnRequestData(
      String name, int chainId, EthereumAddress verifier, dynamic relayRequest)
      : types = {
          'RelayRequest': relayRequestType,
          'RelayData': relayDataType,
        },
        domain = getDomainSeparator(name, verifier, chainId),
        primaryType = 'RelayRequest',
        message = {
          ...relayRequest['request'],
          'relayData': relayRequest['relayData'],
        };
}
