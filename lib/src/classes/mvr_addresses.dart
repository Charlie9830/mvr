import 'package:mvr/src/classes/mvr_address.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/addesses.dart';

class MVRAddresses {
  final List<MVRAddress> addresses;

  MVRAddresses({required this.addresses});

  int? get singleGlobalAddress =>
      addresses.length == 1 ? addresses.first.globalAddress : null;

  bool get isEmpty => addresses.isEmpty;

  const MVRAddresses.empty() : addresses = const [];

  factory MVRAddresses.fromNode(AddressesValueContainer node) {
    return MVRAddresses(
      addresses:
          node.values.map((value) => MVRAddress.fromNode(value)).toList(),
    );
  }
}
