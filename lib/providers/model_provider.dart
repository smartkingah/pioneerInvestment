import 'package:flutter/material.dart';

ModelProvider modelProvider = ModelProvider();

class ModelProvider extends ChangeNotifier {
  String photoUrlData = '';
  String userNameData = '';
  String selectedPackage = "";
  bool isJustFundWallet = false;

  ///seruserDatas
  setIsJustFundWalletData({required bool data}) {
    isJustFundWallet = data;
    notifyListeners();
  }

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
