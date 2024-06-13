import 'package:flutter/cupertino.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';

class SearchScreenProvider extends ChangeNotifier {
  List<NoteModel> searchedNotes = [];
  String searchValue = '';
  setSearchValue(String value) {
    searchValue = value;
    notifyListeners();
  }

  bool isSearching = false;
  setSearching(bool value) {
    isSearching = value;
    notifyListeners();
  }
}
