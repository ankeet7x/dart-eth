import 'dart:convert';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:sdk_app/src/gsnClient/utils.dart';
import 'package:sdk_app/src/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

import '../../contracts/erc20.dart';
import '../../network_config/network_config.dart';

class Permit {
  String name;
  String version;
  int chainId;
  String verifyingContract;
  String owner;
  String spender;
  dynamic value;
  dynamic nonce;
  dynamic deadline;
  String salt;

  Permit({
    required this.name,
    required this.version,
    required this.chainId,
    required this.verifyingContract,
    required this.owner,
    required this.spender,
    required this.value,
    required this.nonce,
    required this.deadline,
    required this.salt,
  });
}

Map<String, dynamic> getTypedPermitTransaction(Permit permit) {
  return {
    'types': {
      'Permit': [
        {'name': 'owner', 'type': 'address'},
        {'name': 'spender', 'type': 'address'},
        {'name': 'value', 'type': 'uint256'},
        {'name': 'nonce', 'type': 'uint256'},
        {'name': 'deadline', 'type': 'uint256'},
      ],
    },
    'primaryType': 'Permit',
    'domain': {
      'name': permit.name,
      'version': permit.version,
      'chainId': permit.chainId,
      'verifyingContract': permit.verifyingContract,
      if (permit.salt != '0x' && permit.salt.isNotEmpty) 'salt': permit.salt,
    },
    'message': {
      'owner': permit.owner,
      'spender': permit.spender,
      'value': permit.value.toString(),
      'nonce': permit.nonce.toString(),
      'deadline': permit.deadline.toString(),
    },
  };
}

Future<Map<String, dynamic>> getPermitEIP712Signature(
  Wallet account,
  String contractName,
  String contractAddress,
  NetworkConfig config,
  int nonce,
  BigInt amount,
  BigInt deadline,
  String salt,
) async {
  // chainId to be used in EIP712
  final chainId = config.gsn.chainId;

  // typed data for signing
  final eip712Data = getTypedPermitTransaction(
    Permit(
      name: contractName,
      version: '1',
      chainId: chainId,
      verifyingContract: contractAddress,
      owner: account.privateKey.address.hex,
      spender: config.gsn.paymasterAddress,
      value: amount.toString(),
      nonce: nonce.toString(),
      deadline: deadline.toString(),
      salt: salt,
    ),
  );

  // signature for metatransaction
  final String signature = EthSigUtil.signTypedData(
      jsonData: jsonEncode(eip712Data), version: TypedDataVersion.V1);

  String r = signature.substring(0, 66); // 66 hex characters for r
  String s = signature.substring(66, 130); // 66 hex characters for s
  int v = int.parse(signature.substring(130, 132),
      radix: 16); // 2 hex characters for v

  printLog("r = $r");
  printLog("s = $s");
  printLog("v = $v");

  return {
    'r': r,
    's': s,
    'v': v,
  };
}

Future<bool> hasPermit(
  Wallet account,
  double amount,
  NetworkConfig config,
  String contractAddress,
  Web3Client provider,
) async {
  try {
    final token = erc20(contractAddress);

    final name = token.abi.name;
    final nonce = await provider.getTransactionCount(token.address);
    final deadline = await getPermitDeadline(provider);
    final eip712Domain = await provider.call(
        contract: token, function: token.function('eip712Domain'), params: []);

    final salt =
        /*5 is hardcoded here because in the erc20 json,
    the salt appears on 5th index in outputs
    of function eip712Domain*/
        eip712Domain[5] as String;

    final decimalAmount =
        EtherAmount.fromBase10String(EtherUnit.ether, amount.toString());

    final signature = await getPermitEIP712Signature(
      account,
      name,
      contractAddress,
      config,
      nonce,
      decimalAmount.getInWei,
      deadline,
      salt,
    );
    provider
        .call(contract: token, function: token.function('name'), params: []);
    await _estimateGasForPermit(
      token,
      EthereumAddress.fromHex(account.privateKey.address.hex),
      EthereumAddress.fromHex(config.gsn.paymasterAddress),
      decimalAmount.getInWei,
      deadline,
      signature['v'],
      signature['r'],
      signature['s'],
      provider,
      EthereumAddress.fromHex(account.privateKey.address.hex),
    );

    return true;
  } catch (e) {
    return false;
  }
}

