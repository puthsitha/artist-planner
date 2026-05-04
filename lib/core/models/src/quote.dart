import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  const Quote({required this.text, required this.author});

  final String text;
  final String author;

  @override
  List<Object?> get props => [text, author];
}

const kInspirationalQuotes = <Quote>[
  Quote(
    text: 'Every artist was first an amateur.',
    author: 'Ralph Waldo Emerson',
  ),
  Quote(
    text: 'Creativity takes courage.',
    author: 'Henri Matisse',
  ),
  Quote(
    text: 'The painter has the universe in their mind and hands.',
    author: 'Leonardo da Vinci',
  ),
  Quote(
    text: 'You can\'t use up creativity. The more you use, the more you have.',
    author: 'Maya Angelou',
  ),
  Quote(
    text: 'Art enables us to find ourselves and lose ourselves at the same time.',
    author: 'Thomas Merton',
  ),
  Quote(
    text: 'A goal without a plan is just a wish.',
    author: 'Antoine de Saint-Exupéry',
  ),
  Quote(
    text: 'Don\'t watch the clock; do what it does — keep going.',
    author: 'Sam Levenson',
  ),
  Quote(
    text: 'You are allowed to be both a masterpiece and a work in progress.',
    author: 'Sophia Bush',
  ),
  Quote(
    text: 'Inspiration exists, but it has to find you working.',
    author: 'Pablo Picasso',
  ),
  Quote(
    text: 'Bloom slowly. Bloom kindly. Bloom in your own season.',
    author: 'Anonymous',
  ),
  Quote(
    text: 'Do small things with great love.',
    author: 'Mother Teresa',
  ),
  Quote(
    text: 'Your only limit is the amount of pink in your imagination.',
    author: 'Anonymous',
  ),
];
