import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:sdk_app/src/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

import 'keyManager.dart';

class AccountsUtil {
  static Wallet? _cachedWallet;
  final KeyManager _keyManager;

  AccountsUtil(this._keyManager);

  static final AccountsUtil _instance = AccountsUtil(KeyManagerImpl());

  factory AccountsUtil.getInstance() {
    return _instance;
  }

  Future<String> createAccount({bool overwrite = false}) async {
    final existingWallet = getWallet();

    if (existingWallet != null && !overwrite) {
      throw 'Account already exists';
    }

    final mnemonic = _keyManager.generateMnemonic();
    _keyManager.saveMnemonic(mnemonic);
    final pkey = await _keyManager.makePrivateKeyFromMnemonic(mnemonic);
    final newWallet = _makeWalletFromPrivateKey(pkey);

    _cachedWallet = newWallet;
    printLog("Wallet address is: ${newWallet.privateKey.address.hex}");
    return newWallet.privateKey.address.hex;
  }

  Future<Wallet> getWallet() async {
    if (_cachedWallet != null) {
      return _cachedWallet!;
    }

    final mnemonic = await _keyManager.getMnemonic();

    if (mnemonic == null) {
      throw "Mnemonic can't be null...";
    }

    final pkey = await _keyManager.makePrivateKeyFromMnemonic(mnemonic);
    final wallet = _makeWalletFromPrivateKey(pkey);

    _cachedWallet = wallet;
    return wallet;
  }

  Future<String?> getAccountAddress() async {
    final wallet = await getWallet();
    return wallet.privateKey.address.hex;
  }

  void permanentlyDeleteAccount() {
    _keyManager.deleteMnemonic();
    _cachedWallet = null;
  }

  Future<String?> getAccountPhrase() async {
    try {
      return await _keyManager.getMnemonic();
    } catch (error) {
      return null;
    }
  }

  String signMessage(String message) {
    final wallet = getWallet();

    if (wallet == null) {
      throw 'No account';
    }
    throw UnimplementedError();
    // return wallet.signMessage(message);
  }

  String signTransaction() {
    final wallet = getWallet();
    if (wallet == null) {
      throw 'No account';
    }
    throw UnimplementedError();
    // return wallet.signTransaction(tx);
  }

  String signHash(String hash) {
    final wallet = getWallet();
    if (wallet == null) {
      throw 'No account';
    }
    throw UnimplementedError();

    // final signingKey = utils.SigningKey(wallet.privateKey);
    //
    // return utils.joinSignature(signingKey.signDigest(hash));
  }

  EthPrivateKey getCredentials(String hexCode) {
    return EthPrivateKey.fromHex(hexCode);
  }

  Wallet _makeWalletFromPrivateKey(String pkey) {
    EthPrivateKey credentials = getCredentials(pkey);

    //TODO: What is this password?
    final Wallet newWallet =
        Wallet.createNew(credentials, 'password', Random.secure());

    return newWallet;
  }

  Future<String> getPrivateKeyHex() async {
    final wallet = await getWallet();
    return hex.encode(wallet.privateKey.privateKey);
  }

  Future<EtherAmount> getBalance() async {
    var wallet = await getWallet();
    if (wallet == null) {
      throw 'No account';
    }

    Web3Client client = getEthClient();
    print(wallet.privateKey.address);
    return client.getBalance(wallet.privateKey.address);
  }
}

Uint8List convertStringToUint8List(String str) {
  final List<int> codeUnits = str.codeUnits;
  final Uint8List unit8List = Uint8List.fromList(codeUnits);

  return unit8List;
}
