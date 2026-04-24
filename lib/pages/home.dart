import 'package:f_llama/ollama.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool answering = false;
  String message = '';

  TextEditingController inputCtrl = TextEditingController();
  TextEditingController chatNameCtrl = TextEditingController();
  ScrollController chatCtrl = ScrollController();
  FocusNode inputFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(emptyChat ? 'f-LLaMA' : chatName),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            spacing: 10,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  controller: chatCtrl,
                  reverse: true,
                  itemCount: chat.length,
                  itemBuilder: (c, i) => Container(
                    width: MediaQuery.of(context).size.width * .80,
                    padding: chat[i]['role'] == 'user'
                        ? EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .20,
                          )
                        : EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * .20,
                          ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              chat[i]['role'] == 'user'
                                  ? 'User'
                                  : chat[i]['model'],
                              style: TextStyle(fontWeight: .bold),
                            ),
                            Text(chat[i]['content']),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          borderSide: BorderSide(width: 3),
                        ),
                      ),
                      focusNode: inputFocus,
                      onChanged: (value) => setState(() => message = value),
                      onSubmitted: (answering || message.isEmpty)
                          ? null
                          : sendQuery,
                      controller: inputCtrl,
                    ),
                  ),
                  IconButton(
                    onPressed: (answering || message.isEmpty)
                        ? null
                        : sendQuery,
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    'Previous chats',
                    style: TextStyle(fontWeight: .bold, fontSize: 16),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        chatName = DateTime.now().toIso8601String();
                        chat = [];
                        emptyChat = true;
                        Navigator.pop(context);
                      });
                    },
                    icon: Icon(Icons.create_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (c, i) => ListTile(
                  title: Text(chatHistory.keys.elementAt(i)),
                  onTap: () {
                    setState(() {
                      chatName = chatHistory.keys.elementAt(i);
                      chat = chatHistory.values.elementAt(i);
                      emptyChat = false;
                      Navigator.pop(context);
                    });
                  },
                  trailing: PopupMenuButton(
                    child: Icon(Icons.more_vert),
                    itemBuilder: (ctx) {
                      chatNameCtrl.value = TextEditingValue(
                        text: chatHistory.keys.elementAt(i),
                        selection: TextSelection(
                          baseOffset: 0,
                          extentOffset: chatHistory.keys.elementAt(i).length,
                        ),
                      );
                      return [
                        PopupMenuItem(
                          child: Text('Rename'),
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Rename chat'),
                              content: TextField(
                                controller: chatNameCtrl,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      var renamedChat = chatHistory.values
                                          .elementAt(i);
                                      chatHistory.remove(
                                        chatHistory.keys.elementAt(i),
                                      );
                                      chatHistory[chatNameCtrl.value.text] =
                                          renamedChat;
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Text('Rename'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          child: Text('Delete'),
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete chat'),
                              content: Text(
                                'Are you sure you want to delete chat ${chatHistory.keys.elementAt(i)}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      chatHistory.remove(
                                        chatHistory.keys.elementAt(i),
                                      );
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
                itemCount: chatHistory.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    inputFocus.dispose();
    super.dispose();
  }

  void sendQuery([_]) async {
    answering = true;
    inputCtrl.text = '';
    inputFocus.requestFocus();
    try {
      await queryAI(
        message,
        setState,
        chatCtrl,
      ).timeout(Duration(milliseconds: 60000));
    } catch (e) {
      print(e);
    }
    answering = false;
  }
}
