//
//  Presupuesto+CoreDataProperties.swift
//  My Finance Controller
//
//  Created by Américo Cantillo on 16/08/16.
//  Copyright © 2016 Américo Cantillo Gutiérrez. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Presupuesto {

    @NSManaged var preservar: NSNumber?
    @NSManaged var descripcion: String?
    @NSManaged var ejecutado: NSNumber?
    @NSManaged var fechaFinal: Date?
    @NSManaged var fechaInicio: Date?
    @NSManaged var ingresos: NSNumber?
    @NSManaged var umbral: NSNumber?
    @NSManaged var valor: NSNumber?
    @NSManaged var activo: NSNumber?
    @NSManaged var secciones: NSSet?

}
