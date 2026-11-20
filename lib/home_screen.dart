import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  int? editingId;
  List<Map<String, dynamic>> expense = [];

  @override
  initState() {
    super.initState();
    readExpense();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    amountController.dispose();
  }

  //Open Database
  Future<Database> openMyDatabase() async {
    String folder = await getDatabasesPath();
    String path = join(folder, 'expense.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          amount REAL
        )
      ''');
      },
    );
  }

  //Add Expense
  Future<void> addExpense() async {
    Database db = await openMyDatabase();
    await db.insert('expenses', {
      'title': titleController.text,
      'amount': amountController.text,
    });
    clearBoxes();
    readExpense();
  }

  //Read Expense
  Future<void> readExpense() async {
    Database db = await openMyDatabase();

    List<Map<String, dynamic>> rows = await db.query(
      'expenses',
      orderBy: 'title ASC',
    );

    if (!mounted) return;

    setState(() {
      expense = rows;
    });
  }

  //Update Expense
  Future<void> updateExpense() async {
    Database db = await openMyDatabase();
    await db.update(
      'expenses',
      {'title': titleController.text, 'amount': amountController.text},
      where: 'id =?',
      whereArgs: [editingId],
    );
    clearBoxes();
    readExpense();
  }

  //Delete Expense
  Future<void> deleteExpense(int id) async {
    Database db = await openMyDatabase();
    await db.delete('expenses', where: 'id =?', whereArgs: [id]);
    clearBoxes();
    readExpense();
  }

  void startEditing(Map<String, dynamic> contact) {
    setState(() {
      editingId = contact['id'];
      titleController.text = contact['title'];
      amountController.text = contact['amount'];
    });
  }

  void saveButtonPressed() {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      return;
    }
    if (editingId == null) {
      addExpense();
    } else {
      updateExpense();
    }
  }

  void clearBoxes() {
    setState(() {
      editingId = null;
      titleController.clear();
      amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Enter Expense Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                hintText: 'Enter Expense Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: saveButtonPressed,
              child: Text(editingId == null ? 'Add Expense' : 'Update Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
