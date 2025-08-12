import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final Color cardColor;

  CardWidget({
    Key? key,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cardColor,
  }) : super(key: key);

  // Método para obtener la ruta del logo según el primer dígito del número
  String _getCardLogo(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'assets/logo_visa.png';
    } else if (cardNumber.startsWith('5')) {
      return 'assets/logo_mastercard.png';
    } else if (cardNumber.startsWith('3')) {
      return 'assets/logo_american.png';
    }
    return 'assets/logo_mastercard.png'; // Un logo por defecto si no coincide
  }

  @override
  Widget build(BuildContext context) {

    final String cardLogoPath = _getCardLogo(cardNumber.replaceAll(' ', ''));
    
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Image.asset(cardLogoPath, width: 40),
          ),
          SizedBox(height: 20),
          Text(
            cardNumber,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardHolderName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                expiryDate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}