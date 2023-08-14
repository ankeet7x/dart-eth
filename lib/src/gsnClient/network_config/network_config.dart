// import '../utils.dart';
// import 'network_config_local.dart';
//
// export 'network_config_local.dart';
// export 'network_config_mumbai.dart';
// export 'network_config_polygon.dart';
//
// class GsnConfig {
//   final PrefixedHexString paymasterAddress;
//   final PrefixedHexString forwarderAddress;
//   final PrefixedHexString relayHubAddress;
//   var PrefixedHexString relayWorkerAddress;
//   final String relayUrl;
//   final String rpcUrl;
//   final IntString chainId;
//   final IntString maxAcceptanceBudget;
//   final String domainSeparatorName;
//   final int gtxDataZero;
//   final int gtxDataNonZero;
//   final int requestValidSeconds;
//   final int maxPaymasterDataLength;
//   final int maxApprovalDataLength;
//   final int maxRelayNonceGap;
//
//   GsnConfig({
//     required this.paymasterAddress,
//     required this.forwarderAddress,
//     required this.relayHubAddress,
//     required this.relayWorkerAddress,
//     required this.relayUrl,
//     required this.rpcUrl,
//     required this.chainId,
//     required this.maxAcceptanceBudget,
//     required this.domainSeparatorName,
//     required this.gtxDataZero,
//     required this.gtxDataNonZero,
//     required this.requestValidSeconds,
//     required this.maxPaymasterDataLength,
//     required this.maxApprovalDataLength,
//     required this.maxRelayNonceGap,
//   });
// }
//
// class NetworkConfig {
//   final Contracts contracts;
//   final GsnConfig gsn;
//   final String? relayerApiKey;
//
//   NetworkConfig({
//     required this.contracts,
//     required this.gsn,
//     this.relayerApiKey,
//   });
// }
