import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mini_mart_management_mobile_app/models/receipt.dart';

class ReceiptPdfService {
  const ReceiptPdfService();

  Future<void> printReceipt(Receipt receipt) async {
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final document = pw.Document();
    final currency = (double value) => '${value.toStringAsFixed(0)} đ';

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (_) => [
          pw.Text(
            'PHIẾU NHẬP KHO',
            style: pw.TextStyle(font: boldFont, fontSize: 20),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Mã phiếu: ${receipt.receiptCode}'),
          pw.Text('Ngày nhập: ${receipt.importDate.toLocal()}'),
          pw.Text('Nhà cung cấp: ${receipt.supplierName}'),
          pw.Text('Nhân viên: ${receipt.employeeName}'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: const ['Sản phẩm', 'Mã lô', 'SL', 'Đơn giá', 'Thành tiền'],
            data: receipt.batchLines
                .map(
                  (line) => [
                    line.productName,
                    line.batchCode,
                    line.quantity.toString(),
                    currency(line.importPrice),
                    currency(line.importPrice * line.quantity),
                  ],
                )
                .toList(growable: false),
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Tổng tiền: ${currency(receipt.totalAmount)}'),
                pw.Text('Đã thanh toán: ${currency(receipt.paidAmount)}'),
                pw.Text('Còn nợ: ${currency(receipt.debtAmount)}'),
              ],
            ),
          ),
          if (receipt.note?.isNotEmpty ?? false) ...[
            pw.SizedBox(height: 16),
            pw.Text('Ghi chú: ${receipt.note}'),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => document.save());
  }
}
