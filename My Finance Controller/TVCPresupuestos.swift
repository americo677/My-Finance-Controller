//
//  TVCPresupuestos.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 5/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit
import CoreData

//class TVCPresupuestos: UITableViewController {


class TVCPresupuestos: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    

    //@IBOutlet weak var btnBudget: UIBarButtonItem!

    class cPresupuesto {
        var titulo: String?
        var rangoFechas: String?
        var porcentaje: String?
        var valor: String?
        var valorIngresos: String?
        var valorEgresos: String?
    }
    
    var oPresupuesto = cPresupuesto()
    
    let preferencias = UserDefaults.standard

    let dflPresupuestoLookingFor = "nameOfBudgetLookingFor"

    let moc = DataController().managedObjectContext
    
    var presupuesto: Presupuesto?
    
    var presupuestos: [AnyObject] = []
    
    let smModelo = CStructureModel()
    
    let prefExecTimes = "ExecTimes"
    
    let strTituloLista = "Customized Budgets"
    
    let strAppTitle = "My Finance Controller"
    
    var intSelectedIndex : Int = -1
        
        
    
    //let MAX_ROW_HEIGHT: CGFloat = 93
    
    let formatterMon : NumberFormatter = NumberFormatter()
    let formatterFlt : NumberFormatter = NumberFormatter()
    var indexSelected: IndexPath = IndexPath()
    
    let dateFormatter: DateFormatter = DateFormatter()
    
    func initFormatters() {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        formatterMon.numberStyle = .currency
        formatterMon.maximumFractionDigits = 2
        formatterFlt.numberStyle = .none
        formatterFlt.maximumFractionDigits = 2
    }

    // MARK: - Consulta a la BD los presupuestos registrados
    func fetchPresupuestos() {
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: smModelo.smPresupuesto.entityName)
        
        let predicado: NSPredicate =  NSPredicate(format: " activo = true ")

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
    
    func initTableViewRowHeight() {
        self.tableView.rowHeight = CCGlobal().MAX_ROW_HEIGHT
        //self.tvPresupuestos.frame.size.width = 500
    }
    
    func getPath(_ fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return fileURL.path
    }

    // MARK: - Carga inicial de datos JSON
    func loadInitJSON() {
        if let dataPath = Bundle.main.path(forResource: "initialbudget", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: dataPath), options: NSData.ReadingOptions.mappedIfSafe)
                do {
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
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
    
    func loadInitJSONPresupuesto(_ budget: NSDictionary) -> Presupuesto {
        //print("Presupuesto: \(budget)")
        
        let presupuesto = NSEntityDescription.insertNewObject(forEntityName: self.smModelo.smPresupuesto.entityName, into: self.moc) as? Presupuesto
        
        for (name, value) in budget {
            
            if name as! String == self.smModelo.smPresupuesto.colDescripcion {
                presupuesto!.setValue(value as! String, forKey: self.smModelo.smPresupuesto.colDescripcion)
            }

            if name as! String == smModelo.smPresupuesto.colFechaIni {
                presupuesto!.setValue(dateFormatter.date(from: value as! String), forKey: smModelo.smPresupuesto.colFechaIni)
            }
            
            if name as! String == smModelo.smPresupuesto.colFechaFin {
                presupuesto!.setValue(dateFormatter.date(from: value as! String), forKey: smModelo.smPresupuesto.colFechaFin)
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
            
            let lpsSeccion = presupuesto?.mutableSetValue(forKey: self.smModelo.smPresupuesto.colSecciones)
            
            if name as! String == "secciones" {
                if let secciones : [NSDictionary] = budget["secciones"] as? [NSDictionary] {
                    for seccion: NSDictionary in secciones {
                        let iSeccion = self.loadInitJSONSeccion(seccion)
                        lpsSeccion?.add(iSeccion)
                    }
                    presupuesto?.setValue(lpsSeccion, forKey: self.smModelo.smPresupuesto.colSecciones)
                }
            }
        }
        return presupuesto!
    }
    
    func loadInitJSONSeccion(_ section: NSDictionary) -> PresupuestoSeccion {
        //print("sección: \(section)")

        let seccion = NSEntityDescription.insertNewObject(forEntityName: self.smModelo.smPresupuestoSeccion.entityName, into: self.moc) as? PresupuestoSeccion
        
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
            
            let lpsRecibo = seccion?.mutableSetValue(forKey: self.smModelo.smPresupuestoSeccion.colRecibos)

            if name as! String == "recibos" {
                if let recibos : [NSDictionary] = section["recibos"] as? [NSDictionary] {
                    for recibo: NSDictionary in recibos {
                        let iRecibo = self.loadInitJSONRecibo(recibo, seccion: seccion!)
                        lpsRecibo?.add(iRecibo)
                    }
                    seccion?.setValue(lpsRecibo, forKey: self.smModelo.smPresupuestoSeccion.colRecibos)
                }
            }
        }
        return seccion!
    }
    
    func loadInitJSONRecibo(_ receipt: NSDictionary, seccion: PresupuestoSeccion) -> Recibo {
        //print("recibo: \(receipt)")
        
        let recibo = NSEntityDescription.insertNewObject(forEntityName: self.smModelo.smRecibo.entityName, into: self.moc) as? Recibo

        for (name, value) in receipt {
            
            if name as! String == self.smModelo.smRecibo.colDescripcion {
                recibo!.setValue(value as! String, forKey: self.smModelo.smRecibo.colDescripcion)
            }
            
            if name as! String == smModelo.smRecibo.colFecha {
                recibo!.setValue(dateFormatter.date(from: value as! String), forKey: smModelo.smRecibo.colFecha)
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
    
    
    func btnBudgetOnTouchInsideUp(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "segueNewPresupuesto", sender: sender)
    }
    
    func btnEditOnTouchInsideUp(_ sender: UIBarButtonItem) {
        
        if self.tableView.isEditing {
            self.editButtonItem.title = "Edit"
            self.tableView.setEditing(false, animated: true)
        } else {
            self.editButtonItem.title = "Done"
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    
    // MARK: - Procedimientos para carga de la vista
    
    func loadPreferences() {
        
        // inicializar los placeholder de los UITextField que lo requieran
        //txtMonto.placeholder  = "Monto del préstamo"
        
        // Para UITextField de entrada numérica
        //self.txtMonto.keyboardType = .decimalPad
        
        // Cambia el color de la navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.gray
        
        // Cambia el color del texto de la navigation bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,  NSFontAttributeName: UIFont(name: CCGlobal().FONT_NAME_TITLE_NAVIGATION_BAR, size: 17)!]
        
        // para el color de los textos de los buttonItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //let leftButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        
        //#selector(self.btnInfoOnTouchInsideUp(_:)
        
        
        let rightButton = UIBarButtonItem(title: "Budget", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.btnBudgetOnTouchInsideUp(_:)))
        
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
        
        
        //leftButton.setTitleTextAttributes(attributes, for: UIControlState.normal)
        self.editButtonItem.setTitleTextAttributes(attributes, for: UIControlState.normal)
        
        self.editButtonItem.action =  #selector(self.btnEditOnTouchInsideUp(_:))
        
        rightButton.setTitleTextAttributes(attributes, for: UIControlState.normal)
        
        backButton.setTitleTextAttributes(attributes, for: UIControlState.normal)
        
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        
        self.navigationItem.backBarButtonItem = backButton
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.backBarButtonItem?.title = "" // = backItem
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let identifier = "presupuestoCell"
        //let nib = UINib(nibName: "PresupuestoCell", bundle: nil)
        //self.tableView.register(nib, forCellReuseIdentifier: identifier)
        
        
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)

        //self.tvPresupuestos.register(CustomTableViewCell.self, forCellReuseIdentifier: identifier)
        
        self.loadPreferences()
        
        
        //self.tvPresupuestos.register(UITableViewCell
            
            //tableView.registerNib(UINib(nibName: "NameInput", bundle: nil), forCellReuseIdentifier: "Cell")
        
        let myBundle = Bundle(for: TVCPresupuestos.self)
        
        let nib = UINib(nibName: "PresupuestoCell", bundle: myBundle)

            
        //self.tvPresupuestos.register(nib, forCellReuseIdentifier: "CustomTableViewCell")
        //self.tableView.register(PresupuestoCell.classForCoder(), )
        self.tableView.register(nib, forCellReuseIdentifier: identifier)


        
        self.tableView.allowsMultipleSelectionDuringEditing = false
        
        //let databasePath = getPath("CDModel.sqlite")
        //print("Ruta de la bd: \(databasePath)")

        self.initFormatters()
        
        self.initTableViewRowHeight()
        
        /*
        let sublayer = CALayer.init()
        sublayer.backgroundColor = UIColor.customLightGrayColor().cgColor
        sublayer.shadowOffset = CGSize(width: 0, height: 3)
        sublayer.shadowRadius = 5.0
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = CGRect(x: 0, y: 0, width: 420, height: 42000)
        self.view.layer.addSublayer(sublayer)
        */
        
        
        let fltExecTimes = preferencias.float(forKey: prefExecTimes)
        
        if fltExecTimes == 0 {
            // Sólo se realiza en el primer lanzamiento de la app
            self.loadInitJSON()
        }

        preferencias.set(fltExecTimes + 1, forKey: prefExecTimes)

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
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //self.navigationItem.leftBarButtonItem?.action = #selector(self.setEnableDisableButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchPresupuestos()
        
        #if LITE_VERSION
            if self.presupuestos.count < CCGlobal().MAX_BUDGETS_LITE_VERSION {
                //self.btnBudget.enabled = true
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else if self.presupuestos.count == CCGlobal().MAX_BUDGETS_LITE_VERSION {
                //self.btnBudget.enabled = false
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                //self.btnBudget.enabled = false
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.showCustomWarningAlert("This is the demo version.  To enjoy the full version of \(self.strAppTitle) we invite you to obtain the full version.  Thank you!.", toFocus: nil)
            }
        #endif

        #if FULL_VERSION
            //self.btnBudget.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.deselectRow(at: indexSelected, animated: true)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    //override
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return strTituloLista
    }
    
    private func tableView(tableView:UITableView!, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat {
        return 44 //CCGlobal().MAX_ROW_HEIGHT
    }
    
    //override
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //override
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return 1
        return self.presupuestos.count
    }
    
    /*
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    */
    
    /*
        
    private func tableView(_ tableView: UITableView, willDisplay cell: CustomTableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.tituloPresupuesto.text = self.presupuetoCell.titulo
        cell.tituloPresupuesto.tag = indexPath.row
        
        cell.rangoFechas.text = self.presupuetoCell.rangoFechas
        cell.rangoFechas.tag = indexPath.row
        
        cell.porcentaje.text = self.presupuetoCell.porcentaje
        cell.porcentaje.tag = indexPath.row
        
        cell.valorPresupuesto.text = self.presupuetoCell.valor
        cell.valorPresupuesto.tag = indexPath.row
        
        cell.valorIngresos.text = self.presupuetoCell.valorIngresos
        cell.valorIngresos.tag = indexPath.row
        
        cell.valorEgresos.text = self.presupuetoCell.valorEgresos
        cell.valorEgresos.tag = indexPath.row

        
        
        /*
        if self.presupuestos.count > 0 {
            self.presupuesto = self.presupuestos[indexPath.row] as? Presupuesto
            
            if self.presupuesto != nil {
                cell = self.customTableView(tableView, cindexPath: indexPath, cpresupuesto: self.presupuesto!, caccessoryType: .disclosureIndicator)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath)
            }
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath)
            
        }
        */
    }
 */

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let identifier = "presupuestoCell"
        
        let cell: PresupuestoCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PresupuestoCell
        
        if self.presupuestos.count > 0 {
            self.presupuesto = self.presupuestos[indexPath.row] as? Presupuesto
            
            if self.presupuesto?.descripcion! != nil {
                //print("pathIndex.row(\(indexPath.row)): \(self.presupuesto!)")
 
                self.oPresupuesto = cPresupuesto()
                
                // Para evitar el re-writting de los labels personalizados
                //for cellView in (cell.contentView.subviews) {
                //    cellView.removeFromSuperview()
                //}
                
                let strTitulo = (self.presupuesto?.descripcion)! as String
                
                self.oPresupuesto.titulo = strTitulo
                
                
                cell.titulo?.text = strTitulo
                cell.titulo?.tag = indexPath.row
                
                //print("Titulo del presupuesto (on cellForRowAt): \(cell.titulo?.text!)")
                
                let strDateRange   = "\(dateFormatter.string(from: ((self.presupuesto?.fechaInicio)! as Date))) - \(dateFormatter.string(from: ((self.presupuesto?.fechaFinal)! as Date)))"
                
                
                self.oPresupuesto.rangoFechas = strDateRange
                
                cell.rangoFechas?.text = strDateRange
                cell.rangoFechas?.tag = indexPath.row
                
                
                let douPresupuesto = (self.presupuesto?.value(forKey: smModelo.smPresupuesto.colValor) as! Double)
                
                let douIngresos = (self.presupuesto?.value(forKey: smModelo.smPresupuesto.colIngresos) as! Double)
                
                let douEjecutado = (self.presupuesto?.value(forKey: smModelo.smPresupuesto.colEjecutado) as! Double)
                
                let douUmbral = (self.presupuesto?.value(forKey: smModelo.smPresupuesto.colUmbral) as! Double)
                
                let porcentaje = (douEjecutado - douIngresos) / douPresupuesto * 100
                
                let strPresupuesto = formatterMon.string(from: NSNumber.init(value: douPresupuesto))!
                
                let strIngreso     = formatterMon.string(from: NSNumber.init(value: douIngresos))!
                
                let strEjecutado   = formatterMon.string(from: NSNumber.init(value: douEjecutado))!
                
                self.oPresupuesto.porcentaje = "  At \(formatterFlt.string(from: NSNumber.init(value: porcentaje))!)%"
                
                cell.porcentaje?.text = "  At " + formatterFlt.string(from: NSNumber.init(value: porcentaje))! + "%"
                cell.porcentaje?.tag = indexPath.row
                
                
                let backgroundView = UIView()
                
                if douUmbral > 0 {
                    if porcentaje >= douUmbral && porcentaje < 100 {
                        cell.porcentaje?.backgroundColor = UIColor.customLightYellowColor()
                        cell.porcentaje?.textColor = UIColor.black
                        //labelPorcentaje.font = UIFont.boldSystemFont(ofSize: 11)
                        backgroundView.backgroundColor = UIColor.customLightYellowColor()
                    } else if porcentaje > 100 {
                        cell.porcentaje?.backgroundColor = UIColor.customLightRedColor()
                        cell.porcentaje?.textColor = UIColor.black
                        //labelPorcentaje.font = UIFont.boldSystemFont(ofSize: 11)
                        backgroundView.backgroundColor = UIColor.customLightRedColor()
                    } else {
                        cell.porcentaje?.backgroundColor = UIColor.customLightGreenColor()
                        cell.porcentaje?.textColor = UIColor.black
                        //labelPorcentaje.font = UIFont.boldSystemFont(ofSize: 11)
                        backgroundView.backgroundColor = UIColor.customLightGreenColor()
                    }
                }
                
                cell.selectedBackgroundView = backgroundView
                
                self.oPresupuesto.valor = strPresupuesto
                cell.valorPresupuesto?.text = strPresupuesto
                cell.valorPresupuesto?.tag = indexPath.row
                
                self.oPresupuesto.valorIngresos = strIngreso
                cell.valorIngresos?.text = String(format: "\(strIngreso)")
                cell.valorIngresos?.tag = indexPath.row
                
                self.oPresupuesto.valorEgresos = strEjecutado
                cell.valorEgresos?.text = String(format: "\(strEjecutado)")
                cell.valorEgresos?.tag = indexPath.row
                
            }
        }
        
        return cell
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

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
                        self.moc.delete(self.presupuestos[indexPath.row] as! NSManagedObject)
                    }
                    
                    self.presupuestos.remove(at: indexPath.row)
                    
                    do {
                        try self.moc.save()
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } catch {
                        let deleteError = error as NSError
                        print(deleteError)
                    }
                }
            #endif
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            self.intSelectedIndex = indexPath.row
            self.performSegue(withIdentifier: "segueNewPresupuesto", sender: self)
        } else {
            self.intSelectedIndex = indexPath.row
            self.performSegue(withIdentifier: "segueDetalle", sender: self)
        }
        
        indexSelected = indexPath
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "segueNewPresupuesto" {

            let vBudget = segue.destination as! TVCPresupuesto

            if self.intSelectedIndex != -1 {
                if self.presupuestos.count > 0 {
                    
                    self.presupuesto = self.presupuestos[self.intSelectedIndex] as? Presupuesto
                    
                    preferencias.set(self.presupuesto?.descripcion, forKey: dflPresupuestoLookingFor)
                }
                vBudget.presupuesto = self.presupuesto
                self.intSelectedIndex = -1
            } else {
                preferencias.set(nil, forKey: dflPresupuestoLookingFor)
                vBudget.presupuesto = nil
            }
            
            vBudget.moc = self.moc
                
        } else if segue.identifier == "segueDetalle" {
            
            let vDetail = segue.destination as! TVCPresupuestoDetalle
            
            if self.intSelectedIndex != -1 {
                if self.presupuestos.count > 0 {
                    
                    self.presupuesto = self.presupuestos[self.intSelectedIndex] as? Presupuesto
                    
                    preferencias.set(self.presupuesto?.descripcion, forKey: dflPresupuestoLookingFor)
                }
                vDetail.presupuesto = self.presupuesto
                self.intSelectedIndex = -1
            } else {
                preferencias.set(nil, forKey: dflPresupuestoLookingFor)
                vDetail.presupuesto = nil
            }

            vDetail.moc = self.moc
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
