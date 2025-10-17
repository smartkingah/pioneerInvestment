import 'package:flutter/material.dart';

ModelProvider modelProvider = ModelProvider();

class ModelProvider extends ChangeNotifier {
  String photoUrlData = '';
  String userNameData = '';

  ///seruserDatas
  setuserPhotUrlData({required String photoUrl}) {
    photoUrlData = photoUrl;

    notifyListeners();
  }

  setuserNameData({required String userName}) {
    userNameData = userName;

    notifyListeners();
  }
}
