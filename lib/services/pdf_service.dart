import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Unified result for text extracted from any document (PDF or DOCX).
class PdfExtractResult {
  final String fileName;
  final int totalPages;
  final int extractedPages;
  final String text;

  const PdfExtractResult({
    required this.fileName,
    required this.totalPages,
    required this.extractedPages,
    required this.text,
  });
}

class PdfService {
  static const int _localMaxChars = 2000;
  static const int _remoteMaxChars = 6000;

  /// Opens a system file picker for **PDF and DOCX**, extracts plain text, and
  /// returns a [PdfExtractResult].  Returns null if the user cancels.
  static Future<PdfExtractResult?> pickAndExtract() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final Uint8List? bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null) throw Exception('Could not read file.');

    final ext = file.name.toLowerCase().split('.').last;
    if (ext == 'docx') return _extractDocx(file.name, bytes);
    return _extractPdf(file.name, bytes);
  }

  // ── PDF ─────────────────────────────────────────────────────────────────────

  static PdfExtractResult _extractPdf(String name, Uint8List bytes) {
    final doc = PdfDocument(inputBytes: bytes);
    final totalPages = doc.pages.count;
    final extractor = PdfTextExtractor(doc);

    final pagesToExtract = totalPages.clamp(1, 10);
    final raw = extractor.extractText(
      startPageIndex: 0,
      endPageIndex: pagesToExtract - 1,
    );
    doc.dispose();

    final clean = raw
        .replaceAll(RegExp(r'\r\n|\r'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();

    return PdfExtractResult(
      fileName: name,
      totalPages: totalPages,
      extractedPages: pagesToExtract,
      text: clean,
    );
  }

  // ── DOCX ────────────────────────────────────────────────────────────────────
  // A .docx file is a ZIP archive.  The main text lives in word/document.xml.

  static PdfExtractResult _extractDocx(String name, Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);

    ArchiveFile? docXml;
    for (final f in archive.files) {
      if (f.name == 'word/document.xml') {
        docXml = f;
        break;
      }
    }
    if (docXml == null) {
      throw Exception('Invalid .docx: word/document.xml not found');
    }

    final xmlStr = String.fromCharCodes(docXml.content as List<int>);
    final text = _parseDocxXml(xmlStr);

    return PdfExtractResult(
      fileName: name,
      totalPages: 1,
      extractedPages: 1,
      text: text,
    );
  }

  /// Walks the Word XML and reassembles paragraphs from <w:t> text runs.
  /// Uses regex on the known-ASCII tag names — no xml-parser dependency.
  static String _parseDocxXml(String xml) {
    final buffer = StringBuffer();
    final paraRe = RegExp(r'<w:p[ >].*?</w:p>', dotAll: true);
    final textRe = RegExp(r'<w:t(?:\s[^>]*)?>([^<]*)</w:t>');

    for (final para in paraRe.allMatches(xml)) {
      final sb = StringBuffer();
      for (final t in textRe.allMatches(para.group(0)!)) {
        sb.write(t.group(1) ?? '');
      }
      final line = sb.toString().trim();
      if (line.isNotEmpty) buffer.writeln(line);
    }

    return buffer
        .toString()
        .trim()
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  // ── Context builder ─────────────────────────────────────────────────────────

  static String buildContext(PdfExtractResult doc, {bool isRemote = false}) {
    final limit = isRemote ? _remoteMaxChars : _localMaxChars;
    final truncated = doc.text.length > limit;
    final snippet = truncated ? '${doc.text.substring(0, limit)}…' : doc.text;

    final pageInfo = doc.totalPages > 1
        ? '${doc.extractedPages}/${doc.totalPages} pages'
        : '1 page';

    final header = '[Document: ${doc.fileName}  ($pageInfo'
        '${truncated ? ', truncated' : ''})]';

    return '$header\n\n$snippet';
  }
}
