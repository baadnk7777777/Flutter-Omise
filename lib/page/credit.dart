import 'package:flutter/material.dart';
import 'package:flutter_omise/component/show_title.dart';

class Credit extends StatefulWidget {
  const Credit({super.key});

  @override
  State<Credit> createState() => _CreditState();
}

class _CreditState extends State<Credit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credit Page"),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // จัดให้ชิดซ้าย.
          children: [
            buildTitle("Name surname"),
            buildNameSurname(),
            buildTitle("ID Card"),
            formIDcard(),
            buildExpireDateAndCVC(),
            buildTitle("Amount"),
            formAmount(),
            const Spacer(), // ดันให้ปุ่มอยู่ด้านล่างสุด.
            buttonAddMoney()
          ],
        ),
      ),
    );
  }

  Container buttonAddMoney() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text("Add money"),
      ),
    );
  }

  Widget formAmount() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
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
        decoration: const InputDecoration(
          hintText: "xxx",
          border: OutlineInputBorder(),
        ),
      );

  Widget formExpireDate() => TextFormField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "xx/xxxx",
          border: OutlineInputBorder(),
        ),
      );

  Widget formIDcard() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
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
          decoration: const InputDecoration(
            labelText: "Name",
            hintText: "Enter your Name",
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget formSurName() => Expanded(
        child: TextFormField(
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
