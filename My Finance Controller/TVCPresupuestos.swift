//
//  TVCPresupuestos.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 5/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit
import CoreData

class TVCPresupuestos: UITableViewController {
    
    @IBOutlet var tvPresupuestos: UITableView!
    
    @IBOutlet weak var btnBudget: UIBarButtonItem!
    
    
    let preferencias = NSUserDefaults.standardUserDefaults()

    let dflPresupuestoLookingFor = "nameOfBudgetLookingFor"

    let moc = DataController().managedObjectContext
    
    var presupuesto: Presupuesto?
    
    var presupuestos: [AnyObject] = []
    
    let smModelo = CStructureModel()
    
    let prefExecTimes = "ExecTimes"
    
    let strTituloLista = "Customized Budgets"
    
    let strAppTitle = "My Finance Controller"
    
    var intSelectedIndex : Int = -1
    
    let MAX_ROW_HEIGHT: CGFloat = 93
    
    let formatterMon : NSNumberFormatter = NSNumberFormatter()
    let formatterFlt : NSNumberFormatter = NSNumberFormatter()
    var indexSelected: NSIndexPath = NSIndexPath()
    
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    func initFormatters() {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        formatterMon.numberStyle = .CurrencyStyle
        formatterMon.maximumFractionDigits = 2
        formatterFlt.numberStyle = .NoStyle
        formatterFlt.maximumFractionDigits = 2
    }

    // MARK: - Consulta a la BD los presupuestos registrados
    func fetchPresupuestos() {
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: smModelo.smPresupuesto.entityName)
        
        let predicado: NSPredicate =  NSPredicate(format: " activo = true ")

        // Create Entity Description
        // Configure Fetch Request
        fetchRequest.entity = NSEntityDescription.entityForName(smModelo.smPresupuesto.entityName, inManagedObjectContext: self.moc
        )
        
        fetchRequest.predicate = predicado

