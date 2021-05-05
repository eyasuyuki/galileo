// Copyright (c) 2013-present, Iván Zaera Avellón - izaera@gmail.com

// This library is dually licensed under LGPL 3 and MPL 2.0. See file LICENSE for more information.

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, you can obtain one at http://mozilla.org/MPL/2.0/.

library cipher.test.key_generators.rsa_key_generator_test;

import 'package:bignum/bignum.dart';
import 'package:cipher/cipher.dart';
import "package:cipher/impl/base.dart";

import "../test/src/fixed_secure_random.dart";
import '../test/key_generators_tests.dart';

/// NOTE: the expected results for these tests have been tested "by hand"
void main() {

  initCipher();

  var rnd = new FixedSecureRandom();

  var rsapars = new RSAKeyGeneratorParameters(new BigInteger("65537"), 2048, 12);
  var params = new ParametersWithRandom(rsapars, rnd);

  var keyGenerator = new KeyGenerator("RSA");
  keyGenerator.init(params);

  runKeyGeneratorTests( keyGenerator, [

    _keyPair(
      "24649663692047164444790643172109370056158709234977203368650147515375245495213442567159484352023028564722607846088040100966055452012530635310929880142309672672370384513414361688667706499439717428347689592753696423610988570895714214920908622106527744596538403468957028226105712420419053355165486523922578029360613666994642331140679324765028868432884033287641095549662040120859273059357594690379309402039994712237709233598606723986537440109010028591440539106473660495784943265016397899779881916920074735104005566018575893835392960697074083820748729243932835684709199184189144330411532000389215869317902155568589589990937",
      "65537",
      "4063958011391574405693927086602098714570316817735457564402777727140844524097551717932743769528797833923246071333464657993778005691371187490037648274068938358865404346665886110838985133992189859366415704864484029740707257099473459148578934981171434157279055334880764911165787611618289996529640995025458223709324848295784182981653521435775135990468151575617415377402359600649196585978093468870169020045627061059125356549455475504958158218546129405411183104108490830376537830617352916950230417099192711318868054030047466626509446719907850666657436082569747996909170379147599626458818599142452671385912424304169295269813",
      "172622988945032241272460594823465727338165469761128582817141296878210996104803340949368540074325243384642718754688224642044903791277270607713426667425998282894170126560269953218957312807290242694167112152302773291330789947866948729188625784460892934126377883318018638038433339229978409110366812585246469634979",
      "142794791369857893518216846152178512365742893193381905408671045383524196038880042688222484665321416966726996826180091369625084659347039997384427839884481875048370565094771341455209579084576003589416828973425288956690619644847967193297411322186095969144940769802524422661706293551748267739368517289465924234003"
    ),

  ]);

}

AsymmetricKeyPair _keyPair(String n, String e, String d, String p, String q)
  => new AsymmetricKeyPair(
      new RSAPublicKey(new BigInteger(n), new BigInteger(e)),
      new RSAPrivateKey(new BigInteger(n), new BigInteger(d), new BigInteger(p), new BigInteger(q))
  );