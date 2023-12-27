abstract class AppValidators {
  static bool isValidEmail(String value) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(value);
  }

  static bool isValidPassword(String value) {
    final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegExp.hasMatch(value);
  }

  static bool isValidPhone(String value) {
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,13}$');
    return phoneRegExp.hasMatch(value);
  }

  static bool isValidName(String value) {
    final nameRegExp = RegExp(r'^[a-zA-Zа-яА-ЯёЁ]+(?: [a-zA-Zа-яА-ЯёЁ]+)*$');
    return nameRegExp.hasMatch(value);
  }

  static bool isValidNumber(String value) {
    final numberRegExp = RegExp(r'^[0-9]+$');
    return numberRegExp.hasMatch(value);
  }

  static bool isValidUrl(String value) {
    final urlRegExp = RegExp(r'^(http(s)?:\/\/)?((w){3}.)?youtu(be|.be)?(\.com)?\/.+$');
    return urlRegExp.hasMatch(value);
  }

  static bool isValidIp(String value) {
    final ipRegExp = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    return ipRegExp.hasMatch(value);
  }
}
