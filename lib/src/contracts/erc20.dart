import 'package:web3dart/web3dart.dart';
import 'dart:convert';

import 'erc20Data.dart';

DeployedContract erc20(String contractAddress) {
  final abi = getErc20DataJson()['abi'];
  return DeployedContract(
    ContractAbi.fromJson(
        jsonEncode(abi), 'ERC20'), // Replace 'ERC20' with your contract name
    EthereumAddress.fromHex(contractAddress),
  );
}
