import 'package:mvr/src/classes/xml_nodes/value_nodes/address_value.dart';

class MVRAddress {
  final int breakValue;
  final int globalAddress;

  MVRAddress({required this.globalAddress, this.breakValue = 0});

  factory MVRAddress.fromNode(AddressValueNode node) {
    return MVRAddress(breakValue: node.breakValue, globalAddress: node.value);
  }
}
