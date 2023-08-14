import 'package:web3dart/web3dart.dart';

import 'IForwarderData.dart';

DeployedContract forwarderContractGetNonceFunction(
    EthereumAddress contractAddress) {
  return DeployedContract(
    //TODO: -> is the second parameter value(i.e. the contract name) correct here?
    //check in other similar files like IRelayHub.dart
    ContractAbi.fromJson(
      '[{"constant": false,"inputs": ${getIForwarderABIData()}]', // Add the ABI of the relay hub contract here
      'getNonce', // Add the contract name here
    ),
    contractAddress,
  );
}