_estimateGasForPermit(
    DeployedContract token,
    EthereumAddress accountAddress,
    EthereumAddress paymasterAddress,
    BigInt decimalAmount,
    BigInt deadline,
    int v,
    String r,
    String s,
    Web3Client provider,
    EthereumAddress fromAddress) async {
  final function = token.function('permit');
  final args = [
    accountAddress,
    paymasterAddress,
    decimalAmount,
    deadline,
    v,
    r,
    s,
  ];

  // Create a list of arguments to pass to the function
  final data = function.encodeCall(args);
  // Prepare the transaction
  final transaction = Transaction(
    from: fromAddress,
    to: token.address,
    gasPrice: EtherAmount.zero(), // Set the gas price to zero to estimate gas
    data: data,
  );
  // Get the Web3Client instance to estimate the gas

// Estimate the gas required for the transaction
  final gasEstimate = await provider.estimateGas(
    gasPrice: EtherAmount.zero(),
    to: token.address,
    data: data,
    sender: fromAddress,
  );

  return gasEstimate;
}

Future<GsnTransactionDetails> getPermitTx(
  Wallet account,
  EthereumAddress destinationAddress,
  double amount,
  NetworkConfig config,
  String contractAddress,
  Web3Client provider,
) async {
  final token = erc20(contractAddress);
  final name = token.abi.name;
  final nonce = await provider.getTransactionCount(
      EthereumAddress.fromHex(account.privateKey.address.hex));
  final decimals = await provider
      .getBalance(EthereumAddress.fromHex(account.privateKey.address.hex));
  final deadline = await getPermitDeadline(provider);
  final eip712Domain = await provider.call(
      contract: token, function: token.function('eip712Domain'), params: []);

  final salt =
      /*5 is hardcoded here because in the erc20 json,
    the salt appears on 5th index in outputs
    of function eip712Domain*/
      eip712Domain[5] as String;

  final decimalAmount =
      EtherAmount.fromBase10String(EtherUnit.ether, amount.toString());

  final signature = await getPermitEIP712Signature(
    account,
    name,
    contractAddress,
    config,
    nonce.toInt(),
    decimalAmount.getInWei,
    deadline,
    salt,
  );

  final tx = await _estimateGasForPermit(
    token,
    EthereumAddress.fromHex(account.privateKey.address.hex),
    EthereumAddress.fromHex(config.gsn.paymasterAddress),
    decimalAmount.getInWei,
    deadline,
    signature['v'],
    signature['r'],
    signature['s'],
    provider,
    EthereumAddress.fromHex(account.privateKey.address.hex),
  );

  final fromTx = await provider
      .call(contract: token, function: token.function('transferFrom'), params: [
    EthereumAddress.fromHex(account.privateKey.address.hex),
    destinationAddress,
    decimalAmount.getInWei,
  ]);

  final paymasterData =
      '0x${token.address.hex.replaceFirst('0x', '')}${fromTx[1].replaceFirst('0x', '')}';
  //following code is inspired from getFeeData method of
  //abstract-provider of ethers js library
  final EtherAmount gasPrice = await provider.getGasPrice();
  final BigInt maxPriorityFeePerGas = BigInt.parse("1500000000");
  final maxFeePerGas =
      gasPrice.getInWei * BigInt.from(2) + (maxPriorityFeePerGas);

  final gsnTx = GsnTransactionDetails(
    from: account.privateKey.address.hex,
    data: tx.data,
    value: "0",
    to: tx.to.hex,
    gas: tx.gasPrice.getInWei,
    maxFeePerGas: maxFeePerGas.toString(),
    maxPriorityFeePerGas: maxPriorityFeePerGas.toString(),
    paymasterData: paymasterData,
  );

  return gsnTx;
}

// get timestamp that will always be included in the next 3 blocks
Future<BigInt> getPermitDeadline(Web3Client provider) async {
  final block = await provider.getBlockInformation();
  return BigInt.from(
      block.timestamp.add(Duration(seconds: 45)).millisecondsSinceEpoch);
}
