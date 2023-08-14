enum RlyEnv {
  local,
}

enum MetaTxMethod {
  Permit,
  ExecuteMetaTransaction,
}

class AccountKeypair {
  final String privateKey;
  final String address;

  AccountKeypair({
    required this.privateKey,
    required this.address,
  });
}

class GsnTransactionDetails {
  // users address
  final String from;
  // tx data
  final String data;
  //contract address
  final String to;

  //ether value
  final String? value;
  //optional gas
  String? gas;

  //should be hex
  String maxFeePerGas;
  //should be hex
  String maxPriorityFeePerGas;
  //paymaster contract address
  final String? paymasterData;

  //Value used to identify applications in RelayRequests.
  final String? clientId;

  // Optional parameters for RelayProvider only:
  /**
   * Set to 'false' to create a direct transaction
   */
  final bool? useGSN;

  GsnTransactionDetails({
    required this.from,
    required this.data,
    required this.to,
    this.value,
    this.gas,
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
    this.paymasterData,
    this.clientId,
    this.useGSN,
  });
}

typedef PrefixedHexString = String;
typedef Address = String;
typedef IntString = String;
