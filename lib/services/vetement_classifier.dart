import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import '../modeles/categorie_vetement.dart';

class VetementClassifier {
  VetementClassifier._internal();
  static final VetementClassifier instance = VetementClassifier._internal();

  bool _modelReady = false;
  JSObject get _jsGlobal => globalContext;

  Future<void> preloadModel() async {
    if (_modelReady) return;
    try {
      final modelPath = Uri.base.resolve('assets/images/model_unquant.tflite');
      final jsPromise = _jsGlobal.callMethod(
        'initNoraModel'.toJS,
        modelPath.toString().toJS,
      ) as JSPromise;
      await jsPromise.toDart;
      _modelReady = true;
      debugPrint('[VetementClassifier] Model ready');
    } catch (e) {
      debugPrint('[VetementClassifier] Failed to load model: $e');
    }
  }

  Future<CategorieVetement?> detecterDepuisBytes(List<int> imageBytes) async {
    await preloadModel();

    final buffer = Uint8List.fromList(imageBytes).buffer.toJS;
    final blob = web.Blob(
      [buffer].toJS,
      web.BlobPropertyBag(type: 'image/jpeg'),
    );

    final urlApi = _jsGlobal['URL'] as JSObject;
    final blobUrl = (urlApi.callMethod(
      'createObjectURL'.toJS,
      blob,
    ) as JSString)
        .toDart;

    try {
      return await _runDetection(blobUrl);
    } finally {
      urlApi.callMethod('revokeObjectURL'.toJS, blobUrl.toJS);
    }
  }

  Future<CategorieVetement?> _runDetection(String imageUrl) async {
    try {
      final jsPromise = _jsGlobal.callMethod(
        'runNoraDetection'.toJS,
        imageUrl.toJS,
      ) as JSPromise;

      final result = await jsPromise.toDart;
      final jsResult = result as JSObject?;
      if (jsResult == null) return null;

      final label = (jsResult['categoryName'] as JSString?)?.toDart;
      final index =
          (jsResult['categoryIndex'] as JSNumber?)?.toDartDouble.round();

      final detected = label ?? _indexToLibelle(index ?? 0);
      debugPrint('[VetementClassifier] Result: $detected');
      return CategorieVetement.fromLibelle(detected);
    } catch (e) {
      debugPrint('[VetementClassifier] Detection error: $e');
      return null;
    }
  }

  String _indexToLibelle(int index) {
    const mapping = [
      'Haut', // index 0
      'Pantalon', // index 1
      'Short', // index 2
      'Veste', // index 3
    ];
    if (index >= 0 && index < mapping.length) return mapping[index];
    return 'Haut';
  }
}
