import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:tokenizer/tokenizer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // State variable to hold the prediction text
  String predictionText = '';

  @override
  void initState() {
    super.initState();
    // Load the TensorFlow Lite model on initialization
    loadModel();
  }

  // Function to load the TensorFlow Lite model
  Future<void> loadModel() async {
    // Load the TensorFlow Lite model and labels
    await Tflite.loadModel(
      model: 'assets/mobilebert.tflite',
      labels: 'assets/labels.txt',
    );
  }

  // Function to run text classification
  Future<void> classifyText(String inputText) async {
    // Tokenize the input text using the tokenizer package
    List<String> tokens = tokenizeText(inputText);

    // Get model output
    var output = await Tflite.runModelOnTextList(texts: [inputText]);
    // Extract predicted label and confidence from the output
    String predictedLabel = output[0]['label'];
    double confidence = output[0]['confidence'];

    // Make decisions based on the prediction
    if (confidence > 0.5) {
      setState(() {
        predictionText =
            'Prediction: $predictedLabel\nConfidence: ${(confidence * 100).toStringAsFixed(2)}%';
      });
    } else {
      setState(() {
        predictionText = 'Uncertain Prediction';
      });
    }
  }

  // Function to preprocess text (simple tokenization)
  List<String> tokenizeText(String inputText) {
    // Create a Tokenizer instance from the tokenizer package
    Tokenizer tokenizer = Tokenizer();
    // Tokenize the input text
    return tokenizer.tokenize(inputText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Classification App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Replace 'Your text to classify' with your actual input text
                classifyText(
                    'debit inr 50000 ac xx8926 121023 200219 upip2a328546155288anurag jain sm blockupi cust id 01351860002 axi ban');
              },
              child: const Text('Classify Text'),
            ),
            const SizedBox(height: 20),
            Text(
              predictionText,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the loaded model when the widget is disposed
    Tflite.close();
    super.dispose();
  }
}
