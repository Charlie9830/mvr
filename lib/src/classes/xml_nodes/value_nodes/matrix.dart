import 'package:mvr/src/classes/xml_nodes/base/mvr_value_node.dart';
import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

class MatrixValueNode extends MVRValueNode<MVRMatrix> {
  MatrixValueNode(super.value) : super(tagName: 'Matrix');

  factory MatrixValueNode.from(XmlElement element) {
    return MatrixValueNode(MVRMatrix.fromString(element.innerText));
  }
}

class MVRMatrix {
  final List<List<double>> matrix;

  MVRMatrix(this.matrix);

  const MVRMatrix.identity()
    : matrix = const [
        [1.0, 0, 0],
        [0, 1.0, 0],
        [0, 0, 1.0],
        [0, 0, 0],
      ];

  @override
  String toString() {
    return matrix.map((row) => '{${row.join(',')}}').join('');
  }

  factory MVRMatrix.fromString(String value) {
    final matchCommasAndClosingCurlyBrackets = RegExp(r',|}');
    final matchOpeningBracketsAndWhitespace = RegExp(r'{|\s');

    final rows = value
        .split(matchCommasAndClosingCurlyBrackets)
        .map(
          (dirtyValue) =>
              dirtyValue.replaceAll(matchOpeningBracketsAndWhitespace, ''),
        )
        .slices(4);

    return MVRMatrix(
      rows
          .map((row) => row.map((value) => double.parse(value)).toList())
          .toList(),
    );
  }
}
