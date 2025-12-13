import UIKit
import FirebaseFirestore

class MeseroPedidoViewController: UIViewController,
                                  UITableViewDelegate,
                                  UITableViewDataSource,
                                  UIPickerViewDelegate,
                                  UIPickerViewDataSource {

    @IBOutlet weak var pickerCategorias: UIPickerView!
    @IBOutlet weak var pickerMesas: UIPickerView!
    @IBOutlet weak var tableView: UITableView!

    let db = Firestore.firestore()

    var categorias: [Categoria] = []
    var platos: [Plato] = []
    var mesas: [Mesa] = []

    /// Items que el mesero selecciona
    var pedidoItems: [Plato] = []

    /// Mesa seleccionada
    var mesaSeleccionada: Mesa?

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerCategorias.delegate = self
        pickerCategorias.dataSource = self

        pickerMesas.delegate = self
        pickerMesas.dataSource = self

        tableView.delegate = self
        tableView.dataSource = self

        cargarCategorias()
        cargarMesas()
    }


    func cargarCategorias() {
        db.collection("categorias").getDocuments { snap, error in
            if let error = error { print("Error:", error); return }

            self.categorias = snap?.documents.compactMap { doc in
                let nombre = doc["nombre"] as? String ?? "Sin nombre"
                return Categoria(id: doc.documentID, nombre: nombre)
            } ?? []

            self.pickerCategorias.reloadAllComponents()

            if let primera = self.categorias.first {
                self.cargarPlatos(categoriaId: primera.id)
            }
        }
    }

 
    func cargarPlatos(categoriaId: String) {
        db.collection("categorias")
            .document(categoriaId)
            .collection("platos")
            .getDocuments { snap, error in

                if let error = error { print("Error:", error); return }

                self.platos = snap?.documents.compactMap { doc in
                    Plato(
                        id: doc.documentID,
                        nombre: doc["nombre"] as? String ?? "",
                        precio: doc["precio"] as? Double ?? 0,
                        imagenURL: doc["imagenURL"] as? String ?? ""
                    )
                } ?? []

                self.tableView.reloadData()
            }
    }

 
    func cargarMesas() {
        db.collection("mesas").getDocuments { snap, error in
            if let error = error {
                print("Error al cargar mesas:", error)
                return
            }

            self.mesas = snap?.documents.compactMap { doc in
                let numero = doc["numero"] as? Int ?? 0
                let estado = doc["estado"] as? String ?? "libre"
                let sillas = doc["sillas"] as? Int ?? 0

                return Mesa(id: doc.documentID, numero: numero, estado: estado, sillas: sillas)
            } ?? []

            self.pickerMesas.reloadAllComponents()

            if let primera = self.mesas.first {
                self.mesaSeleccionada = primera
            }
        }
    }

  
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {

        if pickerView == pickerMesas {
            return mesas.count
        }
        return categorias.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {

        if pickerView == pickerMesas {
            return "Mesa \(mesas[row].numero)"
        }
        return categorias[row].nombre
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {

        if pickerView == pickerMesas {
            mesaSeleccionada = mesas[row]
            return
        }

        let categoriaId = categorias[row].id
        cargarPlatos(categoriaId: categoriaId)
    }

  
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        platos.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PlatoCell",
            for: indexPath
        ) as! PlatoCell

        let plato = platos[indexPath.row]

        cell.lblNombre.text = plato.nombre
        cell.lblPrecio.text = "S/ \(plato.precio)"

        if plato.imagenURL != "" {
            cell.imgPlato.loadFromURL(plato.imagenURL)
        } else {
            cell.imgPlato.image = UIImage(systemName: "photo")
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let plato = platos[indexPath.row]

        pedidoItems.append(plato)

        let alert = UIAlertController(
            title: "Agregado",
            message: "\(plato.nombre) añadido al pedido.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


    @IBAction func generarPedido(_ sender: Any) {

        guard let mesa = mesaSeleccionada else {
            let alert = UIAlertController(
                title: "Selecciona una mesa",
                message: "Debes elegir una mesa para registrar el pedido.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        guard !pedidoItems.isEmpty else {
            let alert = UIAlertController(
                title: "Pedido vacío",
                message: "Añade al menos un plato.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }

        let pedidoRef = db.collection("pedidos").document()

        let total = pedidoItems.reduce(0) { $0 + $1.precio }

        pedidoRef.setData([
            "mesaId": mesa.id,
            "mesaNumero": mesa.numero,
            "estado": "pendiente",
            "fecha": Timestamp(),
            "total": total
        ])

        for plato in pedidoItems {
            pedidoRef.collection("items").addDocument(data: [
                "platoId": plato.id,
                "nombre": plato.nombre,
                "precio": plato.precio,
                "cantidad": 1,
                "subtotal": plato.precio
            ])
        }

        let alert = UIAlertController(
            title: "Pedido creado",
            message: "El pedido fue registrado correctamente.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)

        pedidoItems.removeAll()
    }
}
