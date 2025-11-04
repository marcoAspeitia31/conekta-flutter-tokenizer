import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/card_data.dart';

/// Widget para el formulario de captura de datos de tarjeta
class CardFormWidget extends StatefulWidget {
  final Function(CardData) onSubmit;
  final bool isLoading;

  const CardFormWidget({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<CardFormWidget> createState() => _CardFormWidgetState();
}

class _CardFormWidgetState extends State<CardFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expMonthController = TextEditingController();
  final _expYearController = TextEditingController();
  final _cvcController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expMonthController.dispose();
    _expYearController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de tarjeta es requerido';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Número de tarjeta inválido';
    }
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Solo se permiten números';
    }
    return null;
  }

  String? _validateExpMonth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mes requerido';
    }
    final month = int.tryParse(value);
    if (month == null || month < 1 || month > 12) {
      return 'Mes inválido (01-12)';
    }
    return null;
  }

  String? _validateExpYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Año requerido';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Año inválido';
    }
    final currentYear = DateTime.now().year;
    if (year < currentYear || year > currentYear + 20) {
      return 'Año inválido';
    }
    return null;
  }

  String? _validateCvc(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVC requerido';
    }
    if (value.length < 3 || value.length > 4) {
      return 'CVC inválido (3-4 dígitos)';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Solo se permiten números';
    }
    return null;
  }

  void _formatCardNumber(String value) {
    // Formatear número de tarjeta con espacios cada 4 dígitos
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    final formatted = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(cleaned[i]);
    }
    _numberController.value = TextEditingValue(
      text: formatted.toString(),
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final cardData = CardData(
        name: _nameController.text.trim(),
        number: _numberController.text.replaceAll(RegExp(r'[\s-]'), ''),
        expMonth: _expMonthController.text.padLeft(2, '0'),
        expYear: _expYearController.text,
        cvc: _cvcController.text,
      );
      widget.onSubmit(cardData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nombre del titular
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del titular',
              hintText: 'Juan Pérez',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Número de tarjeta
          TextFormField(
            controller: _numberController,
            decoration: const InputDecoration(
              labelText: 'Número de tarjeta',
              hintText: '4242 4242 4242 4242',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
            ],
            onChanged: _formatCardNumber,
            validator: _validateCardNumber,
          ),
          const SizedBox(height: 16),

          // Fecha de expiración y CVC
          Row(
            children: [
              // Mes
              Expanded(
                child: TextFormField(
                  controller: _expMonthController,
                  decoration: const InputDecoration(
                    labelText: 'Mes',
                    hintText: '12',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: _validateExpMonth,
                ),
              ),
              const SizedBox(width: 16),

              // Año
              Expanded(
                child: TextFormField(
                  controller: _expYearController,
                  decoration: InputDecoration(
                    labelText: 'Año',
                    hintText: DateTime.now().year.toString(),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: _validateExpYear,
                ),
              ),
              const SizedBox(width: 16),

              // CVC
              Expanded(
                child: TextFormField(
                  controller: _cvcController,
                  decoration: const InputDecoration(
                    labelText: 'CVC',
                    hintText: '123',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: _validateCvc,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botón de envío
          ElevatedButton(
            onPressed: widget.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Tokenizar Tarjeta',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}

