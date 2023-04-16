import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_omise/component/show_title.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:omise_flutter/omise_flutter.dart';

import 'package:http/http.dart' as http;

class Credit extends StatefulWidget {
  const Credit({super.key});

  @override
  State<Credit> createState() => _CreditState();
}

class _CreditState extends State<Credit> {
  // Create variable for store data.
  String? name,
      surname,
      idCard,
      expireDateStr,
      expireDateYear,
      expireDateMonth,
      cvc,
      amount;

  // Decare MaskTextInputFormatter for format text.
  MaskTextInputFormatter idCardMask =
      MaskTextInputFormatter(mask: '#### - #### - #### - ####');

  MaskTextInputFormatter expireDateMask =
      MaskTextInputFormatter(mask: '## / ####');

  MaskTextInputFormatter cvcMask = MaskTextInputFormatter(mask: '###');

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credit Page"),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        behavior: HitTestBehavior.opaque,
        child: Form(
          key: formKey,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // จัดให้ชิดซ้าย.
                children: [
                  buildTitle("Name surname"),
                  buildNameSurname(),
                  buildTitle("ID Card"),
                  formIDcard(),
                  buildExpireDateAndCVC(),
                  buildTitle("Amount"),
                  formAmount(),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [buttonAddMoney()],
              )
            ],
          ),
        ),
      ),
    );
  }

  Container buttonAddMoney() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            getTokenAndChargeOmise();
          }
        },
        child: const Text("Add money"),
      ),
    );
  }

  Future<void> getTokenAndChargeOmise() async {
    String publicKey = 'pkey_test_5vgx0dq1krw72uvsyr8';
    print('Value IDCard: $idCard');
    print('Value ExpireDate: $expireDateMonth/$expireDateYear');
    print('Value CVC: $cvc');
    print('Public Key: $publicKey');

    OmiseFlutter omise = OmiseFlutter(publicKey);
    try {
      await omise.token
          .create('$name $surname', idCard!, expireDateMonth!, expireDateYear!,
              cvc!)
          .then((value) async {
        String token = value.id.toString();
        print(token);

        String secretKey = "skey_test_5vgtd17w5kcgvv6tlbj";
        String url = "https://api.omise.co/charges";
        String basicAuth =
            'Basic ' + base64Encode(utf8.encode(secretKey + ":"));

        Map<String, String> headerMap = {};
        headerMap['Authorization'] = basicAuth;
        headerMap['Cache-Control'] = 'no-cache';
        headerMap['Content-Type'] = 'application/x-www-form-urlencoded';

        String zero = '00';
        amount = '$amount$zero';
        print(amount);

        Map<String, dynamic> data = {};
        data['amount'] = amount;
        data['currency'] = 'thb';
        data['card'] = token;

        Uri uri = Uri.parse(url);

        http.Response response = await http.post(
          uri,
          headers: headerMap,
          body: data,
        );

        var result = json.decode(response.body);

        print(result);
      });
    } catch (e) {
      if (e.toString() == "Invalid request: invalid_card: number is invalid.") {
        print(e.toString());
        const Dialog(
          child: Text("number is invalid."),
        );
      }
    }
  }

  Widget formAmount() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return "Please fill amount in the blank";
            } else {
              amount = value.trim();
              return null;
            }
          },

          keyboardType: TextInputType.number, // Keyboard show only number.
          decoration: const InputDecoration(
            labelText: "Amount: ",
            hintText: "0.00",
            suffix: Text("THB"),
            border: OutlineInputBorder(),
          ),
        ),
      );

  Container buildExpireDateAndCVC() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          buildSizedBox(10),
          // ให้ Widget มันเต็มจอ โดยใช้ Expanded.
          Expanded(
            child: Column(
              children: [
                buildTitle("Expire Date"),
                formExpireDate(),
              ],
            ),
          ),
          buildSizedBox(8),
          Expanded(
            child: Column(
              children: [
                buildTitle("CVC"),
                formCVC(),
              ],
            ),
          ),
          buildSizedBox(10),
        ],
      ),
    );
  }

  Widget formCVC() => TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [cvcMask],
        validator: (value) {
          if (value!.isEmpty) {
            return "Please fill CVC in the blank";
          } else {
            if (cvc!.length != 3) {
              return "Please fill CVC 3 digits";
            } else {
              return null;
            }
          }
        },
        onChanged: (value) {
          cvc = cvcMask.getUnmaskedText();
        },
        decoration: const InputDecoration(
          hintText: "xxx",
          border: OutlineInputBorder(),
        ),
      );

  Widget formExpireDate() => TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [expireDateMask],
        validator: (value) {
          if (value!.isEmpty) {
            return "Please fill expire date in the blank";
          } else {
            if (expireDateStr!.length != 6) {
              return "Please fill expire date 6 digits";
            } else {
              expireDateMonth = expireDateStr?.substring(0, 2);
              expireDateYear = expireDateStr?.substring(2, 6);

              int expireDateMonthInt = int.parse(expireDateMonth!);
              int expireDateYearInt = int.parse(expireDateYear!);

              expireDateMonth = expireDateMonthInt.toString();
              int nowYear = int.parse(DateTime.now().year.toString());

              if (expireDateMonthInt > 12 && expireDateYearInt < nowYear) {
                return "Please fill expire date month less than 12 or year greater than $nowYear";
              } else {
                return null;
              }
            }
          }
        },
        onChanged: (value) {
          expireDateStr = expireDateMask.getUnmaskedText();
        },
        decoration: const InputDecoration(
          hintText: "xx/xxxx",
          border: OutlineInputBorder(),
        ),
      );

  Widget formIDcard() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return "Please fill ID Card in the blank";
            } else {
              if (idCard!.length != 16) {
                return "Please fill ID Card 16 digits";
              } else {
                return null;
              }
            }
          },
          inputFormatters: [idCardMask], // use inputFormatters.
          onChanged: (value) {
            //idCard = value.trim();
            idCard = idCardMask.getUnmaskedText();
          },
          keyboardType: TextInputType.number, // Keyboard show only number.
          decoration: const InputDecoration(
            hintText: "xxxx-xxxx-xxxx-xxxx",
            border: OutlineInputBorder(),
          ),
        ),
      );

  Container buildNameSurname() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          buildSizedBox(10),
          formName(),
          buildSizedBox(8),
          formSurName(),
          buildSizedBox(10),
        ],
      ),
    );
  }

  SizedBox buildSizedBox(double width) {
    return SizedBox(
      width: width,
    );
  }

  Widget formName() => Expanded(
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return "Please fill name in the blank";
            } else {
              name = value.trim();
              return null;
            }
          },
          decoration: const InputDecoration(
            labelText: "Name",
            hintText: "Enter your Name",
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget formSurName() => Expanded(
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return "Please fill surname in the blank";
            } else {
              surname = value.trim();
              return null;
            }
          },
          decoration: const InputDecoration(
            labelText: "Surname",
            hintText: "Enter your Surname",
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ShowTitle(title: title, textStyle: const TextStyle(fontSize: 14)),
    );
  }
}
