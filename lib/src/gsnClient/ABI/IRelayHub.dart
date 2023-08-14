import 'package:sdk_app/src/gsnClient/ABI/IRelayHubData.dart';
import 'package:web3dart/web3dart.dart';

DeployedContract relayHubContract(String contractAddress) {
  return DeployedContract(
    ContractAbi.fromJson(
      '[{"constant": false,"inputs": ${getIRelayHubData()}]', // Add the ABI of the relay hub contract here
      'relayHub', // Add the contract name here
    ),
    EthereumAddress.fromHex(contractAddress),
  );
}
