import 'dart:io';

import 'package:contatos_flutter/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  State<StatefulWidget> createState() => _ContactPage();

}

/*
 * State Class 
 */
class _ContactPage extends State<ContactPage> {

  Contact _editContact;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact != null) {
      _editContact = widget.contact;
      
      _nameController.text = _editContact.name;
      _phoneController.text = _editContact.phone;
      _emailController.text = _editContact.email;

    } else {
      _editContact = Contact();
    }
    
  }

  _handleName(String text) {
    setState(() {
      _editContact.name = text;
    });
  }

  void _handleSave() {
    Navigator.pop(context, _editContact);
  }

  Future<bool> _requestPop() {
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editContact.name ?? "Novo Contato"),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editContact.img != null 
                        ? FileImage(File(_editContact.img)) 
                        : AssetImage("images/person.png")
                    ),
                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Nome"),
                textCapitalization: TextCapitalization.words,
                controller: _nameController,
                onChanged: (text) => _handleName(text),
                onSubmitted: (v) => FocusScope.of(context).requestFocus(_phoneFocusNode),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Telefone"),
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                onChanged: (text) => _editContact.phone = text,
                onSubmitted: (v) => FocusScope.of(context).requestFocus(_emailFocusNode),
              ),
              TextField(
                decoration: InputDecoration(labelText: "E-mail"),
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                focusNode: _emailFocusNode,
                onChanged: (text) => _editContact.email = text,
                onSubmitted: (v) => _handleSave(),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          child: Icon(Icons.save),
          onPressed: _handleSave
        ),
      ),
    );
  }

}