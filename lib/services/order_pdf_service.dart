import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../config/company_config.dart';
import '../models/order.dart';
import '../utils/currency_formatter.dart';

/// Service responsible for generating professional, print-ready PDF order documents
/// directly on the device using existing historical order snapshots.
class OrderPdfService {
  // Theme Color Palette
  static final _cPrimary = PdfColor.fromInt(0xFF0D9488);
  static final _cDark = PdfColor.fromInt(0xFF0F172A);
  static final _cSlate = PdfColor.fromInt(0xFF1E293B);
  static final _cMuted = PdfColor.fromInt(0xFF475569);
  static final _cBorder = PdfColor.fromInt(0xFFE2E8F0);
  static final _cDivider = PdfColor.fromInt(0xFFCBD5E1);
  static final _cBg = PdfColor.fromInt(0xFFF8FAFC);
  static final _cRowBorder = PdfColor.fromInt(0xFFF1F5F9);
  static final _cRep = PdfColor.fromInt(0xFF0284C7);
  static final _cDoc = PdfColor.fromInt(0xFF0D9488);
  static final _cChemist = PdfColor.fromInt(0xFF7C3AED);

  /// Generates a PDF byte array for the specified [order].
  ///
  /// Uses strictly the historical data preserved within [order] without querying
  /// any live Firestore collections.
  static Future<Uint8List> generateOrderPdf(OrderModel order) async {
    final pdf = pw.Document(
      title: '${CompanyConfig.companyName} - ${order.orderNumber}',
      author: CompanyConfig.companyName,
    );

    // Load fonts with Unicode support for Indian Rupee symbol; fallback to Helvetica if offline
    pw.ThemeData? theme;
    try {
      final fontRegular = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();
      theme = pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
      );
    } catch (_) {
      theme = pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      );
    }

    final formattedDate = _formatDateTime(order.createdAt);
    final statusText = order.status.toUpperCase();
    final statusColor = _getStatusColor(order.status);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        theme: theme,
        header: (context) => _buildRunningHeader(context, order),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildDocumentHeader(order, formattedDate, statusText, statusColor),
          pw.SizedBox(height: 14),
          _buildPartiesSection(order),
          pw.SizedBox(height: 16),
          _buildItemsTable(order),
          pw.SizedBox(height: 14),
          _buildTotalsSection(order),
        ],
      ),
    );

    return pdf.save();
  }

  /// Compact header shown on page 2 and beyond.
  static pw.Widget _buildRunningHeader(pw.Context context, OrderModel order) {
    if (context.pageNumber == 1) {
      return pw.SizedBox.shrink();
    }
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${CompanyConfig.companyName} | ${CompanyConfig.documentTitle}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.Text(
            'Order: ${order.orderNumber}',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }

  /// Main header on the first page displaying company details, order ID, date, and status.
  static pw.Widget _buildDocumentHeader(
    OrderModel order,
    String formattedDate,
    String statusText,
    PdfColor statusColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _cBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: _cBorder),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                CompanyConfig.companyName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _cDark,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                CompanyConfig.documentTitle.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _cPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'Order #: ',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    order.orderNumber.isNotEmpty ? order.orderNumber : 'N/A',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: _cDark,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'Date: ',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    formattedDate,
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey900,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: pw.BoxDecoration(
                  color: statusColor,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(3),
                  ),
                ),
                child: pw.Text(
                  statusText,
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Clearly separated cards for Representative, Doctor, and Chemist snapshots.
  static pw.Widget _buildPartiesSection(OrderModel order) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _buildPartyCard(
            title: 'REPRESENTATIVE',
            titleColor: _cRep,
            lines: [
              _PartyField('Name', order.representativeName),
              _PartyField('Email', order.representativeEmail),
            ],
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _buildPartyCard(
            title: 'DOCTOR',
            titleColor: _cDoc,
            lines: [
              _PartyField('Name', order.doctorName),
              _PartyField('Specialization', order.doctorSpecialization),
              _PartyField('Phone', order.doctorPhone),
            ],
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _buildPartyCard(
            title: 'CHEMIST',
            titleColor: _cChemist,
            lines: [
              _PartyField('Name', order.chemistName),
              _PartyField('Phone', order.chemistPhone),
              _PartyField('Address', order.chemistAddress),
            ],
          ),
        ),
      ],
    );
  }

  /// Individual information card with a colored header bar.
  static pw.Widget _buildPartyCard({
    required String title,
    required PdfColor titleColor,
    required List<_PartyField> lines,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: _cBorder),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: titleColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(3),
                topRight: pw.Radius.circular(3),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(7),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: lines.map((field) {
                final displayVal =
                    field.value.isNotEmpty ? field.value : '—';
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: '${field.label}: ',
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            fontWeight: pw.FontWeight.bold,
                            color: _cMuted,
                          ),
                        ),
                        pw.TextSpan(
                          text: displayVal,
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            color: _cDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Multi-page capable Medicine Items Table with repeating headers.
  static pw.Widget _buildItemsTable(OrderModel order) {
    if (order.items.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _cBorder),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        alignment: pw.Alignment.center,
        child: pw.Text(
          'No medicine items recorded for this order.',
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      );
    }

    final headers = [
      '#',
      'Medicine',
      'Brand',
      'Variant',
      'Strength',
      'Pack Size',
      'MRP',
      'Supplier Price',
      'Qty',
      'Item Total',
    ];

    final data = <List<String>>[];
    for (int i = 0; i < order.items.length; i++) {
      final item = order.items[i];
      data.add([
        (i + 1).toString(),
        item.medicineName.isNotEmpty ? item.medicineName : '—',
        item.brand.isNotEmpty ? item.brand : '—',
        item.form.isNotEmpty ? item.form : '—',
        item.strength.isNotEmpty ? item.strength : '—',
        item.packSize.isNotEmpty ? item.packSize : '—',
        formatCurrency(item.mrp, showDecimals: true),
        formatCurrency(item.supplierPrice, showDecimals: true),
        item.quantity.toString(),
        formatCurrency(item.itemTotal, showDecimals: true),
      ]);
    }

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(
        fontSize: 7.5,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: _cSlate,
      ),
      headerAlignment: pw.Alignment.centerLeft,
      headerAlignments: {
        0: pw.Alignment.center,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
        8: pw.Alignment.center,
        9: pw.Alignment.centerRight,
      },
      cellStyle: const pw.TextStyle(fontSize: 7),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.centerLeft,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
        8: pw.Alignment.center,
        9: pw.Alignment.centerRight,
      },
      columnWidths: const {
        0: pw.FixedColumnWidth(18),
        1: pw.FlexColumnWidth(2.4),
        2: pw.FlexColumnWidth(1.8),
        3: pw.FlexColumnWidth(1.3),
        4: pw.FlexColumnWidth(1.4),
        5: pw.FlexColumnWidth(1.3),
        6: pw.FlexColumnWidth(1.6),
        7: pw.FlexColumnWidth(1.8),
        8: pw.FixedColumnWidth(26),
        9: pw.FlexColumnWidth(2.0),
      },
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _cRowBorder, width: 0.5),
        ),
      ),
      oddRowDecoration: pw.BoxDecoration(
        color: _cBg,
      ),
    );
  }

  /// Bottom Totals Section showing Total Items, Total Quantity, and Total Order Value.
  static pw.Widget _buildTotalsSection(OrderModel order) {
    final formattedTotalValue =
        formatCurrency(order.totalAmount, showDecimals: true);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 220,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: _cBg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            border: pw.Border.all(color: _cDivider),
          ),
          child: pw.Column(
            children: [
              _buildTotalRow('Total Items:', order.totalItems.toString()),
              pw.SizedBox(height: 3),
              _buildTotalRow('Total Quantity:', order.totalQuantity.toString()),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Divider(color: _cDivider, thickness: 0.5),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Order Value:',
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _cDark,
                    ),
                  ),
                  pw.Text(
                    formattedTotalValue,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _cPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTotalRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 7.5,
            color: _cMuted,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: _cDark,
          ),
        ),
      ],
    );
  }

  /// Page Footer with legal disclaimer and page numbers.
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Computer-generated order document • ${CompanyConfig.companyName}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  /// Safely formats [DateTime] without relying on external internationalization packages.
  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final day = dateTime.day.toString().padLeft(2, '0');
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = months[dateTime.month - 1];
    final year = dateTime.year;

    final hour24 = dateTime.hour;
    final hour12 = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';

    return '$day $month $year, $hour12:$minute $period';
  }

  /// Maps status string to suitable PDF color.
  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const PdfColor(0.15, 0.39, 0.92); // Blue
      case 'processing':
        return const PdfColor(0.85, 0.47, 0.02); // Amber
      case 'delivered':
        return const PdfColor(0.02, 0.59, 0.41); // Green
      case 'cancelled':
        return const PdfColor(0.86, 0.15, 0.15); // Red
      case 'pending':
      default:
        return const PdfColor(0.39, 0.45, 0.55); // Slate
    }
  }
}

class _PartyField {
  final String label;
  final String value;
  const _PartyField(this.label, this.value);
}
