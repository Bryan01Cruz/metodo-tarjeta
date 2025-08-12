import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metodo_tarjetas/widgets/vista_tarjeta.dart';

class AddCardPage extends StatefulWidget {
  AddCardPage({Key? key}) : super(key: key);

  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  Color _selectedColor = Color(0xFF6B45FF);

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() => setState(() {}));
    _cardHolderController.addListener(() => setState(() {}));
    _expiryDateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Método de pago'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nueva tarjeta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CardPreviewWidget(
              cardNumber: _cardNumberController.text.padRight(16, '*').replaceAllMapped(
                  RegExp(r'.{4}'), (match) => '${match.group(0)} ').trim(),
              cardHolderName: _cardHolderController.text.isEmpty
                  ? 'NOMBRE COMPLETO'
                  : _cardHolderController.text.toUpperCase(),
              expiryDate: _expiryDateController.text.isEmpty ? 'MM/AA' : _expiryDateController.text,
              cardColor: _selectedColor,
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _cardNumberController,
              label: 'Número de la tarjeta',
              keyboardType: TextInputType.number,
              maxLength: 16,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 15),
            _buildTextField(
              controller: _cardHolderController,
              label: 'Nombre completo',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _expiryDateController,
                    label: 'Fecha de expiración',
                    keyboardType: TextInputType.datetime,
                    maxLength: 5,
                    inputFormatters: [
                      _DateFormatter(),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildTextField(
                    controller: _cvvController,
                    label: 'Código',
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            _buildColorSelector(),
            SizedBox(height: 30),
            _buildAddCardButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            if (controller.text.length == maxLength)
              Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            counterText: '',
            hintText: label,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Row(
      children: [
        Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 15),
        GestureDetector(
          onTap: () {
            
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey, width: 2),
            ),
          ),
        ),
        Icon(Icons.arrow_drop_down),
      ],
    );
  }

  Widget _buildAddCardButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF9866),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () async {
          try {
            await FirebaseFirestore.instance.collection('tarjetas').add({
              'numero_tarjeta': _cardNumberController.text,
              'nombre_titular': _cardHolderController.text,
              'fecha_expiracion': _expiryDateController.text,
              'color': _selectedColor.value,
              'timestamp': FieldValue.serverTimestamp(),
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tarjeta agregada con éxito!')),
            );
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al agregar la tarjeta: $e')),
            );
          }
        },
        child: Text(
          'Agregar tarjeta',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    String newText = '';

    // Filtra para que solo queden números
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 4) {
      // Limita la longitud a 4 dígitos
      text = text.substring(0, 4);
    }
    
    if (text.length >= 2) {
      // Agrega la barra después de los primeros dos dígitos
      newText = text.substring(0, 2) + '/' + text.substring(2);
    } else {
      newText = text;
    }
    
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}