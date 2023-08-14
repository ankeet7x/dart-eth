import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

const int kChainId = 80001;
const String kMnemonic =
    "viicous until tail chair involve evolve miracle scan table swarm swing toy";
const String kkeyForStoringMnemonic = "kkeyForStoringMnemonic";
bool isStringEmpty(String? str) {
  if (str == null || str.trim().isEmpty) {
    return true;
  }
  return false;
}

printLog(String msg) {
  print("###@@@###---> $msg");
}

const String kEthereumNetworkUrl =
    "https://polygon-mumbai.infura.io/v3/fc4ab81f4b824f9e9c3bdd065f765afc";

Web3Client getEthClient() {
  var apiUrl = kEthereumNetworkUrl; //Replace with your API
  var httpClient = Client();
  return Web3Client(apiUrl, httpClient);
}
