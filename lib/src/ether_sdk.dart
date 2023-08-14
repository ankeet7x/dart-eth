import 'dart:typed_data';

extension ToString on Uint8List {
  String stringValue() {
    Uint8List uint8List = Uint8List.fromList(this); // Example Uint8List
    String convertedString = String.fromCharCodes(uint8List);
    return convertedString;
  }
}
