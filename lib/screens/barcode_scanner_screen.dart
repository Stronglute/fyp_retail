// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
//
// import '../widgets/drawer.dart';
//
// class BarcodeScannerScreen extends StatelessWidget {
//   const BarcodeScannerScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Scan Barcode')),
//       drawer: POSDrawer(),
//       body: MobileScanner(
//         onDetect: (capture) {
//           final barcode = capture.barcodes.firstOrNull;
//           if (barcode != null && barcode.rawValue != null) {
//             Navigator.pop(context, barcode.rawValue);
//           }
//         },
//       ),
//     );
//   }
// }
