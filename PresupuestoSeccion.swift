//
//  PresupuestoSeccion.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 16/07/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//

import Foundation
import CoreData

@objc(PresupuestoSeccion)

class PresupuestoSeccion: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    func addRecibo(recibo: Recibo) {
        let recibos = self.mutableSetValue(forKey: "recibos")
        recibos.add(recibo)
    }

    func removeRecibo(recibo: Recibo) {
        let recibos = self.mutableSetValue(forKey: "recibos")
         recibos.remove(recibo)
    }
    
    func orderByDateRecibos() -> [Recibo] {
        let recibos = self.mutableSetValue(forKey: "recibos").sorted(by: { ($0 as! Recibo).fecha! > ($1  as! Recibo).fecha! }) as! [Recibo]
        
        return recibos
    }
}
