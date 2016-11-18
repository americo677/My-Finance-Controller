//
//  TVCCopySections.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 9/11/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit
import CoreData

class TVCCopySections: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tvSections: UITableView!
    
    weak var delegate: DataBudgetDelegate? = nil
    
    var moc = DataController().managedObjectContext
    var presupuestos: [AnyObject] = []
    var presupuesto: Presupuesto?
    //var presupuestoParaEnviar: Presupuesto?
    
    var sections =  [String]()
    let smModelo = CStructureModel()

    
    // MARK: - Consulta a la BD los presupuestos registrados
    func fetchPresupuestos() {
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: smModelo.smPresupuesto.entityName)
        
        let predicado: NSPredicate =  NSPredicate(format: " activo = true AND descripcion != %@", (self.presupuesto?.descripcion)!)
        
        // Create Entity Description
        // Configure Fetch Request
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: smModelo.smPresupuesto.entityName, in: self.moc
        )
        
        fetchRequest.predicate = predicado
        
        do {
            self.presupuestos = try self.moc.fetch(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fetchPresupuestos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tvSections.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let totalRows = self.presupuestos.count
        return totalRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "copySectionsCell"
        
        // let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier)! as
        UITableViewCell

        if self.presupuestos.count > 0 {
            self.presupuesto = self.presupuestos[indexPath.row] as? Presupuesto
            
            let strTitulo = (self.presupuesto?.descripcion)! as String

            print("Budget <\(indexPath.row)>: \(strTitulo)")
            
            cell.textLabel?.text = strTitulo
        } else {
            cell.textLabel?.text = "No hay presupuestos"
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.presupuestoParaEnviar = self.presupuestos[indexPath.row] as? Presupuesto
        
        delegate?.sendDataBudgetBack!(self.presupuestos[indexPath.row] as? Presupuesto)
        
        //self.performSegue(withIdentifier: "segueBackSections", sender: self)
        
        // go back to the previous view controller
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //if segue.identifier == "segueBackSections" {
        //    let backView: TVCCategoria = segue.destination as! TVCCategoria
        //    backView.presupuesto = self.presupuesto
        //}
    }
 

}
