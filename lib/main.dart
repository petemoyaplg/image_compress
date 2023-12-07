import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Compress image',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Compress image'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<File> originalImages = [];
  File? originalImage;
  File? compressedImage;
  List<File> compressedImages = [];
  int length1 = 0;
  int length2 = 0;
  double variation = 0;
  String taux = "";

  Future<Directory?> getDirectory() async {
    return Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory(); //FOR iOS
  }

  Future pickImages() async {
    List<XFile> files = await ImagePicker().pickMultiImage();
    print("=================================");
    print(files.length);
    print(originalImages.length);
    for (XFile xFile in files) {
      File file = File(xFile.path);
      length1 += await file.length();
      originalImages.add(file);
    }
    print("=================================");
    print(files.length);
    print(originalImages.length);
    setState(() {});
  }

  Future compress() async {
    if (originalImage == null) return null;
    Directory? folderStorage = await getDirectory();
    for (File oFile in originalImages) {
      XFile? cxFile = await FlutterImageCompress.compressAndGetFile(
        oFile.path,
        '${folderStorage!.path}/commpress.jpg',
        quality: 10,
      );
      if (cxFile != null) {
        File file = File(cxFile.path);
        length2 += await file.length();
        compressedImages.add(file);
      }
    }
    variation = (length2 - length1) / length1 * 100;
    taux = variation.abs().toStringAsFixed(2);
    setState(() {});
    // XFile? cfile = await FlutterImageCompress.compressAndGetFile(
    //   originalImage!.path,
    //   '${folderStorage!.path}/commpress.jpg',
    //   quality: 10,
    // );
    // if (cfile != null) {
    //   compressedImage = File(cfile.path);
    // }

    // length2 = await compressedImage?.length();

    // if (length1 != null && length2 != null) {
    //   variation = (length2! - length1!) / length1! * 100;
    //   taux = variation!.abs().toStringAsFixed(2);
    // }

    // setState(() {});
  }

  Future<List<XFile>> compressImages(List<File> files) async {
    List<XFile> cfiles = [];
    for (dynamic file in files) {
      XFile? imgComp = await compressImage(file);
      if (imgComp != null) cfiles.add(imgComp);
    }
    return cfiles;
  }

  Future<XFile?> compressImage(dynamic file) async {
    XFile? imgComp = await FlutterImageCompress.compressAndGetFile(
      file.path,
      '${file.path}/commpress.jpg',
      quality: 10,
    );
    if (imgComp != null) return imgComp;
    return null;
  }

  String convert(int size) {
    final kb = size / 1024;
    final mb = kb / 1024;
    return (mb >= 1)
        ? '${mb.toStringAsFixed(2)} MB'
        : '${kb.toStringAsFixed(2)} KB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Original Image",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        originalImages.isNotEmpty
                            ? Column(
                                children: originalImages
                                    .map((image) => SizedBox(
                                          height: 200,
                                          width: 200,
                                          child: Image.file(image),
                                        ))
                                    .toList(),
                              )
                            : const Text(''),
                        originalImages.isNotEmpty
                            ? Text(
                                convert(length1),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const Text(""),
                        TextButton(
                          onPressed: () async {
                            await pickImages();
                          },
                          child: const Text("Pick an image"),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Compressed Image",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        compressedImages.isNotEmpty
                            ? Column(
                                children: compressedImages
                                    .map((image) => SizedBox(
                                          height: 200,
                                          width: 200,
                                          child: Image.file(image),
                                        ))
                                    .toList(),
                              )
                            : const Text(''),
                        compressedImages.isNotEmpty
                            ? Text(
                                convert(length2),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const Text(""),
                        TextButton(
                          onPressed: () async {
                            await compress();
                          },
                          child: const Text("Compress image"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                compressedImage != null
                    ? Text(
                        'Taux de variation : $taux %',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : const Text('')
              ],
            )
          ],
        ),
      ),
    );
  }
}
