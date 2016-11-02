//
//  TVCPresupuestoDetalle.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 15/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
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


class TVCPresupuestoDetalle: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var tvPresupuesto: UITableView!
    
    @IBOutlet weak var bbtnReceipt: UIBarButtonItem!
    
    var moc = DataController().managedObjectContext
    
    var presupuesto: Presupuesto?
    
    let smModelo = CStructureModel()
    
    var arrRecibo: [AnyObject] = []
    
    var recibo: Recibo?
    
    var seccion: PresupuestoSeccion?
    
    var intTotalRecibos: Int = 0
    
    let dtFormatter: DateFormatter = DateFormatter()
    let fmtMoneda : NumberFormatter = NumberFormatter()
    let fmtFloat : NumberFormatter = NumberFormatter()
    
    var indexSelected: IndexPath = IndexPath()
    let strAppTitle = "My Finance Controller"
    
    let MAX_ROW_HEIGHT: CGFloat = 50
    let MAX_SECTION_ROW_HEIGHT: CGFloat = 55

    enum eTipoRegistro: Int {
        case income = 0
        case expenditure = 1
    }

    func initTableViewRowHeight() {
        self.tvPresupuesto.rowHeight = MAX_ROW_HEIGHT
    }

    func initFormatters() {
        // Preparación del formateador de fecha
        dtFormatter.dateFormat = "dd/MM/yyyy"
        
        // Preparación de los formateadores númericos
        fmtMoneda.numberStyle = .currency
        fmtMoneda.maximumFractionDigits = 2
        
        fmtFloat.numberStyle = .none
        fmtFloat.maximumFractionDigits = 2
        
    }
    
    func writeCoreDataObjectToCVS(_ objects: [NSManagedObject], named: String) -> String {
        
        guard objects.count > 0 else {
            return ""
        }
        
        var strLine: String = ""
        
        let headerBudget = "Budget Name;Start Date;Final Date;Budget Amount;Warning Threshold;Total Income;Money used\n"

        strLine += headerBudget
        
        if self.presupuesto != nil {
            strLine += (self.presupuesto?.descripcion)! + ";"
            
            strLine += dtFormatter.string(from: (self.presupuesto?.fechaInicio)! as Date) + ";"
            
            strLine += dtFormatter.string(from: (self.presupuesto?.fechaFinal)! as Date) + ";"
            
            strLine += fmtFloat.string(from: (self.presupuesto?.valor)!)! + ";"
            
            strLine += fmtFloat.string(from: (self.presupuesto?.umbral)!)! + "%;"
            
            strLine += fmtFloat.string(from: (self.presupuesto?.ingresos)!)! + ";"
            
            strLine += fmtFloat.string(from: (self.presupuesto?.ejecutado)!)! + "\n"
        }
        
        
        for object in objects {
            
            let seccion = object as? PresupuestoSeccion
            
            let headerSection = "Section Name;Section Total Income;Section Total Expenses\n"
            let headerReceipt = "Receipt Description;Date;Income;Expenditure\n"
            
            strLine += headerSection
            
            strLine += (seccion?.descripcion)! + ";"
            strLine += fmtFloat.string(from: (seccion?.totalIngresos)!)! + ";"
            strLine += fmtFloat.string(from: (seccion?.totalEgresos)!)! + "\n"
            
            if seccion?.recibos?.count > 0 {
                let recibos = seccion?.recibos?.allObjects as? [Recibo]
                
                strLine += headerReceipt
                
                for subObject in recibos! {
                    
                    let recibo = subObject as Recibo
                    
                    strLine += recibo.descripcion! + ";"
                    strLine += dtFormatter.string(from: recibo.fecha! as Date) + ";"
                    if recibo.tipo?.hashValue == eTipoRegistro.income.hashValue {
                        strLine += fmtFloat.string(from: recibo.valor!)! + ";\n"
                    } else {
                        strLine += ";" + fmtFloat.string(from: recibo.valor!)! + "\n"
                    }
                }
            }
        }
        
        return strLine
        
    }

    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            
            mail.mailComposeDelegate = self
            mail.setToRecipients([])
            mail.setMessageBody("<p>Here is your Budget</p>", isHTML: true)
            
            
            #if LITE_VERSION
                mail.setSubject(strAppTitle + " Lite demo sending")
            #endif
            
            #if FULL_VERSION
                mail.setSubject(strAppTitle + ": " + (self.presupuesto?.descripcion)!)
            #endif
            
            let csvString = self.writeCoreDataObjectToCVS(self.presupuesto?.secciones?.allObjects as! [NSManagedObject] ,named: "no_name")
            
            let data = csvString.data(using: String.Encoding.utf8)
            
            let strExportFileName = self.presupuesto?.descripcion?.replacingOccurrences(of: " ", with: "_")
            
            mail.addAttachmentData(data!, mimeType: "text/csv", fileName: "\(strExportFileName!).csv")
            
            self.present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
            showCustomWarningAlert("You must authorize sending e-mail.", toFocus: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func btnActionOnTouchInsideup(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: self.strAppTitle, message: "You can send your budget using E-mail.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print(action)
        }
        //alertController.addAction(cancelAction)
        
        //let destroyAction = UIAlertAction(title: "Destroy", style: .Destructive) { (action) in
        //    print(action)
            
        //}
        
        let oneAction = UIAlertAction(title: "Send E-mail", style: .default) { (_) in
            self.sendEmail()
        }

        //let twoAction = UIAlertAction(title: "Two", style: .Default) { (_) in }
        //let threeAction = UIAlertAction(title: "Three", style: .Default) { (_) in }
        //let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addAction(oneAction)
        //alertController.addAction(twoAction)
        //alertController.addAction(threeAction)
        alertController.addAction(cancelAction)
        //alertController.addAction(destroyAction)
        
        self.present(alertController, animated: true) {
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tvPresupuesto.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "CellPresupuestoDetalle")
        
        self.tvPresupuesto.register(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "customHeaderView")
        
        self.initTableViewRowHeight()
        
        #if LITE_VERSION
            //self.navigationController?.toolbarHidden = true
            self.navigationController?.toolbarHidden = false
            var items = [AnyObject]()
            items.append(UIBarButtonItem(title: "Send", style: .Plain, target: self,action: #selector(self.btnActionOnTouchInsideup)))
            self.toolbarItems = items as? [UIBarButtonItem]
        #endif
        
        #if FULL_VERSION
            self.navigationController?.isToolbarHidden = false
            var items = [AnyObject]()
            items.append(UIBarButtonItem(title: "Send", style: .plain, target: self,action: #selector(self.btnActionOnTouchInsideup)))
            self.toolbarItems = items as? [UIBarButtonItem]
        #endif
        
        let sublayer = CALayer.init()
        sublayer.backgroundColor = UIColor.customLightGrayColor().cgColor
        sublayer.shadowOffset = CGSize(width: 0, height: 3)
        sublayer.shadowRadius = 5.0
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = CGRect(x: 0, y: 0, width: 420, height: 42000)
        self.view.layer.addSublayer(sublayer)
        
        self.title = self.presupuesto?.descripcion
        
        self.navigationItem.backBarButtonItem?.title = "" // = backItem

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.initFormatters()
    }
    
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

    override func viewWillAppear(_ animated: Bool) {
        
        #if LITE_VERSION
            self.intTotalRecibos = 0
            if self.presupuesto != nil {
                let secciones = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
                
                for seccion in secciones {
                    intTotalRecibos += (seccion.recibos?.allObjects.count)!
                }
                
                if intTotalRecibos < CCGlobal().MAX_RECEIPTS_FOR_BUDGETS_LITE_VERSION {
                    bbtnReceipt.enabled = true
                    if self.presupuesto != nil {
                        
                        if secciones.count <= 0 {
                            bbtnReceipt.enabled = false
                            showCustomWarningAlert("You must record at least a section!.", toFocus: nil)
                        } else {
                            let seccion = secciones[0]
                            
                            if seccion.descripcion != "" {
                                bbtnReceipt.enabled = true
                            } else {
                                bbtnReceipt.enabled = false
                            }
                        }
                    }
                } else if intTotalRecibos == CCGlobal().MAX_RECEIPTS_FOR_BUDGETS_LITE_VERSION {
                    bbtnReceipt.enabled = false
                    
                }
                //print("Total recibos en Detalles: \(self.intTotalRecibos)")
            }
        #endif
        
        #if FULL_VERSION
            self.bbtnReceipt.isEnabled = true
            if self.presupuesto != nil {
                
                let secciones = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
                
                if secciones.count <= 0 {
                    bbtnReceipt.isEnabled = false
                    showCustomWarningAlert("You must record at least a section!.", toFocus: nil)
                } else {
                    let seccion = secciones[0]
                    
                    if seccion.descripcion != "" {
                        bbtnReceipt.isEnabled = true
                    } else {
                        bbtnReceipt.isEnabled = false
                    }
                }
            }
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tvPresupuesto.deselectRow(at: indexSelected, animated: true)
        tvPresupuesto.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.presupuesto != nil {
            return (self.presupuesto?.secciones?.count)!
        } else {
            return 0
        }
    }
    
    // MARK: - Celda personalizada
    func customTableView(_ ctableView: UITableView, cindexPath: IndexPath, crecibo: Recibo, caccessoryType: UITableViewCellAccessoryType) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellPresupuestoDetalle", for: cindexPath)
        
        // Para evitar el re-writting de los labels personalizados
        for cellView in cell.contentView.subviews {
            cellView.removeFromSuperview()
        }
        
        //print("Descripcion: \(crecibo.valueForKey(smModelo.smRecibo.colDescripcion) as! String!)")
        //print("Fecha: \(crecibo.valueForKey(smModelo.smRecibo.colFecha) as! NSDate!)")
        //print("Tipo: \(crecibo.valueForKey(smModelo.smRecibo.colTipo) as! Int!)")
        //print("Valor: \(fmtMoneda.stringFromNumber( crecibo.valueForKey(smModelo.smRecibo.colValor) as! Double)!)")

        let strDescripcion = crecibo.value(forKey: smModelo.smRecibo.colDescripcion) as! String!
        let dtFecha        = crecibo.value(forKey: smModelo.smRecibo.colFecha) as! Date!
        let intTipo        = crecibo.value(forKey: smModelo.smRecibo.colTipo) as! Int!
        let strValor       = fmtMoneda.string(from: NSNumber.init(value: crecibo.value(forKey: smModelo.smRecibo.colValor) as! Double))!
        
        let fontName =  "Verdana-Bold"
        let fontNameNumeric = "Verdana"
        
        let labelNombre: UILabel = UILabel(frame: CGRect(x: 17.0, y: 0.0, width: 377.0, height: 30.0))
        
        labelNombre.text = "  " + strDescripcion!
        labelNombre.font = UIFont(name: fontName, size: 13)
        labelNombre.textAlignment = NSTextAlignment.left
        labelNombre.textColor = UIColor.black
        labelNombre.tag = cindexPath.row
        cell.contentView.addSubview(labelNombre)

        let labelFecha: UILabel = UILabel(frame: CGRect(x: 17.0, y: 25.0, width: 100.0, height: 30.0))
        labelFecha.text = "  " + dtFormatter.string(from: dtFecha!)
        labelFecha.font = UIFont(name: fontNameNumeric, size: 12)
        labelFecha.textAlignment = NSTextAlignment.left
        labelFecha.textColor = UIColor.black
        labelFecha.tag = cindexPath.row
        cell.contentView.addSubview(labelFecha)
        
        
        let labelValor: UILabel = UILabel(frame: CGRect(x: 250.0, y: 25.0, width: 100.0, height: 30.0))
        labelValor.text = String(format: "\(strValor)")
        labelValor.font = UIFont(name: fontNameNumeric, size: 12)
        labelValor.textAlignment = NSTextAlignment.right
        labelValor.tag = cindexPath.row
        if intTipo == 0 {
            labelValor.textColor = UIColor.blue
        } else if intTipo == 1 {
            labelValor.textColor = UIColor.red
        }
        labelValor.tag = cindexPath.row
        cell.contentView.addSubview(labelValor)
        
        cell.accessoryType = caccessoryType
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MAX_SECTION_ROW_HEIGHT
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: NSInteger) -> UIView {
        
        let cellHeaderViewIdentifier = "customHeaderView"

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: cellHeaderViewIdentifier)! as UITableViewHeaderFooterView
        
        // Para evitar el re-writting de los labels personalizados
        for headerViewItem in headerView.contentView.subviews {
            headerViewItem.removeFromSuperview()
        }
        
        headerView.contentView.frame = CGRect( x: 0.0, y: 0.0, width: 350.0, height: 55.0)
        headerView.contentView.backgroundColor = UIColor.gray

        let labelSeccion   : UILabel = UILabel(frame: CGRect(x: 0.0,  y: 0, width: 350.0, height: 35))
        let labelPorcentaje: UILabel = UILabel(frame: CGRect(x: 0.0, y: 35.00,  width: 350.0, height: 20.0))
        
        labelSeccion.lineBreakMode = .byTruncatingTail
        labelSeccion.numberOfLines = 2

        if self.presupuesto != nil {
            let arr = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
            let presupuestado = self.presupuesto?.valor as! Double
            let strSeccion = "  " + arr[section].descripcion!
            let ejecutadoSeccion = arr[section].totalEgresos as! Double
            let ingresos = arr[section].totalIngresos as! Double
            let porcentaje = (ejecutadoSeccion - ingresos) / presupuestado * 100
            
            let fontName =  "Verdana-Bold"
            let fontNameNumeric = "Verdana"

            labelSeccion.text = strSeccion
            labelSeccion.font = UIFont(name: fontName, size: 14)
            labelSeccion.textColor = UIColor.white
            labelSeccion.tag = section.hashValue
            
            labelPorcentaje.text =  "  At \(fmtFloat.string(from: NSNumber.init(value: porcentaje))!)%"
            labelPorcentaje.font =  UIFont(name: fontNameNumeric, size: 12)
            labelPorcentaje.textColor = UIColor.white
            labelPorcentaje.tag = section.hashValue

            headerView.contentView.addSubview(labelSeccion)
            headerView.contentView.addSubview(labelPorcentaje)
            
        }
        return headerView;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows: Int = 0
        
        if self.presupuesto != nil {
            let arrSeccion = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
            
            let seccion = arrSeccion[section] as PresupuestoSeccion
            
            
            // todo: para revisar
            self.arrRecibo = seccion.mutableSetValue(forKey: smModelo.smPresupuestoSeccion.colRecibos).allObjects as [AnyObject]
            
            numberOfRows = self.arrRecibo.count
            
        }
        
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("CellPresupuestoDetalle", forIndexPath: indexPath)

        // Configure the cell...
        var cell: UITableViewCell?
        
        let arrSeccion = self.presupuesto?.mutableSetValue(forKey: smModelo.smPresupuesto.colSecciones).allObjects
        
        let seccion = arrSeccion![indexPath.section] as! PresupuestoSeccion
        
        self.arrRecibo = seccion.mutableSetValue(forKey: smModelo.smPresupuestoSeccion.colRecibos).allObjects as [AnyObject]

        if self.arrRecibo.count > 0 {
            let recibo = self.arrRecibo[indexPath.row] as! Recibo
        
            let strDescripcion = recibo.value(forKey: smModelo.smRecibo.colDescripcion) as! String!
            //print("Indice: \(indexPath.row)")
            //print("Descripción del recibo: \(strDescripcion)")
            
            let dtFecha        = recibo.value(forKey: smModelo.smRecibo.colFecha) as! Date!
            //print("Fecha del recibo: \(dtFecha)")

            let douValor       = recibo.value(forKey: smModelo.smRecibo.colValor) as! Double
            //print("Valor del recibo: \(douValor)")
            
            if strDescripcion == nil && dtFecha == nil && douValor == 0 {
                self.arrRecibo.remove(at: indexPath.row)
                cell = tableView.dequeueReusableCell(withIdentifier: "CellPresupuestoDetalle", for: indexPath)
            } else {
                cell = customTableView(tableView, cindexPath: indexPath, crecibo: recibo, caccessoryType: .disclosureIndicator)
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "CellPresupuestoDetalle", for: indexPath)
        }
        
        return cell!
    }

    
    @IBAction func barBtnItemAddOnTouchInsideDown(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "segueRecibo", sender: self)
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
            //#if LITE_VERSION
                //showCustomWarningAlert("This is the demo version.  To enjoy the full version of \(self.strAppTitle) we invite you to obtain the full version.  Thank you!.", toFocus: nil)
            //#endif
            
            
            //#if FULL_VERSION
                let arrSeccion = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
                let seccion = arrSeccion[indexPath.section] as PresupuestoSeccion
                self.arrRecibo = seccion.mutableSetValue(forKey: smModelo.smPresupuestoSeccion.colRecibos).allObjects as [AnyObject]
                
                if self.arrRecibo.count > 0 {
                    
                    let recibo = self.arrRecibo[indexPath.row] as! NSManagedObject
                    
                    let monto = recibo.value(forKey: smModelo.smRecibo.colValor) as! Double
                    
                    let tipo  = recibo.value(forKey: smModelo.smRecibo.colTipo) as! Int
                    
                    if eTipoRegistro.expenditure.hashValue == tipo {
                        var egreso  = (seccion.value(forKey: smModelo.smPresupuestoSeccion.colTotalEgresos) as? Double)!
                        var egresos = (self.presupuesto?.value(forKey: smModelo.smPresupuesto.colEjecutado) as? Double)!
                        
                        egreso -= monto
                        egresos -= monto
                        
                        seccion.setValue(egreso, forKey: smModelo.smPresupuestoSeccion.colTotalEgresos)
                        self.presupuesto?.setValue(egresos, forKey: smModelo.smPresupuesto.colEjecutado)
                    } else if eTipoRegistro.income.hashValue == tipo {
                        var ingreso = (seccion.value(forKey: smModelo.smPresupuestoSeccion.colTotalIngresos) as? Double)!
                        var ingresos = (self.presupuesto?.value(forKey: smModelo.smPresupuesto.colIngresos) as? Double)!
                        
                        ingreso -= monto
                        ingresos -= monto
                        
                        seccion.setValue(ingreso, forKey: smModelo.smPresupuestoSeccion.colTotalIngresos)
                        self.presupuesto?.setValue(ingresos, forKey: smModelo.smPresupuesto.colIngresos)
                    }
                    
                    self.moc.delete(self.arrRecibo[indexPath.row] as! NSManagedObject)
                    
                    self.arrRecibo.remove(at: indexPath.row)
                    do {
                        try self.moc.save()
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } catch {
                        let deleteError = error as NSError
                        print(deleteError)
                    }
                }
            //#endif
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let arrSeccion = self.presupuesto?.mutableSetValue(forKey: smModelo.smPresupuesto.colSecciones).allObjects
        
        self.seccion = arrSeccion![indexPath.section] as? PresupuestoSeccion
        
        self.arrRecibo = self.seccion!.mutableSetValue(forKey: smModelo.smPresupuestoSeccion.colRecibos).allObjects as [AnyObject]
        
        if self.arrRecibo.count > 0 {
            self.recibo = self.arrRecibo[indexPath.row] as? Recibo
        } else {
            self.recibo = nil
        }
            self.performSegue(withIdentifier: "segueRecibo", sender: self)
        
        self.indexSelected = indexPath
     }

    
    @IBAction func btnReceiptOnTouchInsideDonw(_ sender: UIBarButtonItem) {

        self.performSegue(withIdentifier: "segueNewRecibo", sender: self)
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
    
    
    @IBAction func bbtnActionOnTouchInsideUp(_ sender: UIBarButtonItem) {
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueRecibo" {
            let vcReg: VCRegistro = segue.destination as! VCRegistro
            vcReg.presupuesto = self.presupuesto
            vcReg.moc         = self.moc
            vcReg.arrSeccion = (self.presupuesto?.secciones?.allObjects as? [PresupuestoSeccion])?.sorted { $0.descripcion < $1.descripcion }
            vcReg.seccion = self.seccion
            vcReg.recibo = self.recibo
            vcReg.intTotalRecibos = self.intTotalRecibos
        } else if segue.identifier == "segueNewRecibo" {
            let vcReg: VCRegistro = segue.destination as! VCRegistro
            vcReg.presupuesto = self.presupuesto
            vcReg.moc         = self.moc
            vcReg.arrSeccion = (self.presupuesto?.secciones?.allObjects as? [PresupuestoSeccion])?.sorted { $0.descripcion < $1.descripcion }
            vcReg.seccion = nil
            vcReg.recibo  = nil
            vcReg.intTotalRecibos = self.intTotalRecibos
        }
    }
    

}
