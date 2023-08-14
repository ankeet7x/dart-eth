import 'package:sdk_app/src/utils/constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart';

sendTokens(Wallet fromWallet, String toAddress) async {
  final client = getEthClient();
  final fromCredentials = fromWallet.privateKey;

  printLog("Send token from= ${hex.encode(fromCredentials.privateKey)}");
  String result = await client.sendTransaction(
    fromCredentials,
    Transaction(
      to: EthereumAddress.fromHex(toAddress),
      gasPrice: EtherAmount.fromInt(EtherUnit.gwei, 100),
      maxGas: 300000,
      value: EtherAmount.fromBase10String(EtherUnit.gwei, "2000000"),
    ),
    chainId: kChainId,
  );

  printLog("The transaction hash = $result");
}

_estimateGasPrice(String fromHex, String toHex, EtherAmount value) async {
  final client = getEthClient();

  // Estimate the gas required for a transaction.
  final gasEstimate = await client.estimateGas(
    data: null,
    sender: EthereumAddress.fromHex(fromHex),
    to: EthereumAddress.fromHex(toHex),
    value: value,
  );

  // Print the gas estimate.
  print("gasEstimate = $gasEstimate");
}
