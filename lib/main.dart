import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metodo_tarjetas/views/pagina_pago.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metodo_tarjetas/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(PaymentMethodsPage());
}