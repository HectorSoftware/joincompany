class UserDataBase{

  int idTable;
  String name;
  String password;
  String company;


  UserDataBase ({this.idTable,this.name,this.password,this.company});


  UserDataBase.map(dynamic obj) {
    this.idTable = obj["idTable"];
    this.name = obj["name"];
    this.password = obj["password"];
    this.company = obj["company"];

  }

  //To insert the data in the bd, we need to convert it into a Map
  //Para insertar los datos en la bd, necesitamos convertirlo en un Map
  Map<String, dynamic> toMap() => {
    "idTable": idTable,
    "name": name,
    "password": password,
    "company": company,
  };
  //to receive the data we need to pass it from Map to json
  //para recibir los datos necesitamos pasarlo de Map a json
  factory UserDataBase.fromMap(Map<String, dynamic> json) => new UserDataBase(
    idTable: json["idTable"],
    name: json["name"],
    password: json["password"],
    company: json["company"],

  );
}