//
//  TVCCategoria.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 5/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit
import CoreData

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TVCCategoria: UITableViewController, DataBudgetDelegate {
    
    let preferencias = UserDefaults.standard
    
    let dflPresupuestoLookingFor = "nameOfBudgetLookingFor"

    var txtNuevaCategoria: UITextField? = nil
    
    var moc = DataController().managedObjectContext
    
    var presupuesto: Presupuesto?
    
    var presupuestoChoosed: Presupuesto? = nil
    
    var presupuestos: [AnyObject] = []

    let smModelo = CStructureModel()
    
    var misCategorias = [String]()
    
    let strAppTitle = "My Finance Controller"

    @IBOutlet weak var tvCategoria: UITableView!
    
    var strPresupuestoNombre: String?
    
    func sendToChooseBudget(sender: AnyObject?) {
                self.performSegue(withIdentifier: "segueCopySections", sender: sender)
    }
    
    func sendDataBudgetBack(_ budget: Presupuesto?) {
        self.presupuestoChoosed = budget
    }
    
    func btnActionOnTouchInsideup(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: self.strAppTitle, message: "You can copy sections from another budget", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print(action)
        }
        
        //alertController.addAction(cancelAction)
        
        //let destroyAction = UIAlertAction(title: "Destroy", style: .Destructive) { (action) in
        //    print(action)
        
        //}
        
        let oneAction = UIAlertAction(title: "Choose", style: .default) { (_) in
            self.sendToChooseBudget(sender: self)
        }
        
        alertController.addAction(oneAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
        }
        
    }
    
    func loadPreferences() {
        
        // inicializar los placeholder de los UITextField que lo requieran
        //txtMonto.placeholder  = "Monto del préstamo"
        
        // Para UITextField de entrada numérica
        //self.txtPresupuesto.keyboardType = .decimalPad
        
        let rightButton = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.addCategoria(_:)))
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        
        
        // Bar title text color
        //let shadow = NSShadow()
        //shadow.shadowColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        //shadow.shadowOffset = CGSize(0, 1)
        
        let color = UIColor.white
        
        let titleFont : UIFont = UIFont(name: CCGlobal().FONT_NAME_TITLE_NAVIGATION_BAR, size: 14)!
        
        let attributes = [
            NSForegroundColorAttributeName : color,
            //NSShadowAttributeName : shadow,
            NSFontAttributeName : titleFont
        ]
        
        
        rightButton.setTitleTextAttributes(attributes, for: UIControlState.normal)
        
        backButton.setTitleTextAttributes(attributes, for: UIControlState.normal)
        
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        
        self.navigationItem.backBarButtonItem = backButton
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadPreferences()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        /*
        let sublayer = CALayer.init()
        sublayer.backgroundColor = UIColor.customLightGrayColor().cgColor
        sublayer.shadowOffset = CGSize(width: 0, height: 3)
        sublayer.shadowRadius = 5.0
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = CGRect(x: 0, y: 0, width: 420, height: 4200)
        self.view.layer.addSublayer(sublayer)
        */
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preferencias.synchronize()
        
        #if FULL_VERSION
            
            var titleButton: String? = "Copy sections from..."
            
            if self.presupuestoChoosed != nil {
                titleButton = "Copy sections from \((self.presupuestoChoosed?.descripcion)!)"
            }
            
            self.navigationController?.isToolbarHidden = false
            var items = [AnyObject]()
            items.append(UIBarButtonItem(title:titleButton, style: .plain, target: self,action: #selector(self.btnActionOnTouchInsideup)))
            self.toolbarItems = items as? [UIBarButtonItem]
        #endif
        
        loadSections()
        tvCategoria.reloadData()
    }
    
    func updateSectionsFromBudgetChoosed() {
        if self.presupuestoChoosed != nil {
            
            let lpsSeccionDestiny = self.presupuesto?.mutableSetValue(forKey: self.smModelo.smPresupuesto.colSecciones)
            
            let lpsSeccionOrigin = self.presupuestoChoosed?.mutableSetValue(forKey: self.smModelo.smPresupuesto.colSecciones)

            // elimina todas las secciones previas del presupuesto destino
            lpsSeccionDestiny?.removeAllObjects()

            for item in lpsSeccionOrigin! {
                let sectionOrigin = item as? PresupuestoSeccion
                
                let psSeccion = NSEntityDescription.insertNewObject(forEntityName: self.smModelo.smPresupuestoSeccion.entityName, into: self.moc) as? PresupuestoSeccion

                let strSeccion = (sectionOrigin?.descripcion!)! as String
                
                psSeccion?.setValue(strSeccion, forKey: self.smModelo.smPresupuestoSeccion.colDescripcion)
                
                psSeccion?.setValue(0.0, forKey: self.smModelo.smPresupuestoSeccion.colTotalIngresos)
                
                psSeccion?.setValue(0.0, forKey: self.smModelo.smPresupuestoSeccion.colTotalEgresos)
                
                lpsSeccionDestiny?.add(psSeccion!)
                
            }
            
            self.presupuesto?.setValue(lpsSeccionDestiny!, forKey: self.smModelo.smPresupuesto.colSecciones)

            // modifica las secciones origen asociandolas al nuevo presupuesto
            //lpsSeccionDestiny = lpsSeccionOrigin
            
            guardarPresupuesto()
        }
    }
    
    // MARK: - Alerta personalizada
    func showCustomWarningAlert(_ strMensaje: String, toFocus: UITextField?) {
        let alertController = UIAlertController(title: strAppTitle, message:
            strMensaje, preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel,handler: {_ in
            
            if toFocus != nil {
                toFocus!.becomeFirstResponder()
            }
            }
        )
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func loadSections() {
        
        updateSectionsFromBudgetChoosed()
        
        if self.presupuesto != nil {
            let sections = self.presupuesto?.secciones?.allObjects as? [PresupuestoSeccion]
            
            misCategorias = [String]()
            
            var item: Int = 0
            
            if sections?.count > 0 {
                repeat {
                    let strSeccion = sections?[item].descripcion!
                    self.misCategorias.append(strSeccion!)
                    item += 1
                } while (item < sections?.count)
            }
        }
        
        preferencias.synchronize()
        
        if let strPresupuestoNombre = preferencias.value(forKey: dflPresupuestoLookingFor) as? String? {
            if strPresupuestoNombre != nil {
                if !strPresupuestoNombre!.isEmpty {
                    //preferencias.setObject(nil, forKey: dflPresupuestoLookingFor)
                    
                    let predicado: NSPredicate =  NSPredicate(format: " descripcion = %@ ", argumentArray: [strPresupuestoNombre!])
                    
                    // Initialize Fetch Request
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: smModelo.smPresupuesto.entityName)
                    
                    // Create Entity Description
                    // Configure Fetch Request
                    fetchRequest.entity = NSEntityDescription.entity(forEntityName: smModelo.smPresupuesto.entityName, in: self.moc
                    )
                    
                    fetchRequest.predicate = predicado
                    
                    do {
                        self.presupuestos = try self.moc.fetch(fetchRequest)
                        
                        self.presupuesto = self.presupuestos.first! as? Presupuesto
                        
                        if self.presupuesto == nil {
                            presupuesto = NSEntityDescription.insertNewObject(forEntityName: smModelo.smPresupuesto.entityName, into: moc) as? Presupuesto
                        }
                        
                    } catch {
                        let fetchError = error as NSError
                        print(fetchError)
                    }
                }
            }
        }
    }
    
    func configurationTextField(_ textField: UITextField!)
    {
        if textField != nil {
            txtNuevaCategoria = textField!        //Save reference to the UITextField
        }
    }
    
    
    @IBAction func addCategoria(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Section", message: "Input a brief description for the new section.  A section allows you grouping incomes and expenditures for a budget.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
            
            (UIAlertAction) in
            
            //print("User click Aceptar button")
            
            var isSectionOk: Bool = false

            if self.txtNuevaCategoria!.hasText {
                
                //if self.misCategorias.contains((self.txtNuevaCategoria?.text)!) {
                    
                let indexFound = self.misCategorias.index(of: (self.txtNuevaCategoria?.text)!)
                
                //print ("Indice recuperado: \(index)")

                if indexFound == nil {
                    isSectionOk = true
                }
                
                #if LITE_VERSION
                    if self.misCategorias.count == CCGlobal().MAX_SECTIONS_FOR_BUDGETS_LITE_VERSION {
                        self.showCustomWarningAlert("This is the demo version.  To enjoy the full version of \(self.strAppTitle) we invite you to obtain the full version.  Thank you!.", toFocus: nil)
                        isSectionOk = false
                    }
                #endif
                
                
                if isSectionOk {
                    let strSeccion = self.txtNuevaCategoria!.text!
                    
                    //print("Texto ingresado: " + self.txtNuevaCategoria!.text!)
                    //print("Texto ingresado: \(strSeccion)")
                    
                    self.misCategorias.append(strSeccion)
                    
                    let lpsSeccion = self.presupuesto?.mutableSetValue(forKey: self.smModelo.smPresupuesto.colSecciones)
                    
                    let psSeccion = NSEntityDescription.insertNewObject(forEntityName: self.smModelo.smPresupuestoSeccion.entityName, into: self.moc) as? PresupuestoSeccion
                    
                    
                    psSeccion?.setValue(strSeccion, forKey: self.smModelo.smPresupuestoSeccion.colDescripcion)
                    
                    psSeccion?.setValue(0.0, forKey: self.smModelo.smPresupuestoSeccion.colTotalIngresos)
                    
                    psSeccion?.setValue(0.0, forKey: self.smModelo.smPresupuestoSeccion.colTotalEgresos)
                    
                    psSeccion?.setValue(self.presupuesto!, forKey: self.smModelo.smPresupuestoSeccion.colPresupuesto)
                    
                    lpsSeccion?.add(psSeccion!)
                    
                    self.presupuesto?.setValue(lpsSeccion!, forKey: self.smModelo.smPresupuesto.colSecciones)
                    
                    self.tvCategoria.beginUpdates()
                    
                    self.tvCategoria.insertRows(at: [IndexPath(row: self.misCategorias.count - 1, section: 0)],with: .automatic)
                    
                    self.tvCategoria.endUpdates()
                    
                    self.guardarPresupuesto()

                } else {
                    self.showCustomWarningAlert("The section \((self.txtNuevaCategoria?.text)!) is already exists!.  Please check it out!", toFocus: nil)
                }
                
            }

        } // closing handler
        ) // closing UIAlertAction
        ) // closing addAction
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func guardarPresupuesto() {
        
        do {
            try self.moc.save()
        } catch let error as NSError {
            print("No se pudo guardar los datos del presupuesto.  Error: \(error)")
        }
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.presupuesto?.value(forKey: smModelo.smPresupuesto.colDescripcion) as? String
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return misCategorias.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategoria", for: indexPath)

        // Configure the cell...
        let fontName = "Verdana"
        cell.textLabel?.font = UIFont(name: fontName , size: 13)
        cell.textLabel?.text = misCategorias[indexPath.row] as String
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

            var arrSeccion = self.presupuesto?.mutableSetValue(forKey: smModelo.smPresupuesto.colSecciones).allObjects
            
            self.moc.delete(arrSeccion?[indexPath.row] as! NSManagedObject)
            
            arrSeccion?.remove(at: indexPath.row)
            
            do {
                try self.moc.save()
                self.loadSections()
                tableView.reloadData()
            } catch {
                let deleteError = error as NSError
                print(deleteError)
            }

            BudgetServices.sharedInstance.syncBalancesOfBudget(budget: self.presupuesto!, moc: self.moc)
            
            /*
            if arrSeccion?.count > 0 {
                let seccion = arrSeccion![indexPath.row] as? PresupuestoSeccion
                
                let egresos = seccion?.value(forKey: smModelo.smPresupuestoSeccion.colTotalEgresos) as? Double
                let ingresos = seccion?.value(forKey: smModelo.smPresupuestoSeccion.colTotalIngresos) as? Double
                
                var totalIngresos = self.presupuesto?.value(forKey: smModelo.smPresupuesto.colIngresos) as? Double
                var totalEgresos = self.presupuesto?.value(forKey: smModelo.smPresupuesto.colEjecutado) as? Double
                
                totalIngresos = totalIngresos! - ingresos!
                totalEgresos = totalEgresos! - egresos!
                
                self.presupuesto?.setValue(totalIngresos!, forKey: smModelo.smPresupuesto.colIngresos)
                self.presupuesto?.setValue(totalEgresos!, forKey: smModelo.smPresupuesto.colEjecutado)
                
                self.moc.delete(arrSeccion?[indexPath.row] as! NSManagedObject)
                
                arrSeccion?.remove(at: indexPath.row)
                
                do {
                    try self.moc.save()
                    self.loadSections()
                    tableView.reloadData()
                } catch {
                    let deleteError = error as NSError
                    print(deleteError)
                }
 
                
                
                
            }
            */
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    override func viewWillDisappear(animated: Bool) {
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
            if segue.identifier == "segueCopySections" {
                let vcCopySections: TVCCopySections = segue.destination as! TVCCopySections
                
                vcCopySections.delegate = self
                vcCopySections.moc = self.moc
                vcCopySections.presupuesto = self.presupuesto
                
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
