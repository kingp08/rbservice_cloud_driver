import 'package:bedrive/utils/text.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class PersonChip {
  PersonChip(this.email, [this.imageUrl]);
  final String email;
  final String? imageUrl;
}

class EmailChipsInput extends StatefulWidget {
  const EmailChipsInput({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  final ValueChanged<List<PersonChip>>? onChanged;

  @override
  EmailChipsInputState createState() => EmailChipsInputState();
}

class EmailChipsInputState extends State<EmailChipsInput> {
  TextEditingController? controller;
  final emptySpace = '\u200B';
  final List<PersonChip> chips = [];
  bool loading = false;
  FocusNode? focusNode;
  List<String> contactEmails = [];

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    FlutterContacts.requestPermission(readonly: true).then((havePermission) {
      if (havePermission) {
        FlutterContacts.getContacts(withProperties: true).then((contacts) {
          contactEmails = contacts
              .map((c) => c.emails.map((e) => e.address))
              .expand((i) => i)
              .toList();
        });
      }
    });
  }

  @override
  void dispose() {
    // controller will be disposed by autocomplete automatically
    focusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: () {
          focusNode!.requestFocus();
        },
        // TODO: https://github.com/flutter/flutter/issues/78746
        // TODO: show image and display name for autocomplete suggestions, need to use custom builder
        child: Autocomplete<String>(
          fieldViewBuilder:
              (BuildContext bc, TextEditingController ctrl, FocusNode fn, _) {
            controller = ctrl;
            focusNode = fn;
            return Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 0,
                children: [
                  ...chips.map((PersonChip chip) {
                    return InputChip(
                      avatar: CircleAvatar(
                        child:
                            text(chip.email[0].toUpperCase(), translate: false),
                      ),
                      label: text(chip.email, translate: false),
                      onPressed: () {
                        editChip(chip);
                      },
                      onDeleted: () {
                        removeChip(chip);
                      },
                    );
                  }),
                  TextField(
                    focusNode: focusNode,
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: trans('Add email to share with'),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    onSubmitted: (value) {
                      addChip(value, focus: false);
                    },
                    onChanged: (value) async {
                      if (value == '' && chips.isNotEmpty) {
                        removeChip(chips.last);

                        // if there are more chips after removing
                        // add empty space so can remove other chips
                        if (chips.isNotEmpty) {
                          setText(emptySpace);
                        }
                      }
                    },
                  )
                ],
              ),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return contactEmails.where((String option) {
              return option.contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            addChip(selection, focus: false);
          },
        ));
  }

  removeChip(PersonChip chip) {
    setState(() {
      chips.removeWhere((c) => c.email == chip.email);
      _notifyListeners();
    });
  }

  addChip(String email, {bool focus = false}) {
    email = email.replaceFirst(emptySpace, '');
    if (email != '' &&
        chips.firstWhereOrNull((c) => c.email == email) == null) {
      setState(() => chips.add(PersonChip(email)));
      _notifyListeners();
    }
    setText(emptySpace);
    if (focus) {
      focusNode!.requestFocus();
    }
  }

  editChip(PersonChip chip) {
    setText(chip.email);
    removeChip(chip);
    focusNode!.requestFocus();
  }

  clearChips() {
    setState(() {
      chips.clear();
      _notifyListeners();
    });
  }

  setText(String text) {
    controller!.text = text;
    controller!.selection = TextSelection.fromPosition(
        TextPosition(offset: controller!.text.length));
  }

  _notifyListeners() {
    if (widget.onChanged != null) {
      widget.onChanged!(chips.toList(growable: false));
    }
  }
}
