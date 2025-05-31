class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final bool isSelected;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false,
  });

  PaymentMethod copyWith({
    String? id,
    String? name,
    String? icon,
    bool? isSelected,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class CardInfo {
  final String cardHolderName;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;

  CardInfo({
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  bool get isValid {
    return cardHolderName.isNotEmpty &&
        cardNumber.length >= 16 &&
        expiryMonth.isNotEmpty &&
        expiryYear.isNotEmpty &&
        cvv.length >= 3;
  }
}

class DeliveryInfo {
  final String city;
  final String address;
  final String phoneNumber;
  final bool saveCard;

  DeliveryInfo({
    required this.city,
    required this.address,
    required this.phoneNumber,
    this.saveCard = false,
  });

  bool get isValid {
    return city.isNotEmpty &&
        address.isNotEmpty &&
        phoneNumber.isNotEmpty;
  }
}

class PaymentRequest {
  final String paymentMethodId;
  final CardInfo cardInfo;
  final DeliveryInfo deliveryInfo;
  final double amount;

  PaymentRequest({
    required this.paymentMethodId,
    required this.cardInfo,
    required this.deliveryInfo,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentMethodId': paymentMethodId,
      'cardHolderName': cardInfo.cardHolderName,
      'cardNumber': cardInfo.cardNumber,
      'expiryMonth': cardInfo.expiryMonth,
      'expiryYear': cardInfo.expiryYear,
      'cvv': cardInfo.cvv,
      'city': deliveryInfo.city,
      'address': deliveryInfo.address,
      'phoneNumber': deliveryInfo.phoneNumber,
      'saveCard': deliveryInfo.saveCard,
      'amount': amount,
    };
  }
}