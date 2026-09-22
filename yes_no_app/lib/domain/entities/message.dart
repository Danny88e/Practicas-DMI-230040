
enum FromWho { me, her }

class Message {
    final String text;
    final String imageUlr;
    final FromWho fromWho;

    Message({
        required this.text,
        required this.imageUlr,
        required this.fromWho,
    });
}