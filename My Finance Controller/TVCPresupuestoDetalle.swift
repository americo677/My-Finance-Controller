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
    
    let dtFormatter: NSDateFormatter = NSDateFormatter()
    let fmtMoneda : NSNumberFormatter = NSNumberFormatter()
    let fmtFloat : NSNumberFormatter = NSNumberFormatter()
    
    var indexSelected: NSIndexPath = NSIndexPath()
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
        fmtMoneda.numberStyle = .CurrencyStyle
        fmtMoneda.maximumFractionDigits = 2
        
        fmtFloat.numberStyle = .NoStyle
        fmtFloat.maximumFractionDigits = 2
        
    }
    
    func writeCoreDataObjectToCVS(objects: [NSManagedObject], named: String) -> String {
        
        guard objects.count > 0 else {
            return ""
        }
        
        var strLine: String = ""
        
        let headerBudget = "Budget Name;Start Date;Final Date;Budget Amount;Warning Threshold;Total Income;Money used\n"

        strLine += headerBudget
        
        if self.presupuesto != nil {
            strLine += (self.presupuesto?.descripcion)! + ";"
            
            strLine += dtFormatter.stringFromDate((self.presupuesto?.fechaInicio)!) + ";"
            
            strLine += dtFormatter.stringFromDate((self.presupuesto?.fechaFinal)!) + ";"
            
            strLine += fmtFloat.stringFromNumber((self.presupuesto?.valor)!)! + ";"
            
            strLine += fmtFloat.stringFromNumber((self.presupuesto?.umbral)!)! + "%;"
            
            strLine += fmtFloat.stringFromNumber((self.presupuesto?.ingresos)!)! + ";"
            
            strLine += fmtFloat.stringFromNumber((self.presupuesto?.ejecutado)!)! + "\n"
        }
        
        
        for object in objects {
            
            let seccion = object as? PresupuestoSeccion
            
            let headerSection = "Section Name;Section Total Income;Section Total Expenses\n"
            let headerReceipt = "Receipt Description;Date;Income;Expenditure\n"
            
            strLine += headerSection
            
            strLine += (seccion?.descripcion)! + ";"
            strLine += fmtFloat.stringFromNumber((seccion?.totalIngresos)!)! + ";"
            strLine += fmtFloat.stringFromNumber((seccion?.totalEgresos)!)! + "\n"
            
            if seccion?.recibos?.count > 0 {
                let recibos = seccion?.recibos?.allObjects as? [Recibo]
                
                strLine += headerReceipt
                
                for subObject in recibos! {
                    
                    let recibo = subObject as Recibo
                    
                    strLine += recibo.descripcion! + ";"
                    strLine += dtFormatter.stringFromDate(recibo.fecha!) + ";"
                    if recibo.tipo?.hashValue == eTipoRegistro.income.hashValue {
                        strLine += fmtFloat.stringFromNumber(recibo.valor!)! + ";\n"
                    } else {
                        strLine += ";" + fmtFloat.stringFromNumber(recibo.valor!)! + "\n"
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
            
            let data = csvString.dataUsingEncoding(NSUTF8StringEncoding)
            
            let strExportFileName = self.presupuesto?.descripcion?.stringByReplacingOccurrencesOfString(" ", withString: "_")
            
            mail.addAttachmentData(data!, mimeType: "text/csv", fileName: "\(strExportFileName!).csv")
            
            self.presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
            showCustomWarningAlert("You must authorize sending e-mail.", toFocus: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func btnActionOnTouchInsideup(sender: AnyObject) {
        
        let alertController = UIAlertController(title: self.strAppTitle, message: "You can send your budget using E-mail.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print(action)
        }
        //alertController.addAction(cancelAction)
        
        //let destroyAction = UIAlertAction(title: "Destroy", style: .Destructive) { (action) in
        //    print(action)
            
        //}
        
        let oneAction = UIAlertAction(title: "Send E-mail", style: .Default) { (_) in
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
        
        self.presentViewController(alertController, animated: true) {
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tvPresupuesto.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "CellPresupuestoDetalle")
        
        self.tvPresupuesto.registerClass(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "customHeaderView")
        
        self.initTableViewRowHeight()
        
        #if LITE_VERSION
            //self.navigationController?.toolbarHidden = true
            self.navigationController?.toolbarHidden = false
            var items = [AnyObject]()
            items.append(UIBarButtonItem(title: "Send", style: .Plain, target: self,action: #selector(self.btnActionOnTouchInsideup)))
            self.toolbarItems = items as? [UIBarButtonItem]
        #endif
        
        #if FULL_VERSION
            self.navigationController?.toolbarHidden = false
            var items = [AnyObject]()
            items.append(UIBarButtonItem(title: "Send", style: .Plain, target: self,action: #selector(self.btnActionOnTouchInsideup)))
            self.toolbarItems = items as? [UIBarButtonItem]
        #endif
        
        let sublayer = CALayer.init()
        sublayer.backgroundColor = UIColor.customLightGrayColor().CGColor
        sublayer.shadowOffset = CGSizeMake(0, 3)
        sublayer.shadowRadius = 5.0
        sublayer.shadowOpacity = 0.8;
        sublayer.frame = CGRectMake(0, 0, 420, 42000)
        self.view.layer.addSublayer(sublayer)
        
        self.title = self.presupuesto?.descripcion
        
        self.navigationItem.backBarButtonItem?.title = "" // = backItem

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.initFormatters()
    }
    
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

    override func viewWillAppear(animated: Bool) {
        
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
            self.bbtnReceipt.enabled = true
            if self.presupuesto != nil {
                
                let secciones = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
                
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
        #endif
    }
    
    override func viewDidAppear(animated: Bool) {
        tvPresupuesto.deselectRowAtIndexPath(indexSelected, animated: true)
        tvPresupuesto.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.presupuesto != nil {
            return (self.presupuesto?.secciones?.count)!
        } else {
            return 0
        }
    }
    
    // MARK: - Celda personalizada
    func customTableView(ctableView: UITableView, cindexPath: NSIndexPath, crecibo: Recibo, caccessoryType: UITableViewCellAccessoryType) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CellPresupuestoDetalle", forIndexPath: cindexPath)
        
        // Para evitar el re-writting de los labels personalizados
        for cellView in cell.contentView.subviews {
            cellView.removeFromSuperview()
        }
        
        //print("Descripcion: \(crecibo.valueForKey(smModelo.smRecibo.colDescripcion) as! String!)")
        //print("Fecha: \(crecibo.valueForKey(smModelo.smRecibo.colFecha) as! NSDate!)")
        //print("Tipo: \(crecibo.valueForKey(smModelo.smRecibo.colTipo) as! Int!)")
        //print("Valor: \(fmtMoneda.stringFromNumber( crecibo.valueForKey(smModelo.smRecibo.colValor) as! Double)!)")

        let strDescripcion = crecibo.valueForKey(smModelo.smRecibo.colDescripcion) as! String!
        let dtFecha        = crecibo.valueForKey(smModelo.smRecibo.colFecha) as! NSDate!
        let intTipo        = crecibo.valueForKey(smModelo.smRecibo.colTipo) as! Int!
        let strValor       = fmtMoneda.stringFromNumber( crecibo.valueForKey(smModelo.smRecibo.colValor) as! Double)!
        
        let fontName =  "Verdana-Bold"
        let fontNameNumeric = "Verdana"
        
        let labelNombre: UILabel = UILabel(frame: CGRectMake(17.0, 0.0, 377.0, 30.0))
        
        labelNombre.text = "  " + strDescripcion
        labelNombre.font = UIFont(name: fontName, size: 13)
        labelNombre.textAlignment = NSTextAlignment.Left
        labelNombre.textColor = UIColor.blackColor()
        labelNombre.tag = cindexPath.row
        cell.contentView.addSubview(labelNombre)

        let labelFecha: UILabel = UILabel(frame: CGRectMake(17.0, 25.0, 100.0, 30.0))
        labelFecha.text = "  " + dtFormatter.stringFromDate(dtFecha!)
        labelFecha.font = UIFont(name: fontNameNumeric, size: 12)
        labelFecha.textAlignment = NSTextAlignment.Left
        labelFecha.textColor = UIColor.blackColor()
        labelFecha.tag = cindexPath.row
        cell.contentView.addSubview(labelFecha)
        
        
        let labelValor: UILabel = UILabel(frame: CGRectMake(250.0, 25.0, 100.0, 30.0))
        labelValor.text = String(format: "\(strValor)")
        labelValor.font = UIFont(name: fontNameNumeric, size: 12)
        labelValor.textAlignment = NSTextAlignment.Right
        labelValor.tag = cindexPath.row
        if intTipo == 0 {
            labelValor.textColor = UIColor.blueColor()
        } else if intTipo == 1 {
            labelValor.textColor = UIColor.redColor()
        }
        labelValor.tag = cindexPath.row
        cell.contentView.addSubview(labelValor)
        
        cell.accessoryType = caccessoryType
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MAX_SECTION_ROW_HEIGHT
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: NSInteger) -> UIView {
        
        let cellHeaderViewIdentifier = "customHeaderView"

        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(cellHeaderViewIdentifier)! as UITableViewHeaderFooterView
        
        // Para evitar el re-writting de los labels personalizados
        for headerViewItem in headerView.contentView.subviews {
            headerViewItem.removeFromSuperview()
        }
        
        headerView.contentView.frame = CGRectMake( 0.0, 0.0, 350.0, 55.0)
        headerView.contentView.backgroundColor = UIColor.grayColor()

        let labelSeccion   : UILabel = UILabel(frame: CGRectMake(0.0,  0, 350.0, 35))
        let labelPorcentaje: UILabel = UILabel(frame: CGRectMake(0.0, 35.00,  350.0, 20.0))
        
        labelSeccion.lineBreakMode = .ByTruncatingTail
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
            labelSeccion.textColor = UIColor.whiteColor()
            labelSeccion.tag = section.hashValue
            
            labelPorcentaje.text =  "  At \(fmtFloat.stringFromNumber(porcentaje)!)%"
            labelPorcentaje.font =  UIFont(name: fontNameNumeric, size: 12)
            labelPorcentaje.textColor = UIColor.whiteColor()
            labelPorcentaje.tag = section.hashValue

            headerView.contentView.addSubview(labelSeccion)
            headerView.contentView.addSubview(labelPorcentaje)
            
        }
        return headerView;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows: Int = 0
        
        if self.presupuesto != nil {
            let arrSeccion = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
            
            let seccion = arrSeccion[section] as PresupuestoSeccion
            
            
            // todo: para revisar
            self.arrRecibo = seccion.mutableSetValueForKey(smModelo.smPresupuestoSeccion.colRecibos).allObjects
            
            numberOfRows = self.arrRecibo.count
            
        }
        
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("CellPresupuestoDetalle", forIndexPath: indexPath)

        // Configure the cell...
        var cell: UITableViewCell?
        
        let arrSeccion = self.presupuesto?.mutableSetValueForKey(smModelo.smPresupuesto.colSecciones).allObjects
        
        let seccion = arrSeccion![indexPath.section] as! PresupuestoSeccion
        
        self.arrRecibo = seccion.mutableSetValueForKey(smModelo.smPresupuestoSeccion.colRecibos).allObjects

        if self.arrRecibo.count > 0 {
            let recibo = self.arrRecibo[indexPath.row] as! Recibo
        
            let strDescripcion = recibo.valueForKey(smModelo.smRecibo.colDescripcion) as! String!
            //print("Indice: \(indexPath.row)")
            //print("Descripción del recibo: \(strDescripcion)")
            
            let dtFecha        = recibo.valueForKey(smModelo.smRecibo.colFecha) as! NSDate!
            //print("Fecha del recibo: \(dtFecha)")

            let douValor       = recibo.valueForKey(smModelo.smRecibo.colValor) as! Double
            //print("Valor del recibo: \(douValor)")
            
            if strDescripcion == nil && dtFecha == nil && douValor == 0 {
                self.arrRecibo.removeAtIndex(indexPath.row)
                cell = tableView.dequeueReusableCellWithIdentifier("CellPresupuestoDetalle", forIndexPath: indexPath)
            } else {
                cell = customTableView(tableView, cindexPath: indexPath, crecibo: recibo, caccessoryType: .DisclosureIndicator)
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("CellPresupuestoDetalle", forIndexPath: indexPath)
        }
        
        return cell!
    }

    
    @IBAction func barBtnItemAddOnTouchInsideDown(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("segueRecibo", sender: self)
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
            //#if LITE_VERSION
                //showCustomWarningAlert("This is the demo version.  To enjoy the full version of \(self.strAppTitle) we invite you to obtain the full version.  Thank you!.", toFocus: nil)
            //#endif
            
            
            //#if FULL_VERSION
                let arrSeccion = self.presupuesto?.secciones?.allObjects as! [PresupuestoSeccion]
                let seccion = arrSeccion[indexPath.section] as PresupuestoSeccion
                self.arrRecibo = seccion.mutableSetValueForKey(smModelo.smPresupuestoSeccion.colRecibos).allObjects
                
                if self.arrRecibo.count > 0 {
                    
                    let recibo = self.arrRecibo[indexPath.row] as! NSManagedObject
                    
                    let monto = recibo.valueForKey(smModelo.smRecibo.colValor) as! Double
                    
                    let tipo  = recibo.valueForKey(smModelo.smRecibo.colTipo) as! Int
                    
                    if eTipoRegistro.expenditure.hashValue == tipo {
                        var egreso  = (seccion.valueForKey(smModelo.smPresupuestoSeccion.colTotalEgresos) as? Double)!
                        var egresos = (self.presupuesto?.valueForKey(smModelo.smPresupuesto.colEjecutado) as? Double)!
                        
                        egreso -= monto
                        egresos -= monto
                        
                        seccion.setValue(egreso, forKey: smModelo.smPresupuestoSeccion.colTotalEgresos)
                        self.presupuesto?.setValue(egresos, forKey: smModelo.smPresupuesto.colEjecutado)
                    } else if eTipoRegistro.income.hashValue == tipo {
                        var ingreso = (seccion.valueForKey(smModelo.smPresupuestoSeccion.colTotalIngresos) as? Double)!
                        var ingresos = (self.presupuesto?.valueForKey(smModelo.smPresupuesto.colIngresos) as? Double)!
                        
                        ingreso -= monto
                        ingresos -= monto
                        
                        seccion.setValue(ingreso, forKey: smModelo.smPresupuestoSeccion.colTotalIngresos)
                        self.presupuesto?.setValue(ingresos, forKey: smModelo.smPresupuesto.colIngresos)
                    }
                    
                    self.moc.deleteObject(self.arrRecibo[indexPath.row] as! NSManagedObject)
                    
                    self.arrRecibo.removeAtIndex(indexPath.row)
                    do {
                        try self.moc.save()
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    } catch {
                        let deleteError = error as NSError
                        print(deleteError)
                    }
                }
            //#endif
            
            
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let arrSeccion = self.presupuesto?.mutableSetValueForKey(smModelo.smPresupuesto.colSecciones).allObjects
        
        self.seccion = arrSeccion![indexPath.section] as? PresupuestoSeccion
        
        self.arrRecibo = self.seccion!.mutableSetValueForKey(smModelo.smPresupuestoSeccion.colRecibos).allObjects
        
        if self.arrRecibo.count > 0 {
            self.recibo = self.arrRecibo[indexPath.row] as? Recibo
        } else {
            self.recibo = nil
        }
            self.performSegueWithIdentifier("segueRecibo", sender: self)
        
        self.indexSelected = indexPath
     }

    
    @IBAction func btnReceiptOnTouchInsideDonw(sender: UIBarButtonItem) {

        self.performSegueWithIdentifier("segueNewRecibo", sender: self)
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
    
    
    @IBAction func bbtnActionOnTouchInsideUp(sender: UIBarButtonItem) {
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueRecibo" {
            let vcReg: VCRegistro = segue.destinationViewController as! VCRegistro
            vcReg.presupuesto = self.presupuesto
            vcReg.moc         = self.moc
            vcReg.arrSeccion = (self.presupuesto?.secciones?.allObjects as? [PresupuestoSeccion])?.sort { $0.descripcion < $1.descripcion }
            vcReg.seccion = self.seccion
            vcReg.recibo = self.recibo
            vcReg.intTotalRecibos = self.intTotalRecibos
        } else if segue.identifier == "segueNewRecibo" {
            let vcReg: VCRegistro = segue.destinationViewController as! VCRegistro
            vcReg.presupuesto = self.presupuesto
            vcReg.moc         = self.moc
            vcReg.arrSeccion = (self.presupuesto?.secciones?.allObjects as? [PresupuestoSeccion])?.sort { $0.descripcion < $1.descripcion }
            vcReg.seccion = nil
            vcReg.recibo  = nil
            vcReg.intTotalRecibos = self.intTotalRecibos
        }
    }
    

}
