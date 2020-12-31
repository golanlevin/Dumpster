
class Sadness {

  String author;
  String verbiage;
  int id;

  Sadness(int id, String author, String verbiage) {
    this.author = author;
    this.verbiage = verbiage;
    this.id = id;
  }

  String toString() {
    return "id: " + id + " author: " + author + " verbiage: " + verbiage + "]";
  }
}

