import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:xml/xml.dart';

class AddressValueNode extends MVRValueNode<int> {
  int breakValue;
  AddressValueNode(super.value, {this.breakValue = 0}) : super(tagName: 'Address');

  factory AddressValueNode.from(XmlElement element) {
    final value = element.innerText;

    final asInt = int.tryParse(value.trim());

    if (asInt != null) {
      return AddressValueNode(
        asInt,
        breakValue: int.tryParse(element.getAttribute('break') ?? '-') ?? 0,
      );
    } else {
      final [universe, address] = value.split('.');

      final universeAsInt = int.parse(universe.trim());
      final addressAsInt = int.parse(address.trim());

      return AddressValueNode(
        (universeAsInt * 512) + addressAsInt,
        breakValue: int.tryParse(element.getAttribute('break') ?? '-') ?? 0,
      );
    }
  }
}
