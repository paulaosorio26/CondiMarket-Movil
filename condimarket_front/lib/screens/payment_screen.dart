import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<dynamic> cartItems;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();

  // Controllers para los campos de texto
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Estado de la pantalla
  List<PaymentMethod> _paymentMethods = [];
  String _selectedPaymentMethod = 'debit_card';
  bool _saveCard = false;
  bool _isLoading = false;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);

    try {
      final methods = await _paymentService.getPaymentMethods();
      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error al cargar métodos de pago');
    }
  }

  Future<void> _processPayment() async {
    if (!_validateForm()) return;

    setState(() => _isProcessingPayment = true);

    try {
      final cardInfo = CardInfo(
        cardHolderName: _cardHolderController.text,
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryMonth: _expiryMonthController.text,
        expiryYear: _expiryYearController.text,
        cvv: _cvvController.text,
      );

      final deliveryInfo = DeliveryInfo(
        city: _cityController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        saveCard: _saveCard,
      );

      final paymentRequest = PaymentRequest(
        paymentMethodId: _selectedPaymentMethod,
        cardInfo: cardInfo,
        deliveryInfo: deliveryInfo,
        amount: widget.totalAmount,
      );

      final success = await _paymentService.processPayment(paymentRequest);

      setState(() => _isProcessingPayment = false);

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Error procesando el pago. Intenta nuevamente.');
      }
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      _showErrorDialog('Error inesperado. Intenta nuevamente.');
    }
  }

  bool _validateForm() {
    if (_cardHolderController.text.isEmpty) {
      _showErrorDialog('Por favor ingresa el nombre del titular');
      return false;
    }

    if (_cardNumberController.text.replaceAll(' ', '').length < 16) {
      _showErrorDialog('Número de tarjeta inválido');
      return false;
    }

    if (_expiryMonthController.text.isEmpty || _expiryYearController.text.isEmpty) {
      _showErrorDialog('Por favor ingresa la fecha de vencimiento');
      return false;
    }

    if (_cvvController.text.length < 3) {
      _showErrorDialog('CVV inválido');
      return false;
    }

    if (_cityController.text.isEmpty || _addressController.text.isEmpty) {
      _showErrorDialog('Por favor completa la información de entrega');
      return false;
    }

    if (_phoneController.text.isEmpty) {
      _showErrorDialog('Por favor ingresa tu número celular');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('¡Pago Exitoso!'),
          ],
        ),
        content: Text('Tu pedido ha sido procesado correctamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar dialog
              Navigator.pop(context); // Volver a la pantalla anterior
            },
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de pago'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de progreso
            _buildProgressIndicator(),
            SizedBox(height: 24),

            // Métodos de pago
            _buildPaymentMethods(),
            SizedBox(height: 24),

            // Información de la tarjeta
            _buildCardForm(),
            SizedBox(height: 24),

            // Información de entrega
            _buildDeliveryForm(),
            SizedBox(height: 32),

            // Botón de finalizar compra
            _buildFinishButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep('Pedido', true, true),
        Expanded(child: Container(height: 2, color: Colors.green)),
        _buildProgressStep('Pago', true, true),
        Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
        _buildProgressStep('Orden\nConfirmada', false, false),
      ],
    );
  }

  Widget _buildProgressStep(String title, bool isCompleted, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : (isActive ? Colors.orange : Colors.grey.shade300),
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            color: Colors.white,
            size: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métodos de pago',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: _paymentMethods.map((method) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method.id;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedPaymentMethod == method.id
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: _selectedPaymentMethod == method.id
                          ? Colors.green
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(method.icon, style: TextStyle(fontSize: 24)),
                      SizedBox(height: 8),
                      Text(
                        '\$${widget.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        method.name,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Nombre del titular de la tarjeta',
          _cardHolderController,
          TextInputType.text,
        ),
        SizedBox(height: 16),
        _buildTextField(
          'Correo electrónico',
          TextEditingController(), // Campo adicional del mockup
          TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        _buildTextField(
          'Número de tarjeta',
          _cardNumberController,
          TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            _CardNumberInputFormatter(),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Mes/Año',
                _expiryMonthController,
                TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
            ),
            SizedBox(width: 8),
            Text('/'),
            SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                '',
                _expiryYearController,
                TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'CVV',
                _cvvController,
                TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _saveCard,
              onChanged: (value) {
                setState(() {
                  _saveCard = value ?? false;
                });
              },
            ),
            Text('Guardar esta tarjeta'),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Ciudad',
          _cityController,
          TextInputType.text,
        ),
        SizedBox(height: 16),
        _buildTextField(
          'Dirección',
          _addressController,
          TextInputType.text,
        ),
        SizedBox(height: 16),
        _buildTextField(
          'Número celular',
          _phoneController,
          TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      TextInputType keyboardType, {
        List<TextInputFormatter>? inputFormatters,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isProcessingPayment
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Procesando...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        )
            : Text(
          'Finalizar compra',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Formatter para el número de tarjeta
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}