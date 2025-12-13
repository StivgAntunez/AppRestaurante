import UIKit
import FirebaseFirestore

class CocineroPedidoDetalleViewController: UIViewController,
                                           UITableViewDelegate,
                                           UITableViewDataSource {

    @IBOutlet weak var lblMesa: UILabel!
    @IBOutlet weak var lblEstado: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblHora: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnPreparando: UIButton!
    @IBOutlet weak var btnListo: UIButton!

    let db = Firestore.firestore()

    
    
    var pedidoId: String = ""
    var items: [ItemPedido] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        cargarPedido()
        cargarItems()
    }

    func cargarPedido() {
        db.collection("pedidos").document(pedidoId).getDocument { doc, error in
            if let error = error {
                print("Error obteniendo pedido:", error)
                return
            }

            guard let data = doc?.data() else { return }

            let mesaNum = data["mesaNumero"] as? Int ?? 0
            let estado = data["estado"] as? String ?? "-"
            let total = data["total"] as? Double ?? 0
            let fecha = (data["fecha"] as? Timestamp)?.dateValue() ?? Date()

        
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"

            self.lblMesa.text = "Mesa \(mesaNum)"
            self.lblEstado.text = estado.capitalized
            self.lblTotal.text = "Total: S/ \(total)"
            self.lblHora.text = formatter.string(from: fecha)

           
            self.configurarBotones(estado: estado)
        }
    }


    func cargarItems() {
        db.collection("pedidos")
            .document(pedidoId)
            .collection("items")
            .getDocuments { snap, error in

                if let error = error {
                    print("Error cargando items:", error)
                    return
                }

                self.items = snap?.documents.compactMap { doc in
                    ItemPedido(
                        id: doc.documentID,
                        nombre: doc["nombre"] as? String ?? "",
                        precio: doc["precio"] as? Double ?? 0,
                        cantidad: doc["cantidad"] as? Int ?? 1,
                        subtotal: doc["subtotal"] as? Double ?? 0
                    )
                } ?? []

                self.tableView.reloadData()
            }
    }

 
    func configurarBotones(estado: String) {
        switch estado {
        case "pendiente":
            btnPreparando.isHidden = false
            btnListo.isHidden = true

        case "preparando":
            btnPreparando.isHidden = true
            btnListo.isHidden = false

        case "listo":
            btnPreparando.isHidden = true
            btnListo.isHidden = true

        default:
            break
        }
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ItemPedidoCell",
            for: indexPath
        )

        let item = items[indexPath.row]

        cell.textLabel?.text = "\(item.nombre) x\(item.cantidad)"
        cell.detailTextLabel?.text = "S/ \(item.subtotal)"

        return cell
    }

    @IBAction func prepararTapped(_ sender: Any) {
        actualizarEstado("preparando")
    }

    
    @IBAction func listoTapped(_ sender: Any) {
        actualizarEstado("listo")
    }

  
    func actualizarEstado(_ nuevoEstado: String) {
        db.collection("pedidos").document(pedidoId).updateData([
            "estado": nuevoEstado
        ]) { error in
            if let error = error {
                print("Error actualizando estado:", error)
                return
            }

            self.lblEstado.text = nuevoEstado.capitalized
            self.configurarBotones(estado: nuevoEstado)

            let alert = UIAlertController(
                title: "Actualizado",
                message: "El pedido ahora está: \(nuevoEstado).",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

