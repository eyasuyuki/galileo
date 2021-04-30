library sqljocky.query_stream_handler;

import 'dart:async';
import 'dart:convert';

import 'package:galileo_sqljocky5/constants.dart';
import 'package:galileo_typed_buffer/galileo_typed_buffer.dart';

import '../handlers/handler.dart';
import '../handlers/ok_packet.dart';

import 'package:galileo_sqljocky5/public/results/row.dart';
import 'package:galileo_sqljocky5/public/results/field.dart';
import 'package:galileo_sqljocky5/public/results/results.dart';

// TODO import 'result_set_header_packet.dart';
import 'package:galileo_sqljocky5/internal/result_parser/standard_data_packet.dart';

class QueryStreamHandler extends HandlerWithResult {
  final String sql;
  int _state = stateHeaderPacket;

  late OkPacket _okPacket;
  // TODO ResultSetHeaderPacket _resultSetHeaderPacket;
  final fieldPackets = <Field>[];

  Map<String, int>? _fieldIndex;

  late StreamController<Row> _streamController;

  final _resultsCompleter = Completer<StreamedResults>();

  QueryStreamHandler(this.sql);

  Uint8List createRequest() {
    var encoded = utf8.encode(sql);
    var buffer = FixedWriteBuffer(encoded.length + 1);
    buffer.byte = COM_QUERY;
    buffer.writeList(encoded);
    return buffer.data;
  }

  HandlerResponse processResponse(ReadBuffer response) {
    var packet = checkResponse(response, false, _state == stateRowPacket);
    if (packet == null) {
      if (response[0] == PACKET_EOF) {
        if (_state == stateFieldPacket) {
          return _handleEndOfFields();
        } else if (_state == stateRowPacket) {
          return _handleEndOfRows();
        }
      } else {
        switch (_state) {
          case stateHeaderPacket:
            _handleHeaderPacket(response);
            break;
          case stateFieldPacket:
            _handleFieldPacket(response);
            break;
          case stateRowPacket:
            _handleRowPacket(response);
            break;
        }
      }
    } else if (packet is OkPacket) {
      return _handleOkPacket(packet);
    }
    return HandlerResponse();
  }

  @override
  Future<StreamedResults> get streamedResults => _resultsCompleter.future;

  _handleEndOfFields() {
    _state = stateRowPacket;
    _streamController = StreamController<Row>(onCancel: () {
      _streamController.close();
    });
    this._fieldIndex = createFieldIndex();
    var stream = StreamedResults(null, null, fieldPackets, stream: _streamController.stream);
    _resultsCompleter.complete(stream);
    return HandlerResponse();
  }

  _handleEndOfRows() {
    // the connection's _handler field needs to have been nulled out before
    // the stream is closed, otherwise the stream will be reused in an
    // unfinished state.
    _streamController.close();
    return HandlerResponse(result: _streamController.stream);
  }

  _handleHeaderPacket(ReadBuffer response) {
    // TODO _resultSetHeaderPacket = ResultSetHeaderPacket.fromBuffer(response);
    _state = stateFieldPacket;
  }

  _handleFieldPacket(ReadBuffer response) {
    var fieldPacket = Field.fromBuffer(response);
    fieldPackets.add(fieldPacket);
  }

  _handleRowPacket(ReadBuffer response) {
    List<dynamic> values = parseStandardDataResponse(response, fieldPackets);
    var row = Row(values, _fieldIndex);
    _streamController.add(row);
  }

  _handleOkPacket(packet) {
    _okPacket = packet;

    if ((packet.serverStatus & SERVER_MORE_RESULTS_EXISTS) != 0) {
      // TODO: I think this is to do with multiple queries. Will probably break.
      throw UnsupportedError("Not implemented!");
    }

    //TODO is this finished value right?
    var stream = StreamedResults(_okPacket.insertId, _okPacket.affectedRows, fieldPackets);
    _resultsCompleter.complete(stream);
    return HandlerResponse(result: stream);
  }

  Map<String, int> createFieldIndex() {
    var identifierPattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
    var fieldIndex = Map<String, int>();
    for (var i = 0; i < fieldPackets.length; i++) {
      var name = fieldPackets[i].name!;
      if (identifierPattern.hasMatch(name)) {
        fieldIndex[name] = i;
      }
    }
    return fieldIndex;
  }

  @override
  String toString() => "QueryStreamHandler($sql)";

  static const int stateHeaderPacket = 0;
  static const int stateFieldPacket = 1;
  static const int stateRowPacket = 2;
}
