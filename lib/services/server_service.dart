import 'dart:io';

class ServerService {
  static String name1 = "TIM 1", logoPath1 = "";
  static String name2 = "TIM 2", logoPath2 = "";

  static void updateData(String n1, String l1, String n2, String l2) {
    name1 = n1;
    logoPath1 = l1;
    name2 = n2;
    logoPath2 = l2;
  }

  static Future<void> startServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    print('Server jalan di http://localhost:8080');

    server.listen((HttpRequest request) async {
      final path = request.uri.path;

      // Tambahkan pengecekan .html di sini
      if (path == '/logo1' || path == '/logo1.html') {
        _serveImageHtml(request, logoPath1, "logo1_img");
      } else if (path == '/logo2' || path == '/logo2.html') {
        _serveImageHtml(request, logoPath2, "logo2_img");
      } else if (path == '/name1' || path == '/name1.html') {
        _serveText(request, name1);
      } else if (path == '/name2' || path == '/name2.html') {
        _serveText(request, name2);
      }
      // ... dst untuk logo1_img dan logo2_img tetap sama
      else if (path == '/logo1_img')
        await _sendRawImage(request, logoPath1);
      else if (path == '/logo2_img')
        await _sendRawImage(request, logoPath2);
      else {
        request.response.close();
      }
    });
  }

  static void _serveImageHtml(
    HttpRequest request,
    String filePath,
    String endpoint,
  ) {
    request.response.headers.contentType = ContentType.html;
    request.response.write(
      '<html><head><meta http-equiv="refresh" content="2"></head><body style="margin:0;display:flex;justify-content:center;align-items:center;"><img src="/$endpoint?t=${DateTime.now().millisecondsSinceEpoch}" style="max-width:100%;max-height:100%;object-fit:contain;"></body></html>',
    );
    request.response.close();
  }

  static Future<void> _sendRawImage(
    HttpRequest request,
    String filePath,
  ) async {
    if (filePath.isNotEmpty) {
      final file = File(filePath);
      if (await file.exists()) {
        request.response.headers.contentType = ContentType('image', 'png');
        await file.openRead().pipe(request.response);
        return;
      }
    }
    request.response.headers.contentType = ContentType('image', 'png');
    request.response.add([
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      13,
      73,
      72,
      68,
      82,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      8,
      6,
      0,
      0,
      0,
      31,
      21,
      196,
      137,
      0,
      0,
      0,
      11,
      73,
      68,
      65,
      84,
      8,
      215,
      99,
      96,
      0,
      2,
      0,
      0,
      5,
      0,
      1,
      226,
      38,
      5,
      155,
      0,
      0,
      0,
      0,
      73,
      69,
      78,
      68,
      174,
      66,
      96,
      130,
    ]);
    await request.response.close();
  }

  static void _serveText(HttpRequest request, String text) {
    request.response.headers.contentType = ContentType.html;
    request.response.write(
      '<html><head><meta http-equiv="refresh" content="1"></head><body style="color:white;font-family:sans-serif;font-size:50px;font-weight:bold;text-shadow:2px 2px 4px black;margin:0;display:flex;align-items:center;justify-content:center;">$text</body></html>',
    );
    request.response.close();
  }
}
