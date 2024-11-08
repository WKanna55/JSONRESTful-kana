//
//  ViewControllerBuscar.swift
//  JSONRESTful
//
//  Created by Willian Kana Choquenaira on 8/11/24.
//

import UIKit

class ViewControllerBuscar: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var peliculas = [Peliculas]()
    
    @IBOutlet weak var txtBuscar: UITextField!
    @IBOutlet weak var tablaPeliculas: UITableView!
    
    
    @IBAction func btnBuscar(_ sender: Any) {
        let ruta="http://localhost:3000/peliculas?"
        let nombre = txtBuscar.text!
        let url = ruta + "nombre_like=\(nombre)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")
        if nombre.isEmpty{
            let ruta = "http://localhost:3000/peliculas/"
            self.cargarPeliculas(ruta: ruta) { self.tablaPeliculas.reloadData()
            }
        }else{
            cargarPeliculas(ruta: crearURL) {
                if self.peliculas.count <= 0{
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se encontraron coincidencias para : \(nombre)", accion: "cancel")
                }else{
                    self.tablaPeliculas.reloadData()
                }
            }
        }
    }
    
    
    
    @IBAction func btnSalir(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaPeliculas.delegate = self
        tablaPeliculas.dataSource = self
        
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta) {
            self.tablaPeliculas.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta) {
            self.tablaPeliculas.reloadData()
        }
    }
    
    // tabla metodos
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peliculas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(peliculas[indexPath.row].nombre)"
        cell.detailTextLabel?.text = "Genero:\(peliculas[indexPath.row].genero) - Duracion:\(peliculas[indexPath.row].duracion)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pelicula = peliculas[indexPath.row]
        performSegue(withIdentifier: "segueEditar", sender: pelicula)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditar" {
            let siguienteVC = segue.destination as! ViewControllerAgregar
            siguienteVC.pelicula = sender as? Peliculas
        }
    }
    
    //tarea DELETE
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pelicula = peliculas[indexPath.row]
            
            // Crear el alert de confirmación
            let alert = UIAlertController(
                title: "¿Eliminar película?",
                message: "¿Estás seguro que deseas eliminar \(pelicula.nombre)?",
                preferredStyle: .alert
            )
            
            // Acción de cancelar
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            
            // Acción de eliminar
            alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { _ in
                // Construir la URL para el DELETE
                let ruta = "http://localhost:3000/peliculas/\(pelicula.id)"
                
                // Llamar al método DELETE
                self.metodoDELETE(ruta: ruta)
                
                // Eliminar de nuestro arreglo local
                self.peliculas.remove(at: indexPath.row)
                
                // Eliminar la fila de la tabla con animación
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
            
            // Mostrar el alert
            present(alert, animated: true)
        }
    }

    // Opcional: Personalizar el texto del botón eliminar
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
    }
    
    // metodos personales
    func cargarPeliculas(ruta: String, completed: @escaping () -> ()){
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do{
                    self.peliculas = try JSONDecoder().decode([Peliculas].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("Error en JSON")
                }
            }
        }.resume()
    }
    
    //tarea DELETE
    func metodoDELETE(ruta: String) {
        let url: URL = URL(string: ruta)!
        var request = URLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "DELETE"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if (data != nil) {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    print(dict);
                } catch {
                    // catch any exception here
                }
            }
        })
        task.resume()
    }
    
    func mostrarAlerta(titulo:String, mensaje:String, accion:String){
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }

}
