//
//  ViewController.swift
//  MyCalendar
//
//  Created by Jess Chandler on 9/6/17.
//  Copyright © 2017 Jess Chandler. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    // the first view controller is a welcome screen and user clicks a button to
    // view their calendar
    // if they have not given permission, get permission to access calendar 

    // MARK: - Properties

    var events: [EKEvent]?      // set by loadevents
    var calendar: EKCalendar!   // should be set to calendar w/ title Calendar
    var eventStore: EKEventStore! // set on view did load

    @IBOutlet weak var askPermissionsView: UIView!
    // MARK: - LifeCycle
    override func viewDidLoad() {
        self.view.backgroundColor = vryltorange
        eventStore = EKEventStore()
    }

    // MARK: - Button Actions

    @IBAction func viewCalendarTapped(_ sender: MyButton) {

        // check if user permissions
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        // deal with permissions
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens first time push button on new device
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            // fetch user calendar named "Calendar" and present next screen
                self.setCalendar()
                if calendar != nil {
                    self.loadEvents(calendar: calendar)
                }
            // present next screen
            performSegue(withIdentifier: "showCalendarSegue", sender: self)

        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            askPermissionsView.fadeIn()
        }

            }

    // MARK: - Methods

    func requestAccessToCalendar() {
        EKEventStore().requestAccess(to: .event, completion: {
            (accessGranted: Bool, error: Error?) in

            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.setCalendar()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    self.askPermissionsView.fadeIn()
                })
            }
        })
    }

    func setCalendar(){
        let cals = EKEventStore().calendars(for: EKEntityType.event)
        print(cals)
        
        for cal in cals {
            print (cal.title)
            if cal.title == "Calendar" {
                self.calendar = cal
            }
        }
        // TODO: if user has no calendar named "Calendar", show alert
        print("no calendar named Calendar")
    }


    func loadEvents(calendar: EKCalendar) {

        let startDate = Date() // now
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())

        if let endDate = endDate {

            let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])

            self.events = eventStore.events(matching: eventsPredicate).sorted {
                (e1: EKEvent, e2: EKEvent) in

                return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
            }
        }
    }




    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showCalendarSegue"{
            let targetVC = segue.destination as! CalViewController

            if events == nil{
                print("no events")
                loadEvents(calendar: calendar)
                targetVC.events = events
            }
            targetVC.eventStore = eventStore
            targetVC.calendar = calendar
            targetVC.events = events

        }

        else {
            print("no segue")
        }
    }

}


