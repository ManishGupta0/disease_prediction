import 'dart:io';

import 'package:disease_prediction/loading_widget.dart';
import 'package:disease_prediction/result_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

final symptomsList = [
  'Headaches',
  'Nausia',
  'Vomiting',
  'Pain',
  'Fever',
  'Chills',
  'Sore throat',
  'Diarrhea',
  'Cough',
  'Shortness of breath',
  'Fatigue',
  'Muscle aches',
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> symptoms = [];
  final List<String> reports = [];

  TextEditingController _symptomController = TextEditingController();

  // var _selectedSymptom = '';

  void _addSymptom() {
    final s = _symptomController.text.trim();
    if (!symptoms.contains(s)) {
      symptoms.add(s);
    }
    _symptomController.clear();
  }

  void _removeSymptom(String symptom) {
    symptoms.remove(symptom);
    setState(() {});
  }

  void _pickReport() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      for (var p in result.paths) {
        if (p != null && !reports.contains(p)) {
          reports.add(p);
        }
      }
    }

    setState(() {});
  }

  void _removeReport(String path) {
    reports.remove(path);
    setState(() {});
  }

  void _clearReports() {
    reports.clear();
    setState(() {});
  }

  Future<void> _getAnalysisResult() async {
    await Future.delayed(const Duration(seconds: 5));
  }

  void _findDisease() async {
    showDialog(
      context: context,
      builder: (context) {
        return const SimpleDialog(
          children: [
            LoadingWidget(),
          ],
        );
      },
    );

    await _getAnalysisResult();
    if (mounted) {
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const ResultPage();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Disease Prediction App'),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _addSymptoms(),
                      const Divider(height: 32),
                      _addReports(),
                      const Divider(height: 32),
                      _addMedicines(),
                    ],
                  ),
                ),
              ),
              _findDiseaseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blockButton({
    required String label,
    Widget? icon,
    void Function()? onPressed,
  }) {
    if (icon == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
          ),
          child: Text(
            label,
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
        ),
        icon: icon,
        label: Text(
          label,
        ),
      ),
    );
  }

  Widget _inputAutocomplete() {
    return Autocomplete(
      onSelected: (option) {},
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        _symptomController = textEditingController;
        _symptomController.addListener(() {
          setState(() {});
        });

        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
          decoration: InputDecoration(
            hintText: 'find symptoms...',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 2,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                textEditingController.clear();
              },
              icon: const Icon(Icons.close),
            ),
          ),
          onChanged: (value) {},
        );
      },
      optionsBuilder: (textEditingValue) {
        return symptomsList.where((symptom) {
          return symptom
              .toLowerCase()
              .startsWith(textEditingValue.text.trim().toLowerCase());
        }).toList();
      },
    );
  }

  Widget _addSymptoms() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _inputAutocomplete(),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _symptomController.text.trim().isEmpty
                  ? null
                  : () {
                      _addSymptom();
                    },
              child: const Text('Add'),
            ),
          ],
        ),
        if (symptoms.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 8),
              // Text(
              //   'Symptoms : ${_symptomController.text}',
              // ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...symptoms.map(
                      (e) => Chip(
                        label: Text(e),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          _removeSymptom(e);
                        },
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _addReports() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _blockButton(
                label: 'Add Report',
                icon: const Icon(Icons.add),
                onPressed: () {
                  _pickReport();
                },
              ),
            ),
            if (reports.isNotEmpty) const SizedBox(width: 8),
            if (reports.isNotEmpty)
              TextButton(
                onPressed: _clearReports,
                child: const Text(
                  'clear',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        if (reports.isNotEmpty) const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            children: [
              ...reports.map(
                (image) {
                  return Stack(
                    children: [
                      Container(
                        // color: Colors.red,
                        child: Container(
                          width: 64,
                          height: 64,
                          margin: const EdgeInsets.only(top: 8, right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black26),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                              image: Image.file(File(image)).image,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            _removeReport(image);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black12,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addMedicines() {
    return Column(
      children: [
        _blockButton(
          label: 'Add Medicine',
          icon: const Icon(Icons.add),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _findDiseaseButton() {
    final active = symptoms.isNotEmpty || reports.isNotEmpty;

    return _blockButton(
      label: 'Find Disease',
      icon: const Icon(Icons.search),
      onPressed: active
          ? () {
              _findDisease();
            }
          : null,
    );
  }
}
