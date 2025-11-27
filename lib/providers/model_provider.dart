import 'package:flutter/material.dart';

ModelProvider modelProvider = ModelProvider();

class ModelProvider extends ChangeNotifier {
  String photoUrlData = '';
  String userNameData = '';
  String selectedPackage = "";

  ///seruserDatas
  setuserPhotUrlData({required String photoUrl}) {
    photoUrlData = photoUrl;
    notifyListeners();
  }

  setuserNameData({required String userName}) {
    userNameData = userName;
    notifyListeners();
  }

  setuSelectedPackage({required String selectedPackageData}) {
    selectedPackage = selectedPackageData;
    notifyListeners();
  }

  clearProvider() {
    // photoUrlData = '';
    // userNameData = '';
    selectedPackage = '';
    notifyListeners();
  }
}