        do {
            self.presupuestos = try self.moc.executeFetchRequest(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func initTableViewRowHeight() {
        self.tvPresupuestos.rowHeight = MAX_ROW_HEIGHT
        //self.tvPresupuestos.frame.size.width = 500
    }
    
    func getPath(fileName: String) -> String {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(fileName)
        return fileURL.path!
    }

    // MARK: - Carga inicial de datos JSON
    func loadInitJSON() {
        if let dataPath = NSBundle.mainBundle().pathForResource("initialbudget", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: dataPath, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    if let budgetsJSON : [NSDictionary] = jsonResult["Presupuesto"] as? [NSDictionary] {
                        for budgetJSON: NSDictionary in budgetsJSON {
                            
                            //for (name, value) in budget {
                            //    print("\(name) , \(value)")
                            //}

                            self.presupuesto = self.loadInitJSONPresupuesto(budgetJSON)
                            
                            do {
                                try self.moc.save()
                            } catch let error as NSError {
                                print("No se pudo guardar los datos precargados de presupuesto.  Error: \(error)")
                            }
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        self.presupuesto = nil
    }
    
    func loadInitJSONPresupuesto(budget: NSDictionary) -> Presupuesto {
        //print("Presupuesto: \(budget)")
        
        let presupuesto = NSEntityDescription.insertNewObjectForEntityForName(self.smModelo.smPresupuesto.entityName, inManagedObjectContext: self.moc) as? Presupuesto
        
        for (name, value) in budget {
            
            if name as! String == self.smModelo.smPresupuesto.colDescripcion {
                presupuesto!.setValue(value as! String, forKey: self.smModelo.smPresupuesto.colDescripcion)
            }

            if name as! String == smModelo.smPresupuesto.colFechaIni {
                presupuesto!.setValue(dateFormatter.dateFromString(value as! String), forKey: smModelo.smPresupuesto.colFechaIni)
            }
            
            if name as! String == smModelo.smPresupuesto.colFechaFin {
                presupuesto!.setValue(dateFormatter.dateFromString(value as! String), forKey: smModelo.smPresupuesto.colFechaFin)
            }

            if name as! String == smModelo.smPresupuesto.colIngresos {
                presupuesto!.setValue(value as! Double, forKey: smModelo.smPresupuesto.colIngresos)
            }

            if name as! String == smModelo.smPresupuesto.colEjecutado {
                presupuesto!.setValue(value as! Double, forKey: smModelo.smPresupuesto.colEjecutado)
            }

            if name as! String == smModelo.smPresupuesto.colValor {
                presupuesto!.setValue(value as! Double, forKey: smModelo.smPresupuesto.colValor)
            }

            if name as! String == smModelo.smPresupuesto.colUmbral {
                presupuesto!.setValue(value as! Double, forKey: smModelo.smPresupuesto.colUmbral)
            }

            if name as! String == smModelo.smPresupuesto.colPreservar {
                if value as! Bool == true {
                    presupuesto!.setValue(true, forKey: smModelo.smPresupuesto.colPreservar)
                } else {
                    presupuesto!.setValue(false, forKey: smModelo.smPresupuesto.colPreservar)
                }
            }

            if name as! String == smModelo.smPresupuesto.colActivo {
                if value as! Bool == true {
                    presupuesto!.setValue(true, forKey: smModelo.smPresupuesto.colActivo)
                } else {
                    presupuesto!.setValue(false, forKey: smModelo.smPresupuesto.colActivo)
                }
            }
            
            let lpsSeccion = presupuesto?.mutableSetValueForKey(self.smModelo.smPresupuesto.colSecciones)
            
            if name as! String == "secciones" {
                if let secciones : [NSDictionary] = budget["secciones"] as? [NSDictionary] {
                    for seccion: NSDictionary in secciones {
                        let iSeccion = self.loadInitJSONSeccion(seccion)
                        lpsSeccion?.addObject(iSeccion)
                    }
                    presupuesto?.setValue(lpsSeccion, forKey: self.smModelo.smPresupuesto.colSecciones)
                }
            }
        }
        return presupuesto!
    }
    
    func loadInitJSONSeccion(section: NSDictionary) -> PresupuestoSeccion {
        //print("sección: \(section)")

        let seccion = NSEntityDescription.insertNewObjectForEntityForName(self.smModelo.smPresupuestoSeccion.entityName, inManagedObjectContext: self.moc) as? PresupuestoSeccion
        
        for (name, value) in section {
            
            if name as! String == self.smModelo.smPresupuestoSeccion.colDescripcion {
                seccion!.setValue(value as! String, forKey: self.smModelo.smPresupuestoSeccion.colDescripcion)
            }
            
            if name as! String == smModelo.smPresupuestoSeccion.colTotalIngresos {
                seccion!.setValue(value as! Double, forKey: smModelo.smPresupuestoSeccion.colTotalIngresos)
            }
            
            if name as! String == smModelo.smPresupuestoSeccion.colTotalEgresos {
                seccion!.setValue(value as! Double, forKey: smModelo.smPresupuestoSeccion.colTotalEgresos)
            }

            if name as! String == smModelo.smPresupuestoSeccion.colPresupuesto {
                seccion!.setValue(self.presupuesto, forKey: smModelo.smPresupuestoSeccion.colPresupuesto)
            }
            
            let lpsRecibo = seccion?.mutableSetValueForKey(self.smModelo.smPresupuestoSeccion.colRecibos)

            if name as! String == "recibos" {
                if let recibos : [NSDictionary] = section["recibos"] as? [NSDictionary] {
                    for recibo: NSDictionary in recibos {
                        let iRecibo = self.loadInitJSONRecibo(recibo, seccion: seccion!)
                        lpsRecibo?.addObject(iRecibo)
                    }
                    seccion?.setValue(lpsRecibo, forKey: self.smModelo.smPresupuestoSeccion.colRecibos)
                }
            }
        }
        return seccion!
    }
    
    func loadInitJSONRecibo(receipt: NSDictionary, seccion: PresupuestoSeccion) -> Recibo {
        //print("recibo: \(receipt)")
        
        let recibo = NSEntityDescription.insertNewObjectForEntityForName(self.smModelo.smRecibo.entityName, inManagedObjectContext: self.moc) as? Recibo

        for (name, value) in receipt {
            
            if name as! String == self.smModelo.smRecibo.colDescripcion {
                recibo!.setValue(value as! String, forKey: self.smModelo.smRecibo.colDescripcion)
            }
            
            if name as! String == smModelo.smRecibo.colFecha {
                recibo!.setValue(dateFormatter.dateFromString(value as! String), forKey: smModelo.smRecibo.colFecha)
            }
            
            if name as! String == smModelo.smRecibo.colTipo {
                recibo!.setValue(value as! Double, forKey: smModelo.smRecibo.colTipo)
            }
            
            if name as! String == smModelo.smRecibo.colValor {
                recibo!.setValue(value as! Double, forKey: smModelo.smRecibo.colValor)
            }
            
            recibo!.setValue(seccion, forKey: smModelo.smRecibo.colSeccion)
        }

        return recibo!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem?.title = "" // = backItem
        
        tvPresupuestos.allowsMultipleSelectionDuringEditing = false
        
        //let databasePath = getPath("CDModel.sqlite")
        //print("Ruta de la bd: \(databasePath)")

        self.initFormatters()
        
        self.initTableViewRowHeight()
        
        let sublayer = CALayer.init()
        sublayer.backgroundColor = UIColor.customLightGrayColor().CGColor
        sublayer.shadowOffset = CGSizeMake(0, 3)
        sublayer.shadowRadius = 5.0
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = CGRectMake(0, 0, 420, 42000)
        self.view.layer.addSublayer(sublayer)
        
        tvPresupuestos.delegate = self
        tvPresupuestos.dataSource = self
        
        tvPresupuestos.allowsSelectionDuringEditing = true
        
        let fltExecTimes = preferencias.floatForKey(prefExecTimes)
        
        if fltExecTimes == 0 {
            // Sólo se realiza en el primer lanzamiento de la app
            self.loadInitJSON()
        }

        preferencias.setFloat(fltExecTimes + 1, forKey: prefExecTimes)

        //print ("Ejecuciones: \(fltExecTimes + 1)")

        #if LITE_VERSION
            self.navigationItem.title = strAppTitle + " Lite"

            if !(Int(fltExecTimes) < CCGlobal().MAX_EXECUTIONS_FOR_LITE_VERSION) {
                showCustomWarningAlert("This is the demo version.  To enjoy the full version of \(strAppTitle) we invite you to obtain the full version.  Thank you!.", toFocus: nil)
            }
        #endif
        
        #if FULL_VERSION
            self.navigationItem.title = strAppTitle
        #endif
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        //self.navigationItem.leftBarButtonItem?.action = #selector(self.setEnableDisableButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchPresupuestos()
        
        #if LITE_VERSION
            if self.presupuestos.count < CCGlobal().MAX_BUDGETS_LITE_VERSION {
                self.btnBudget.enabled = true
            } else if self.presupuestos.count == CCGlobal().MAX_BUDGETS_LITE_VERSION {
                self.btnBudget.enabled = false
            } else {
                self.btnBudget.enabled = false
                self.showCustomWarningAlert("This is the demo version.  To enjoy the full version of \(self.strAppTitle) we invite you to obtain the full version.  Thank you!.", toFocus: nil)
            }
        #endif

        #if FULL_VERSION
            self.btnBudget.enabled = true
        #endif
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tvPresupuestos.deselectRowAtIndexPath(indexSelected, animated: true)
        self.tvPresupuestos.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return strTituloLista
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return 1
        return self.presupuestos.count
    }
    
    // MARK: - Celda personalizada
    func customTableView(ctableView: UITableView, cindexPath: NSIndexPath, cpresupuesto: Presupuesto, caccessoryType: UITableViewCellAccessoryType) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("CustomTableViewCell", forIndexPath: cindexPath)
        
        // Para evitar el re-writting de los labels personalizados
        for cellView in cell.contentView.subviews {
            cellView.removeFromSuperview()
        }
        
        //let labelTitle     : UILabel = UILabel(frame: CGRectMake(0.0, 0.0, 377.0, 35.0))
        let labelTitle     : UILabel = UILabel(frame: CGRectMake(0.0, 0.0, 339.0, 35.0))
        labelTitle.lineBreakMode = .ByTruncatingTail
        labelTitle.numberOfLines = 2
        
        //let labelDateRange : UILabel = UILabel(frame: CGRectMake(0.0,  35.0, 377.0, 18.0))
        
        let labelDateRange : UILabel = UILabel(frame: CGRectMake(0.0,  35.0, 339.0, 18.0))

        let labelPorcentaje: UILabel = UILabel(frame: CGRectMake(0.0, 53.0,  78.0, 20.0))
        
        let labelPresupuesto: UILabel = UILabel(frame: CGRectMake(  0.0, 68.0, 100.0, 25.0))
        let labelIngresos   : UILabel = UILabel(frame: CGRectMake(112.0, 68.0, 100.0, 25.0))
        let labelEgresos    : UILabel = UILabel(frame: CGRectMake(237.0, 68.0, 100.0, 25.0))
        
        let douPresupuesto = cpresupuesto.valueForKey(smModelo.smPresupuesto.colValor) as! Double
        
        let douIngresos = cpresupuesto.valueForKey(smModelo.smPresupuesto.colIngresos) as! Double
        
        let douEjecutado = cpresupuesto.valueForKey(smModelo.smPresupuesto.colEjecutado) as! Double
        
        let douUmbral = cpresupuesto.valueForKey(smModelo.smPresupuesto.colUmbral) as! Double
        
        let porcentaje = (douEjecutado - douIngresos) / douPresupuesto * 100
        
        let strTitulo      = cpresupuesto.valueForKey(smModelo.smPresupuesto.colDescripcion) as! String
        
        let strDateRange   = "\(dateFormatter.stringFromDate(cpresupuesto.fechaInicio!)) - \(dateFormatter.stringFromDate(cpresupuesto.fechaFinal!))"
        let strPresupuesto = formatterMon.stringFromNumber(douPresupuesto)!
        let strIngreso     = formatterMon.stringFromNumber(douIngresos)!
        let strEjecutado   = formatterMon.stringFromNumber(douEjecutado)!
        
        let fontName =  "Verdana-Bold"
        let fontNameNumeric = "Verdana"
        
        //print("Presupuesto: \(strTitulo)")
        //print("Porcentaje: \(porcentaje)")
        //print("Umbral: \(douUmbral)")
        
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        
        labelTitle.text = "  " + strTitulo
        labelTitle.font = UIFont(name: fontName, size: 13)
        labelTitle.textColor = UIColor.blackColor()
        labelTitle.tag = cindexPath.row
        labelTitle.backgroundColor = UIColor.grayColor()
        cell.contentView.addSubview(labelTitle)
        
        labelDateRange.text = "  " + strDateRange
        labelDateRange.font = UIFont(name: fontNameNumeric, size: 11)
        labelDateRange.textColor = UIColor.blackColor()
        labelDateRange.tag = cindexPath.row
        labelDateRange.backgroundColor = UIColor.grayColor()
        cell.contentView.addSubview(labelDateRange)
        
        
        labelPorcentaje.text = "  At " + formatterFlt.stringFromNumber(porcentaje)! + "%"
        labelPorcentaje.font =  UIFont(name: fontName, size: 12)
        labelPorcentaje.textColor = UIColor.blueColor()
        labelPorcentaje.tag = cindexPath.row
        labelPorcentaje.textAlignment = .Left
        labelPorcentaje.frame.size.height = 15

        let backgroundView = UIView()
        if douUmbral > 0 {
            if porcentaje >= douUmbral && porcentaje < 100 {
                labelPorcentaje.backgroundColor = UIColor.customLightYellowColor()
                labelPorcentaje.textColor = UIColor.blackColor()
                labelPorcentaje.font = UIFont.boldSystemFontOfSize(12)
                backgroundView.backgroundColor = UIColor.customLightYellowColor()
            } else if porcentaje > 100 {
                labelPorcentaje.backgroundColor = UIColor.customLightRedColor()
                labelPorcentaje.textColor = UIColor.blackColor()
                labelPorcentaje.font = UIFont.boldSystemFontOfSize(12)
                backgroundView.backgroundColor = UIColor.customLightRedColor()
            } else {
                labelPorcentaje.backgroundColor = UIColor.customLightGreenColor()
                labelPorcentaje.textColor = UIColor.blackColor()
                labelPorcentaje.font = UIFont.boldSystemFontOfSize(12)
                backgroundView.backgroundColor = UIColor.customLightGreenColor()
            }
        }
        cell.selectedBackgroundView = backgroundView
        cell.contentView.addSubview(labelPorcentaje)

        labelPresupuesto.text = strPresupuesto
        labelPresupuesto.font =  UIFont(name: fontNameNumeric, size: 11)
        labelPresupuesto.textColor = UIColor.blackColor()
        labelPresupuesto.tag = cindexPath.row
        labelPresupuesto.textAlignment = .Right
        //labelPresupuesto.backgroundColor = UIColor.customBlueColor()
        cell.contentView.addSubview(labelPresupuesto)
        
        labelIngresos.text = String(format: "\(strIngreso)")
        labelIngresos.font = UIFont(name: fontNameNumeric, size: 11)
        labelIngresos.textColor = UIColor.blueColor()
        labelIngresos.tag = cindexPath.row
        labelIngresos.textAlignment = .Right
        //labelIngresos.backgroundColor = UIColor.customLightYellowColor()
        cell.contentView.addSubview(labelIngresos)
        
        labelEgresos.text = String(format: "\(strEjecutado)")
        labelEgresos.font = UIFont(name: fontNameNumeric, size: 11)
        labelEgresos.textColor = UIColor.redColor()
        labelEgresos.tag = cindexPath.row
        labelEgresos.textAlignment = .Right
        cell.contentView.addSubview(labelEgresos)
        
        cell.accessoryType = caccessoryType

        return cell

    }
    
    /*
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    }
 
    */
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        // Configure the cell...
        var cell: UITableViewCell?
        
        if self.presupuestos.count > 0 {
            self.presupuesto = self.presupuestos[indexPath.row] as? Presupuesto
            
            if self.presupuesto != nil {
                cell = self.customTableView(tableView, cindexPath: indexPath, cpresupuesto: self.presupuesto!, caccessoryType: .DisclosureIndicator)
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("CustomTableViewCell", forIndexPath: indexPath)
            }
            
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("CustomTableViewCell", forIndexPath: indexPath)
                    
        }
        return cell!
    }
    

    /*
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    }
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            //showCustomWarningAlert("Has seleccionado la row: \(indexPath.row) en modo de edición", toFocus: nil)
            
            self.intSelectedIndex = indexPath.row
            self.toolbarItems?.first?.enabled = true

            self.performSegueWithIdentifier("segueNewPresupuesto", sender: self)
        } else {
            self.intSelectedIndex = indexPath.row
            self.performSegueWithIdentifier("segueDetalle", sender: self)
        }
        
        indexSelected = indexPath
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

    /*
    override func tableView(tableView: UITableView,  accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        self.intSelectedIndex = indexPath.row
        
        self.performSegueWithIdentifier("segueDetalle", sender: self)

    }
    */
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        // Estilo checkbox - No repinta el background de los label
        //return UITableViewCellEditingStyle(rawValue: 3)!
        // Estilo sin imagen - permite eliminación
        //return UITableViewCellEditingStyle(rawValue: 0)!
        // Estilo inserción - funciona Ok pero no es coherente el icono
        //return UITableViewCellEditingStyle(rawValue: 2)!
        // Estilo por default eliminación
        return UITableViewCellEditingStyle(rawValue: 1)!

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
            
            #if LITE_VERSION
                self.showCustomWarningAlert("This is the demo version.  To enjoy the full version of \(self.strAppTitle) we invite you to obtain the full version.  Thank you!.", toFocus: nil)
            #endif
            
            #if FULL_VERSION
                if self.presupuestos.count > 0 {
                    self.presupuesto = self.presupuestos[indexPath.row] as? Presupuesto
                    
                    let boolPreservar: Bool = self.presupuesto!.preservar as! Bool
                    
                    if boolPreservar {
                        self.presupuesto?.setValue(false, forKey: smModelo.smPresupuesto.colActivo)
                    } else {
                        self.moc.deleteObject(self.presupuestos[indexPath.row] as! NSManagedObject)
                    }
                    
                    self.presupuestos.removeAtIndex(indexPath.row)
                    
                    do {
                        try self.moc.save()
                        
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    } catch {
                        let deleteError = error as NSError
                        print(deleteError)
                    }
                }
            #endif
            
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }    
    }

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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "segueNewPresupuesto" {

            let vBudget = segue.destinationViewController as! TVCPresupuesto

            if self.intSelectedIndex != -1 {
                if self.presupuestos.count > 0 {
                    
                    self.presupuesto = self.presupuestos[self.intSelectedIndex] as? Presupuesto
                    
                    preferencias.setObject(self.presupuesto?.descripcion, forKey: dflPresupuestoLookingFor)
                }
                vBudget.presupuesto = self.presupuesto
                self.intSelectedIndex = -1
            } else {
                preferencias.setObject(nil, forKey: dflPresupuestoLookingFor)
                vBudget.presupuesto = nil
            }
            
            vBudget.moc = self.moc
                
        } else if segue.identifier == "segueDetalle" {
            
            let vDetail = segue.destinationViewController as! TVCPresupuestoDetalle
            
            if self.intSelectedIndex != -1 {
                if self.presupuestos.count > 0 {
                    
                    self.presupuesto = self.presupuestos[self.intSelectedIndex] as? Presupuesto
                    
                    preferencias.setObject(self.presupuesto?.descripcion, forKey: dflPresupuestoLookingFor)
                }
                vDetail.presupuesto = self.presupuesto
                self.intSelectedIndex = -1
            } else {
                preferencias.setObject(nil, forKey: dflPresupuestoLookingFor)
                vDetail.presupuesto = nil
            }

            vDetail.moc = self.moc
        }
    }
}
