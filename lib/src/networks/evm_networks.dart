import 'package:sdk_app/src/ether_sdk.dart';
import 'package:sdk_app/src/gsnClient/gsnClient.dart';
import 'package:sdk_app/src/gsnClient/gsnTxHelpers.dart';
import 'package:sdk_app/src/gsnClient/network_config/network_config_mumbai.dart';
import 'package:sdk_app/src/gsnClient/utils.dart';
import 'package:sdk_app/src/utils/constants.dart';

import 'package:web3dart/web3dart.dart';

import '../account.dart';
import '../contracts/erc20.dart';
import '../error.dart';
import '../gsnClient/EIP712/MetaTransactions.dart';
import '../gsnClient/EIP712/PermitTransaction.dart';
import '../network_config/network_config.dart';

Future<String> transfer(
  String destinationAddress,
  double amount,
  NetworkConfig network, {
  PrefixedHexString? tokenAddress,
  MetaTxMethod? metaTxMethod,
}) async {
  final account = await AccountsUtil.getInstance().getWallet();

  tokenAddress = tokenAddress ?? network.contracts.rlyERC20;

  if (account == null) {
    throw missingWalletError;
  }

  final sourceBalance = await getBalance(network, tokenAddress: tokenAddress);

  final sourceFinalBalance = sourceBalance - amount;

  if (sourceFinalBalance < 0) {
    throw insufficientBalanceError;
  }

  final ethers = getEthClient();

  GsnTransactionDetails? transferTx;

  if (metaTxMethod != null &&
      (metaTxMethod == MetaTxMethod.Permit ||
          metaTxMethod == MetaTxMethod.ExecuteMetaTransaction)) {
    if (metaTxMethod == MetaTxMethod.Permit) {
      transferTx = await getPermitTx(
        account,
        EthereumAddress.fromHex(destinationAddress),
        amount,
        network,
        tokenAddress,
        ethers,
      );
    } else {
      transferTx = await getExecuteMetatransactionTx(
        account,
        destinationAddress,
        amount,
        network,
        tokenAddress,
        ethers,
      );
    }
  } else {
    final executeMetaTransactionSupported = await hasExecuteMetaTransaction(
        account, destinationAddress, amount, network, tokenAddress, ethers);

    final permitSupported = await hasPermit(
      account,
      amount,
      network,
      tokenAddress,
      ethers,
    );

    if (executeMetaTransactionSupported) {
      transferTx = await getExecuteMetatransactionTx(
        account,
        destinationAddress,
        amount,
        network,
        tokenAddress,
        ethers,
      );
    } else if (permitSupported) {
      transferTx = await getPermitTx(
        account,
        EthereumAddress.fromHex(destinationAddress),
        amount,
        network,
        tokenAddress,
        ethers,
      );
    } else {
      throw transferMethodNotSupportedError;
    }
  }
  return relay(transferTx!, network);
}

Future<double> getBalance(
  NetworkConfig network, {
  PrefixedHexString? tokenAddress,
}) async {
  final account = await AccountsUtil.getInstance().getWallet();
  //if token address use it otherwise default to RLY
  tokenAddress = tokenAddress ?? network.contracts.rlyERC20;
  if (account == null) {
    throw missingWalletError;
  }

  final ethers = getEthClient();

  final token = erc20(tokenAddress);
  // final decimals = await token.decimals();
  final bal = await ethers.getBalance(account.privateKey.address);
  return bal.getValueInUnit(EtherUnit.gwei);
}

Future<String> claimRly(NetworkConfig network) async {
  final account = await AccountsUtil.getInstance().getWallet();

  if (account == null) {
    throw missingWalletError;
  }

  final existingBalance = await getBalance(network);

  if (existingBalance > 0) {
    throw priorDustingError;
  }

  final ethers = getEthClient();

  final claimTx = await GsnUtils().getClaimTx(
      AccountKeypair(
        privateKey: account.privateKey.privateKey.stringValue(),
        address: account.privateKey.address.hex,
      ),
      network,
      ethers);

  return relay(claimTx, network);
}

// This method is deprecated. Update to 'claimRly' instead.
// Will be removed in future library versions.
Future<String> registerAccount(NetworkConfig network) async {
  print("This method is deprecated. Update to 'claimRly' instead.");

  return claimRly(network);
}

Future<String> relay(
  GsnTransactionDetails tx,
  NetworkConfig network,
) async {
  final account = await AccountsUtil.getInstance().getWallet();

  if (account == null) {
    throw missingWalletError;
  }

  return relayTransaction(
      AccountKeypair(
        privateKey: account.privateKey.privateKey.stringValue(),
        address: account.privateKey.address.toString(),
      ),
      mumbaiNetworkConfig,
      tx);
}

dynamic getEvmNetwork(NetworkConfig network) {
  return {
    'transfer': (
      String destinationAddress,
      double amount, {
      PrefixedHexString? tokenAddress,
      MetaTxMethod? metaTxMethod,
    }) {
      return transfer(
        destinationAddress,
        amount,
        network,
        tokenAddress: tokenAddress,
        metaTxMethod: metaTxMethod,
      );
    },
    'getBalance': (PrefixedHexString? tokenAddress) {
      return getBalance(network, tokenAddress: tokenAddress);
    },
    'claimRly': () {
      return claimRly(network);
    },
    // This method is deprecated. Update to 'claimRly' instead.
    // Will be removed in future library versions.
    'registerAccount': () {
      return registerAccount(network);
    },
    'relay': (GsnTransactionDetails tx) {
      return relay(tx, network);
    },
    'setApiKey': (String apiKey) {
      network.relayerApiKey = apiKey;
    },
  };
}
