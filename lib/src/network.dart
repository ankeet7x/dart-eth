import 'package:sdk_app/src/gsnClient/utils.dart';
import 'package:sdk_app/src/networks/evm_networks.dart';

import 'network_config/network_config_mumbai.dart';

abstract class Network {
  Future<double> getBalance([String? tokenAddress]);
  Future<String> transfer(String destinationAddress, double amount,
      [String? tokenAddress, MetaTxMethod? metaTxMethod]);
  Future<String> claimRly();
  Future<String> relay(GsnTransactionDetails tx);
  void setApiKey(String apiKey);
}

final Network RlyMumbaiNetwork = getEvmNetwork(MumbaiNetworkConfig);
