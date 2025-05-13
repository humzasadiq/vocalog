import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final String initialValue;
  final Function(String) onChanged;

  const LanguageDropdown({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  static const Map<String, String> languageOptions = {
    'auto': 'Auto Detect',
    'urd': 'Urdu',
    'eng': 'English',
    'spa': 'Spanish',
    'fra': 'French',
    'deu': 'German',
    'ita': 'Italian',
    'por': 'Portuguese',
    'pol': 'Polish',
    'tur': 'Turkish',
    'rus': 'Russian',
    'nld': 'Dutch',
    'ces': 'Czech',
    'ara': 'Arabic',
    'hin': 'Hindi',
    'jpn': 'Japanese',
    'kor': 'Korean',
    'zho': 'Chinese (Mandarin)',
    'vie': 'Vietnamese',
    'ind': 'Indonesian',
    'msa': 'Malay',
    'tha': 'Thai',
    'ben': 'Bengali',
    'ukr': 'Ukrainian',
    'heb': 'Hebrew',
    'tam': 'Tamil',
    'tel': 'Telugu',
    'mar': 'Marathi',
    'fil': 'Filipino',
    'cat': 'Catalan',
    'swe': 'Swedish',
    'dan': 'Danish',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade600),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: languageOptions.containsKey(initialValue) ? initialValue : 'auto',
            dropdownColor: const Color.fromARGB(255, 47, 47, 47),
            style: TextStyle(color: Colors.grey.shade300),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
            ),
            items: languageOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
} 