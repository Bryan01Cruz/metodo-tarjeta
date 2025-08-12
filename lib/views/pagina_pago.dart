import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metodo_tarjetas/views/agregar_tarjeta.dart';
import 'package:metodo_tarjetas/widgets/widget_tarjeta.dart';
import 'package:metodo_tarjetas/controllers/controlador_tarjeta.dart';

class PaymentMethodsPage extends StatelessWidget {
  PaymentMethodsPage({Key? key}) : super(key: key);

  final PaymentController controller = Get.put(PaymentController());

  void _showSnackBar(BuildContext context, String message, {Color color = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handlePayment(BuildContext context) {
    if (controller.selectedCardId == null) {
      _showSnackBar(context, 'Debe seleccionar una tarjeta.', color: Colors.red);
    } else {
      _showSnackBar(context, 'El pago a sido realizado con exito.', color: Colors.green);
      // Aquí podrías agregar la lógica real de pago
    }
  }

  Future<void> _deleteCard(BuildContext context, String docId) async {
    bool confirm = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Confirmar eliminación'),
            content: Text('¿Estás seguro de que deseas eliminar esta tarjeta?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('tarjetas').doc(docId).delete();
        if (controller.selectedCardId == docId) {
          controller.setSelectedCard(null);
        }
        _showSnackBar(context, 'Tarjeta eliminada con éxito!', color: Colors.green);
      } catch (e) {
        _showSnackBar(context, 'Error al eliminar la tarjeta: $e', color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {}//=> Get.back(),
        ),
        title: Text('Volver'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Método de pago',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Tarjetas de crédito y débito',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tarjetas').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Algo salió mal');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Text('No tienes tarjetas guardadas.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                    String docId = doc.id;

                    return GestureDetector(
                      onTap: () {
                        controller.setSelectedCard(controller.selectedCardId == docId ? null : docId);
                      },
                      child: Obx(() {
                        bool isSelected = controller.selectedCardId == docId;
                        return Container(
                          margin: EdgeInsets.only(bottom: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.orange : Colors.transparent,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Stack(
                            children: [
                              CardWidget(
                                cardNumber: data['numero_tarjeta'],
                                cardHolderName: data['nombre_titular'],
                                expiryDate: data['fecha_expiracion'],
                                cardColor: Color(data['color']),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                              // Ícono de eliminar movido a la parte superior izquierda
                              Positioned(
                                top: 10,
                                left: 10,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => _deleteCard(context, docId),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 10),
            _buildAddCardButton(context),
            SizedBox(height: 20),
            _buildPayButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCardButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => AddCardPage());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.black),
            SizedBox(width: 10),
            Text(
              'Agregar tarjeta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
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
        onPressed: () => _handlePayment(context),
        child: Text(
          'Pagar',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}