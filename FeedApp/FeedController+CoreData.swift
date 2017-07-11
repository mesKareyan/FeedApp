//
//  FeedController+CoreData.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/11/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Fetched results controller delegate

extension NewsFeedController : NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == fetchedResultsControllerTV {
            tableView.beginUpdates()
            return
        }
        
        self.blockOperation = BlockOperation()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        //for Table View
        if controller == fetchedResultsControllerTV {
            
            switch type {
            case .insert:
                self.tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                self.tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                self.tableView.insertRows(at: [newIndexPath!], with: .fade)
                self.tableView.deleteRows(at: [indexPath!], with: .fade)
            }
            
        } else if controller == fetchedResultsControllerCV {
            
            switch type {
            case .insert:
                self.blockOperation.addExecutionBlock {
                    self.collectionView.insertItems(at: [newIndexPath!])
                }
            case .delete:
                self.blockOperation.addExecutionBlock {
                    self.collectionView.deleteItems(at: [indexPath!])
                }
            case .update:
                self.blockOperation.addExecutionBlock {
                    self.collectionView.reloadItems(at: [indexPath!])
                }
            case .move:
                self.blockOperation .addExecutionBlock {
                    self.collectionView.insertItems(at: [newIndexPath!])
                    self.collectionView.deleteItems(at: [indexPath!])
                }
            }
            
        }
        
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        
        //for Table View
        if controller == fetchedResultsControllerTV {
            switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            case .move:
                break
            case .update:
                tableView.reloadSections(IndexSet(integer: sectionIndex), with: .fade)
                break
            }
        } else if controller == fetchedResultsControllerCV {
            switch type {
            case .insert:
                self.blockOperation.addExecutionBlock {
                    self.collectionView.insertSections(IndexSet(integer: sectionIndex))
                }
            case .delete:
                self.blockOperation.addExecutionBlock {
                    self.collectionView.deleteSections(IndexSet(integer: sectionIndex))
                }
            case .update:
                self.blockOperation.addExecutionBlock {
                    self.collectionView.reloadSections(IndexSet(integer: sectionIndex))
                }
            case .move:
                break
            }
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if controller == fetchedResultsControllerTV {
            self.tableView.endUpdates()
        } else if controller == fetchedResultsControllerCV {
            self.collectionView.performBatchUpdates({
                self.blockOperation.start()
            }, completion: { (finished) in
                // Do whatever
            })
        }
        
        func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if controller == self.fetchedResultsControllerTV {
                tableView.reloadData()
            }
        }
    }
}
