//
//  CalViewController.swift
//  EventTracker
//
//  Created by Jess Chandler on 9/3/17.
//  Copyright © 2017 Andrew Bancroft. All rights reserved.
//

import UIKit
import EventKit
import JTAppleCalendar

class CalViewController: UIViewController, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    var calendar: EKCalendar! // set by segue
    var events: [EKEvent]? // set by segue and updated with loadevents
    var datesWithEvents: [Date]?
    let todaysDate = Date()
    var eventsToShow : [String: [EKEvent]] = [:] // date: events
    var eventswTitles : [String: [String]] = [:]
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
        //loadEvents()
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


        //loadEvents()
        //print("Load Events in calviewcontroller")
        print(events ?? "no events")

        setupCalendarView() // just spacing

        calCollectionView.visibleDates { dateSegment in
            self.setDateSegment(dateSegment : dateSegment)
        }
        eventsToShow = getEventsToShow(events: events)
        print(eventsToShow.keys)
        eventswTitles = getEventsTitles(events: events)
        print(eventswTitles)

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



    

    // MARK: - Event Methods

    func loadEvents() {

        let startDate = Date() // now
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())

        if let endDate = endDate {
            let eventStore = EKEventStore()

            let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])

            self.events = eventStore.events(matching: eventsPredicate).sorted {
                (e1: EKEvent, e2: EKEvent) in

                return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
            }
        }
    }

    func getEventsToShow(events: [EKEvent]?) -> [String: [EKEvent]]{
        if events != nil{
            formatter.dateFormat = "yyyy MM dd"
            var dict = [String: [EKEvent]]()
            for event in events!{
                let edate = formatter.string(from: event.startDate)
                if dict[edate] != nil {
                    // there is already an event on this date
                    dict[edate]! += [event]
                } else {
                    dict[edate] = [event]
                }
            }
            return dict
        } else {
            return [:]
        }
    }

    func prepareEventTable(dateString: String) -> [String] {
        print("looking up \(dateString)")
        var daysList = [String]()
        if eventswTitles[dateString] != nil{
            daysList = eventswTitles[dateString]!
        } else {
            daysList = ["Free - No Events"]
        }
        print(daysList)
        return daysList
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
        cell.activeLine.isHidden = !eventsToShow.contains{$0.key == formatter.string(from: state.date)} ? true : false
    }


    func setupCalendarView(){
        calCollectionView.minimumLineSpacing = 0
        calCollectionView.minimumInteritemSpacing = 0
    }


    func setupLabel(info:String){
        testLabel.text = info
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
        formatter.dateFormat = "yyyy MM dd"
        eventsInDay = prepareEventTable(dateString: formatter.string(from: cellState.date))
        print("found eventsInDay: \(eventsInDay)")
        let makelabel = "\(eventsInDay.count) Event(s) on \(String(describing: cellState.day).capitalized) \(cellState.text)"
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
        print("Trying to show: \(eventsInDay.count) items")
        return eventsInDay.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell")!
        cell.textLabel?.text = eventsInDay[indexPath.row]
        return cell
    }


    

} // end of CalViewController


