class Radios{
  final int? id;
  final String? title;
  final String? link;
  final String? thumbnail;
  final String? interest;

  static const String TABLE = "radio";
  static final columns = ["id", "title", "thumbnail", "link", "interest"]; 

  Radios({this.id, this.title, this.thumbnail, this.link, this.interest});

  factory Radios.fromJson(Map<String, dynamic> json) {
    //print(json);
    int id = int.parse(json['id'].toString());
    return Radios(
      id: id,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      link: json['link'] as String?,
      interest: json['interest'] as String?
    );
  }

   factory Radios.fromMap(Map<String, dynamic> data) {
      return Radios( 
         id: data['id'], 
         title: data['title'], 
         thumbnail : data['thumbnail'],
         link : data['link'],
         interest : data['interest']
      ); 
   } 

  Map<String, dynamic> toMap() => {
      "id": id, 
      "title": title, 
      "thumbnail": thumbnail,
      "link": link,
      "interest": interest
   };
}