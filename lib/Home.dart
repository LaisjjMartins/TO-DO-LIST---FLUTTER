import 'package:flutter/material.dart'; //import da função runApp
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
class Home extends StatefulWidget { //stfull
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
   List _listaTarefas = [];
    TextEditingController _controller = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

   Future<File> _getFile() async {
     final diretorio = await getApplicationDocumentsDirectory();
     return File("${diretorio.path}/dados.json" );
   }

    _salvartarefa() async {
     String textoDigitado = _controller.text;

     Map<String, dynamic> tarefa = Map();
     tarefa ["titulo"] = textoDigitado;
     tarefa ["realizada"] = false;

     setState((){
       _listaTarefas.add(tarefa);
     });
     _salvarArquivo();
    }
    _salvarArquivo() async{
     var arquivo = await _getFile();
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
    }

   _lerArquivo() async {
     try {
       final arquivo = await _getFile();
       return arquivo.readAsString();
     } catch (e) {
       return print(e);
     }
   }
    @override
    void initState() {
    super.initState();

    _lerArquivo().then( (dados){
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
    }

   showAlert(BuildContext context)
   {
     // configura o button
     Widget okButton = ElevatedButton(
       child: Text("Editar"),
       onPressed: () {
         Navigator.of(context).pop();
         _salvartarefa();
         _controller.clear();
       },
     );
     // configura o  AlertDialog
     AlertDialog alerta = AlertDialog(
       title: Text("Editar tarefa"),
       content: TextFormField(
         controller: _controller,
         decoration: InputDecoration(
             labelText: "Digite a nova tarefa"
         ),
         onChanged: (text){
           print("editar");
         },
       ),
       actions: [
         okButton,
       ],
     );
     // exibe o dialog
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return alerta;
       },
     );
   }

    Widget criarItem(context, index) {
      final item = _listaTarefas[index]["titulo"];
      return Dismissible(
        key: Key(item),

        background: Container(
          color:Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:  <Widget> [
              Icon(
                Icons.delete,
                color: Colors.white,
              ),


            ],
          ),
        ),
        secondaryBackground: Container(
          color: Colors.yellow,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:  <Widget> [
              Icon(
                Icons.edit,
                color: Colors.white,
              ),

            ],
          ),
        ),

        child: CheckboxListTile(
          title: Text(_listaTarefas[index]["titulo"],  style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.bold

          ),
          ),

          controlAffinity: ListTileControlAffinity.leading,

          value: _listaTarefas[index]["realizada"],
          onChanged: (valorAlterado){
            setState(() {
              _listaTarefas[index]["realizada"] = valorAlterado;
            });
            _salvarArquivo();
          },
        ),
        onDismissed: (direction){
          if(direction == DismissDirection.startToEnd){
            //Remo o item da lista
            print("delete");
            _listaTarefas.removeAt(index);
            _salvarArquivo();
          }
          else if(direction == DismissDirection.endToStart){
            print("edit");
            _listaTarefas.removeAt(index);
            _salvarArquivo();
            showAlert(context);
          }

        },
      );
    }

    @override
    Widget build(BuildContext context) {
    return Scaffold( //Defini uma estrutura padrão para o aplicativo.
      appBar: AppBar(
        title: Text("To-Do-List"),
        backgroundColor: Colors.grey,
        centerTitle: true,
      ),
     body: Container(
       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child:
          Form(
            key: _formKey,
            child: Row(
              children: <Widget> [
                Expanded(child: TextFormField(
                  controller: _controller,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                      fontWeight: FontWeight.bold
                  ),
                decoration: InputDecoration(
                  hintText: 'Escreva uma nova tarefa',
                  hintStyle: TextStyle(
                    fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                  filled: true,
                ),
                keyboardType: TextInputType.text,
                validator: (value){
                  if(value!.isEmpty){ //Se tiver vazio
                   return "Preencha a tarefa";
                  }
                  return null;
                }
                )
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: ElevatedButton(
                    child: Icon(Icons.add),
                    //child: Text('Add'),
                    onPressed: () {
                      if(_formKey.currentState!.validate()) {
                        _salvartarefa();
                      }
                      _controller.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)
                      ),
                      primary: Colors.green,
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.normal
                      )
                    ),
                  ),
                ),

              ],

            ),
          ),

        ),
        Expanded(
          child: ListView.builder(
              itemCount: _listaTarefas.length,
              itemBuilder: criarItem,


            ),
            )


          ]
        ),
      )
     );
  }

   }
