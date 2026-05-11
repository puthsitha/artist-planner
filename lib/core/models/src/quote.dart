import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  const Quote({
    required this.text,
    required this.author,
    required this.khmerText,
    required this.khmerAuthor,
  });

  final String text; // English
  final String author; // English
  final String khmerText; // Khmer
  final String khmerAuthor; // Khmer

  @override
  List<Object?> get props => [text, author, khmerText, khmerAuthor];
}

const kInspirationalQuotes = <Quote>[
  Quote(
    text: 'Every artist was first an amateur.',
    author: 'Ralph Waldo Emerson',
    khmerText:
        'កុំទុកចិត្តមេឃ កុំទុកចិត្តផ្កាយ បើគេថាកូនមានសហាយ កុំជេរម្ដាយអ្នកស្រុក',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'Creativity takes courage.',
    author: 'Henri Matisse',
    khmerText:
        'ចំណេះចេះនៅតែក្នុងក្បួន ប្រពន្ធនៅឆ្ងាយអំពីខ្លួន ជួនជាត្រូវការរអាចិត្ត',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'The painter has the universe in their mind and hands.',
    author: 'Leonardo da Vinci',
    khmerText: 'ដំរីជើងបួន គង់មានភ្លាត់ អ្នកប្រាជ្ញចេះស្ទាត់ គង់មានភ្លេច',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'You can\'t use up creativity. The more you use, the more you have.',
    author: 'Maya Angelou',
    khmerText: 'តក់ៗពេញបំពង់ ឆុងៗកន្លះក្រហែត',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text:
        'Art enables us to find ourselves and lose ourselves at the same time.',
    author: 'Thomas Merton',
    khmerText: 'ធ្វើស្រែឲ្យមើលស្មៅ ទុកដាក់កូនចៅ មើលផៅសន្ដាន',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'A goal without a plan is just a wish.',
    author: 'Antoine de Saint-Exupéry',
    khmerText: 'ប្រាជ្ញមិនស្មើប្រប បាក់ស្លឹកត្រចៀកខ្លប មិនស្មើអាឡេមឡឺម',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'Don\'t watch the clock; do what it does — keep going.',
    author: 'Sam Levenson',
    khmerText: 'មើលឲ្យជាក់ សឹមញាក់ចិញ្ចើម ប្រពន្ធមិនទាន់ផើម កុំអាលរកឱស',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'You are allowed to be both a masterpiece and a work in progress.',
    author: 'Sophia Bush',
    khmerText: 'ស្លឲ្យសាប អង្គុយឲ្យទាប មារយាទឲ្យខ្ពស់',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'Inspiration exists, but it has to find you working.',
    author: 'Pablo Picasso',
    khmerText: 'ហុចអំបោះ ស្រណោះដៃ ឲ្យសូត្រមួយសរសៃ ចង់បានផាមួងមួយ',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'Bloom slowly. Bloom kindly. Bloom in your own season.',
    author: 'Anonymous',
    khmerText: 'ត្រុកៗ អ្នកស្រុកមើលងាយ រលាស់គូទខ្ចាយ មានឱតមានភ័ន្ត',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'Do small things with great love.',
    author: 'Mother Teresa',
    khmerText: 'ចេះមិនឈ្នះចង់ បានមិនឈ្នះបង់ ត្រង់មិនឈ្នះទាល់',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
  Quote(
    text: 'Your only limit is the amount of pink in your imagination.',
    author: 'Anonymous',
    khmerText: 'កូនដឹងគុណ ទោះមួយសុទ្ធ ប្រសើរបំផុត ជាងកូនច្រើន',
    khmerAuthor: 'ពាក្យស្លោកខ្មែរ',
  ),
];
