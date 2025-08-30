import 'package:flutter/foundation.dart';
import '../models/payment_method_model.dart';
import '../services/database_service.dart';

class PaymentMethodProvider with ChangeNotifier {
  List<PaymentMethod> _methods = [];
  bool _isLoading = false;

  List<PaymentMethod> get methods => _methods;
  bool get isLoading => _isLoading;

  Future<void> loadMethods() async {
    _isLoading = true;
    notifyListeners();
    _methods = await DatabaseService.instance
        .getPaymentMethods();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMethod(String name) async {
    await DatabaseService.instance.addPaymentMethod(name);
    await loadMethods(); // DB変更後にリストを再読み込み
  }

  Future<void> updateMethod(int id, String newName) async {
    await DatabaseService.instance.updatePaymentMethod(
      id,
      newName,
    );
    await loadMethods();
  }

  Future<void> deleteMethod(int id) async {
    await DatabaseService.instance.deletePaymentMethod(id);
    await loadMethods();
  }
}
