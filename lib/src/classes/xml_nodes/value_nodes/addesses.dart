import 'package:mvr/src/classes/xml_nodes/base/mvr_node.dart';
import 'package:mvr/src/classes/xml_nodes/base/mvr_value_container.dart';
import 'package:mvr/src/classes/xml_nodes/value_nodes/address_value.dart';
import 'package:xml/xml.dart';

class AddressesValueContainer extends MVRValueContainer<AddressValueNode> {
  AddressesValueContainer(super.values) : super(tagName: 'Addresses');

  factory AddressesValueContainer.from(XmlElement element) {
    return AddressesValueContainer(
      MVRNode.mapChildren(element.childElements).cast<AddressValueNode>(),
    );
  }
}
