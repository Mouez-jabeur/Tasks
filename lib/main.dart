import 'package:flutter/material.dart';
import 'note.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
        hintColor: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final Note note = settings.arguments as Note;
          return MaterialPageRoute(
            builder: (context) {
              return EditNoteScreen(note: note);
            },
          );
        }
        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case '/add':
                return AddNoteScreen();
              case '/categories':
                return NoteCategoriesScreen();
              default:
                return NoteListScreen();
            }
          },
        );
      },
    );
  }
}

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () {
              Navigator.pushNamed(context, '/categories');
            },
          ),
        ],
      ),
      body: notes.isEmpty
          ? Center(
              child: Text(
                'No notes available',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Color(0xFF2D2D2D),
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      notes[index].title,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    subtitle: Text(
                      notes[index].content,
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: Chip(
                      label: Text(
                        notes[index].category,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.teal,
                    ),
                    onTap: () async {
                      final updatedNote = await Navigator.pushNamed(
                        context,
                        '/edit',
                        arguments: notes[index],
                      );
                      if (updatedNote != null && updatedNote is Note) {
                        setState(() {
                          notes[index] = updatedNote;
                        });
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add');
          if (result != null && result is Note) {
            setState(() {
              notes.add(result);
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'General';
  final List<String> _categories = ['General', 'Work', 'Personal', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: null,
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: Color(0xFF2D2D2D),
              style: TextStyle(color: Colors.white),
              iconEnabledColor: Colors.teal,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.teal),
              ),
              onPressed: () {
                final title = _titleController.text;
                final content = _contentController.text;
                if (title.isNotEmpty && content.isNotEmpty) {
                  Navigator.pop(
                    context,
                    Note(
                      title: title,
                      content: content,
                      category: _selectedCategory,
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color(0xFF2D2D2D),
                        title: Text('Error', style: TextStyle(color: Colors.white)),
                        content: Text('Title and content cannot be empty.', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK', style: TextStyle(color: Colors.teal)),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

class EditNoteScreen extends StatefulWidget {
  final Note note;

  EditNoteScreen({required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  final List<String> _categories = ['General', 'Work', 'Personal', 'Other'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedCategory = widget.note.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: null,
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: Color(0xFF2D2D2D),
              style: TextStyle(color: Colors.white),
              iconEnabledColor: Colors.teal,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.teal),
              ),
              onPressed: () {
                final title = _titleController.text;
                final content = _contentController.text;
                if (title.isNotEmpty && content.isNotEmpty) {
                  widget.note.title = title;
                  widget.note.content = content;
                  widget.note.category = _selectedCategory;
                  Navigator.pop(context, widget.note);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color(0xFF2D2D2D),
                        title: Text('Error', style: TextStyle(color: Colors.white)),
                        content: Text('Title and content cannot be empty.', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK', style: TextStyle(color: Colors.teal)),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

class NoteCategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Categories'),
      ),
      body: Center(
        child: Text(
          'Note Categories',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

