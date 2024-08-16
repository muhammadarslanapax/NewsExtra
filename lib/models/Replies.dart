
class Replies{
  final int? id, commentId, date, edited;
  final String? email,name;
   String? content;

  Replies({this.id, this.commentId, this.email, this.name, this.content, this.date, this.edited});

  factory Replies.fromJson(Map<String, dynamic> json) {
    //print(json);
    int id = int.parse(json['id'].toString());
    int commentId = int.parse(json['comment_id'].toString());
    int date = int.parse(json['date'].toString());
    int edited = int.parse(json['edited'].toString());
    return Replies(
      id: id,
      email: json['email'] as String?,
      name: json['name'] as String?,
      content : json['content'] as String?,
      date: date,
      commentId: commentId,
      edited: edited
    );
  }

   factory Replies.fromMap(Map<String, dynamic> data) {
      return Replies( 
         id: data['id'], 
         email: data['email'],
         name: data['name'],
         content : data['thumbnail'],
         date: data['date'],
         commentId: data['commentId'],
         edited: data['edited']
      ); 
   } 

  Map<String, dynamic> toMap() => {
      "id": id, 
      "email" : email,
      "name" : name,
      "content" : content,
      "date" : date,
      "commentId" : commentId,
      "edited" : edited
   };
}