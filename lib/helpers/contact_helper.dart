import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = 'contacts';
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String phoneColumn = 'phoneColumn';
final String imgColoumn = 'imgColumn';

class ContactHelper {
  
  // Singleton
  static final ContactHelper _instance = ContactHelper.internal();
  ContactHelper.internal();
  factory ContactHelper() => _instance;

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDB();
    return _db;
  }

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contactsnew.db');

    //ABRE o banco passando o caminho, versao e um onCreate com  os comandos de criação das tabelas para executar na primeira vez que executar
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColoumn TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    if (contact == null) return null;
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(
      contactTable, 
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColoumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    }

    return null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    if (contact == null) return -1;
    Database dbContact = await db;
    return await dbContact.update(
      contactTable, 
      contact.toMap(), 
      where: "$idColumn = ?", 
      whereArgs: [contact.id]
    );
  }

  Future<List<Contact>> getAllContacts() async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> contacts = List();
    for (Map m in maps) {
      contacts.add(Contact.fromMap(m));
    }
    return contacts;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }

}

/*
 * Model  
 */
class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map contactMap) {
    id = contactMap[idColumn];
    name = contactMap[nameColumn];
    email = contactMap[emailColumn];
    phone = contactMap[phoneColumn];
    img = contactMap[imgColoumn];
  }

  Map<String, dynamic> toMap() {
    Map contactMap = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColoumn: img
    };

    if (id != null) {
      contactMap[idColumn] = id;
    }

    //_InternalLinkedHashMap<dynamic, dynamic>
    return Map<String, dynamic>.from(contactMap);
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }

}