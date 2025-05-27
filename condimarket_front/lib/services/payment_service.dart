import 'dart:convert';
import 'dart:async';
import '../models/payment_model.dart';

class PaymentService {
  static const String _baseUrl = 'https://api.condimarket.com';

  Future<List<PaymentMethod>> getPaymentMethods() async {
    // Simulación de métodos de pago disponibles
    await Future.delayed(Duration(milliseconds: 500));

    return [
      PaymentMethod(
        id: 'debit_card',
        name: 'Tarjeta de débito',
        icon: '💳',
        isSelected: true,
      ),
      PaymentMethod(
        id: 'credit_card',
        name: 'Tarjeta de crédito',
        icon: '💳',
      ),
    ];
  }

  Future<bool> processPayment(PaymentRequest paymentRequest) async {
    try {
      // Simulación de procesamiento de pago
      await Future.delayed(Duration(seconds: 2));

      // Aquí iría la integración real con el procesador de pagos
      // Por ejemplo: Stripe, PayPal, etc.

      print('Procesando pago: ${paymentRequest.toJson()}');

      // Simulamos éxito en el 90% de los casos
      return DateTime.now().millisecondsSinceEpoch % 10 != 0;

    } catch (e) {
      print('Error procesando pago: $e');
      return false;
    }
  }

  Future<bool> validateCard(String cardNumber, String cvv, String expiryMonth, String expiryYear) async {
    try {
      // Validaciones básicas
      if (cardNumber.length < 16) return false;
      if (cvv.length < 3) return false;

      int month = int.tryParse(expiryMonth) ?? 0;
      int year = int.tryParse(expiryYear) ?? 0;

      if (month < 1 || month > 12) return false;
      if (year < DateTime.now().year % 100) return false;

      // Simulación de validación con el banco
      await Future.delayed(Duration(milliseconds: 800));

      return true;
    } catch (e) {
      return false;
    }
  }

  String formatCardNumber(String cardNumber) {
    // Formato: XXXX XXXX XXXX XXXX
    String formatted = cardNumber.replaceAll(' ', '');
    String result = '';

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && i % 4 == 0) {
        result += ' ';
      }
      result += formatted[i];
    }

    return result;
  }

  String getCardType(String cardNumber) {
    String cleanNumber = cardNumber.replaceAll(' ', '');

    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) {
      return 'Mastercard';
    } else if (cleanNumber.startsWith('3')) {
      return 'American Express';
    }

    return 'Desconocida';
  }
}