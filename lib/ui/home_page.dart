import 'dart:io';

import 'package:contatos_flutter/helpers/contact_helper.dart';
import 'package:contatos_flutter/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {OrderAZ, OrderZA}

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

  void _orderList(OrderOptions result) {
    setState(() {
      switch(result) {
        case OrderOptions.OrderAZ:
        contactsList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
        case OrderOptions.OrderZA:
        contactsList.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      }
    });
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
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de A-Z'),
                value: OrderOptions.OrderAZ,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de Z-A'),
                value: OrderOptions.OrderZA,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
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
      onTap: () => _showOptions(context, index),
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
                  fit: BoxFit.cover,
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
                Text(contactsList[index].email ?? "-"),
                Container(height: 4,),
                Text(contactsList[index].phone ?? "-")
              ],
            )
          ]),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return BottomSheet(
          onClosing: () {}, 
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  
                  FlatButton(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Ligar',
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                    onPressed: () async {
                      String urlTel = 'tel:${contactsList[index].phone}';
                      if (await canLaunch(urlTel)) {
                        await launch(urlTel);
                      } else {
                        print('deu ruim, não tem acesso para chamada');
                      }
                      Navigator.pop(context);
                    },
                  ),
                  
                  FlatButton(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Editar',
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showContactPage(contact: contactsList[index]);
                    }, 
                  ),
                  
                  FlatButton(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                    onPressed: () async {
                      helper.deleteContact(contactsList[index].id);
                      setState(() {
                        contactsList.removeAt(index);
                        Navigator.pop(context);
                      });
                    }, 
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

}
