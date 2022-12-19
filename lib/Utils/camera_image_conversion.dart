import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart';
import 'package:mr_tcp/method_channelling/yuv_chanelling.dart';
import 'package:path_provider/path_provider.dart';

/*typedef convert_func = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

final DynamicLibrary convertImageLib = Platform.isAndroid
    ? DynamicLibrary.open("libconvertImage.so")
    : DynamicLibrary.process();

Convert? conv;*/

YuvChannelling _yuvChannelling = YuvChannelling();


/*init() {
  // Load the convertImage() function from the library
  // conv=convertImageLib.lookupFunction('convertImage');
  conv = convertImageLib
      .lookup<NativeFunction<convert_func>>('convertImage')
      .asFunction();
}

Uint8List? convertYUV420toImageColorWithC(CameraImage image) {
  if (conv == null) {
    init();
  }
  Uint8List? bytes;
  try {
    // Allocate memory for the 3 planes of the image

    Pointer<Uint8> p = calloc.call(image.planes[0].bytes.length);
    // p.value= image.planes[0].bytes.length;
    Pointer<Uint8> p1 = calloc.call(image.planes[1].bytes.length);
    // p1.value= image.planes[1].bytes.length;
    Pointer<Uint8> p2 = calloc.call(image.planes[2].bytes.length);
    // p2.value= image.planes[2].bytes.length;


    print(
        '${image.planes[0].bytes.length} ${image.planes[1].bytes.length} ${image.planes[2].bytes.length}');
    print(
        '${image.planes[1].bytesPerRow} ${image.planes[1].bytesPerPixel} ${image.width} ${image.height}');
    print(image.planes[0].bytesPerRow);

    print('*');
    // Assign the planes data to the pointers of the image
    Uint8List pointerList = p.asTypedList(image.planes[0].bytes.length);
    print('*');
    Uint8List pointerList1 = p1.asTypedList(image.planes[1].bytes.length);
    print('*');
    Uint8List pointerList2 = p2.asTypedList(image.planes[2].bytes.length);
    print('*');
    pointerList.setRange(
        0, image.planes[0].bytes.length, image.planes[0].bytes);
    print('*');
    pointerList1.setRange(
        0, image.planes[1].bytes.length, image.planes[1].bytes);
    print('*');
    pointerList2.setRange(
        0, image.planes[2].bytes.length, image.planes[2].bytes);
    print('*');

    // Call the convertImage function and convert the YUV to RGB
    Pointer<Uint32> imgP = conv!(p, p1, p2, image.planes[1].bytesPerRow,
        image.planes[1].bytesPerPixel!, image.width, image.height);
    print('*');
    // Get the pointer of the data returned from the function to a List
    List<int> imgData =
        imgP.asTypedList((image.planes[0].bytesPerRow * image.height));
    print('*');
    // Generate image from the converted data
    // var img = imglib.Image.fromBytes(image.height, image.planes[0].bytesPerRow, imgData);

    // Free the memory space allocated
    // from the planes and the converted data
    calloc.free(imgP);
    print('*');
    calloc.free(p);
    print('*');
    calloc.free(p1);
    print('*');
    calloc.free(p2);
    print('*');

    bytes = Uint8List.fromList(imgData);
    print('*');
    // String tempPath = (await getTemporaryDirectory()).path;
    // File file = File('$tempPath/image.png');
    // await file.writeAsBytes(
    //     bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
  } catch (e) {
    return null;
  }
  return bytes;
}

Future<Uint8List?> compressImageFromList(Uint8List image) async {
  var result = await FlutterImageCompress.compressWithList(
    image,
    quality: 20,
  );
  return result;
}

Future<Uint8List?> compressImage(File file) async {
  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: 20,
  );
  // print(file.lengthSync());
  // print(result?.length);
  return result;
}

Future<Uint8List?> convertYUV420toImageColor(CameraImage image) async {
  var start = DateTime.now();

  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 0;

    print(
        '${image.planes[0].bytes.length} ${image.planes[1].bytes.length} ${image.planes[2].bytes.length}');
    print(
        '${image.planes[1].bytesPerRow} ${image.planes[1].bytesPerPixel} ${image.width} ${image.height}');
    print(image.planes[0].bytesPerRow);

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var img = Image(width, height); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
    }
    print((DateTime.now().difference(start).inMilliseconds));
    PngEncoder pngEncoder = PngEncoder(level: 0, filter: 0);
    Uint8List png = Uint8List.fromList(pngEncoder.encodeImage(img));

    // muteYUVProcessing = false;
    print((DateTime.now().difference(start).inMilliseconds));
    return png;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}*/

Future<Uint8List> convertYUV420toImageColor2(CameraImage cameraImage) async {
  return await _yuvChannelling.yuv_transform(cameraImage);
}
