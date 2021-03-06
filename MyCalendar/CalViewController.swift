//
//  CalViewController.swift
//  EventTracker
//
//  Created by Jess Chandler on 9/3/17.
//  Copyright © 2017 Andrew Bancroft. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI
import JTAppleCalendar

class CalViewController: UIViewController, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource, UITableViewDelegate, UITableViewDataSource,
    EKEventEditViewDelegate{

    // MARK: - Properties
    var eventStore: EKEventStore!   // set by segue
    var calendar: EKCalendar!       // set by segue
    var events: [EKEvent]?          // set by segue and updated with loadevents
    let todaysDate = Date()
    var thisDayAgenda = [AgendaItem]() // id (event.row), type, event
    var eventsOnDay : [String: Int] = [:] // date: count events
    var eventsInDay: [String] = ["Free - No Events"] // for table

    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calCollectionView: JTAppleCalendarView!
    @IBOutlet weak var testLabel: UILabel!

    @IBOutlet weak var dayTable: UITableView!
    let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale

        return dateFormatter
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        calCollectionView.calendarDataSource = self
        calCollectionView.calendarDelegate = self

        self.view.backgroundColor = vryltorange
        calCollectionView.backgroundColor = ltbrightorange
        dayTable.backgroundColor = vryltorange

        dayTable.delegate = self
        dayTable.dataSource = self

        //print(events ?? "no events")
        print("Hey, I'm printing an event")
        print(events?[0])
        for event in events!{
            print(event.startDate)
        }

        setupCalendarView() // just spacing

        calCollectionView.visibleDates { dateSegment in
            self.setDateSegment(dateSegment : dateSegment)
        }

        eventsOnDay = getDayActivity(events: events)


        self.calCollectionView.reloadData()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Button Functions

    @IBAction func todayTapped(_ sender: UIButton) {
        // scroll to today (or set another date)
        calCollectionView.scrollToDate(Date(), animateScroll: true)
        // select today
        calCollectionView.selectDates([Date()])
    }

    @IBAction func addEventTapped(_ sender: UIButton) {
        // create an instance of EKEventEditViewController()
        let targetVC = EKEventEditViewController()
        // make it pretty
        targetVC.view.backgroundColor = vryltorange
        // give it some data
        targetVC.eventStore = self.eventStore
        targetVC.editViewDelegate = self
        self.present(targetVC, animated: true, completion: nil)
    }

    // MARK: - Event Methods

    func loadEvents() {

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





    func getEventsTitles(events: [EKEvent]?) -> [String: [String]]{
        if events != nil{
            formatter.dateFormat = "yyyy MM dd"
            var dict = [String: [String]]()
            for event in events!{
                let edate = formatter.string(from: event.startDate)
                if dict[edate] != nil {
                    // there is already an event on this date
                    dict[edate]! += [event.title]
                } else {
                    dict[edate] = [event.title]
                }
            }
            return dict
        } else {
            return [:]
        }
    }
    func getDayActivity(events: [EKEvent]?) -> [String: Int]{
        if events != nil{
            formatter.dateFormat = "yyyy MM dd"
            var dict = [String: Int]()
            for event in events!{
                let edate = formatter.string(from: event.startDate)
                dict[edate] = (dict[edate] ?? 0) + 1
            }
            for (key, value) in dict {
                print("\(key) has \(value) event(s)")
            }
            return dict

        } else {
            return [:]
        }
    }

    func getDayAgenda(date: Date, events: [EKEvent]?) -> [AgendaItem]{
        if events != nil{
            formatter.dateFormat = "yyyy MM dd"
            let today = formatter.string(from: date)
            //var dict = [Int: EKEvent]()
            var agenda = [AgendaItem]()
            for event in events!{
                let edate = formatter.string(from: event.startDate)
                if edate == today {
                    agenda.append( AgendaItem(
                        id: events!.index(of: event)!,
                        type: "fun", event: event)
                    )
                }
            }
            return agenda
        } else {
            return []
        }
    }

    // MARK: - Calendar View Methods

    func setDateSegment(dateSegment: DateSegmentInfo){
        guard let mdate = dateSegment.monthDates.first?.date else {return}
        formatter.dateFormat = "YYYY"
        yearLabel.text = formatter.string(from: mdate)
        yearLabel.textColor = dkorange
        formatter.dateFormat = "MMM"
        monthLabel.text = formatter.string(from: mdate)
        monthLabel.textColor = dkorange
    }

    func configureCell(cell: JTAppleCell?, state: CellState){
        guard let validCell = cell as? CustomCell else { return }

        handleCellTextColor(cell: validCell, state: state)
        handleCellVisibility(cell: validCell, state: state)
        handleCellSelection(cell: validCell, state: state)
        handleCellEvents(cell: validCell, state: state)
    }

    func handleCellTextColor(cell: CustomCell, state: CellState){
        formatter.dateFormat = "yyyy MM dd"
        let todaysDateString = formatter.string(from: todaysDate)
        let callDateString = formatter.string(from: state.date)
        if todaysDateString == callDateString {
            cell.dateLabel.textColor = UIColor.blue
        } else {
            cell.dateLabel.textColor = state.isSelected ? UIColor.white : UIColor.black
        }
    }
    func handleCellVisibility(cell: CustomCell, state: CellState){
        cell.isHidden = state.dateBelongsTo == .thisMonth ? false : true
    }
    func handleCellSelection(cell: CustomCell, state: CellState){
        if state.isSelected{
            cell.highlightCircle.isHidden = false
            cell.bounce()

        }else{
            cell.highlightCircle.isHidden = state.isSelected ? false : true
        }
    }

    func handleCellEvents(cell: CustomCell, state: CellState){
        formatter.dateFormat = "yyyy MM dd"
        cell.activeLine.isHidden = !eventsOnDay.contains{$0.key == formatter.string(from: state.date)} ? true : false
    }


    func setupCalendarView(){
        calCollectionView.minimumLineSpacing = 0
        calCollectionView.minimumInteritemSpacing = 0
        testLabel.text = "" // make it blank
    }


    func setupLabel(info:String){
        testLabel.text = info
    }


    func loadUpCalendar(){
        self.loadEvents()
        eventsOnDay = getDayActivity(events: events)
        self.setupCalendarView()
        self.calCollectionView.reloadData()
        self.dayTable.reloadData()
    }


    // MARK: - JTAppleCalendar Methods

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        var startDate = Date()
        if events != nil{
            // deal with date foremater
            let firstEventDate = formatter.date(from: formatter.string(from: self.events![0].startDate))
            //let lastEventDate = formatter.date(from: formatter.string(from: self.events![self.events!.count-1].startDate))
            startDate = firstEventDate ?? Date()  // first or now
        }

        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate!)

        return parameters
    }

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        configureCell(cell: cell, state: cellState)
        return cell
    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CustomCell else {return}
        configureCell(cell: cell, state: cellState)

        // prepare the view below the calendar
        thisDayAgenda = getDayAgenda(date: cellState.date, events: events)
        let makelabel = "\(String(describing: cellState.day).capitalized) \(cellState.text)"
        setupLabel(info: makelabel)
        dayTable.reloadData()
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CustomCell else {return}
        configureCell(cell: cell, state: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setDateSegment(dateSegment : visibleDates)
        testLabel.text = "" // reset when scroll
    }

    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "header", for: indexPath) as! HeaderView
        return header
    }

    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }

    // MARK: - TableViewDelegate Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Trying to show: \(thisDayAgenda.count) items")
        return thisDayAgenda.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell")! as! DayTableViewCell
        formatter.dateFormat = "HH:mm" // just time!
        let start = formatter.string(from: (thisDayAgenda[indexPath.row].event.startDate))
        let end = formatter.string(from: (thisDayAgenda[indexPath.row].event.endDate))
        cell.startTimeLabel.text = start
        cell.stopTimeLabel.text = end
        cell.eventTitlelabel.text = thisDayAgenda[indexPath.row].event.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // create an instance of EKEventEditViewController()
        let targetVC = EKEventEditViewController()
        // make it pretty
        
        targetVC.navigationBar.tintColor = brightorange
        // give it some data
        targetVC.eventStore = self.eventStore
        let selectedIndexPath = thisDayAgenda[indexPath.row].id
        targetVC.event = events?[selectedIndexPath]
        targetVC.editViewDelegate = self
        self.present(targetVC, animated: true, completion: nil)
    }


    // MARK: - EKEventEditViewDelegate Methods
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {

        dismiss(animated: true, completion: nil)

        self.loadUpCalendar()


    }

    // MARK: - Navigation Functions



} // end of CalViewController


