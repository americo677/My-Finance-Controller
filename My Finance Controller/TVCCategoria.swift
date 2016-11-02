//
//  TVCCategoria.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 5/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit
import CoreData

class TVCCategoria: UITableViewController {
    
    let preferencias = NSUserDefaults.standardUserDefaults()
    
    let dflPresupuestoLookingFor = "nameOfBudgetLookingFor"

    var txtNuevaCategoria: UITextField? = nil
    
    var moc = DataController().managedObjectContext
    
    var presupuesto: Presupuesto?
    
    var presupuestos: [AnyObject] = []

    let smModelo = CStructureModel()
    
    var misCategorias = [String]()
    
    let strAppTitle = "My Finance Controller"

    @IBOutlet weak var tvCategoria: UITableView!
    
    var strPresupuestoNombre: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        let sublayer = CALayer.init()
        sublayer.backgroundColor = UIColor.customLightGrayColor().CGColor
        sublayer.shadowOffset = CGSizeMake(0, 3)
        sublayer.shadowRadius = 5.0
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = CGRectMake(0, 0, 420, 4200)
        self.view.layer.addSublayer(sublayer)
        
        loadSections()
    }

    override func viewWillAppear(animated: Bool) {
        self.preferencias.synchronize()
        
    }
    
    // MARK: - Alerta personalizada
    func showCustomWarningAlert(strMensaje: String, toFocus: UITextField?) {
        let alertController = UIAlertController(title: strAppTitle, message:
            strMensaje, preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel,handler: {_ in
            
            if toFocus != nil {
                toFocus!.becomeFirstResponder()
            }
            }
        )
        
        alertController.addAction(action)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func loadSections() {
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
        
        if let strPresupuestoNombre = preferencias.valueForKey(dflPresupuestoLookingFor) as? String? {
            if strPresupuestoNombre != nil {
                if !strPresupuestoNombre!.isEmpty {
                    //preferencias.setObject(nil, forKey: dflPresupuestoLookingFor)
                    
                    let predicado: NSPredicate =  NSPredicate(format: " descripcion = %@ ", argumentArray: [strPresupuestoNombre!])
                    
                    // Initialize Fetch Request
                    let fetchRequest = NSFetchRequest(entityName: smModelo.smPresupuesto.entityName)
                    
                    // Create Entity Description
                    // Configure Fetch Request
                    fetchRequest.entity = NSEntityDescription.entityForName(smModelo.smPresupuesto.entityName, inManagedObjectContext: self.moc
                    )
                    
                    fetchRequest.predicate = predicado
                    
                    do {
                        self.presupuestos = try self.moc.executeFetchRequest(fetchRequest)
                        
                        self.presupuesto = self.presupuestos.first! as? Presupuesto
                        
                        if self.presupuesto == nil {
                            presupuesto = NSEntityDescription.insertNewObjectForEntityForName(smModelo.smPresupuesto.entityName, inManagedObjectContext: moc) as? Presupuesto
                        }
                        
                    } catch {
                        let fetchError = error as NSError
                        print(fetchError)
                    }
                }
            }
        }
    }
    
    func configurationTextField(textField: UITextField!)
    {
        if textField != nil {
            txtNuevaCategoria = textField!        //Save reference to the UITextField
        }
    }
    
    
    @IBAction func addCategoria(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Section", message: "Input a brief description for the new section.  A section allows you grouping incomes and expenditures for a budget.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
            
            (UIAlertAction) in
            
            //print("User click Aceptar button")
            
            var isSectionOk: Bool = false

            if self.txtNuevaCategoria!.hasText() {
                
                //if self.misCategorias.contains((self.txtNuevaCategoria?.text)!) {
                    
                let indexFound = self.misCategorias.indexOf((self.txtNuevaCategoria?.text)!)
                
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
                    
                    let lpsSeccion = self.presupuesto?.mutableSetValueForKey(self.smModelo.smPresupuesto.colSecciones)
                    
                    let psSeccion = NSEntityDescription.insertNewObjectForEntityForName(self.smModelo.smPresupuestoSeccion.entityName, inManagedObjectContext: self.moc) as? PresupuestoSeccion
                    
                    
                    psSeccion?.setValue(strSeccion, forKey: self.smModelo.smPresupuestoSeccion.colDescripcion)
                    
                    psSeccion?.setValue(0.0, forKey: self.smModelo.smPresupuestoSeccion.colTotalIngresos)
                    
                    psSeccion?.setValue(0.0, forKey: self.smModelo.smPresupuestoSeccion.colTotalEgresos)
                    
                    psSeccion?.setValue(self.presupuesto!, forKey: self.smModelo.smPresupuestoSeccion.colPresupuesto)
                    
                    lpsSeccion?.addObject(psSeccion!)
                    
                    self.presupuesto?.setValue(lpsSeccion!, forKey: self.smModelo.smPresupuesto.colSecciones)
                    
                    self.tvCategoria.beginUpdates()
                    
                    self.tvCategoria.insertRowsAtIndexPaths([NSIndexPath(forRow: self.misCategorias.count - 1, inSection: 0)],withRowAnimation: .Automatic)
                    
                    self.tvCategoria.endUpdates()
                    
                    self.guardarPresupuesto()

                } else {
                    self.showCustomWarningAlert("The section \((self.txtNuevaCategoria?.text)!) is already exists!.  Please check it out!", toFocus: nil)
                }
                
            }

        } // closing handler
        ) // closing UIAlertAction
        ) // closing addAction
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func guardarPresupuesto() {
        
        do {
            try self.moc.save()
        } catch let error as NSError {
            print("No se pudo guardar los datos del presupuesto.  Error: \(error)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.presupuesto?.valueForKey(smModelo.smPresupuesto.colDescripcion) as? String
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return misCategorias.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellCategoria", forIndexPath: indexPath)

        // Configure the cell...
        let fontName = "Verdana"
        cell.textLabel?.font = UIFont(name: fontName , size: 13)
        cell.textLabel?.text = misCategorias[indexPath.row] as String
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source

            var arrSeccion = self.presupuesto?.mutableSetValueForKey(smModelo.smPresupuesto.colSecciones).allObjects
            
            if arrSeccion?.count > 0 {
                let seccion = arrSeccion![indexPath.row] as? PresupuestoSeccion
                
                let egresos = seccion?.valueForKey(smModelo.smPresupuestoSeccion.colTotalEgresos) as? Double
                let ingresos = seccion?.valueForKey(smModelo.smPresupuestoSeccion.colTotalIngresos) as? Double
                
                var totalIngresos = self.presupuesto?.valueForKey(smModelo.smPresupuesto.colIngresos) as? Double
                var totalEgresos = self.presupuesto?.valueForKey(smModelo.smPresupuesto.colEjecutado) as? Double
                
                totalIngresos = totalIngresos! - ingresos!
                totalEgresos = totalEgresos! - egresos!
                
                self.presupuesto?.setValue(totalIngresos!, forKey: smModelo.smPresupuesto.colIngresos)
                self.presupuesto?.setValue(totalEgresos!, forKey: smModelo.smPresupuesto.colEjecutado)
                
                self.moc.deleteObject(arrSeccion?[indexPath.row] as! NSManagedObject)
                
                arrSeccion?.removeAtIndex(indexPath.row)
                
                do {
                    try self.moc.save()
                    self.loadSections()
                    tableView.reloadData()
                } catch {
                    let deleteError = error as NSError
                    print(deleteError)
                }
            }
        } else if editingStyle == .Insert {
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
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
            if segue.identifier == "segueMasterCuotas" {
                let vcCategoria: TVCCategoria = segue.destinationViewController as! TVCCategoria
                
                vcMasterCuotas.cppPlan = cppPlan!
            }
    }
    */

}
