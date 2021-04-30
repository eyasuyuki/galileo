library sqljocky.prepare_handler;

import 'dart:convert';

import 'package:galileo_typed_buffer/galileo_typed_buffer.dart';

import 'package:galileo_sqljocky5/constants.dart';
import 'package:galileo_sqljocky5/public/exceptions/exceptions.dart';
import '../handlers/handler.dart';
import 'package:galileo_sqljocky5/public/results/field.dart';

import 'prepared_query.dart';
import 'prepare_ok_packet.dart';

export 'prepared_query.dart';

class PrepareHandler extends Handler {
  final String sql;
  PrepareOkPacket? _okPacket;
  int _parametersToRead = 0;
  int _columnsToRead = 0;
  List<Field?>? _parameters;
  List<Field?>? _columns;

  PrepareOkPacket? get okPacket => _okPacket;
  List<Field?>? get parameters => _parameters;
  List<Field?>? get columns => _columns;

  PrepareHandler(this.sql);

  Uint8List createRequest() {
    List<int> encoded = utf8.encode(sql);
    var buffer = FixedWriteBuffer(encoded.length + 1);
    buffer.byte = COM_STMT_PREPARE;
    buffer.writeList(encoded);
    return buffer.data;
  }

  HandlerResponse processResponse(ReadBuffer response) {
    var packet = checkResponse(response, true);
    if (packet == null) {
      if (_parametersToRead > -1) {
        if (response[0] == PACKET_EOF) {
          if (_parametersToRead != 0) {
            throw MySqlProtocolError("Unexpected EOF packet; was expecting another $_parametersToRead parameter(s)");
          }
        } else {
          var fieldPacket = Field.fromBuffer(response);
          _parameters![_okPacket!.parameterCount - _parametersToRead] = fieldPacket;
        }
        _parametersToRead--;
      } else if (_columnsToRead > -1) {
        if (response[0] == PACKET_EOF) {
          if (_columnsToRead != 0) {
            throw MySqlProtocolError("Unexpected EOF packet; was expecting another $_columnsToRead column(s)");
          }
        } else {
          var fieldPacket = Field.fromBuffer(response);
          _columns![_okPacket!.columnCount - _columnsToRead] = fieldPacket;
        }
        _columnsToRead--;
      }
    } else if (packet is PrepareOkPacket) {
      _okPacket = packet;
      _parametersToRead = packet.parameterCount;
      _columnsToRead = packet.columnCount;
      _parameters = List<Field?>.filled(_parametersToRead, null, growable: false);
      _columns = List<Field?>.filled(_columnsToRead, null, growable: false);
      if (_parametersToRead == 0) {
        _parametersToRead = -1;
      }
      if (_columnsToRead == 0) {
        _columnsToRead = -1;
      }
    }

    if (_parametersToRead == -1 && _columnsToRead == -1) {
      return HandlerResponse(result: PreparedQuery(this));
    }
    return HandlerResponse();
  }
}
