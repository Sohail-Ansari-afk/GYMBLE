import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';

class AsyncDropdownButton<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final bool isLoading;
  final String Function(T) itemText;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final Widget Function(T)? selectedItemBuilder;
  final Widget Function(T)? itemBuilder;

  const AsyncDropdownButton({
    Key? key,
    required this.hint,
    required this.value,
    required this.items,
    required this.isLoading,
    required this.itemText,
    this.validator,
    this.onChanged,
    this.selectedItemBuilder,
    this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: true,
        hint: Text(
          hint,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: CupertinoColors.placeholderText,
          ),
        ),
        items: isLoading
            ? []
            : items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: itemBuilder != null
                      ? itemBuilder!(item)
                      : Text(
                          itemText(item),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                          ),
                        ),
                );
              }).toList(),
        value: value,
        onChanged: onChanged,
        selectedItemBuilder: selectedItemBuilder != null
            ? (context) {
                return items.map((item) {
                  return selectedItemBuilder!(item);
                }).toList();
              }
            : null,
        buttonStyleData: ButtonStyleData(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
            ),
            color: CupertinoColors.systemBackground,
          ),
        ),
        iconStyleData: IconStyleData(
          icon: isLoading
              ? const CupertinoActivityIndicator()
              : const Icon(
                  CupertinoIcons.chevron_down,
                  size: 18,
                ),
          iconSize: 18,
          iconEnabledColor: CupertinoColors.systemGrey,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: CupertinoColors.systemBackground,
          ),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(6),
            thumbVisibility: MaterialStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}