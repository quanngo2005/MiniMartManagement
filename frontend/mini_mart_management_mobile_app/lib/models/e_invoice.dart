class EInvoice {
  const EInvoice({
    required this.eInvoiceId,
    required this.orderId,
    required this.orderCode,
    required this.invoiceSerial,
    required this.invoiceNumber,
    required this.totalBeforeVAT,
    required this.vatAmount,
    required this.totalAfterVAT,
    required this.issuedAt,
    required this.status,
    this.buyerTaxCode,
    this.buyerName,
    this.buyerAddress,
    this.gdtAuthCode,
    this.xmlContent,
  });

  final int eInvoiceId;
  final int orderId;
  final String orderCode;
  final String invoiceSerial;
  final String invoiceNumber;
  final String? buyerTaxCode;
  final String? buyerName;
  final String? buyerAddress;
  final double totalBeforeVAT;
  final double vatAmount;
  final double totalAfterVAT;
  final String? gdtAuthCode;
  final String? xmlContent;
  final DateTime? issuedAt;
  final bool status;

  factory EInvoice.fromJson(Map<String, dynamic> json) {
    return EInvoice(
      eInvoiceId: _asInt(json['eInvoiceId'] ?? json['EInvoiceId']),
      orderId: _asInt(json['orderId'] ?? json['OrderId']),
      orderCode: (json['orderCode'] ?? json['OrderCode'] ?? '') as String,
      invoiceSerial:
          (json['invoiceSerial'] ?? json['InvoiceSerial'] ?? '') as String,
      invoiceNumber:
          (json['invoiceNumber'] ?? json['InvoiceNumber'] ?? '') as String,
      buyerTaxCode: _asStringOrNull(
        json['buyerTaxCode'] ?? json['BuyerTaxCode'],
      ),
      buyerName: _asStringOrNull(json['buyerName'] ?? json['BuyerName']),
      buyerAddress: _asStringOrNull(
        json['buyerAddress'] ?? json['BuyerAddress'],
      ),
      totalBeforeVAT: _asDouble(
        json['totalBeforeVAT'] ?? json['TotalBeforeVAT'],
      ),
      vatAmount: _asDouble(json['vatAmount'] ?? json['VATAmount']),
      totalAfterVAT: _asDouble(json['totalAfterVAT'] ?? json['TotalAfterVAT']),
      gdtAuthCode: _asStringOrNull(json['gdtAuthCode'] ?? json['GDTAuthCode']),
      xmlContent: _asStringOrNull(json['xmlContent'] ?? json['XMLContent']),
      issuedAt: _parseDate(json['issuedAt'] ?? json['IssuedAt']),
      status: (json['status'] ?? json['Status'] ?? false) == true,
    );
  }

  String get statusLabel => status ? 'Đã phát hành' : 'Tạm lưu';
}

class EInvoiceDetailResponse {
  const EInvoiceDetailResponse({required this.invoice, required this.items});

  final EInvoice invoice;
  final List<EInvoiceDetail> items;

  factory EInvoiceDetailResponse.fromJson(Map<String, dynamic> json) {
    final invoiceJson = json['invoice'] ?? json['Invoice'];
    final itemsJson = json['items'] ?? json['Items'];

    return EInvoiceDetailResponse(
      invoice: EInvoice.fromJson(Map<String, dynamic>.from(invoiceJson as Map)),
      items: (itemsJson as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(EInvoiceDetail.fromJson)
          .toList(growable: false),
    );
  }
}

class EInvoiceDetail {
  const EInvoiceDetail({
    required this.eInvoiceDetailId,
    required this.eInvoiceId,
    required this.orderDetailId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.amountBeforeVAT,
    required this.vatRate,
    required this.vatAmount,
    required this.amountAfterVAT,
  });

  final int eInvoiceDetailId;
  final int eInvoiceId;
  final int orderDetailId;
  final String productName;
  final String unit;
  final int quantity;
  final double unitPrice;
  final double discountAmount;
  final double amountBeforeVAT;
  final double vatRate;
  final double vatAmount;
  final double amountAfterVAT;

  factory EInvoiceDetail.fromJson(Map<String, dynamic> json) {
    return EInvoiceDetail(
      eInvoiceDetailId: _asInt(
        json['eInvoiceDetailId'] ?? json['EInvoiceDetailId'],
      ),
      eInvoiceId: _asInt(json['eInvoiceId'] ?? json['EInvoiceId']),
      orderDetailId: _asInt(json['orderDetailId'] ?? json['OrderDetailId']),
      productName: (json['productName'] ?? json['ProductName'] ?? '') as String,
      unit: (json['unit'] ?? json['Unit'] ?? '') as String,
      quantity: _asInt(json['quantity'] ?? json['Quantity']),
      unitPrice: _asDouble(json['unitPrice'] ?? json['UnitPrice']),
      discountAmount: _asDouble(
        json['discountAmount'] ?? json['DiscountAmount'],
      ),
      amountBeforeVAT: _asDouble(
        json['amountBeforeVAT'] ?? json['AmountBeforeVAT'],
      ),
      vatRate: _asDouble(json['vatRate'] ?? json['VatRate']),
      vatAmount: _asDouble(json['vatAmount'] ?? json['VatAmount']),
      amountAfterVAT: _asDouble(
        json['amountAfterVAT'] ?? json['AmountAfterVAT'],
      ),
    );
  }
}

int _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
String? _asStringOrNull(dynamic value) => value?.toString();
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse('$value');
}
