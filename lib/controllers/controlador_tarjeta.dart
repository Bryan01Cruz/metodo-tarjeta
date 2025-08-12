import 'package:get/get.dart';

class PaymentController extends GetxController {
  final Rx<String?> _selectedCardId = Rx<String?>(null);

  String? get selectedCardId => _selectedCardId.value;

  void setSelectedCard(String? cardId) {
    _selectedCardId.value = cardId;
  }
}