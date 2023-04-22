import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
  }

  var titleController = TextEditingController();
  var descController = TextEditingController();

  //initializing hive folder or table
  var taskBox = Hive.box('taskBox');

  //empty list
  List<Map<String, dynamic>> ourTasks = [];

  //create data
  createData(Map<String, dynamic> data) async {
    await taskBox.add(data);
    readData();
    print(taskBox.length);
  }

  //read data
  readData() async {
    var newData = taskBox.keys.map((key) {
      final item = taskBox.get(key);
      return {'key': key, 'title': item['title'], 'task': item['task']};
    }).toList();

    setState(() {
      ourTasks = newData.reversed.toList();
      print(ourTasks.length);
    });
  }

  //update data
  updateData(int? key, Map<String, dynamic>data)async{
    await taskBox.put(key, data);
    readData();
  }

  //delete data
  deleteData(int? key)async{
    await taskBox.delete(key);
    readData();
  }

  showFormModal(context, int? key) async {
    titleController.clear();
    descController.clear();

    if(key != null){
      final item = ourTasks.firstWhere((element) => element['key'] == key);
      titleController.text = item['title'];
      descController.text = item['task'];
    }
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Enter Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'Enter task',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                //on press of the button create data
                var data = {
                  'title': titleController.text,
                  'task': descController.text,
                };
                if(key == null){
                  createData(data);
                } else{
                  updateData(key, data);
                }

                Navigator.pop(context);
              },
              child: Text( key == null ? 'Add Task' : "update task"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal(context, null);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Hive Crud'),
      ),
      body: ListView.builder(
          itemCount: ourTasks.length,
          itemBuilder: (context, index) {
            var currentItem = ourTasks[index];
            return Card(
              color: Colors.orangeAccent,
                child: ListTile(
              title: Text(currentItem['title']),
              subtitle: Text(currentItem['task']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: ()async{
                        showFormModal(context, currentItem['key']);
                      }, icon: const Icon(Icons.edit),),
                      IconButton(onPressed: (){
                        deleteData(currentItem['key']);
                      }, icon: const Icon(Icons.delete),),
                    ],
                  ),
            ));
          }),
    );
  }
}
