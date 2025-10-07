class EligibilityResult {
  final bool eligible;
  final double? amount;
  final double? interestRate;
  final List<String>? terms;
  final List<String>? reasons;
  final String? mobile;
  final String? partnerId;
  final String? sessionId;
  final Map<String, dynamic>? result;

  EligibilityResult({
    required this.eligible,
    this.amount,
    this.interestRate,
    this.terms,
    this.reasons,
    this.mobile,
    this.partnerId,
    this.sessionId,
    this.result,
  });

  factory EligibilityResult.fromJson(Map<String, dynamic> json) {
    return EligibilityResult(
      eligible: json['eligible'] ?? false,
      amount:
      (json['amount'] != null) ? (json['amount'] as num).toDouble() : null,
      interestRate: (json['interestRate'] != null)
          ? (json['interestRate'] as num).toDouble()
          : null,
      terms: json['terms'] != null ? List<String>.from(json['terms']) : null,
      reasons:
      json['reasons'] != null ? List<String>.from(json['reasons']) : null,
      mobile: json['mobile'],
      partnerId: json['partnerId'],
      sessionId: json['sessionId'],
      result: json['result'] != null
          ? Map<String, dynamic>.from(json['result'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eligible': eligible,
      'amount': amount,
      'interestRate': interestRate,
      'terms': terms,
      'reasons': reasons,
      'mobile': mobile,
      'partnerId': partnerId,
      'sessionId': sessionId,
      'result': result,
    };
  }
}

class PartnerConfig {
  final String? partnerId;
  final String? partnerName;
  final String? userId;
  final Map<String, dynamic>? userData;
  final String? sessionId;
  final String? phoneNumber;
  final ThemeConfig? theme;
  final String apiKey;
  final String apiSecret;
  final String? environment;

  PartnerConfig({
    this.partnerId,
    this.partnerName,
    this.userId,
    this.userData,
    this.sessionId,
    this.phoneNumber,
    this.theme,
    required this.apiKey,
    required this.apiSecret,
    this.environment,
  });

  factory PartnerConfig.fromJson(Map<String, dynamic> json) {
    return PartnerConfig(
      partnerId: json['partnerId'],
      partnerName: json['partnerName'],
      userId: json['userId'],
      userData: json['userData'] != null
          ? Map<String, dynamic>.from(json['userData'])
          : null,
      sessionId: json['sessionId'],
      phoneNumber: json['phoneNumber'],
      theme: json['themeConfig'] != null
          ? ThemeConfig.fromJson(Map<String, dynamic>.from(json['themeConfig']))
          : null,
      apiKey: json['apiKey'] ?? '',
      apiSecret: json['apiSecret'] ?? '',
      environment: json['environment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partnerId': partnerId,
      'partnerName': partnerName,
      'userId': userId,
      'userData': userData,
      'sessionId': sessionId,
      'phoneNumber': phoneNumber,
      'themeConfig': theme?.toJson(),
      'apiKey': apiKey,
      'apiSecret': apiSecret,
      'environment': environment,
    };
  }
}

class ThemeConfig {
  final String? primaryColor;
  final String? secondaryColor;
  final String? fontFamily;
  final String? logoUrl;
  final String? name;

  ThemeConfig({
    this.primaryColor,
    this.secondaryColor,
    this.fontFamily,
    this.logoUrl,
    this.name,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
      fontFamily: json['fontFamily'],
      logoUrl: json['logoUrl'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'fontFamily': fontFamily,
      'logoUrl': logoUrl,
      'name': name,
    };
  }
}

enum SDKMode {
  popup,
  inline,
}

enum SDKEventType {
  ready,
  eligibilityResult,
  error,
  close,
  initiated,
  closeFrame,
}

class SDKEvent {
  final SDKEventType type;
  final Map<String, dynamic>? data;

  SDKEvent({
    required this.type,
    this.data,
  });
}

class SDKError {
  final String code;
  final String message;

  SDKError({
    required this.code,
    required this.message,
  });
}
