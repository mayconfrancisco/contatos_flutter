import 'dart:io';

import 'package:contatos_flutter/helpers/contact_helper.dart';
import 'package:contatos_flutter/ui/contact_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();
  List contactsList = List();

  @override
  void initState() {
    super.initState();
    _fetchAllContacts();
  }

  void _fetchAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contactsList = list;
      });
    });
  }

  /*
   * Show Contact Page
   */
  void _showContactPage({Contact contact}) async {
    Contact recContact = await Navigator.push(context, 
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
    );

    contact != null 
      ? await helper.updateContact(recContact) 
      : await helper.saveContact(recContact);

    _fetchAllContacts();
  }

  /*
   * Build 
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showContactPage,
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: contactsList.length,
        itemBuilder: (context, index) {
          return _buildCardContact(context, index);
        }
      ),
    );
  }

  /*
   * Build Card Item 
   */
  Widget _buildCardContact(context, index) {
    return GestureDetector(
      onTap: () => _showContactPage(contact: contactsList[index]),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: <Widget>[
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: contactsList[index].img != null 
                    ? FileImage(File(contactsList[index].img))
                    : AssetImage('images/person.png'))
              ),
              margin: EdgeInsets.only(right: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(contactsList[index].name ?? "No Name",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(contactsList[index].email),
                Container(height: 4,),
                Text(contactsList[index].phone)
              ],
            )
          ]),
        ),
      ),
    );
  }

}
