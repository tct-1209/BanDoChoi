import 'package:flutter/foundation.dart';
import '../models/address.dart';

class AddressProvider extends ChangeNotifier {
  final List<Address> _addresses = [
    // Mock addresses for demo
    Address(
      id: 'ADDR001',
      userId: '2',
      fullName: 'Nguyễn Văn A',
      phone: '0987654321',
      street: '123 Nguyễn Văn Linh',
      ward: 'Phường 1',
      district: 'Quận 7',
      city: 'TP.HCM',
      isDefault: true,
    ),
    Address(
      id: 'ADDR002',
      userId: '2',
      fullName: 'Nguyễn Văn A',
      phone: '0987654321',
      street: '456 Lê Văn Việt',
      ward: 'Phường Tăng Nhơn Phú A',
      district: 'Quận 9',
      city: 'TP.HCM',
      isDefault: false,
    ),
  ];

  List<Address> get addresses => _addresses;

  List<Address> getAddressesByUserId(String userId) {
    return _addresses.where((addr) => addr.userId == userId).toList();
  }

  Address? getDefaultAddress(String userId) {
    try {
      return _addresses.firstWhere(
        (addr) => addr.userId == userId && addr.isDefault,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> addAddress(Address address) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (address.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        if (_addresses[i].userId == address.userId && _addresses[i].isDefault) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
    }
    
    _addresses.add(address);
    notifyListeners();
  }

  Future<void> updateAddress(Address address) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _addresses.indexWhere((addr) => addr.id == address.id);
    if (index >= 0) {
      if (address.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          if (_addresses[i].userId == address.userId && _addresses[i].isDefault && i != index) {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
        }
      }
      _addresses[index] = address;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addresses.removeWhere((addr) => addr.id == addressId);
    notifyListeners();
  }

  Future<void> setDefaultAddress(String addressId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (var i = 0; i < _addresses.length; i++) {
      if (_addresses[i].userId == userId) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: _addresses[i].id == addressId,
        );
      }
    }
    notifyListeners();
  }
}
