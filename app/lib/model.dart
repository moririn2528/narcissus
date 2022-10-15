class Test {
  final int id;
  final String name;
  final String hash;

  Test({required this.id, required this.name, required this.hash});

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      name: json['name'],
      hash: json['hash'],
    );
  }
}
