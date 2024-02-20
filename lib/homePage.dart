import 'package:flutter/material.dart';
import 'package:to_do_app/database.dart';
import 'package:to_do_app/myWidgets.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Set<int> _selectedIndices = {};
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchControler = TextEditingController();
  int checkState = 0;
  TextEditingController dateInput = TextEditingController();
  //final String formattedDateTime = now.toIso8601String();
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void refreshList() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
      titleController.clear();
      descriptionController.clear();
      dateInput.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    refreshList();
    // Loading the diary when the app starts
  }

  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      titleController.text = existingJournal['title'];
      descriptionController.text = existingJournal['description'];
      dateInput.text = existingJournal['date'];
      checkState = existingJournal['checkState'];
    }
    Future<void> showAlertDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            // <-- SEE HERE
            title: const Text(
              'Please fill all fields',
              style: TextStyle(fontSize: 14),
            ),

            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        // <-- SEE HERE
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (BuildContext context) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // this will prevent the soft keyboard from covering the text fields
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            myDialogTextField('ُTitle', Icons.star, titleController, () {}),
            const SizedBox(
              height: 10,
            ),
            myDialogTextField(
                'Description', Icons.star, descriptionController, () {}),
            const SizedBox(
              height: 10,
            ),
            myDialogTextField(
              "Date",
              Icons.star,
              dateInput,
              () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100));

                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  setState(() {
                    dateInput.text = formattedDate;
                  });
                } else {}
              },
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 100,
              height: 45,
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      dateInput.text.isEmpty) {
                    showAlertDialog();
                    return;
                  }
                  // Save new journal
                  if (id == null) {
                    await _addItem();
                  }

                  if (id != null) {
                    await _updateItem(id);
                  }

                  // Clear the text fields
                  titleController.text = '';
                  descriptionController.text = '';
                  dateInput.text = '';
                  // Close the bottom sheet
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                child: Text(
                  id == null ? 'Save' : 'Update',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      refreshList();
    } else {
      results = _journals
          .where((user) => user['title']
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _journals = results;
    });
  }

// Insert a new item to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(titleController.text, descriptionController.text,
        dateInput.text, checkState);
    refreshList();
  }

  // Update an existing item
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, titleController.text,
        descriptionController.text, dateInput.text, checkState);
    refreshList();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.blue,
      content: Text(
        'Delete Successfull',
        style: TextStyle(color: Colors.white),
      ),
    ));
    refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    child: TextField(
                      controller: searchControler,
                      onChanged: (value) => _runFilter(value),
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 30,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 249, 253, 252),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade900),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: _journals.isNotEmpty
                          ? ListView.builder(
                              itemCount: _journals.length,
                              itemBuilder: (BuildContext context, index) {
                                void taskDetails() {
                                  titleController.text =
                                      _journals[index]['title'];
                                  descriptionController.text =
                                      _journals[index]['description'];
                                  dateInput.text = _journals[index]['date'];
                                  _updateItem(_journals[index]['id']);
                                }

                                return Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Container(
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 244, 246, 248),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _journals[index]['title'],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                _journals[index]['date'],
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                myIcon(
                                                    Icons.share, Colors.green,
                                                    () {
                                                  Share.share(_journals[index]
                                                          ['title'] +
                                                      "     " +
                                                      _journals[index]
                                                          ['description'] +
                                                      "     " +
                                                      _journals[index]['date']);
                                                }),
                                                myIcon(
                                                  Icons.edit,
                                                  Colors.blue,
                                                  () => _showForm(
                                                      _journals[index]['id']),
                                                ),
                                                myIcon(
                                                  Icons.delete,
                                                  Colors.redAccent,
                                                  () => _deleteItem(
                                                      _journals[index]['id']),
                                                ),
                                                Checkbox(
                                                  value: _journals[index]
                                                          ['checkState'] ==
                                                      1,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      _journals[index][
                                                                  'checkState'] ==
                                                              value!
                                                          ? 1
                                                          : 0;
                                                      if (value == true) {
                                                        _selectedIndices
                                                            .add(index);
                                                        checkState = 1;
                                                        taskDetails();
                                                      } else {
                                                        _selectedIndices
                                                            .remove(index);
                                                        checkState = 0;
                                                        taskDetails();
                                                      }
                                                    });
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Text(
                              'ٔNot any record',
                              style: TextStyle(fontSize: 24),
                            ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(null),
          child: const Icon(
            Icons.add,
            size: 28,
          ),
        ),
      ),
    );
  }
}
